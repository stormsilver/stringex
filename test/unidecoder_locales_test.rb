require "test/unit"

$: << File.join(File.dirname(__FILE__), '../lib')
require File.join(File.dirname(__FILE__), "../init")

class UnidecoderLocalesTest < Test::Unit::TestCase
  def test_locale
    assert_nothing_raised {
      LuckySneaks::Unidecoder.locale = :en
    }
    assert_equal :en, LuckySneaks::Unidecoder.locale
  end
  
  def test_load_path
    assert_nothing_raised {
      LuckySneaks::Unidecoder.load_path << "/path/to/yaml"
    }
    assert ["/path/to/yaml"], LuckySneaks::Unidecoder.load_path
  end
  
  def test_try_locales
    LuckySneaks::Unidecoder.load_path << "test/test.yml"
    LuckySneaks::Unidecoder.locale = :test
    assert_equal "infinity", LuckySneaks::Unidecoder.decode("∞")
  end
  
  def test_decode_with_no_locales
    assert_equal "?", LuckySneaks::Unidecoder.decode("∞")
  end
end