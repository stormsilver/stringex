require "test/unit"

$: << File.join(File.dirname(__FILE__), '../lib')
require File.join(File.dirname(__FILE__), "../init")

# This is a mock
module I18n
  @@locale = nil
  
  class << self
    def locale
      @@locale ||= nil
    end
    
    def locale=(new_locale)
      @@locale = new_locale
    end
  end
end

class UnidecoderLocalesTest < Test::Unit::TestCase
  def teardown
    # This is fuckall ugly but need to ensure things start fresh
    Stringex::Unidecoder.load_path = nil
    Stringex::Unidecoder.locale = nil
    Stringex::UnidecoderLocales.send :remove_const, "LOCALES_CODEPOINTS"
    Stringex::UnidecoderLocales.const_set "LOCALES_CODEPOINTS", Hash.new { |h, k|
      begin
        if path = Stringex::Unidecoder.load_path.detect{|p| p =~ /\/#{k}.yml$/}
          x = YAML::load_file(path)
          h[k] = x
        else
          raise Stringex::Unidecoder::InvalidLoadPath
        end
      rescue
        raise Stringex::Unidecoder::InvalidLoadPath
      end
    }
    I18n.locale = nil
  end
  
  def test_locale
    assert_nothing_raised {
      Stringex::Unidecoder.locale = :en
    }
    assert_equal :en, Stringex::Unidecoder.locale
  end
  
  def test_locales_uses_i18n
    I18n.locale = :es
    assert_equal :es, Stringex::Unidecoder.locale
  end
  
  def test_load_path
    assert_nothing_raised {
      Stringex::Unidecoder.load_path << "/path/to/yaml"
    }
    assert ["/path/to/yaml"], Stringex::Unidecoder.load_path
  end
  
  def test_decode_with_no_locales
    assert_equal "?", Stringex::Unidecoder.decode("∞")
  end
  
  def test_decode_with_unidecoder_locales
    Stringex::Unidecoder.load_path = ["test/custom.yml", "test/i18n.yml"]
    Stringex::Unidecoder.locale = :custom
    assert_equal "infinity", Stringex::Unidecoder.decode("∞")
  end
  
  def test_decode_with_i18n_locales
    Stringex::Unidecoder.load_path = ["test/custom.yml", "test/i18n.yml"]
    I18n.locale = :i18n
    assert_equal "loop-de-loop", Stringex::Unidecoder.decode("∞")
  end
  
  def test_decode_with_no_load_paths
    Stringex::Unidecoder.locale = :custom
    assert_raises(Stringex::Unidecoder::InvalidLoadPath) {
      Stringex::Unidecoder.decode("∞")
    }
  end
  
  def test_decode_from_character
    Stringex::Unidecoder.load_path = ["test/custom.yml", "test/i18n.yml"]
    Stringex::Unidecoder.locale = :custom
    assert_equal "trademark", Stringex::Unidecoder.decode("™")
  end
end