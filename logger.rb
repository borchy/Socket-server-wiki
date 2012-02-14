class Logger
  @@clients = []
  
  def self.add client
    @@clients << client
  end

  def self.log message
    @@clients.each do |client|
      begin
        client.puts message
      rescue
        @@clients.delete client
      end
    end
  end
end
