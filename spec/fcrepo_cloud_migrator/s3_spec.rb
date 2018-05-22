# frozen_string_literal: true

RSpec.describe FcrepoCloudMigrator::S3 do
  let(:bucket) { 's3://bucket-key/' }
  let(:s3) { described_class.new(bucket: bucket, file: 'spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca/fcr%3Ametadata.ttl') }

  describe '.file_extension' do
    it 'gets the file extension from the graph' do
      expect(s3.file_extension).to eq('.jpg')
    end
  end

  describe '.binary' do
    it 'derives the location of the binary for a file' do
      expect(s3.binary).to eq('spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca.binary')
    end
  end

  describe '.checksum_from_graph' do
    it 'gets the checksum from the graph' do
      expect(s3.checksum_from_graph).to eq('7dc9ca05fd6ae49afde0bc3fa65ae5a6b66b539e')
    end
  end

  describe '.destination' do
    it 'derives the location on s3 to upload the binary' do
      expect(s3.destination).to eq("#{bucket}7dc9ca05fd6ae49afde0bc3fa65ae5a6b66b539e")
    end
  end
end
