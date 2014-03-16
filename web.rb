class Caskbot::Web < Sinatra::Base
  get '/' do
    "Hello! I am Caskbot!"
  end

  post '/dev/null' do
    puts params.inspect, body.inspect
  end
end
