# frozen_string_literal: true

module FcrepoCloudMigrator
  class Metadata
    attr_reader   :binary, :bucket, :file
    attr_accessor :graph

    def initialize(bucket:, file:, binary:, graph:)
      @bucket = bucket
      @file   = file
      @binary = binary
      @graph  = graph
    end

    def graph_with_s3_filenames
      statement = new_filename_statement
      return graph if filename_subject.to_s.start_with?('s3://')

      remove_filename
      remove_mime_type
      graph.send(:insert_statement, statement)
      graph
    end

    def output
      RDF::Turtle::Writer.buffer(prefixes: prefixes) do |writer|
        graph_with_s3_filenames.each_statement do |statement|
          writer << statement
        end
      end
    end

    private

      def new_filename_statement
        subject   = filename_subject
        object    = "s3://#{bucket}/#{binary.checksum_from_graph}"
        predicate = EBUCORE_FILENAME_PREDICATE
        RDF::Statement.new(subject, predicate, object)
      end

      def filename_subject
        filename_query.first.subject
      end

      def remove_filename
        filename_query.each do |statement|
          graph.send(:delete_statement, statement)
        end
      end

      def filename_query
        graph.query(predicate: EBUCORE_FILENAME_PREDICATE)
      end

      def remove_mime_type
        mimetype_query.each do |statement|
          graph.send(:delete_statement, statement)
        end
      end

      def mimetype_query
        graph.query(predicate: EBUCORE_MIMETYPE_PREDICATE)
      end

      def prefixes # rubocop:disable Metrics/MethodLength
        {
          dc:           'http://purl.org/dc/elements/1.1/',
          ebucore:      'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#',
          fedora:       'http://fedora.info/definitions/v4/repository#',
          fedoraconfig: 'http://fedora.info/definitions/v4/config#',
          foaf:         'http://xmlns.com/foaf/0.1/',
          image:        'http://www.modeshape.org/images/1.0',
          jcr:          'http://www.jcp.org/jcr/1.0',
          ldp:          'http://www.w3.org/ns/ldp#',
          mix:          'http://www.jcp.org/jcr/mix/1.0',
          mode:         'http://www.modeshape.org/1.0',
          ns001:        'http://purl.org/dc/terms/',
          ns002:        'http://projecthydra.org/works/models#',
          ns003:        'info:fedora/fedora-system:def/model#',
          ns004:        'http://id.loc.gov/vocabulary/relators/',
          ns005:        'http://scholarsphere.psu.edu/ns#',
          ns006:        'http://pcdm.org/models#',
          ns007:        'http://www.w3.org/ns/auth/acl#',
          ns008:        'http://www.openarchives.org/ore/terms/',
          ns009:        'http://www.iana.org/assignments/relation/',
          ns010:        'http://pcdm.org/use#',
          ns011:        'http://www.w3.org/2003/12/exif/ns#',
          ns012:        'http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#',
          ns013:        'http://projecthydra.org/ns/fits/',
          ns014:        'http://sweet.jpl.nasa.gov/2.2/reprDataFormat.owl#',
          ns015:        'http://projecthydra.org/ns/mix/',
          ns016:        'http://www.w3.org/2011/content#',
          ns017:        'http://projecthydra.org/ns/audio/',
          ns018:        'http://fedora.info/definitions/1/0/access/ObjState#',
          ns019:        'http://projecthydra.org/ns/odf/',
          ns020:        'http://projecthydra.org/ns/auth/acl#',
          ns021:        'http://purl.org/spar/datacite/',
          nt:           'http://www.jcp.org/jcr/nt/1.0',
          rdf:          'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
          rdfs:         'http://www.w3.org/2000/01/rdf-schema#',
          sv:           'http://www.jcp.org/jcr/sv/1.0',
          test:         'info:fedora/test/',
          xml:          'http://www.w3.org/XML/1998/namespace',
          xs:           'http://www.w3.org/2001/XMLSchema',
          xsi:          'http://www.w3.org/2001/XMLSchema-instance',
          premis:       'http://www.loc.gov/premis/rdf/v1#'
        }
      end
  end
end
