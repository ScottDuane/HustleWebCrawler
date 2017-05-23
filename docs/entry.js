document.addEventListener('DOMContentLoaded', () => {
  let urls = ['https://github.com', 'https://www.google.com'];
  let crawler = new Crawler(urls);
  crawler.crawl();
})
