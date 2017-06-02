module SwaggerJekyll
  class Schema::Anything < Schema
    def compact_type
      'anything'
    end

    def example
      'undefined'
    end
  end
end
