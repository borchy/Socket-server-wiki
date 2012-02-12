require 'socket'
require 'uri'

class Http

  attr_reader :request
  attr_reader :variables
  
  def initialize(socket)
    @socket = socket
    @request = socket.gets
    @headers = parse_headers
    @variables = parse_variables
  end

  def parse_headers
    headers = {}
    while (line = @socket.gets) != "\r\n" do
      key, value = line.split(":").map(&:strip)
      headers[key] = value
    end
    headers
  end

  def parse_variables
    if /GET/.match @request
      parse_get_variables
    elsif /POST/.match @request
      parse_post_variables
    else
      raise "The request doesn't match the possible preset"
    end
  end

  def parse_get_variables
    query_match = /\?([\w%=&]+)/.match(@request)
    parse_query_variables query_match[1] if query_match
  end

  def parse_post_variables
    content_length = @headers["Content-Length"]
    query = @socket.read content_length.to_i
    parse_query_variables query
  end

  def parse_query_variables(query)
    variables = {}
    return variables unless query
    query.split("&").each do |field|
      key, value = field.split "="
      variables[key] = URI.decode_www_form_component value
    end
    variables
  end
end
