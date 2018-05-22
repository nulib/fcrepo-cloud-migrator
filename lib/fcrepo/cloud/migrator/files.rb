# frozen_string_literal: true

require 'byebug'

module Fcrepo
  module Cloud
    module Migrator
      # TODO
      class Files
        attr_reader :directory
        def initialize(bucket, directory)
          @bucket = bucket
          @directory = directory
        end

        # Given a directory, recursively walks the directly to find all .ttl
        # files that reference a fcrepo file with any mimetype
        def find_all_files
          [].tap do |fcrepo_file|
            Dir.glob("#{directory}**/*.ttl").map do |file|
              RDF::Graph.load(file, format: :ttl).each_statement do |statement|
                if statement.predicate.to_s == 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename'
                  fcrepo_file << file
                  next
                end
              end
            end
          end
        end
      end
    end
  end
end
