# coding: utf-8
require "iconv"
require 'digest/md5'
require 'base64'

require 'rubygems'
require 'rest_client'
require 'crack'

module TopTerminalHelper
  # 生成签名
  # Example:
  # params = {:fields => 'user_id', :nick => '', ...}
  # app_secret = 'e26cee20c18b7d70160337e027f2c651'
  # sign = sign(param,app_secret)
  def sign(param,sercetCode)
    Digest::MD5.hexdigest(sercetCode + param.sort_by { |k,v| k.to_s }.flatten.join).upcase
  end


  def sign007(params, sercetCode)
    Digest::MD5.hexdigest(sercetCode + params.sort().collect{ |key, value| key.to_s+value.to_s}.join + sercetCode).upcase
  end
  # 解析 top response
  def parse(response, format = :json)
    if(format == :xml)
      Crack::XML.parse(response)
    else
      Crack::JSON.parse(response)   # json解析，我遇到了点问题。如果要使用的话，请多测试。
    end
  end
end


class TopTerminal
  extend TopTerminalHelper

  def self.top_auth_url; @@top_auth_url ;end
  def self.top_env; @@top_env ;end
  def self.app_key; @@app_key ;end
  def self.app_secret; @@app_secret ;end
  
  @@app_key = 'xxxxxx'
  @@app_secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  # app 请求top 返回的文本格式（本人测试中遇到了Crack无法解析特定json字符串的问题）
  @@app_accept_format = 'xml'
  # top 版本
  @@top_version = '2.0'
  # top 环境
  @@top_env = [:production,:test].first
  if @@top_env == :production
    # top 地址
    @@top_url = 'http://gw.api.taobao.com/router/rest'        # 正式环境
    # top 授权地址
    @@top_auth_url = 'http://container.open.taobao.com/container?appkey=' << @@app_key  # 正式环境
  else
    # top 地址
    @@top_url = 'http://gw.api.tbsandbox.com/router/rest'     # 测试环境
    # top 授权地址
    @@top_auth_url = 'http://open.taobao.com/isv/authorize.php?appkey=' << @@app_key    # 测试环境
  end
  
  # top api 的图片字段  (top规定除签名和图片外的参数不签名  http://wiki.open.taobao.com/index.php/Session%E5%92%8C%E7%AD%BE%E5%90%8D)
  @@top_image_field = [:image]
  
  @@default_options = { 
    :app_key=> @@app_key,
    :format => @@app_accept_format,
    :timestamp=> Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    :v=> @@top_version
  }
  
  def self.call(options)
    response = nil
    case options.delete( :http_method ) || :get
    when :get
      response = RestClient.get @@top_url,:params => request_params_sign( @@default_options.merge(options) )
    when :post
      response = RestClient.post @@top_url, request_params_sign( @@default_options.merge(options) )
    when :put
      
    when :delete

    else
      # 开发者设置了错误的，http_method
      # TODO 抛出异常
    end
    parse_response response
  end

  # 对请求参数进行签名
  def self.request_params_sign(params)
    p_c = params.clone
    @@top_image_field.each { |key| p_c.delete key }  # 去掉不需要签名的字段
    params[:sign] = sign(p_c,@@app_secret)
    params
  end

  # 解析top 的 response
  def self.parse_response response
    case response.code
    when 200
      response = parse response.to_s, :xml
    else
      # top 未能正常处理请求
      {}
    end
  end
  # 验证top回调签名
  def self.validate_top_sign(params)
    params['top_appkey'] == TopTerminal.app_key &&
    params['top_sign'] == Base64.encode64(Digest::MD5.digest("#{TopTerminal.app_key}#{params['top_parameters']}#{params['top_session']}#{TopTerminal.app_secret}")).chomp
  end
  # 验证top消息通知URL签名
  def self.validate_top_notify_sign(params)
    params.delete(:sign)
    params[:sign] == sign( params, @@app_secret )
  end
  # top 回调参数解析
  # ==============================================
  # params: top_parametes => top 回调参数字符串
  # return: params => 解析后的hash
  def self.decode_top_params(top_parameters)
    url_params_str = Base64.decode64(top_parameters)
    params = {}
    url_params_str.split('&').each do |param_str|
      kv = param_str.split('=')
      params[kv[0].to_sym] = kv[1]
    end
    params[:visitor_nick] = Iconv.iconv("UTF-8//IGNORE","GBK//IGNORE",params[:visitor_nick]).first
    params
  end
end
