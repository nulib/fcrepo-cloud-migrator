# frozen_string_literal: true

module FcrepoCloudMigrator
  class Files
    attr_reader :directory

    def initialize(directory)
      @directory = directory
    end

    def find_all_files
      [].tap do |fcrepo_file|
        Dir.glob("#{directory}**/*.ttl").map do |file|
          fcrepo_file << file if contains_ebucore_filename?(file)
        end
      end
    end

    private

      def contains_ebucore_filename?(file)
        RDF::Graph.load(file, format: :ttl).each_statement.any? do |statement|
          statement.predicate.to_s == 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename'
        end
      end
  end
end
