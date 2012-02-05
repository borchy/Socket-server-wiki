require 'socket'
require './http'

class Wiki
  NewLineTag = "<br>"
  IndexPage = "Main_Page"
  EditPage = "edit"
  FormContentsVariable = "contents"

  def initialize
    @server = TCPServer.new('127.0.0.1', 2009)
  end
  
  def run
    while true
      Thread.start(@server.accept) do |client|
        http = Http.new(client)
        
        if http.request_type == Http::GET
          page = path_array(http.request)
          html_content = ""
          if page.size == 0
            html_content = read_page(IndexPage)
          elsif page.size == 1
            page_name = page.first
            if File.exist? page_name
              html_content = read_page(page_name)
            else
              html_content = create_page_form(page_name)
            end
          elsif page.size == 2
            if page[1] == EditPage
              page_name = page.first
              if File.exist? page_name
                html_content = edit_page_form(page_name, decode_contents(read_page(page_name)))
              else
                http.redirect(page_name)
              end
            else
              http.error
            end
          else
            http.error
          end
          
          http.respond(html_content)
        elsif http.request_type == Http::POST
          page_name = path_array(http.request).first
          page_contents = encode_contents(http.variables[FormContentsVariable])
          create_page(page_name, page_contents)
          http.redirect(page_name)
        end
      end
    end
  end
  
  def encode_contents(contents)
    contents.gsub(Http::CR, NewLineTag)
  end
  
  def decode_contents(contents) 
    contents.gsub(NewLineTag, Http::CR)  
  end
  
  def path(request)
    page_url = /\/[\w\/\.]*/.match request
    page_url.to_s
  end
  
  def path_array(request)
    path(request).split("/").delete_if(&:empty?)
  end
  
  def read_page(name)
    File.open(name, "r") do |file|
      file.read
    end
  end
  
  def create_page_form(page_name)
    form_page("Create the new page", page_name, "")
  end
  
  def edit_page_form(page_name, page_contents)
    form_page("Edit the current page", page_name, page_contents)
  end
  
  def form_page(title, page_name, page_contents) 
    contents = <<-HTML
<html>
  <head>
  </head>
  <body>
    #{title}
    <form action="#{page_name}" method="post">
      <textarea name="#{FormContentsVariable}" cols=60 rows=30>#{page_contents}</textarea>
      <br>
      <input type="submit" value="Submit" />
    </form>
  </body>
</html> 
  HTML
  end
  
  def create_page(name, contents)
    File.open(name, "w") do |file|
      file.write(contents)
    end
  end
end

Wiki.new.run
