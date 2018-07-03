module Paperclip
  module Storage
    module Fog
      def fast_url(style_name = default_style)
        u = expiring_url(Time.now + 3600,style_name)
        "https://#{(u.match /http\:\/\/(.*)\?/)[1]}" rescue u
      end
      alias_method :url, :fast_url
    end
  end
end
