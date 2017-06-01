module SwaggerPages
  class CategoryPage < Jekyll::Page
    def initialize(site, base, dir, api_data)
      tag = api_data['tag']
      verbs = api_data['verbs']
      spec = api_data['specification']
      filename = get_page_friendly_filename(tag)

      @site = site
      @base = base
      @dir = dir
      @name = "#{filename}.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'reference.html')
      self.data['api'] = Hash.new
      self.data['api']['category'] = tag
      self.data['api']['operations'] = verbs
      self.data['api']['version'] = spec.info.version
      self.data['hrefs'] = verbs.map do |verb|
        {
          'title' => "[#{verb.verb}] #{verb.summary}",
          'anchor' => '#' + verb.operationId
        }
      end

      self.data['title'] = "#{tag}"
    end

    def get_page_friendly_filename(name)
      name.gsub(/[^\w\s_-]+/, '')
            .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
            .gsub(/\s+/, '_')
    end
  end
end