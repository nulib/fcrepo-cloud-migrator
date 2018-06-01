# frozen_string_literal: true
module FcrepoCloudMigrator
  module Util
    def self.resource_path(str)
      str.to_s.sub(%r{^.*?/(rest/.+?)(#.+)?$}, '\1')
    end

    def self.sparql(graph)
      StringIO.new.tap do |result|
        result << "INSERT {\n"
        graph.statements.each do |st|
          result << "  " << st.to_s << "\n"
        end
        result << "}\nWHERE { }"
      end.string
    end
  end
end
