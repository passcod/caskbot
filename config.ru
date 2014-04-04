require 'bundler'
Bundler.require :default, (ENV['RACK_ENV'] || 'production').to_sym

module Caskbot
  class << self
    extend Memoist

    attr_accessor :bot

    def github
      Github.new do |c|
        c.oauth_token = ENV['GITHUB_TOKEN']
        c.repo = ENV['GITHUB_REPO']
        c.user = ENV['GITHUB_USER']
      end
    end

    def config
      c = Hashie::Mash.new
      ENV.each { |k,v| c[k.downcase] = v }
      return c
    end

    memoize :github, :config
  end

  module Plugins
    def self.to_a
      self.constants.map { |c| self.const_get c }
    end
  end

  module Hookins
    def self.to_a
      self.constants.map { |c| self.const_get c }
    end
  end
end

Dir['./hookins/*.rb'].each { |p| require p }
Dir['./plugins/*.rb'].each { |p| require p }
require './bot'
require './web'

Thread.new { Caskbot.bot.start }
run Caskbot::Web
