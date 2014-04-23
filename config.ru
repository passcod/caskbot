require 'bundler'
Bundler.require :default, (ENV['RACK_ENV'] || 'production').to_sym

module Caskbot
  class << self
    extend Memoist

    attr_accessor :bot

    def github
      stack = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end

      Octokit.middleware = stack
      Octokit::Client.new access_token: ENV['GITHUB_TOKEN']
    end

    def config
      c = Hashie::Mash.new
      ENV.each { |k,v| c[k.downcase] = v }
      return c
    end

    def mainchan
      Caskbot.bot.channel_list.find ENV['IRC_CHANNELS'].split.first
    end

    def root
      __dir__
    end

    def template(file)
      Tilt.new(root + '/templates/' + file + '.hbs')
    end

    def shorten(url)
      begin
        GitIo.shorten url
      rescue
        url
      end
    end

    def gisten(filename, contents, opts = {})
      opts[:filename] ||= filename
      opts[:public] ||= false
      opts[:anonymous] ||= true
      Caskbot.shorten Gist.gist(contents, opts)['html_url']
    end

    memoize :config, :gisten, :github, :root, :shorten, :template
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
