require 'time'
require 'base64'

class Caskbot::Plugins::Audit
  include Cinch::Plugin
  include ActionView::Helpers::DateHelper
  extend Memoist

  match /audit\s?(.*)/
  @@commands = ['audit', 'audit {summary,}']

  def cmd_summary(m, *params)
    file = get_file
    summary = parse file.content

    r = Caskbot.template('audit_summary.hbs').render(Object.new, {
      summary: summary,
      started_ago: distance_of_time_in_words_to_now(summary.started),
      url: Caskbot.shorten(file._links.html)
    }).gsub(/\s+/, ' ').split('{NL}').each do |line|
      m.reply line.strip
    end
  end

  def try_date(date)
    begin
      DateTime.parse date
    rescue
      DateTime.now
    end
  end

  def parse(file)
    f = file.split("\n")
    r = {}
    r[:started]  = try_date f.shift.match(/(?:at\s)(.+)/)[1]
    
    nfail = 0
    nnots = 0
    nbads = 0
    total = 0
    tests = []
    infos = {}
    
    f.each do |line|
      if line[0] == ' '
        t, s = line.split ':', 2
        infos[tests.last][:_data] << line
        infos[tests.last][t.strip.downcase.to_sym] = s.strip if s
      else
        t, s = line.split ':', 2
        t.strip!
        tests << t
        infos[t] = {_data: [], status: s.strip}

        total += 1
        nfail += 1 if s =~ /download error/
        nnots += 1 if s =~ /no checksum/
        nbads += 1 if s =~ /mismatch/
      end
    end

    pfail = (nfail * 100.0 / total).round 1
    pnots = (nnots * 100.0 / total).round 1
    pbads = (nbads * 100.0 / total).round 1

    r[:casks] = infos
    r[:total] = total
    r[:errors] = {amount: nfail, percent: pfail}
    r[:no_sums] = {amount: nnots, percent: pnots}
    r[:mismatch] = {amount: nbads, percent: pbads}

    Hashie::Mash.new r
  end

  def repo
    Caskbot.github.repo('alebcay/cask-tasting')
  end

  def get_file(ref = nil)
    opts = {path: 'CaskTasting.txt'}
    opts[:ref] = ref if ref
    f = repo.rels[:contents].get(uri: opts).data
    f.content = Base64.decode64 f.content if f.encoding == 'base64'
    return f
  end

  def execute(m, param)
    param ||= ''
    call, params = param.split /\s+/, 2
    if call
      params ||= []
      send "cmd_#{call}".to_sym, m, *params
    else
      send :cmd_summary, m
    end
  end

  memoize :parse, :repo, :try_date
end
