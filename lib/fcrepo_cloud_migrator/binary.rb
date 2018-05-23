# frozen_string_literal: true

require 'pathname'

module FcrepoCloudMigrator
  class Binary
    attr_reader :checksum, :file, :graph

    EBUCORE_FILENAME_PREDICATE      = 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename'
    PREMIS_MESSAGE_DIGEST_PREDICATE = 'http://www.loc.gov/premis/rdf/v1#hasMessageDigest'

    def initialize(file:)
      @file        = file
      @graph       = RDF::Graph.load(file, format: :ttl)
      @checksum    = checksum_from_graph
    end

    def path
      Pathname("#{Pathname(file).parent.parent}/#{File.basename(Pathname(file).parent)}.binary").to_s
    end

    def checksum_from_graph
      graph.each_statement do |statement|
        return statement.object.to_s.split(':').last if statement.predicate.to_s == PREMIS_MESSAGE_DIGEST_PREDICATE
      end
    end
  end
end
