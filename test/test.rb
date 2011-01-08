# coding: utf-8
require 'base64'
require 'iconv'

top_parameters = "aWZyYW1lPTEmdHM9MTI4OTEyODI2MzIyNCZ2aWV3X21vZGU9ZnVsbCZ2aWV3X3dpZHRoPTAmdmlzaXRvcl9pZD0xNzU5ODI4NzMmdmlzaXRvcl9uaWNrPczJ18XLvL+8"
p Base64.decode64 top_parameters
visitor_nick = "\xCC\xC9\xD7\xC5\xCB\xBC\xBF\xBC"
p Iconv.iconv("UTF-8//IGNORE","GBK//IGNORE",visitor_nick).to_s