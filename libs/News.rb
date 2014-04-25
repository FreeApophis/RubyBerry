require 'open-uri'
require 'rss'

class News
  def initialize
    @url = 'http://www.srf.ch/news/bnf/rss/1890'
  end

  def last
    open(@url) do |rss|
      feed = RSS::Parser.parse(rss)
      return feed.items.last.title
    end
  end

  def next
  end
end
