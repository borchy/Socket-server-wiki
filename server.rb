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
          handle_get_request(http.request, navigator)
        elsif /POST/.match http.request
          handle_post_request(http, navigator)
        else
          navigator.error
        end        
      end
    end
  end

  private

  def handle_get_request(request, navigator)
    html_content = ""
    if /\/\s/.match request
      html_content = request_index_page
    elsif page_match = /GET \/(\w+)\s/.match(request)
      html_content = request_page(page_match[1])
    elsif page_match = /GET \/(\w+)\/edit\s/.match(request)
      html_content = request_edit_page(page_match[1], navigator)
    else
      navigator.error
    end
    navigator.success(html_content) if html_content
  end

    def request_index_page
    Page.load_html_page("Main_Page")
  end
  
  def request_page(page_name)
    html_content = ""
    if Page.page_exists? page_name
      html_content = Page.load_html_page(page_name)
    else
      html_content = Form.create_page_form(page_name)
    end
    html_content
  end

  def request_edit_page(page_name, navigator)
    if Page.page_exists? page_name
      html_content = Form.edit_page_form(page_name, Page.load_page(page_name))
    else
      navigator.redirect(page_name)
    end
  end

  def handle_post_request(http, navigator)
    if page_match = /POST \/(\w+)/.match(http.request)
      page_name = page_match[1]
      Page.create_page(page_name, http.variables["contents"])
      navigator.redirect(page_name)
    else
      navigator.error
    end
  end
end

server = Server.new 'localhost', 2008
server.run
