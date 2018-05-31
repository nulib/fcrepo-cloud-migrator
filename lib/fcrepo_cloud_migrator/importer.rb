# frozen_string_literal: true

require 'pathname'
require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'
require 'faraday'
require 'aws-sdk-s3'

module FcrepoCloudMigrator
  class Importer
    attr_reader :source, :from, :to

    def initialize(source:, from:, to:, dry_run: false)
      @source   = initialize_source(source)
      @from     = from
      @to       = to
      @dry_run  = dry_run
    end

    def logger
      FcrepoCloudMigrator.logger
    end

    def import_all
      content_files.each do |file|
        next if file.match?(%r{/fcr%3Aversion})
        import(path: file)
      end

      access_control_files.each do |file|
        import(path: file)
      end
    end

    def import(path:)
      logger.info("importing: #{path}")
      graph = load_file(path: path)
      return if graph.empty?
      resource_path = graph.query([:s, RDF::RDFV.type, :o]).first.subject.path
      if binary?(graph)
        import_binary(
          resource_path: resource_path,
          path:          Pathname(path).parent.to_s + '.binary',
          mime_type:     graph.query([:s, RDF::Vocab::EBUCore.hasMimeType, :o]).first.object.value
        )
        resource_path += '/fcr:metadata'
      end
      import_metadata(resource_path: resource_path, graph: graph)
    end

    def import_binary(resource_path:, path:, mime_type:)
      logger.info("  binary: #{resource_path}")
      put(resource_path) do |req|
        req.headers['Content-Type']      = mime_type
        req.headers['Transfer-Encoding'] = 'chunked'
        req.body                         = source.io_for(path)
      end
    end

    def import_metadata(resource_path:, graph:)
      logger.info("  metadata: #{resource_path}")
      put(resource_path) do |req|
        req.headers['Content-Type'] = 'text/turtle'
        req.body                    = graph.dump(:ttl)
      end
    end

    def load_file(path:)
      ttl = source.content_for(path).gsub(from, to)
      RDF::Graph.new.tap do |graph|
        graph.from_ttl(ttl)
        graph.statements.each do |st|
          graph.delete(st) if st.predicate.starts_with?(RDF::Vocab::Fcrepo4) ||
                              st.object.starts_with?(RDF::Vocab::Fcrepo4) ||
                              st.predicate == RDF::Vocab::LDP.contains
        end
      end
    end

    private

      def initialize_source(source)
        case source
        when /^s3:/
          require 'fcrepo_cloud_migrator/s3'
          FcrepoCloudMigrator::S3.new(source)
        else
          require 'fcrepo_cloud_migrator/file'
          FcrepoCloudMigrator::File.new(source)
        end
      end

      def put(resource_path)
        resp = if @dry_run
                 OpenStruct.new(status: 200, body: resource_path)
               else
                 conn.put do |req|
                   req.path = resource_path
                   req.headers['Prefer'] = 'handling=lenient; received="minimal"'
                   yield(req)
                 end
               end
        logger.info("    #{resp.status}|#{resp.body}")
      end

      def conn
        @conn ||= Faraday.new(url: base_url)
      end

      def binary?(graph)
        graph.query([nil, RDF::RDFV.type, RDF::URI('http://pcdm.org/models#File')]).count.positive?
      end

      def base_url
        URI.parse(to).merge('/')
      end

      def content_files
        @content_files ||= (ttl_files - access_control_files).sort_by(&:length)
      end

      def access_control_files
        @access_control_files ||= ttl_files.select { |path| path.match?(/[a-f0-9-]{36}.ttl$/) }.sort_by(&:length)
      end

      def ttl_files
        source.ttl_files
      end
  end
end
