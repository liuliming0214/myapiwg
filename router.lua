--liming10@leju.com
--检验请求的sign签名是否正确
--网关相关逻辑处理
--相关插件应用
--nginx本地缓存应用
--capture 请求代理
ngx.header.content_type = "application/json;charset=utf8";
local tools		= require("libraries.tools")
local verify 	= require ("libraries.verify")
local req		= require("libraries.req")
local json  	= require "cjson";
local handler	= require ("libraries.plugins")--加载插件
local result 	= require("libraries.result")
local msgconfig = require ("conf.message")
--读取 post get参数.处理相关逻辑
local request_method = ngx.var.request_method
local args = nil
args = req.getArgs()
--相关参数验证  封装到插件  或者 公共类
--verify_info = verify.checkField(args,{appid = true,method = true,sign = true})
--if verify_info ~=nil then
	--处理返回结果
	--ngx.say(json.encode(verify_info))
	--return 
--end
--引入插件  判断 签名验证
local handler_info = handler.getHandler(args)
if handler_info ~=nil then
	--处理返回结果
	ngx.say(json.encode(handler_info))
	return 
end
-- 处理相关请求数据  获取redis缓存信息
local appinfo = tools.getAppinfo(args)
if  appinfo.method ~=request_method then
	--处理返回结果
	--ngx.say(json.encode(result.resultData(msgconfig['request']['code'],msgconfig['request']['msg'],{})))
	--return 
end
-- 处理相关请求 get或者post
local res = tools.requsetHttp(args,appinfo)
-- 验证返回的数据是否正常
--local data = json.decode(res.body)
--if type(res.body) == "string" or data['code'] == nil or data['msg'] == nil or  res=='' then
--	ngx.say(json.encode(result.resultData(1013,'数据不规范 缺少code,msg!',{})))
--	return
--end

ngx.say(res.body)