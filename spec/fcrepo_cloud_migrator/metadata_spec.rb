# frozen_string_literal: true

RSpec.describe FcrepoCloudMigrator::Metadata do
  let(:bucket)   { 'test-bucket' }
  let(:binary)   { FcrepoCloudMigrator::Binary.new(file: file, graph: graph) }
  let(:file)     { 'spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca/fcr%3Ametadata.ttl' }
  let(:graph)    { RDF::Graph.load(file, format: :ttl) }
  let(:metadata) { described_class.new(bucket: bucket, file: file, binary: binary, graph: graph) }

  describe '.graph_with_s3_filenames' do
    it 'modifies the ebucore#filename statement' do
      expect(ebucore_filename_object(metadata.graph_with_s3_filenames)).to eq 's3://7dc9ca05fd6ae49afde0bc3fa65ae5a6b66b539e'
    end

    it 'returns the graph unmodified if the ebucore#filename statment is an s3 URI' do
      allow(metadata).to receive(:filename_subject).and_return(RDF::URI('s3://'))
      expect(metadata.graph_with_s3_filenames == graph).to be_truthy
    end

    it 'removes the ebucore#hasMimeType statement' do
      expect(has_mimetype?(metadata.graph_with_s3_filenames)).to be_falsey
    end
  end

  describe '.output' do
    it 'serializes turtle with the correct statements' do
      # this assertion should be checking for (graph.count - 1)
      # due to the ebcore#hasMimeType statement removal, but there is
      # a duplicate statement ("a ldp:NonRDFSource ;") in the
      # fcrepo-import-tool that is not duplicated in RDF::Turtle::Writer
      expect(RDF::Reader.for(:turtle).new(metadata.output).triples.count)
        .to eq graph.count
    end
  end

  def ebucore_filename_object(graph)
    filename_statements = graph.query(predicate: RDF::URI(EBUCORE_FILENAME_PREDICATE))
    filename_statements.first.object.to_s
  end

  def has_mimetype?(graph)
    graph.query(predicate: RDF::URI(EBUCORE_MIMETYPE_PREDICATE)).any?
  end
end
