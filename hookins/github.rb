require 'json'
require 'time'

class Caskbot::Hookins::Github
  class << self
    def process(event_type, payload)
      if event_type == 'push'
        %w[created_at pushed_at].each do |field|
          date = Time.at(payload['repository'][field]).utc.to_datetime
          payload['repository'][field] = date
        end
      end

      fres = Faraday::Response.new \
        status: 200,
        body: JSON.dump(payload),
        response_headers: {
          'Content-type' => 'application/json',
          'X-GITHUB-EVENT' => event_type
        }

      event = Sawyer::Response.new(Caskbot.github.agent, fres).data

      send '_' + event_type.to_s, event
    end

    def _issues(event)
      new_issue event.issue if event.action == 'opened'
    end

    def _pull_request(event)
      new_issue event.pull_request if event.action == 'opened'
    end

    def _create(event)
      if event.ref_type == 'tag' && event.ref[0] == 'v'
        link = 'https://github.com/caskroom/homebrew-cask/releases/tag/'
        Caskbot.mainchan.safe_msg Caskbot
          .template('new_release')
          .render(Object.new, {
            version: event.ref.slice(1, event.ref.length),
            url: Caskbot.shorten(link + event.ref)
          })
      end
    end

    def method_missing(name, *args, &block)
      puts "Event not handled: #{name[1..name.length]}"
    end

    def _new_issue(issue)
      Caskbot.mainchan.safe_msg Caskbot::Plugins::Issues.format_issue(issue, template: 'new_issue')
    end
  end
end
