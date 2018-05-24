# frozen_string_literal: true

require 'fcrepo_cloud_migrator/files'
require 'fcrepo_cloud_migrator/binary'
require 'fcrepo_cloud_migrator/upload'
require 'fcrepo_cloud_migrator/logging'
require 'fcrepo_cloud_migrator/metadata'
require 'rdf/turtle'

EBUCORE_FILENAME_PREDICATE      = RDF::URI('http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename')
EBUCORE_MIMETYPE_PREDICATE      = RDF::URI('http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasMimeType')
PREMIS_MESSAGE_DIGEST_PREDICATE = RDF::URI('http://www.loc.gov/premis/rdf/v1#hasMessageDigest')

module FcrepoCloudMigrator
  def self.logger
    FcrepoCloudMigrator::Logging.logger
  end

  def self.logger=(log)
    FcrepoCloudMigrator::Logging.logger = log
  end
end
