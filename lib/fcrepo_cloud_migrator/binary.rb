# frozen_string_literal: true

require 'pathname'

module FcrepoCloudMigrator
  class Binary
    attr_reader :checksum, :file, :graph

    def initialize(file:, graph:)
      @file        = file
      @graph       = graph
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
