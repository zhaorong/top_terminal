# coding: utf-8

require 'test/unit'
require 'rubygems'
require 'crack'

class TestCrack < Test::Unit::TestCase
  #
  #   测试发现，crack认为部分淘宝的json字符串不合法。
  #   猜想是crack解析中文字符串的问题，不想深入研究原因了。
  #   暂时top_terminal只支持XML格式解析 （当然你可以修改成json的）
  #

  def test_parse_json1
    # Crack 的json 解析出错了。。。。。。
    json1 =  "{\"items_get_response\":\"李大幅度\",\"price\":12312323}"
    parsed_json = Crack::JSON.parse(json1)
    assert parsed_json.is_a?( Hash ), '这里出错了'
  end

  def test_parse_json2
    json2 =  "{\"price\":12312323,\"items_get_response\":\"李大幅度\"}"
    parsed_json = Crack::JSON.parse(json2)
    assert parsed_json.is_a?( Hash ), '同样的字符串调个个，就没问题。。。。。。。'
  end
  
end
