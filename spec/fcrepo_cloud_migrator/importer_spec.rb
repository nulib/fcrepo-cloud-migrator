# frozen_string_literal: true

require 'byebug'

RSpec.describe FcrepoCloudMigrator::Importer do
  let(:importer) { described_class.new(source: source, from: from, to: to) }
  let(:source)   { File.expand_path('../../fixtures/data', __FILE__)       }
  let(:from)     { 'http://sample-repo.edu:1234/fcrepo/rest/'              }
  let(:to)       { 'http://output-repo.edu/fedora/rest/new/'               }

  let(:conn)     { instance_spy('faraday')                                 }
  let(:req)      { instance_spy('request', headers: {})                    }
  let(:resp)     { OpenStruct.new(status: 200, body: 'test')               }

  before do
    allow(conn).to receive(:run_request).and_yield(req).and_return(resp)
    allow(Faraday).to receive(:new).with(url: 'http://output-repo.edu/fedora').and_return(conn)
  end

  it '#import_all' do
    importer.import_all
    # Expect 6 creates (put) and 4 relation updates (patch),
    # all with resource paths starting with `rest/new/`
    expect(conn).to have_received(:run_request).with(:put, nil, nil, nil).exactly(6).times
    expect(conn).to have_received(:run_request).with(:patch, nil, nil, nil).exactly(4).times
    expect(req).to have_received(:path=).with(%r{^rest/new/}).exactly(10).times
    expect(req).not_to have_received(:path=).with(%r{^(?!rest/new/)})
  end
end
