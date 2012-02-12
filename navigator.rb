require 'socket'
require './page'

class Navigator
  def initialize(socket)
    @socket = socket
  end

  def success(html_content)
    response("200 OK", html_content)
  end

  def error
    response("404 Not Found", Page.load_page("error.html"))
  end

  def response(status_code, html_content)
    @socket.puts <<-HTML
HTTP/1.1 #{status_code}
Content-Type: text/html
Content-Length: #{html_content.size}

#{html_content}    
    HTML
    @socket.close
  end

  def redirect(page_name)
    @socket.puts "HTTP/1.1 301 Moved Permanently\n" +
      "Location: /#{page_name}"
    @socket.close
  end
end
