module SwaggerJekyll
  class Tag
    attr_accessor :tag
    def initialize(tag, hash, specification)
      @tag = tag
      @hash = hash
      @specification = specification
    end

    def description
      @hash['description']
    end

    def to_liquid
      @hash.dup.merge(
        'tag' => @tag,
        'description' => description
      )
    end
  end
end
