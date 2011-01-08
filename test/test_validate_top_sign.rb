require File.join File.dirname(__FILE__),'..','top_terminal'
require 'test/unit'

class TestValidateTopTerminal < Test::Unit::TestCase
  def test_validate_top_terminal
    validated_params ={"top_appkey"=>"12132760", "top_parameters"=>"aWZyYW1lPTEmdHM9MTI5MDU2MTI4NzU3MyZ2aXNpdG9yX2lkPTE2NDQ5MTAxNyZ2aXNpdG9yX25pY2s9emhyX3d1eGlhbg==", "top_session"=>"21017b162aaa16e2c3ca1cf7acf7725e878a8", "top_sign"=>"NR/SucKvP/pX8ob/OdDyvw==", "agreement"=>"true", "agreementsign"=>"12132760-21509354-19025C478422D785EAD1519419000A28", "y"=>"16", "x"=>"26"}
    assert TopTerminal.validate_top_sign(validated_params)
  end
end