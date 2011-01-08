require 'test/unit'
require 'digest/md5'

class TestTopTerminalHelper < Test::Unit::TestCase

  
  def sign006(param,sercetCode)
      ps = param.sort_by { |k,v| k.to_s }.flatten.join
      p ps
      Digest::MD5.hexdigest(sercetCode + ps + sercetCode).upcase
  end
  def sign007(params, sercetCode)
      Digest::MD5.hexdigest(sercetCode + params.sort().collect{ |key, value| key.to_s+value.to_s}.join + sercetCode).upcase
  end

  
  def test_sgin
    
  
    params = {:app_key=>"12132760", :format=>"xml", :timestamp=>"2010-11-10 11:19:55", :v=>"2.0", :method=>"taobao.items.get", :fields=>"title, price, nick, post_fee, location.state, location.city, pic_url, num_iid, volume, score", :q=>"test", :page_size=>"10", :order_by=>"volume:desc"}
    
    p sign006(params,'e26cee20c18b7d70160337e027f2c651')
    p sign007(params,'e26cee20c18b7d70160337e027f2c651')
    assert true
  end
end
