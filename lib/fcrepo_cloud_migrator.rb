# frozen_string_literal: true

require 'fcrepo_cloud_migrator/files'
require 'fcrepo_cloud_migrator/logging'
require 'rdf/turtle'

# 1. gather all the ttl in the export_directory
# 2. figure out which ones have mimetype `next unless`
# 3. calculate s3 location and name
# 4. upload the file and verify hash in process
# 5. edit ttl and write place

module FcrepoCloudMigrator
  def self.logger
    FcrepoCloudMigrator::Logging.logger
  end

  def self.logger=(log)
    FcrepoCloudMigrator::Logging.logger = log
  end
end
