require 'digest/sha2'

class Caskbot::Plugins::Hash
  include Cinch::Plugin

  match %r{hash (https?://.+)}
  @@commands = ['hash']

  def execute(m, url)
    digest = Digest::SHA2.new(256)

    request = Typhoeus::Request.new url, followlocation: true
    request.on_headers do |res|
      if res.code == 200
        info "[hash] Getting checksum for #{url}"
      else
        info "[hash] Failed getting #{url}"
        m.reply Caskbot.template('hash_fail.hbs').render Object.new, {
          url: url,
          code: res.code,
          response: res
        }
        return
      end
    end

    request.on_body do |chunk|
      digest.update chunk
    end

    request.on_complete do |res|
      m.reply Caskbot.template('hash.hbs').render Object.new, {
        hash: digest.hexdigest,
        url: url
      }
    end

    info "[hash] Attempting to get #{url}"
    request.run
  end
end
