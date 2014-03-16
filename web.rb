require 'json'

class Caskbot::Web < Sinatra::Base
  get '/' do
    "Hello! I am Caskbot!"
  end

  post '/dev/null' do
    u = Gist.gist(JSON.dump(env) + "\n\n" + JSON.dump(params) + "\n\n" + request.body.read, {
      # FIXME: Revoke token once done debugging
      access_token: 'b04e4e898623dc5dbe63e11b956cbe8418f37540',
      filename: request.path.gsub('/', '.') + '.txt',
      public: false
    })['html_url']
    puts u
    u
  end

  post '/hookin/github' do
    if params.include? 'payload'
      Caskbot::Hookin::Github.process params['payload']
    end
    [204,'']
  end
end
