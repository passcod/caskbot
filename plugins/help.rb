class Caskbot::Plugins::Help
  include Cinch::Plugin

  match 'help'
  @@commands = ['help']

  def execute(m)
    m.reply 'Commands: ' + Caskbot::Plugins.to_a
      .map { |p| p.class_variable_get(:'@@commands') if p.class_variable_defined?(:'@@commands') }
      .flatten
      .reject { |p| !p }
      .map { |p| '!' + p } # FIXME: don't hardcode prefix
      .join(', ')
  end
end
