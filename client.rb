require 'socket'

raise ArgumentError, "Invalid number of arguments. Quad dotted IP address and port number expected" if ARGV.size != 2
socket = TCPSocket.new ARGV[0], ARGV[1].to_i
socket.puts "logger"

begin
  while (line = socket.gets)
    puts line
  end
rescue SystemExit, Interrupt
  socket.close
end

