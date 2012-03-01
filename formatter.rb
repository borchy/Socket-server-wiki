# encoding: utf-8

class Formatter
  attr_reader :markdown_text
  
  def initialize(markdown_text = "")
    raise ArgumentError, "Please provide an actual string" unless markdown_text
    @markdown_text = markdown_text
  end

 def lines_split(str)
    str.lines.to_a << "\n"
  end
  
  def markdown_to_html(markdown, included_tags = Hash.new(true))
    result = ""
    last_tag = :empty
    buffer = Buffer.new
    lines_split(markdown).each do |line|
      current_tag = tag_type(line)
      tag = create_tag(last_tag)

      # TODO it could be simplified...I hope
      if last_tag == current_tag and tag.multiline?
        buffer.write(line)
      elsif last_tag == current_tag and not tag.multiline?
        result << tag.parse(buffer.read); buffer.write(line)
      elsif last_tag == :empty and current_tag == :empty
        result << line
      elsif last_tag != current_tag and current_tag != :empty
        result << tag.parse(buffer.read); buffer.write(line);
      elsif last_tag != current_tag and current_tag == :empty
        result << tag.parse(buffer.read) << line
      end
      
      last_tag = current_tag
    end
    result[0..result.size - 2]
  end
  
  def to_html
    markdown_to_html(@markdown_text)
  end

  def tag_type(line)
    [:header, :code, :quote, :ordered_list, :unordered_list, :empty, :paragraph].each do |tag|
      return tag if create_tag(tag).regex =~ line
    end
  end

  def create_tag(tag)
    camel_case = tag.to_s.split("_").map(&:capitalize).join
    Kernel.eval(camel_case).new
  end
  
  alias to_s to_html

  def inspect
    markdown_text
  end
end

class Buffer
  def initialize(text = "")
    @text = text
  end

  def read
    result = @text.clone
    @text.clear
    result
  end

  def write(text)
    @text << text
  end
end

class SpecialCharacters
  def SpecialCharacters.convert(line)
    line.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;")
  end
end

class Link
  def Link.convert(text)
    # TODO: duplication
    text.split("\n").map { |line| convert_line(line) }.join("\n")
  end
  
  def Link.convert_line(line)
    regex = /\[([[:alnum:][:punct:]\s]+)\]\(([[:alnum:][:punct:]\s]+)\)/
    line.gsub(regex) do
      if !$1.include?("]") and !$1.include?("\n") and !$2.include?("\n") and !$2.include?(")")
        "<a href=\"#{$2}\">#{$1}</a>"
      end
    end
  end
end

class Emphasis    
  def regex
    /\_([[:graph:]]+)\_/
  end

  def opening_regex
    /\_([[:graph:]])/
  end

  def closing_regex
    /([[:graph:]])\_/
  end

  def to_s(phrase)
    "<em>" + phrase + "</em>"
  end

  def length
    1
  end
end

class Strong
  def regex
    /\*\*([[:graph:]]+)\*\*/
  end

  def opening_regex
    /\*\*([[:graph:]])/
  end

  def closing_regex
    /([[:graph:]])\*\*/
  end

  def to_s(phrase)
    "<strong>" + phrase + "</strong>"
  end

  def length
    2
  end
end

class TextStyleFactory
  @@tags = [:emphasis, :strong]

  def TextStyleFactory.create(tag)
    camel_case = tag.to_s.split("_").map(&:capitalize).join
    Kernel.eval(camel_case).new
  end
  
  def TextStyleFactory.create_all
    @@tags.map do |tag|
      self.create(tag)
    end
  end
end

class TextStyleFormatting
  def TextStyleFormatting.convert_words(line)
    tags = TextStyleFactory::create_all
    result = line.clone
    tags.each do |tag|
      result = result.gsub(tag.regex) { tag.to_s($1) }
    end
    result
  end

  def TextStyleFormatting.first_index_per_tag(line)
    hash = {} 
    TextStyleFactory::create_all.each do |tag|
      hash[tag] = line.index(tag.opening_regex)
    end   
    hash.delete_if do |key, value|
      if value == nil
        true
      elsif
        second_index = line.index(key.closing_regex, value + 1)
        if second_index == nil
          true
        end
      end
    end
    hash
  end

  def TextStyleFormatting.first_interval(hash, line)
    first_index = line.size
    second_index = 0
    first_tag = nil
    hash.each do |key, value|
      if value < first_index
        first_tag = key
        first_index = value
        second_index = line.index(first_tag.closing_regex, first_index + 1)
      end
    end
    [first_tag, first_index, second_index]
  end

  def TextStyleFormatting.convert_interval(text, from, to)
    convert(text[from, to - from])
  end

  def TextStyleFormatting.convert(line)
    result = convert_words(line)
    hash = first_index_per_tag(result)
    first_tag, first_index, second_index = first_interval(hash, result)
    if first_tag and second_index
      first_tag_text = first_tag.to_s(convert_interval(result, first_index + first_tag.length, second_index + 1))
      after_first_tag = convert_interval(result, second_index + first_tag.length + 1, result.size)
      if first_index > 0
        result[0..first_index-1] + first_tag_text + after_first_tag
      else
        first_tag_text + after_first_tag
      end
    else
      result
    end
  end
end

class Tag
  def parse_line(line, chars = true, links = true, style = true)
    result = line.clone
    result = chars ? SpecialCharacters::convert(result) : result
    result = links ? Link::convert(result) : result
    result = style ? TextStyleFormatting::convert(result) : result
  end
end

class Empty
  def multiline?
    false
  end

  def regex
    /^\r$/
  end

  def parse(text)
    ""
  end
end

class Header < Tag
  def multiline?
    false
  end
  
  def regex
    /^\s{,3}([#]{1,4})\s([[:graph:]\s]+)$/
  end
  
  def parse(text)
    match_data = regex.match(text)
    header_size = match_data[1].size
    sentence = match_data[2]
    content = parse_line(sentence.strip)
    if text.end_with? "\n"
      "<h#{header_size}>" + content.chomp + "</h#{header_size}>" + "\n"      
    else
      "<h#{header_size}>" + content + "</h#{header_size}>"
    end
  end
end

class Code < Tag
  def multiline?
    true
  end
  
  def regex
    /^\s{4}([[:graph:]\s]+)$/
  end
  
  def parse(text)
    print text.lines.to_a
    content = text.lines.map{ |line| parse_line(regex.match(line)[1], true, false , false) }.join
    if text.end_with? "\n"
      "<pre><code>" + content.chomp + "</code></pre>" + "\n"
    else
      "<pre><code>" + content + "</code></pre>"
    end
  end
end

class Paragraph < Tag
  def multiline?
    true
  end

  def regex
    //
  end
  
  def parse(text)
    content = text.lines.map { |line| parse_line(line) }.join("\n")
    if text.end_with? "\n"
      "<p>" + content.chomp + "</p>" + "\n"
    else
      "<p>" + content + "</p>"
    end
  end
end

class Quote < Tag
  def multiline?
    true
  end
  
  def regex
    /^>\s([[:graph:]\s]*)$/
  end

  def parse(text)
    formatter = Formatter.new
    included_tags = Hash.new(false)
    included_tags[:paragraph] = true
    included_tags[:empty] = true
    content = formatter.markdown_to_html(text.split("\n").map{ |line| regex.match(line)[1] }.join("\n"), included_tags)
    if text.end_with? "\n"
      "<blockquote>" + content.chomp + "</blockquote>" + "\n"
    else
      "<blockquote>" + content + "</blockquote>"
    end
  end
end

class List < Tag
  def multiline?
    true
  end

  def list_string(text)
    text.lines.map{ |line| "  " + "<li>" + parse_line(regex.match(line)[1]) + "</li>" }.join("\n")
  end

  def parse(text)
    tag(list_string(text))
  end
end

class OrderedList < List  
  def regex
    /^[\d]\.\s([[:graph:]\s]*)$/
  end
  
  def tag(text)
    "<ol>" + "\n" + text + "\n" + "</ol>" + "\n"
  end
end

class UnorderedList < List
  def regex
    /^\*\s([[:graph:]\s]*)$/
  end

  def tag(text)
    "<ul>" + "\n" + text + "\n" + "</ul>" + "\n"
  end
end
