require 'json'
require 'time'

class Caskbot::Hookins::Github
  class << self
    def process(event_type, payload)
      puts 'Received payload!'
      
      puts 'Github: ' + Gist.gist(JSON.dump(payload), {
        access_token: Caskbot.config.github_token,
        filename: event_type + '.json',
        public: false
      })['html_url']

      puts 'Github (pretty): ' + Gist.gist(JSON.pretty_generate(payload), {
        access_token: Caskbot.config.github_token,
        filename: event_type + '.json',
        public: false
      })['html_url']

      if event_type == 'push'
        %w[created_at pushed_at].each do |field|
          date = DateTime.parse payload['repository'][field]
          payload['repository'][field] = date
        end
      end

      env = Faraday::Env.from \
        status: 200,
        body: JSON.dump(payload),
        response_headers: {
          'Content-type' => 'application/json',
          'X-GITHUB-EVENT' => event_type
        }

      wrap = Github::ResponseWrapper.new \
        Faraday::Response.new(env),
        Caskbot.github

      puts 'Github (wrapped): ' + Gist.gist(wrap.inspect, {
        access_token: Caskbot.config.github_token,
        filename: event_type + '.rb',
        public: false
      })['html_url']

    end
  end
end
