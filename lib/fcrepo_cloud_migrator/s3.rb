# frozen_string_literal: true
module FcrepoCloudMigrator
  class S3
    attr_reader :bucket

    def initialize(source)
      @bucket = Aws::S3::Bucket.new(name: URI.parse(source).host)
    end

    def ttl_files
      @ttl_files ||= bucket.objects.collect(&:key).select { |key| key.end_with?('.ttl') } - ['rest.ttl']
    end

    def io_for(path)
      bucket.object(path).get.body
    end

    def content_for(path)
      io_for(path).read
    end
  end
end
