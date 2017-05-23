# Ruby Web Crawler

This is demo code that implements a basic web crawler in Ruby. It takes in an initial list of URLs and a number of webpages to visit. It visits each URL and parses the HTML content as it goes. Once it has exhausted its list of URLs or has visited its allotted number of pages, it prints the phone number list to the terminal.

### Using the Crawler

To test this crawler, clone this repo, navigate to the root, and run `ruby entry.rb`. You can also edit the `urls` variable in that file to test it with different URLs.

### How the Crawler Works

The crawler initializes with a list of URLs, which it saves as an array in an instance variable. The `@urls` array is treated as a queue (and, in Ruby, has the time complexity we'd want from that data structure).  When the crawler starts (via the `#crawl` method), it shifts the next URL off the queue and loads its HTML content using the `open-uri` gem. It parses the HTML content, looking for phone numbers and other URLs to visit.

- When it finds a phone number, it pushes the number onto the `@phone_numbers` array,
- When it finds a new URL, it pushes the URL onto the back of the `@urls` queue.

As it visits URLs, it keeps track of how many visits have been made with an instance variable. Once it runs out of URLs or reaches its `@max_visits`, it terminates.

### How the Parsing Works

The `open-uri` gem's `open(url).read` method returns a string. In order to optimize our time complexity, we read this string through character by character exactly once. Note that this is the minimum amount of work that we must do, since we must parse the entire HTML document.

The parsing function loops through the characters of the HTML document, and it looks for one of these cases:

- An open tag `<` indicates that we're inside an opening or closing HTML tag. We check using `parse_tag_opener` to see whether this is an `<a></a>` tag. If it is, we look for the `href` setting and push its value onto the `@url` queue.
- A digit or an open parenthesis indicates that we could be looking at a phone number. We check using `parse_phone_candidate`, which accounts for a pared down set of possible phone numbers.  Our simplifying assumptions are:
  - Phone numbers are 10 digits in length (international numbers are *not* accounted for)
  - Phone numbers can take the form `555.123.4567`, `(555) 123-4567`, `5551234567`, or `555-123-4567`.
- A closing tag indicates that we're leaving whatever tag we're currently within -- this only affects our search for a valid URL, so we reset our boolean `inside_link_tag` in this case
- All other cases indicate a character that we don't care about, so we skip it.

### Keeping Track of Numbers

A trie is used to store the phone numbers. Right now, there's an improvement to be made when it comes to the readability and the space complexity of this part of the crawler. The trie works well to store and look up phone numbers. When we have a candidate phone number, we first look it up in the trie; if it's there, we skip it.  If not, we insert it into both the trie and the `@phone_numbers` array. Doing the lookup with a trie speeds up the time complexity of that lookup to constant time rather than linear in the number of stored phone numbers.

### Directions for Improvement

Here are some improvements I'd make with more time:

- **Error handling**: the `.open` command raises an error for a bad URL on its own, so this is currently housed in a `begin/rescue` block, but this handling could be better.
- **Performance**: although we are doing the minimum amount of work on each webpage, we are using a single thread. This has a huge impact on performance. With more time, I would make this a multi-threaded program.
- **Phone number storage**: as noted, the phone numbers are housed in two different data structures. This is because I wrote the trie last and ran short of time; with more time, I'd write `Trie.print_all` and call that to print the numbers.
- **Tests**: some basic RSpec tests to make sure the error handling and parsing is happening appropriately would be good here. I would do this by testing all the helper functions separately, using an HTML document that I write and store instead of calling upon a live webpage. Additionally, I'd test the error handling for a few URLs known to be broken.
