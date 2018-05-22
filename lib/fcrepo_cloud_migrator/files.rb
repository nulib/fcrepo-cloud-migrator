# frozen_string_literal: true

module FcrepoCloudMigrator
  class Files
    attr_reader :directory

    EBUCORE_FILENAME_PREDICATE    = 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename'
    FEDORA_HAS_VERSIONS_PREDICATE = 'http://fedora.info/definitions/v4/repository#hasVersions'

    def initialize(directory)
      @directory = directory
    end

    def find_all_files
      [].tap do |fcrepo_file|
        Dir.glob("#{directory}**/*.ttl").map do |file|
          graph = RDF::Graph.load(file, format: :ttl)
          if contains_ebucore_filename?(graph)
            fcrepo_file << file
            FcrepoCloudMigrator.logger.info("#{file} has multiple versions") if multiple_versions?(graph)
          end
        end
      end
    end

    private

      def contains_ebucore_filename?(graph)
        graph.predicates.map(&:to_s).include?(EBUCORE_FILENAME_PREDICATE)
      end

      def multiple_versions?(graph)
        graph.predicates.map(&:to_s).include?(FEDORA_HAS_VERSIONS_PREDICATE)
      end
  end
end
