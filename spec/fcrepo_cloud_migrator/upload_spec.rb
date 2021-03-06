# frozen_string_literal: true

RSpec.describe FcrepoCloudMigrator::Upload do
  let(:binary) { FcrepoCloudMigrator::Binary.new(file: file, graph: graph) }
  let(:file)   { 'spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca/fcr%3Ametadata.ttl' }
  let(:graph)  { RDF::Graph.load(file, format: :ttl) }
  let(:upload) { described_class.new(bucket: 'mybucket-123', binary: binary) }
  let(:logger) { instance_spy('logger') }

  describe '.upload_binary' do
    context 'success' do
      before do
        allow(Aws::S3::Resource).to receive(:new).and_return(Aws::S3::Resource.new(stub_responses: true))
      end

      it 'uploads the file' do
        expect(upload.upload_binary).to be_truthy
      end
    end

    context 'error' do
      before do
        allow(FcrepoCloudMigrator).to receive(:logger).and_return(logger)
      end

      it 'handles and logs errors' do
        allow(Aws::S3::Resource).to receive(:new).and_raise(RuntimeError)
        expect(upload.upload_binary).to be_falsey
        expect(logger).to have_received(:error).once
      end

      it 'handles and logs Aws::S3::MultipartUploadError' do
        allow(Aws::S3::Resource).to receive(:new).and_raise(Aws::S3::MultipartUploadError)
        expect(upload.upload_binary).to be_falsey
        expect(logger).to have_received(:error).once
      end
    end

    context 'already exists in bucket' do
      before do
        allow(FcrepoCloudMigrator).to receive(:logger).and_return(logger)
        allow(Aws::S3::Bucket).to receive(:new).and_return(obj)
        allow(Aws::S3::Resource).to receive(:new).and_return(Aws::S3::Resource.new(stub_responses: true))
      end

      let(:obj) { instance_spy('obj') }

      it 'logs when the object already exists in the bucket' do
        allow(obj).to receive(:exists?).and_return(true)
        expect(upload.upload_binary).to be_truthy
        expect(logger).to have_received(:info).once
      end
    end
  end
end
