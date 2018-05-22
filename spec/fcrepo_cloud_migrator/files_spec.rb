# frozen_string_literal: true

RSpec.describe FcrepoCloudMigrator::Files do
  describe '.find_all_files' do
    it 'collects all ttl files containing the ebucore#filename predicate' do
      expect(described_class.new('spec/fixtures/data/').find_all_files)
        .to contain_exactly 'spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca/fcr%3Ametadata.ttl',
                            'spec/fixtures/data/01/3r074v01q/files/84df4a72-1149-4438-874d-495aef0d84ca/fcr%3Aversions/version1/fcr%3Ametadata.ttl',
                            'spec/fixtures/data/01/3r074v01q/files/a0b9b7b5-de28-47eb-a22d-0a71686dc9dd/fcr%3Ametadata.ttl'
    end
  end
end
