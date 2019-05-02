module Utils
  # From https://stackoverflow.com/questions/5712096
  # SW-1723
  def Utils.download_to_file(uri)
    stream = (ENV['ssl_verify']=="false") ? open(uri, "rb", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) : open(uri, "rb")
    return stream if stream.respond_to?(:path) # Already file-like

    Tempfile.new("ill_crop").tap do |file|
      file.binmode
      IO.copy_stream(stream, file)
      stream.close
      file.rewind
    end
  end
end
