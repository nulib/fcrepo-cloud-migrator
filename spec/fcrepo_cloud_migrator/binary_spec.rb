# frozen_string_literal: true

RSpec.describe FcrepoCloudMigrator::Binary do
  let(:binary) { described_class.new(file: file, graph: graph) }
  let(:file)   { 'spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca/fcr%3Ametadata.ttl' }
  let(:graph)  { RDF::Graph.load(file, format: :ttl) }

  describe '.path' do
    it 'derives the location of the binary for a file' do
      expect(binary.path).to eq('spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca.binary')
    end
  end

  describe '.checksum_from_graph' do
    it 'gets the checksum from the graph' do
      expect(binary.checksum_from_graph).to eq('7dc9ca05fd6ae49afde0bc3fa65ae5a6b66b539e')
    end
  end
end
