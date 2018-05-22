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
          if contains_ebucore_filename?(file)
            fcrepo_file << file
            FcrepoCloudMigrator.logger.info("#{file} has multiple versions") if multiple_versions?(file)
          end
        end
      end
    end

    private

      def contains_ebucore_filename?(file)
        RDF::Graph.load(file, format: :ttl).each_statement.any? do |statement|
          statement.predicate.to_s == EBUCORE_FILENAME_PREDICATE
        end
      end

      def multiple_versions?(file)
        [].tap do |versions|
          RDF::Graph.load(file, format: :ttl).each_statement do |statement|
            versions << statement if statement.predicate.to_s == FEDORA_HAS_VERSIONS_PREDICATE
          end
        end.uniq.any?
      end
  end
end
