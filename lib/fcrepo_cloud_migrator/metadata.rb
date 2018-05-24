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
        object    = "s3://#{binary.checksum_from_graph}"
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
          premis:       'http://www.loc.gov/premis/rdf/v1#',
          nt:           'http://www.jcp.org/jcr/nt/1.0',
          ns021:        'http://purl.org/spar/datacite/',
          rdfs:         'http://www.w3.org/2000/01/rdf-schema#',
          ns020:        'http://projecthydra.org/ns/auth/acl#',
          ns004:        'http://id.loc.gov/vocabulary/relators/',
          ns003:        'info:fedora/fedora-system:def/model#',
          ns002:        'http://projecthydra.org/works/models#',
          ns001:        'http://purl.org/dc/terms/',
          xsi:          'http://www.w3.org/2001/XMLSchema-instance',
          ns008:        'http://www.openarchives.org/ore/terms/',
          mode:         'http://www.modeshape.org/1.0',
          ns007:        'http://www.w3.org/ns/auth/acl#',
          ns006:        'http://pcdm.org/models#',
          ns005:        'http://scholarsphere.psu.edu/ns#',
          xml:          'http://www.w3.org/XML/1998/namespace',
          ns009:        'http://www.iana.org/assignments/relation/',
          jcr:          'http://www.jcp.org/jcr/1.0',
          fedoraconfig: 'http://fedora.info/definitions/v4/config#',
          mix:          'http://www.jcp.org/jcr/mix/1.0',
          foaf:         'http://xmlns.com/foaf/0.1/',
          image:        'http://www.modeshape.org/images/1.0',
          sv:           'http://www.jcp.org/jcr/sv/1.0',
          test:         'info:fedora/test/',
          ns011:        'http://www.w3.org/2003/12/exif/ns#',
          ns010:        'http://pcdm.org/use#',
          ns015:        'http://projecthydra.org/ns/mix/',
          ns014:        'http://sweet.jpl.nasa.gov/2.2/reprDataFormat.owl#',
          ns013:        'http://projecthydra.org/ns/fits/',
          ns012:        'http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#',
          ns019:        'http://projecthydra.org/ns/odf/',
          ns018:        'http://fedora.info/definitions/1/0/access/ObjState#',
          ns017:        'http://projecthydra.org/ns/audio/',
          ns016:        'http://www.w3.org/2011/content#',
          rdf:          'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
          fedora:       'http://fedora.info/definitions/v4/repository#',
          ebucore:      'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#',
          ldp:          'http://www.w3.org/ns/ldp#',
          xs:           'http://www.w3.org/2001/XMLSchema',
          dc:           'http://purl.org/dc/elements/1.1/'
        }
      end
  end
end
