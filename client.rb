require 'socket'

socket = TCPSocket.new 'localhost', 2008
socket.puts "logger"

begin
  while (line = socket.gets)
    puts line
  end
rescue SystemExit, Interrupt
  socket.close
end

