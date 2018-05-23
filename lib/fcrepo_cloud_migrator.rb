# frozen_string_literal: true

require 'fcrepo_cloud_migrator/files'
require 'fcrepo_cloud_migrator/binary'
require 'fcrepo_cloud_migrator/upload'
require 'fcrepo_cloud_migrator/logging'
require 'fcrepo_cloud_migrator/metadata'
require 'rdf/turtle'

module FcrepoCloudMigrator
  def self.logger
    FcrepoCloudMigrator::Logging.logger
  end

  def self.logger=(log)
    FcrepoCloudMigrator::Logging.logger = log
  end
end
