module LuckySneaks
  # This implementation borrows from Sven Fuch's i18n for Ruby
  # http://github.com/svenfuchs/i18n/tree/master
  #
  # Short Version: You add your localized transliterations to the load_path,
  # then specify a locale to use. Unidecoder can also use the locale
  # settings from Rails' [or the standalone] I18n. In the latter case,
  # you will still have to provide Unidecoder with a load path.
  # 
  # Localized transliterations must be a YAML-represented Hash containing
  # key-value pairs of a character's Unicode codepoint and it's desired
  # transliteration. You may also put the character itself.
  # 
  # FWIW: the methods in LuckySneaks::UnidecoderLocales::ClassMethods
  # are mixed into LuckySneaks::Unidecoder as class method.
  module UnidecoderLocales
    LOCALES_CODEPOINTS = Hash.new { |h, k|
      begin
        if path = LuckySneaks::Unidecoder.load_path.detect{|p| p =~ /\/#{k}.yml$/}
          x = YAML::load_file(path)
          h[k] = x
        else
          raise LuckySneaks::Unidecoder::InvalidLoadPath
        end
      rescue
        raise LuckySneaks::Unidecoder::InvalidLoadPath
      end
    } unless defined?(LOCALES_CODEPOINTS)
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      @@locale = nil
      @@load_path = nil
      
      # Returns Unidecoder-specific locale or <tt>nil</tt> if no locale is set
      def locale
        @@locale ||= i18n_locale || nil
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
      def i18n_locale
        return unless defined?(I18n) && !I18n.locale.nil?
        I18n.locale
      end
      
      def try_locales(codepoint, locale_arg = locale)
        return if locale_arg.nil?
        LuckySneaks::UnidecoderLocales::LOCALES_CODEPOINTS[locale_arg][codepoint] ||
          LuckySneaks::UnidecoderLocales::LOCALES_CODEPOINTS[locale_arg][codepoint.unpack("U").first]
      end
    end
  end
end