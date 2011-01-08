require File.join File.dirname(__FILE__),'..','top_terminal'
require 'test/unit'

class TestTopTerminal < Test::Unit::TestCase

  def test_call_taobao_items_get  # no need session
    get_response = TopTerminal.call(:http_method => :get,:method => 'taobao.items.get', :fields => 'title, num_iid, price, cid', :q => 'test')
    post_response = TopTerminal.call(:http_method => :post,:method => 'taobao.items.get', :fields => 'title, num_iid, price, cid', :q => 'test')
    assert (get_response['items_get_response'] == post_response['items_get_response']), "GET,POST获得的结果竟然不一致"
  end

  def test_call_taobao_postages_get # need session
    session_key = '230535befaf5bf92e010fb4f869a557f46c2d'  # 可以用 get_session_key_for_test 方法产生
    response = TopTerminal.call(:method => 'taobao.postages.get', :fields => 'postage_id, name', :session => session_key)
    assert_not_nil response['postages_get_response']
  end

  

  def test_taobao_item_add
    session_key = '2287360502221eab45406dc53c7ae20998cde'  # 可以用 get_session_key_for_test 方法产生
    response = TopTerminal.call(
      :http_method => :post,
      :method => 'taobao.item.add',
      :num => 10, :price => 123, :type => 'fixed',
      :stuff_status => 'new', :title => 'zhr test item', :desc => 'this is the description of zhr test item.',
      'location.state' => '江苏', 'location.city' => '南京', 
      :cid => 50005777,
      :image => File.new("D:\\images\\wolong.jpg"),
      :session => session_key
    )
    assert_not_nil response['item_add_response']
  end

  def test_get_session_key_for_test
    session_key = get_session_key_for_test true
    assert !session_key.empty?
  end
  
  private
  # 以下方法参考 https://github.com/elvuel/tb_ruby_sdk  实现
  # web    应用设置 hook = true
  # client 应用设置 hook = false
  # TODO 测试client应用调用是否正常
  def get_session_key_for_test(hook=false)
    appkey = '12132760'
    
    url = "http://open.taobao.com/isv/authorize.php?appkey=#{appkey}"
    response = RestClient.get(url)
    auth = RestClient.post(url, {"zhxz" => "2", "nick" => "躺着思考", "url" => "http://localhost:3000"},{:cookies => response.cookies}).to_s
    auth.gsub!('<input type="text" id="autoInput" value="', "ELVUEL")
    auth =~ /ELVUEL(.[^"]*)"/
    authcode = $1
    p '授权码为：', authcode
    url = ""
    session_key = ""
    if hook
      response = Net::HTTP.get_response(URI.parse("http://container.api.tbsandbox.com/container?authcode=#{authcode}"))
      case response
        # when Net::HTTPSuccess     then response
      when Net::HTTPRedirection
        url = response['location']
      else
        url = ""
      end
      session_key = url.split("top_session=")[1].split("&")[0] unless url.empty?
    else
      session_key = RestClient.get("http://container.api.tbsandbox.com/container?authcode=#{authcode}").to_s
    end
    p 'session key 为：', session_key
    session_key
  end
end