# frozen_string_literal: true
module FcrepoCloudMigrator
  class S3
    attr_reader :base_path, :bucket, :file_type

    def initialize(source, file_type=:ttl)
      @bucket = Aws::S3::Bucket.new(name: URI.parse(source).host)
      @file_type = file_type
    end

    def all_files
      @all_files ||= bucket.objects.collect(&:key).select { |key| key.end_with?(".#{file_type}") } - ["rest.#{file_type}"]
    end

    def io_for(path)
      bucket.object(path).get.body
    end

    def content_for(path)
      io_for(path).read
    end
  end
end
