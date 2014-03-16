require 'json'

class Caskbot::Hookins::Github
  class << self
    def process(event_type, payload)
      puts 'Github hookin: ' + Gist.gist(JSON.pretty_generate(payload), {
        access_token: Caskbot.config.github_token,
        filename: event_type + '.json',
        public: false
      })['html_url']
    end
  end
end
