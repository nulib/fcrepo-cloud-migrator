# frozen_string_literal: true
module FcrepoCloudMigrator
  class File
    attr_reader :base_path

    def initialize(source)
      @base_path = Pathname.new(source)
    end

    def ttl_files
      @ttl_files ||= Pathname.glob(base_path.join('**/*.ttl')).collect { |p| p.relative_path_from(base_path).to_s } - ['rest.ttl']
    end

    def io_for(path)
      ::File.open(::File.join(base_path, path), 'r')
    end

    def content_for(path)
      io_for(path).read
    end
  end
end
