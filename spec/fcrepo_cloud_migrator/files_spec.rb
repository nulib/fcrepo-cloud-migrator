# frozen_string_literal: true

RSpec.describe FcrepoCloudMigrator::Files do
  describe '.find_all_files' do
    it 'collects all ttl files containing the ebucore#filename predicate' do
      expect(described_class.new('spec/fixtures/data/').find_all_files)
        .to contain_exactly 'spec/fixtures/data/73/7m01bk73c/files/5e19909f-8f36-4a8f-b3e0-f4e81c13a587/fcr%3Ametadata.ttl'
    end
  end
end
