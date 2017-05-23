

class Crawler {
  constructor (urls) {
    this.urls = urls
  };

  visitUrl (url) {
    $("html").load(url, (responseHTML) => {
      this.parseHTML(responseHTML);
    })
  };

  parseHTML (htmlData) {
    console.log(htmlData);
  };

  crawl () {
    while (this.urls.length > 0) {
      let url = this.urls.shift();
      this.visitUrl(url);
    };
  };
};
