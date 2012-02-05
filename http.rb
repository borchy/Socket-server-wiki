require 'socket'
require 'uri'

class Http
  CR = "\r\n"
  GET = "GET"
  POST = "POST"
  
  attr_reader :socket
  attr_reader :request
  attr_reader :headers
  attr_reader :variables

  def initialize(socket)
    @socket = socket
    @request = socket.readline
    @headers = init_headers
    @variables = init_variables
  end
  
  def init_headers
    headers = {}
      until (line = socket.readline) == CR do 
      key, value = line.split ":"
      headers[key.strip] = value.strip
    end
    headers
  end
  private :init_headers
  
  def init_variables
    case request_type
    when GET then get_variables
    when POST then post_variables
    end
  end
  private :init_variables

  def request_type
    type = /\w+/.match(request).to_s
    case type
    when GET then GET
    when POST then POST
    else GET
    end
  end
  
  def get_variables
    url = page_url
    query_start = url.rindex("?")
    if query_start
      query = url[query_start+1..url.size]
      query_variables(query)
    end
  end
  private :get_variables
  
  def post_variables
    content_length = headers["Content-Length"].to_i
    query = socket.read(content_length)
    query_variables(query)
  end
  private :post_variables

  def page_url
    request.split(" ")[1]
  end
  
  def query_variables(query)
    variables = {}
    query.split("&").each do |field|
      key, value = field.split("=")
      variables[key] = URI.decode_www_form_component(value)
    end
    variables
  end
  private :query_variables
  
  def error
    html_content = <<-HTML
<html>
  <head>
  </head>
  <body>
    <h1>ERROR</h1>
    <p>
      <h3>No such page exists</h3>
    </p>
  </body>
</html>          
    HTML
    socket_write "HTTP/1.1 404 Not Found" + CR +
                 "Content-Type: text/html" + CR +
                 "Content-Length: #{html_content.size}" + CR +
                 CR +
                 html_content
  end
  
  def redirect(page_name)
    socket_write "HTTP/1.1 301 Moved Permanently" + CR +
                 "Location: /#{page_name}" + CR +
                 CR
  end
  
  def respond(html_content)
    socket_write "HTTP/1.1 200 OK" + CR +
                 "Content-Type: text/html" + CR +
                 "Content-Length: #{html_content.size}" + CR +
                 CR +
                 html_content
  end
  
  def socket_write(message)
    socket.puts message
    socket.close
  end
  private :socket_write
end
