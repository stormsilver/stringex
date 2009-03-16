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
    LuckySneaks::Unidecoder.load_path = nil
    LuckySneaks::Unidecoder.locale = nil
    LuckySneaks::UnidecoderLocales.send :remove_const, "LOCALES_CODEPOINTS"
    LuckySneaks::UnidecoderLocales.const_set "LOCALES_CODEPOINTS", Hash.new { |h, k|
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
    }
    I18n.locale = nil
  end
  
  def test_locale
    assert_nothing_raised {
      LuckySneaks::Unidecoder.locale = :en
    }
    assert_equal :en, LuckySneaks::Unidecoder.locale
  end
  
  def test_locales_uses_i18n
    I18n.locale = :es
    assert_equal :es, LuckySneaks::Unidecoder.locale
  end
  
  def test_load_path
    assert_nothing_raised {
      LuckySneaks::Unidecoder.load_path << "/path/to/yaml"
    }
    assert ["/path/to/yaml"], LuckySneaks::Unidecoder.load_path
  end
  
  def test_decode_with_no_locales
    assert_equal "?", LuckySneaks::Unidecoder.decode("∞")
  end
  
  def test_decode_with_unidecoder_locales
    LuckySneaks::Unidecoder.load_path = ["test/custom.yml", "test/i18n.yml"]
    LuckySneaks::Unidecoder.locale = :custom
    assert_equal "infinity", LuckySneaks::Unidecoder.decode("∞")
  end
  
  def test_decode_with_i18n_locales
    LuckySneaks::Unidecoder.load_path = ["test/custom.yml", "test/i18n.yml"]
    I18n.locale = :i18n
    assert_equal "loop-de-loop", LuckySneaks::Unidecoder.decode("∞")
  end
  
  def test_decode_with_no_load_paths
    LuckySneaks::Unidecoder.locale = :custom
    assert_raises(LuckySneaks::Unidecoder::InvalidLoadPath) {
      LuckySneaks::Unidecoder.decode("∞")
    }
  end
  
  def test_decode_from_character
    LuckySneaks::Unidecoder.load_path = ["test/custom.yml", "test/i18n.yml"]
    LuckySneaks::Unidecoder.locale = :custom
    assert_equal "trademark", LuckySneaks::Unidecoder.decode("™")
  end
end