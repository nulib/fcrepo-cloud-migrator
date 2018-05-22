# frozen_string_literal: true
require 'pathname'

module FcrepoCloudMigrator
  class S3
    attr_reader :file, :graph

    EBUCORE_FILENAME_PREDICATE      = 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename'
    PREMIS_MESSAGE_DIGEST_PREDICATE = 'http://www.loc.gov/premis/rdf/v1#hasMessageDigest'

    def initialize(file)
      @file = file
      @graph = RDF::Graph.load(file, format: :ttl)
    end

    def file_extension
      graph.each_statement do |statement|
        return File.extname(statement.object.to_s) if statement.predicate.to_s == EBUCORE_FILENAME_PREDICATE
      end
    end

    def binary
      Pathname("#{Pathname(file).parent.parent}/#{File.basename(Pathname(file).parent)}.binary").to_s
    end

    def checksum
      graph.each_statement do |statement|
        return statement.object.to_s.split(':').last if statement.predicate.to_s == PREMIS_MESSAGE_DIGEST_PREDICATE
      end
    end
  end
end
