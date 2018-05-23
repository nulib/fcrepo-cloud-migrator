# frozen_string_literal: true

module FcrepoCloudMigrator
  class Metadata
    EBUCORE_FILENAME_PREDICATE = 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename'
    def initialize(file:)
      @file = file
      @graph = RDF::Graph.load(file, format: :ttl)
    end

    # ebucore:locator and ebucore:filename to s3 location

    # remove ebucore:hasMimeType
  end
end
