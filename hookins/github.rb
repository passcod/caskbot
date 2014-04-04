require 'json'
require 'time'

class Caskbot::Hookins::Github
  class << self
    def process(event_type, payload)
      if event_type == 'push'
        %w[created_at pushed_at].each do |field|
          date = DateTime.parse payload['repository'][field]
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

      case event_type
      when 'issues'
        new_issue event.issue if event.action == 'opened'
      when 'pull_request'
        new_issue event.pull_request if event.action == 'opened'
      when 'create'
        if event.ref_type == 'tag' && event.ref[0] == 'v'
          link = GitIo.shorten "https://github.com/phinze/homebrew-cask/releases/tag/#{event.ref}"
          Caskbot.mainchan.safe_msg "New release! #{event.ref} - #{link}"
        end
      end
    end

    def new_issue(issue)
      Caskbot.mainchan.safe_msg 'New: ' + Caskbot::Plugins::Issues.format_issue(issue)
    end
  end
end
