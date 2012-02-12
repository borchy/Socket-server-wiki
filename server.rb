require 'socket'
require './http'
require './page'
require './form'
require './navigator'

class Server
  def initialize(host, port)
    @host = host
    @port = port
  end

  def run
    server = TCPServer.new @host, @port
    loop do
      Thread.start(server.accept) do |client|
        http = Http.new client
        navigator = Navigator.new client

        if /GET/.match http.request
          html_content = ""
          if /\/\s/.match http.request
            html_content = Page.load_html_page("Main_Page")
          elsif page_match = /GET \/(\w+)\s/.match(http.request)
            page_name = page_match[1]
            if Page.page_exists? page_name
              html_content = Page.load_html_page(page_name)
            else
              html_content = Form.create_page_form(page_name)
            end
          elsif page_match = /GET \/(\w+)\/edit\s/.match(http.request)
            page_name = page_match[1]
            if Page.page_exists? page_name
              html_content = Form.edit_page_form(page_name, Page.load_page(page_name)) 
            else
              navigator.redirect(page_name)
            end
          else
            navigator.error("<h1>ERROR</h1>")
          end
          navigator.success(html_content)
        elsif /POST/.match http.request
          if page_match = /POST \/(\w+)/.match(http.request)
            page_name = page_match[1]
            Page.create_page(page_name, http.variables["contents"])
            navigator.redirect(page_name)
          else
            navigator.error("<h1>ERROR</h1>")
          end
        else
          navigator.error("<h1>ERROR</h1>")
        end        
      end
    end
  end
end

server = Server.new 'localhost', 2008
server.run
