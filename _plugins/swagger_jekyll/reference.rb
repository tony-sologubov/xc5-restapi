require 'hana'

module SwaggerJekyll
  class Reference
    class << self; attr_accessor :registry end
    attr_accessor :name

    @registry = Hash.new

    def initialize(name, hash, specification)
      @name = name
      @hash = hash
      @specification = specification

      fail "This isn't a reference: #{hash.inspect}" unless hash['$ref']
    end

    def to_liquid
      {
        'name' => name,
        'compact_type' => compact_type,
        'properties' => properties,
      }
    end

    %w(title description summary).each do |field|
      define_method(field) do
        dereference.send(field)
      end
    end

    def ref
      @hash['$ref'].gsub(/^#/, '')
    end

    def dereferenced?
      @_dereferenced != nil
    end

    def dereference
      unless dereferenced?
        pointer = Hana::Pointer.new(ref)
        target = pointer.eval(@specification.json)
        raise "Unable to dereference #{ref}" if target.nil?
        @_dereferenced = Schema.factory(@name, target, @specification)
      end

      @_dereferenced
    end

    def properties
      dereference.properties
    end

    def type
      ref.gsub('/definitions/', '')
    end

    def compact_type
      "<#{type}>"
    end

    def example
      if Reference.registry.include?(type) 
        Reference.registry[type]
      else 
        Reference.registry[type] = true
        Reference.registry[type] = dereference.example
        dereference.example
      end
    end
  end
end
