require 'socket'

class Navigator
  def initialize(socket)
    @socket = socket
  end

  def success(html_content)
    response("200 OK", html_content)
  end

  def error(html_content)
    response("404 Not Found", html_content)
  end

  def response(status_code, html_content)
    @socket.puts "HTTP/1.1 #{status_code}\n" +
      "Content-Type: text/html\n" +
      "Content-Length: #{html_content.size}\n" +
      "\n" +
      "#{html_content}"
    @socket.close
  end

  def redirect(page_name)
    @socket.puts "HTTP/1.1 301 Moved Permanently\n" +
      "Location: /#{page_name}"
    @socket.close
  end
end
