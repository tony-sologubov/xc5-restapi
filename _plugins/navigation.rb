# encoding: utf-8

# Jekyll plugin for providing navigation.
# adds {% navigation_menu %} tag
#
# Author: Eugene Dementjev
# Version: 0.3.5

module JekyllXcart
  module NavigationPlugin
    class BreadcrumbsTag < Liquid::Tag

    end

    class MenuTag < Liquid::Tag
      def initialize(tag_name, baseurl, tokens)
        super
        @baseurl = baseurl
      end

      def render(context)
        @site = context.registers[:site]
        @config = context.registers[:site].config
        @page = context.environments.first["page"]

        @starting_level = @page['menu_level'] || 2
        baseurl = context[@baseurl.strip]

        @menu_items = @site.pages.select { |item| item.data.fetch('lang', '') == @page.fetch('lang', @config['lang_default']) }
        @menu_items = @menu_items.sort { |a, b| a <=> b }

        level = render_level(@starting_level, baseurl)

        return level[:markup]
      end

      def render_level(level, parent, force_active_class = false)
        menu_id = level == @starting_level ? 'id="navigation-menu"' : ''
        css_class = level == @starting_level ? 'ui sticky large vertical secondary navigation accordion pointing' : 'content'

        items = @menu_items.map { |item| render_item(item, level, parent) }

        items_text = items.map { |item| item[:markup] }.join
        is_active = items.map { |item| item[:active] }.any?

        active_class = level > @starting_level && (is_active || force_active_class) ? 'active' : ''

        if items_text.strip.length > 0 then
          markup = <<-HTML
          <div #{menu_id} class="#{css_class} menu #{active_class}">
            #{items_text}
          </div>
          HTML

        else
          markup = ''
        end

        return {:markup => markup, :active => is_active}
      end

      def render_item(item, level, parent)
        parts = item['url'].sub('/', '').gsub('index.html', '').split('/')
        itembase = parts.slice(0, level).join('/')

        if item.data.fetch('show_in_sidebar', true) && 
           item.data.fetch('title', '') &&
           itembase == parent &&
           parts.length > level &&
           parts.length <= level + 1

          # Menu item is active
          is_active = item['identifier'] == @page['identifier']
          active_class = is_active ? 'active' : ''

          next_level = render_level(level + 1, parts.join('/'), is_active)
          has_next_level = next_level[:markup].length > 0

          # href submenus
          # -------------
          # if not has_next_level && item.include?('hrefs')
          #   next_level = render_hrefs(item, is_active)
          #   has_next_level = next_level[:markup].length > 0
          # end

          next_opener = has_next_level ? '<a class="opener"><i class="dropdown icon"></i></a>' : ''
          has_sub = has_next_level ? 'has-sub' : ''

          active_title_class = next_level[:active] || (is_active && has_next_level) ? 'active' : ''

          url = @site.baseurl + item['url']
          markup = <<-HTML
            <div class="anchor-link item #{has_sub} #{active_class}">
                <div class="title #{active_title_class}">
                  <a class="link " href="#{url}" >#{item['title']}</a>
                  #{next_opener}
                </div>
                #{next_level[:markup]}
            </div>
          HTML

          return {:markup => markup, :active => is_active || next_level[:active] }
        else
          return {:markup => '', :active => false }
        end

      end

      def render_hrefs(item, is_active)
        if not item['hrefs'].nil? && item['hrefs'].length > 0
          active_class = is_active ? 'active' : ''

          items_text = item['hrefs'].reduce(String.new) do |markup, href|
            href_url = @site.baseurl + item['url'] + href['anchor']
            markup = markup + <<-HTML
              <div class="anchor-link item">
                  <div class="title">
                    <a class="link " href="#{href_url}" >#{href['title']}</a>
                  </div>
              </div>
            HTML

            markup
          end

          markup = <<-HTML
          <div class="content menu #{active_class}">
            #{items_text}
          </div>
          HTML

          return {:markup => markup, :active => false }
        else 
          return {:markup => '', :active => false }
        end
      end

    end
  end
end

Liquid::Template.register_tag('navigation_menu', JekyllXcart::NavigationPlugin::MenuTag)