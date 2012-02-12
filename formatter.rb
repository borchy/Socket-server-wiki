class Formatter
  def self.convert_to_html(contents)
    contents.gsub("\n", "<br>")
  end  
end
