require 'json'

class Caskbot::Hookins::Github
  class << self
    def process(event_type, payload)
      puts 'Github hookin: ' + Gist.gist(JSON.dump(payload), {
        # FIXME: Get new token for caskbot that we can gist with
        access_token: 'b04e4e898623dc5dbe63e11b956cbe8418f37540',
        filename: event_type + '.json',
        public: false
      })['html_url']
    end
  end
end
