require 'time'

# Hack to get ActionView to like us
class Object
  def acts_like?(duck)
    respond_to? :"acts_like_#{duck}?"
  end
end

class Caskbot::Plugins::Issues
  include Cinch::Plugin

  listen_to :channel

  class << self
    include ActionView::Helpers::DateHelper
    extend Memoist

    def format_issue(issue, opts = {})
      opts[:template] ||= 'issue'
      is_pr = issue.html_url.split('/').reverse[1] == 'pull'

      date, actioner, comments = case issue.state
      when 'closed'
        puts 'up'
        [issue.closed_at, issue.closed_by.login, nil]
      when 'open'
        issue.state = 'opened'
        [issue.created_at, nil, issue.comments]
      when 'merged'
        [issue.closed_at, issue.closed_by.login, nil]
      else
        [issue.created_at, issue.user.login, issue.comments]
      end

      r = Caskbot.template(opts[:template]).render(Object.new, {
        actioner: actioner,
        issue: issue,
        is_pr: is_pr,
        time_ago: distance_of_time_in_words_to_now(date),
        url: Caskbot.shorten(issue.html_url)
      })

      r.gsub /\s+/, ' '
    end
  end

  def listen(m)
    m.message.scan(/#(\d+)/).each do |issue|
      begin
        repo = Octokit.repo 'caskroom/homebrew-cask'
        issue = repo.rels[:issues].get(uri: {number: issue[0]}).data
      rescue Octokit::TooManyRequests, Octokit::TooManyLoginAttempts
        m.reply 'Rate-limited, try again later'
      rescue Octokit::NotFound, Octokit::Forbidden
        m.reply "##{issue[0]} doesn't exist"
      rescue
        m.reply 'Unknown error. Maintainers, check the Heroku logs'
      else
        m.reply self.class.format_issue issue
      end
    end
  end
end
