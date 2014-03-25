class Caskbot::Plugins::Badsums
  include Cinch::Plugin

  match 'badsums'
  @@commands = ['badsums']

  def execute(m)
    failed = 'https://dl.dropboxusercontent.com/u/17915390/CaskDLFailed.txt'
    badsum = 'https://dl.dropboxusercontent.com/u/17915390/CaskSumError.txt'

    nfail = Typhoeus.get(failed).body.split.length
    nbads = Typhoeus.get(badsum).body.split.length
    m.reply "#{nfail} failed downloads and #{nbads} bad checksums"
    m.reply "Details at: http://bit.ly/1hVqdXG"
  end
end
