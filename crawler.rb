require 'open-uri'
require 'open_uri_redirections'
require_relative 'trie'

class Crawler
  def initialize(urls, max_visits = 1000)
    @urls = urls
    @max_visits = max_visits
    @visited_count = 0
    @phone_numbers = []
    @phone_number_trie = Trie.new
  end

  def visit_url(url)
    begin
      @visited_count += 1
      @content = open(url, :allow_redirections => :all).read
      parse_html
    rescue
      raise "Bad URL"
    end
  end

  def parse_html
    inside_link_tag = false
    # Case 1: we find ourselves at a digit, a potential phone number
    # Handle by looking at the 10-12 positions that follow; parse accordingly
    # Case 2: we are inside an <a> tag.
    # If our current position is an "s", that could be the start of the src portion of the tag. Check if that is the case; find the url.
    # Otherwise, we're inside the tag but the character is irrelevant. Move on.
    # Case 3: something else. move on.

    current_idx = 0
    digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    while current_idx < @content.length
      if digits.include?(@content[current_idx]) && !inside_link_tag
        current_idx = parse_phone_candidate(current_idx, false)
      elsif @content[current_idx] == "("
        current_idx = digits.include?(@content[current_idx + 1]) ? parse_phone_candidate(current_idx + 1, true) : current_idx + 2
      elsif inside_link_tag && @content[current_idx] == "h"
        current_idx = parse_url_candidate(current_idx)
      elsif @content[current_idx] == "<"
        tag_opener_data = parse_tag_opener(current_idx)
        inside_link_tag = tag_opener_data[0]
        current_idx = tag_opener_data[1]
      elsif @content[current_idx] == ">"
        inside_link_tag = false
        current_idx += 1
      else
        current_idx += 1
      end
    end

  end

  def crawl
    while @urls.length > 0 && @visited_count <= @max_visits
      url = @urls.shift
      visit_url(url)
    end

    print_phone_numbers
  end

  private
  def parse_phone_candidate(idx, open_paren)
    current_idx = idx
    phone_number = ""
    end_found = false
    digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    legal_non_digits = ['.', '-', ' ']
    legal_non_digits << ')' if open_paren

    until current_idx - idx > 13
      char = @content[current_idx]
      if digits.include?(char)
        phone_number += char
        current_idx += 1
      elsif char == ")"
        if legal_non_digits.include?(")")
          legal_non_digits.pop
          current_idx += 1
        else
          @phone_numbers << phone_number if phone_number.length == 10
          return current_idx + 1
        end
      elsif legal_non_digits.include?(char)
        current_idx += 1
      else
        if phone_number.length == 10 && !@phone_number_trie.lookup(phone_number)
          @phone_number_trie.insert(phone_number)
          @phone_numbers << phone_number
        end

        return current_idx + 1
      end
    end

    current_idx
  end

  def parse_tag_opener(idx)
    return idx + 1 unless @content[idx + 1]

    tag_name = ""
    until @content[idx] == " " || @content[idx].nil?
      tag_name += @content[idx]
      idx += 1
    end

    if tag_name == "a"
      [true, idx]
    else
      [false, idx]
    end
  end

  def parse_url_candidate(idx)
    setting = ""
    current_idx = idx

    3.times do |_|
      return current_idx if @content[current_idx].nil?
      setting += @content[current_idx]
    end

    return current_idx + 1 unless setting == "href"
    return current_idx + 2 unless @content[current_idx + 1] == "="
    return current_idx + 3 unless @content[current_idx + 2] == '"'

    current_idx += 3
    url = ""
    until @content[current_idx] == '"'
      url += @content[current_idx]
      current_idx += 1
    end

    @urls << url
    current_idx + 1
  end

  def print_phone_numbers
    if @phone_numbers.empty?
      puts "No phone numbers found."
    else
      puts "Phone number list:"
      @phone_numbers.each do |number|
        puts number[0..2] + "-" + number[3..5] + "-" + number[6..-1]
      end
    end
  end
end
