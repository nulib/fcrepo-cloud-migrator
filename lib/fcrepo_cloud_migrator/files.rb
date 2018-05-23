# frozen_string_literal: true

module FcrepoCloudMigrator
  class Files
    attr_reader :directory

    EBUCORE_FILENAME_PREDICATE = 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename'

    def initialize(directory:)
      @directory = directory
    end

    def find_all_files
      [].tap do |fcrepo_file|
        Dir.glob("#{directory}**/*.ttl").map do |file|
          graph = RDF::Graph.load(file, format: :ttl)
          if contains_ebucore_filename?(graph)
            block_given? ? yield(file) : fcrepo_file << file
          end
        end
      end
    end

    private

      def contains_ebucore_filename?(graph)
        graph.predicates.map(&:to_s).include?(EBUCORE_FILENAME_PREDICATE)
      end
  end
end
