class Caskbot::Web < Sinatra::Base
  get '/' do
    "Hello! I am Caskbot!"
  end
end
