# frozen_string_literal: true

require 'fcrepo/cloud/migrator/files'
require 'rdf/turtle'

# 1. gather all the ttl in the export_directory
# 2. figure out which ones have mimetype `next unless`
# 3. calculate s3 location and name
# 4. upload the file and verify hash in process
# 5. edit ttl and write place

module Fcrepo
  module Cloud
    module Migrator
    end
  end
end
