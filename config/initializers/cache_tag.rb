module ActionView
  module Helpers
    module CacheHelper
      def fragment_for(name = {}, options = nil, &block) #:nodoc:
        Rails.logger.info "USING THE PATCH CACHE METHOD name: #{name} "
        if fragment = controller.read_fragment(name, options)
          fragment
        else
          # VIEW TODO: Make #capture usable outside of ERB
          # This dance is needed because Builder can't use capture
          pos = output_buffer.length
          cache_tag = Digest::MD5.hexdigest(name.to_s)
          yield cache_tag, name
          output_safe = output_buffer.html_safe?
          fragment = output_buffer.slice!(pos..-1)
          if output_safe
            self.output_buffer = output_buffer.class.new(output_buffer)
          end
          controller.write_fragment(name, fragment, options)
        end
      end
    end
  end
end
