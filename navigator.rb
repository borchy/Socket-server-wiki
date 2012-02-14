require 'socket'
require './page'
require './logger'

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
    output = <<-RESPONSE
HTTP/1.1 #{status_code}
Content-Type: text/html
Content-Length: #{html_content.size}

#{html_content}    
    RESPONSE
    Logger.log "RESPONSE>> #{output}"
    @socket.puts output
    @socket.close
  end

  def redirect(page_name)
    @socket.puts <<-RESPONSE
HTTP/1.1 301 Moved Permanently
Location: /#{page_name}
    RESPONSE
    @socket.close
  end
end
