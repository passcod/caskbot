Caskbot.bot = Cinch::Bot.new do
  configure do |c|
    c.channels = ENV['IRC_CHANNELS'].split
    c.nick = ENV['IRC_NICK']
    c.password = ENV['IRC_PASSWORD'] if ENV.include? 'IRC_PASSWORD'
    c.port = ENV['IRC_PORT'].to_i
    c.realname = ENV['IRC_REALNAME']
    c.server = ENV['IRC_SERVER']
    c.ssl.use = ENV['IRC_SSL'].to_i >= 1 if ENV.include? 'IRC_SSL'
    c.ssl.verify = ENV['IRC_SSL'].to_i >= 2 if ENV.include? 'IRC_SSL'
    c.user = ENV['IRC_USER'] if ENV.include? 'IRC_USER'
    c.plugins.plugins = Caskbot::Plugins.to_a
  end
end
