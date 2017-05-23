document.addEventListener('DOMContentLoaded', () => {
  let urls = ['http://github.com', 'http://www.google.com'];
  let crawler = new Crawler(urls);
  crawler.crawl();
})
