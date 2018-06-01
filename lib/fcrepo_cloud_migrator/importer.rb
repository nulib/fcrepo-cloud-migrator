# frozen_string_literal: true

require 'pathname'
require 'erb'
require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'
require 'faraday'
require 'aws-sdk-s3'

module FcrepoCloudMigrator
  class Importer
    attr_reader :source, :from, :to, :relations

    def initialize(source:, from:, to:, dry_run: false)
      @source    = initialize_source(source)
      @from      = from
      @to        = to
      @relations = FcrepoCloudMigrator::Relations.new(to)
      @dry_run   = dry_run
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

      relations.each do |graph|
        import_relations(graph: graph)
      end
    end

    def import(path:)
      logger.info("importing: #{path}")
      graph, resource_path = load_file(path: path)
      return if graph.empty?
      if binary?(graph)
        mime_type = graph.query([:s, RDF::Vocab::EBUCore.hasMimeType, :o]).first.object.value
        checksum = graph.query([:s, RDF::Vocab::PREMIS.hasMessageDigest, :o]).first.object.value.split(/:/).last
        delete_predicates(graph, [RDF::Vocab::PREMIS.hasSize, RDF::Vocab::PREMIS.hasMessageDigest])
        
        import_binary(
          resource_path: resource_path,
          path:          Pathname(path).parent.to_s + '.binary',
          mime_type:     mime_type,
          checksum:      checksum
        )
        resource_path += '/fcr:metadata'
      end
      import_metadata(resource_path: resource_path, graph: graph)
    end

    def import_binary(resource_path:, path:, mime_type:, checksum:)
      logger.info("  binary: #{resource_path}")
      put(resource_path) do |req|
        req.headers['Content-Type']      = mime_type
        req.headers['Transfer-Encoding'] = 'chunked'
        req.headers['Digest']            = "sha1=#{checksum}"
        req.body                         = source.io_for(path)
      end
    end

    def import_metadata(resource_path:, graph:)
      logger.info("  metadata: #{resource_path}")
      put(resource_path) do |req|
        req.headers['Content-Type'] = 'text/turtle'
        req.headers['Prefer']       = 'handling=lenient; received="minimal"'
        req.body                    = graph.dump(:ttl)
      end
    end

    def import_relations(graph:)
      resource_path = Util.resource_path(graph.subjects.first)
      logger.info("  relations: #{resource_path}")
      patch(resource_path) do |req|
        req.headers['Content-Type'] = 'application/sparql-update'
        req.body                    = sparql(graph)
      end
    end

    def load_file(path:)
      ttl = source.content_for(path).gsub(from, to)
      resource_path = nil
      g = RDF::Graph.new.tap do |graph|
        graph.from_ttl(ttl)
        resource_path = relations.extract(graph)
        graph.statements.each do |st|
          graph.delete(st)
          graph << [RDF::URI(''), st.predicate, st.object]
        end
      end
      [g, resource_path]
    end

    def with_transaction
      start_transaction
      yield
      end_transaction(:commit)
    rescue StandardError
      end_transaction(:rollback)
      raise
    end

    private

      def delete_predicates(graph, predicates)
        graph.statements.each do |st|
          graph.delete(st) if predicates.include?(st.predicate)
        end
      end

      def sparql(graph)
        erb = <<~__EOF__
        INSERT {
        <% graph.statements.each do |st| -%>
          <%= ['<>', st.predicate.to_base, st.object.to_base].join(' ') %>
        <% end -%>
        }
        WHERE { }
        __EOF__
        template = ERB.new(erb, nil, '-')
        template.result(OpenStruct.new(graph: graph).instance_eval { binding })
      end

      def start_transaction
        raise 'Transaction in progress' unless @tx_id.nil?
        resp = conn.post { |req| req.path = '/rest/fcr:tx' }
        @tx_id = resp.headers['Location'].split(/\//).last
        logger.info("Beginning transaction #{@tx_id}")
        logger.info("    #{resp.status}|#{resp.body}")
      end

      def end_transaction(type)
        raise 'No transaction in progress' if @tx_id.nil?
        begin
          logger.info("#{type} transaction #{@tx_id}")
          resp = conn.post { |req| req.path = tx_path("/rest/fcr:tx/fcr:#{type}") }
          logger.info("    #{resp.status}|#{resp.body}")
        ensure
          @tx_id = nil
        end
      end

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

      def tx_path(resource_path)
        return resource_path if @tx_id.nil?
        resource_path.sub(%r{^(/rest)/(.+)$}, '\1/' + @tx_id + '/\2')
      end

      def transmit(method, resource_path)
        resp = if @dry_run
                 OpenStruct.new(status: 200, body: resource_path)
               else
                 conn.run_request(method, nil, nil, nil) do |req|
                   req.path = tx_path(resource_path)
                   yield(req)
                 end
               end
        logger.info("    #{resp.status}|#{resp.body}")
      end

      def patch(resource_path, &block)
        transmit(:patch, resource_path, &block)
      end

      def post(resource_path, &block)
        transmit(:post, resource_path, &block)
      end

      def put(resource_path, &block)
        transmit(:put, resource_path, &block)
      end

      def conn
        @conn ||= Faraday.new(url: base_url)
      end

      def binary?(graph)
        graph.query([nil, RDF::RDFV.type, RDF::URI('http://pcdm.org/models#File')]).count.positive?
      end

      def base_url
        to.split(%r{/rest/}).first
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
