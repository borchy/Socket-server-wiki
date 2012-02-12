require './formatter'

class Page
  def self.page_exists?(page_name)
    File.exists? page_name
  end

  def self.create_page(page_name, contents)
    File.open(page_name, "w") do |file|
      file.write(contents)
    end
  end

  def self.load_page(page_name)
    File.open(page_name, "r") do |file|
      file.read
    end
  end

  def self.load_html_page(page_name)
    Formatter.convert_to_html(load_page(page_name))
  end
end
