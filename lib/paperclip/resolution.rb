module Paperclip
  class Resolution
    def initialize(file)
      @file = file
      raise_if_blank_file
    end

    def make
      resolution_string.lines.each do |item| 
        if item.strip.start_with? "Resolution:"
          r = item.split(" ")[1]
          return r.split("x")[0].to_i
        end
      end
      return 0
    end

   def resolution_string
      begin
        Paperclip.run(
          "identify",
          "-units PixelsPerInch  -verbose :file", {
            :file => "#{path}[0]"
          }, {
            :swallow_stderr => true
          }
        )
      rescue Cocaine::ExitStatusError
        ""
      rescue Cocaine::CommandNotFoundError => e
        raise_because_imagemagick_missing
      end
    end

    def path
      @file.respond_to?(:path) ? @file.path : @file
    end 
    def raise_if_blank_file
      if path.blank?
        raise Errors::NotIdentifiedByImageMagickError.new("Cannot find the resolution of a file with a blank name")
      end
    end

    def raise_because_imagemagick_missing
      raise Errors::CommandNotFoundError.new("Could not run the `identify` command. Please install ImageMagick.")
    end
  end
end
