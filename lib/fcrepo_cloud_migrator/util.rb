# frozen_string_literal: true
module FcrepoCloudMigrator
  module Util
    def self.resource_path(str)
      str.to_s.sub(%r{^.*?/(rest/.+)$}, '\1')
    end
  end
end
