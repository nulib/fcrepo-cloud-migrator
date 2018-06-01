# frozen_string_literal: true
module FcrepoCloudMigrator
  class Relations
    include Enumerable
    attr_accessor :base_url

    def initialize(base_url)
      @base_url = base_url
    end

    def extract(graph)
      relations = RDF::Graph.new
      graph.statements.each do |st|
        graph.delete(st) if exclude?(st)
        if st.object.start_with?(base_url)
          graph.delete(st)
          relations << st unless exclude?(st)
        end
      end
      persist(relations)
      relations.subjects.first.path
    end

    def persist(graph)
      ::File.open(relation_file, 'a') do |file|
        file.puts(graph.dump(:ntriples))
      end
    end

    def each
      graph = RDF::Graph.load(relation_file)
      graph.subjects.each do |subject|
        RDF::Graph.new do |g|
          graph.query([subject, :p, :o]).each { |st| g << st }
          yield g
        end
      end
    end

    def relation_file
      @relation_file ||= ::File.join(Dir.tmpdir, SecureRandom.hex(8) + '.nt')
    end

    private

      def exclude?(st)
        st.predicate.starts_with?(RDF::Vocab::Fcrepo4) ||
          st.object.starts_with?(RDF::Vocab::Fcrepo4) ||
          st.predicate == RDF::Vocab::LDP.contains ||
          !st.subject.to_s.match?(%r{/rest/}) ||
          st.subject.to_s.match?(%r{/fcr:})
      end
  end
end
