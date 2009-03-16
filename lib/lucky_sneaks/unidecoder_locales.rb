module LuckySneaks
  # This implementation borrows from Sven Fuch's i18n for Ruby
  # http://github.com/svenfuchs/i18n/tree/master
  module UnidecoderLocales
    LOCALES_CODEPOINTS = Hash.new { |h, k|
      path = LuckySneaks::Unidecoder.load_path.detect{|p| p =~ /\/#{k}.yml$/}
      x = YAML::load_file(path)
      h[k] = x
    } unless defined?(LOCALES_CODEPOINTS)
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      @@locale = nil
      @@load_path = nil
      
      # Returns Unidecoder-specific locale or <tt>nil</tt> if no locale is set
      def locale
        @@locale ||= nil
      end
      
      # Sets Unidecoder-specific locale
      def locale=(new_locale)
        @@locale = new_locale
      end
      
      # Returns load path for Unidecoder-specific locale files or empty array
      # if no load path is set. <b>Note:</b> the load path is expected to act
      # like an array.
      def load_path
        @@load_path ||= []
      end
      
      # Sets load path for Unidecoder-specific locale files
      def load_path=(path)
        @@load_path = path
      end
      
    private
      def try_locales(codepoint, locale_arg = @@locale)
        return nil if locale_arg.nil?
        LuckySneaks::UnidecoderLocales::LOCALES_CODEPOINTS[locale_arg][codepoint.unpack("U").first]
      end
    end
  end
end