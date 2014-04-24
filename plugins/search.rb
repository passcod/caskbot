require 'getoptlong'
require 'time'

class Caskbot::Plugins::Search
  include Cinch::Plugin
  extend Memoist

  match /search(.*)/
  @@commands = ['search [--force] [-r REPO [-r ...]] PATTERN']

  @@updated = {}

  def get_casklist(repo)
    unless %r{/} =~ repo
      repo = if repo == 'cask' or repo == 'homebrew-cask'
        'phinze/homebrew-cask'
      elsif %r{^homebrew-} =~ repo
        "caskroom/#{repo}"
      else
        "caskroom/homebrew-#{repo}"
      end
    end

    begin
      ghr = Caskbot.github.repo(repo)
      casks = ghr.rels[:contents].get(uri: {path: 'Casks'}).data
      casks.map { |f| f[:name].sub(/\.rb$/, '') }
    rescue
      []
    end
  end

  def casklist(repo)
    cached = @@updated[repo] && @@updated[repo] > DateTime.now - (1.0/24)
    cached = cached && !@@force
    if cached
      get_casklist(repo)
    else
      @@force = false
      @@updated[repo] = DateTime.now
      puts "Cache for #{repo} busted"
      get_casklist(repo, true)
    end
  end

  def parse_arguments param
    ARGV.clear
    param.split.each { |p| ARGV << p }
    opts = GetoptLong.new(
      ['--force', '-f', GetoptLong::NO_ARGUMENT],
      ['--repo',  '-r', GetoptLong::REQUIRED_ARGUMENT]
    )
    repo = []
    opts.each do |opt, arg|
      case opt
      when '--repo'
        repo << arg
      when '--force'
        @@force = true
      end
    end
    rest = ARGV
    {repos: repo, pattern: rest.join(' ')}
  end

  def get_list(repos, pattern)
    repos.map do |repo|
      casklist(repo).grep(/#{pattern}/).map do |f|
        if repos.length == 1
          f
        else
          [repo, f].join '/'
        end
      end
    end.flatten.sort
  end

  def execute(m, param)
    param ||= ''
    param.strip!
    if param == ''
      m.reply "Usage: #{@@commands.first}"
    else
      args = parse_arguments param
      repos = args[:repos]
      repos = %w[cask versions] if repos.length == 0
      list = get_list repos, args[:pattern]
      joined = list.first(5).join(', ')
      if list.length > 5
        gist = Caskbot.gisten 'Cask search results', list.join("\n")
        joined += " and #{list.length - 5} others: #{gist}"
      end
      joined = 'No results.' if list.length == 0
      m.reply joined
    end
  end

  memoize :get_casklist, :parse_arguments
end
