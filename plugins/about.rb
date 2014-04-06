class Caskbot::Plugins::About
  include Cinch::Plugin

  match 'about'
  @@commands = ['about']

  def execute(m)
    m.reply Caskbot.template('about').render
  end
end
