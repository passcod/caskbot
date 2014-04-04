require 'time'

# Hack to get ActionView to like us
class Object
  def acts_like?(duck)
    respond_to? :"acts_like_#{duck}?"
  end
end

class Caskbot::Plugins::Issues
  include Cinch::Plugin
  include ActionView::Helpers::DateHelper

  listen_to :channel

  def listen(m)
    m.message.scan(/#(\d+)/).each do |issue|
      begin
        repo = Octokit.repo 'phinze/homebrew-cask'
        issue = repo.rels[:issues].get(uri: {number: issue[0]}).data
      rescue
        m.reply "##{issue[0]} doesn't exist."
      else
        is_pr = issue.html_url.split('/').reverse[1] == 'pull'
        date, actioner, comments = case issue.state
        when 'closed'
          [issue.closed_at, issue.closed_by.login, nil]
        when 'open'
          issue.body['state'] = 'opened'
          [issue.created_at, nil, issue.comments]
        when 'merged'
          [issue.closed_at, issue.closed_by.login, nil]
        else
          [issue.created_at, issue.user.login, issue.comments]
        end


        rep = []
        rep << "##{issue.number}:"
        rep << 'PR' if is_pr
        rep << "\"#{issue.title}\""
        rep << "by #{issue.user.login},"
        rep << issue.state
        rep << "by #{actioner}" if actioner
        rep << distance_of_time_in_words_to_now(date)
        rep << 'ago -'
        rep << begin
          GitIo.shorten issue.html_url
        rescue
          issue.html_url
        end
        m.reply rep.join ' '
      end
    end
  end
end
