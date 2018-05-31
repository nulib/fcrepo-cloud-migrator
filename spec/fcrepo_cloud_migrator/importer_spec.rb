# frozen_string_literal: true

require 'byebug'

RSpec.describe FcrepoCloudMigrator::Importer do
  let(:source)   { File.expand_path('../../fixtures/data', __FILE__) }
  let(:from)     { 'http://sample-repo.edu:1234/fcrepo/rest/' }
  let(:to)       { 'http://output-repo.edu/rest/' }
  let(:importer) { described_class.new(source: source, from: from, to: to) }
  let(:conn)     { instance_spy('faraday') }
  let(:req)      { instance_spy('request', headers: {}) }
  let(:resp)     { OpenStruct.new(status: 200, body: 'test') }

  before do
    allow(conn).to receive(:put).and_yield(req).and_return(resp)
    allow(Faraday).to receive(:new).and_return(conn)
  end

  it '#import_all' do
    importer.import_all
    expect(conn).to have_received(:put).exactly(6).times
  end
end
