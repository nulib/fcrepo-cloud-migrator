# frozen_string_literal: true

require 'aws-sdk-s3'

module FcrepoCloudMigrator
  class Upload
    attr_accessor :binary, :bucket, :region

    def initialize(bucket:, binary:, region: 'us-east-1')
      @bucket = bucket
      @binary = binary
      @region = region
    end

    def upload_binary
      begin
        resource = Aws::S3::Resource.new(region: region)
        obj = resource.bucket(bucket).object(binary.checksum_from_graph)
        obj.upload_file(binary.path)
      rescue Aws::S3::MultipartUploadError => e
        FcrepoCloudMigrator.logger.error("Failed to multipart upload binary #{binary} with MultipartUploadError #{e.errors}")
        false
      rescue => e
        FcrepoCloudMigrator.logger.error("Failed to upload binary #{binary} with error #{e}")
        false
      end
    end
  end
end
