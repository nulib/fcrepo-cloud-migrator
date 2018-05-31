# frozen_string_literal: true

require 'fcrepo_cloud_migrator/importer'
require 'fcrepo_cloud_migrator/logging'

module FcrepoCloudMigrator
  def self.logger
    FcrepoCloudMigrator::Logging.logger
  end

  def self.logger=(log)
    FcrepoCloudMigrator::Logging.logger = log
  end
end
