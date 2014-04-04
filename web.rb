require 'json'

class Caskbot::Web < Sinatra::Base
  get '/' do
    "Hello! I am Caskbot!"
  end

  post '/dev/null' do
    u = Gist.gist(JSON.dump(env) + "\n\n" + JSON.dump(params) + "\n\n" + request.body.read, {
      access_token: Caskbot.config.github_token,
      filename: request.path.gsub('/', '.') + '.txt',
      public: false
    })['html_url']
    puts u
    u
  end

  post '/hookin/github' do
    if env.include? 'HTTP_X_GITHUB_EVENT'
      Caskbot::Hookins::Github.process(
        env['HTTP_X_GITHUB_EVENT'],
        JSON.load(params['payload'])
      )
    else
      puts "Received non-github event on github hook, ignoring."
    end
    [204,'']
  end
end
