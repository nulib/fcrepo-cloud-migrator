# frozen_string_literal: true
module FcrepoCloudMigrator
  class File
    attr_reader :base_path, :file_type

    def initialize(source, file_type=:ttl)
      @base_path = Pathname.new(source)
      @file_type = file_type
    end

    def all_files
      @all_files ||= Pathname.glob(base_path.join("**/*.#{file_type}")).collect { |p| p.relative_path_from(base_path).to_s } - ["rest.#{file_type}"]
    end

    def io_for(path)
      ::File.open(::File.join(base_path, path), 'r')
    end

    def content_for(path)
      io_for(path).read
    end
  end
end
