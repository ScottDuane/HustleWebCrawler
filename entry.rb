require_relative 'crawler'
require 'open-uri'

urls = ["https://www.google.com", "https://www.stackoverflow.com"]
crawler = Crawler.new(urls)
crawler.crawl
