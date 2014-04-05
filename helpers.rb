module Caskbot::Helpers
  class << self
    def shorten(url)
      begin
        GitIo.shorten url
      rescue
        url
      end
    end
  end
end
