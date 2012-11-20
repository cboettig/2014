require 'feedzirra'

# Example of parsing an atom feed (from github) using feedzirra 

module Jekyll
  class FeedzirraBlockTag < Liquid::Tag
    def render(context)
      feed = Feedzirra::Feed.fetch_and_parse("https://github.com/cboettig.atom")
      # consider formatting properly
      feed.title + feed.entries[0].content + feed.entries[1].content + feed.entries[2].content + feed.entries[3].content 
    end
  end

end

Liquid::Template.register_tag('feedzirra', Jekyll::FeedzirraBlockTag)

