module SwaggerJekyll
  class Response < Struct.new(:code, :hash, :specification)
    def description
      hash['description']
    end

    def to_liquid
      hash.dup.merge(
        'code' => code,
        'compact_type' => compact_type,
        'schema' => response_type,
        'example' => example
      )
    end

    def compact_type
      response_type.compact_type
    end

    def response_type
      Schema.factory(nil, hash['schema'], specification)
    end

    def example
      string = 'hey' + response_type.example.to_json + 'awdad'

      puts string.inspect

      string
    end
  end
end
