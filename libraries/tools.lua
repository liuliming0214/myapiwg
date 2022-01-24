-- liming10@leju.com
-- 相关操作
local json 		= require("common.json")
local redis		= require ("libraries.redis")
local signcheck	= require ("libraries.signcheck")
local msgconfig = require ("conf.message")
local cachekey 	= require ("conf.cachekey")
local verify 	= require ("libraries.verify")
local libreqs		= require("libraries.req")
local _M = {}
local HTTP_METHODS = {
    GET       = ngx.HTTP_GET,
    HEAD      = ngx.HTTP_HEAD,
    PUT       = ngx.HTTP_PUT,
    POST      = ngx.HTTP_POST,
    DELETE    = ngx.HTTP_DELETE,
    OPTIONS   = ngx.HTTP_OPTIONS,
    MKCOL     = ngx.HTTP_MKCOL,
    COPY      = ngx.HTTP_COPY,
    MOVE      = ngx.HTTP_MOVE,
    PROPFIND  = ngx.HTTP_PROPFIND,
    PROPPATCH = ngx.HTTP_PROPPATCH,
    LOCK      = ngx.HTTP_LOCK,
    UNLOCK    = ngx.HTTP_UNLOCK,
    PATCH     = ngx.HTTP_PATCH,
    TRACE     = ngx.HTTP_TRACE,
}
-- 根据参数 获取缓存相关数据信息
function  _M.getAppinfo(req)
	local appid = req.appid
	-- 判断  method是否存在 入口以判断
	--相关参数验证  封装到插件  或者 公共类
	verify_info = verify.checkField(req,{appid = true,method = true})
	if verify_info ~=nil then
		--处理返回结果
		ngx.say(json.encode(verify_info))
		return 
	end
	local methodinfo  = ''
	-- 先获取Nginx缓存数据
	local shared_wg_application	= ngx.shared.shared_wg_application;
	--获得本地缓存的值
    local resp		= shared_wg_application:get(cachekey['wg_method']..req.method);
	-- 判断一下逻辑
	if resp ~= nil then
		methodinfo	= json.decode(resp)
	else
		local red 	  = redis:new()
		--得到此appid对应的method
		local resp, err		= red:hGet(cachekey['wg_application']..appid,req.method)
		if not resp or (resp == ngx.null) then  
			red.close_redis(red)
			local return_info = {
				status = msgconfig['redis_code'],
				data   = msgconfig['redis_msg']
			}
			--处理返回结果
			ngx.say(json.encode(return_info))
			return 
		end 
		-- 如果获取到缓存  存入本地缓存
		-- safe_set 如果 已经存在 就覆盖  
        shared_wg_application:set(cachekey['wg_method']..req.method,resp,cachekey['wg_app_time']);
		methodinfo	= json.decode(resp)
	end
	
	return methodinfo

end


-- 根据参数 获取缓存相关数据信息
function  _M.requsetHttp(req,appinfo)
	-- 定义数组
	local reqtable = {}
	local timestamp = os.time()
	
	-- 平台接口 sys_app_id
	reqtable['sys_app_id']	= appinfo.sys_app_id
	reqtable['timestamp']	= timestamp
	reqtable['app_id']		= req.appid
	reqtable['method']		= req.method
	--获取新的sign
	local sign				= signcheck.getSign(reqtable,appinfo.sys_app_secret)-- 平台接口 sys_app_secret
	
	local res	= ''
	local ctx	= {}
	-- 定义验证header
	ngx.req.set_header("Wg-Sys-App-Id", appinfo.sys_app_id);
	ngx.req.set_header("Wg-Sign", sign);
	ngx.req.set_header("Wg-Timestamp", timestamp);
	ngx.req.set_header("Wg-App-Id", req.appid);
	ngx.req.set_header("Wg-method", req.method);
	ctx = ngx.ctx 
	--ngx.say(json.decode(ngx.req.get_uri_args()))
	ctx.target_uri 		= appinfo.api_url
	local res = ngx.location.capture('/internet_proxy', {
		method 	= HTTP_METHODS[ngx.req.get_method()], 
		args 	= ngx.req.get_uri_args(),			-- get和post  请求所需参数放一起了
		always_forward_body = true, -- 转发父请求的request body
		share_all_vars      = true,
		ctx 	= ctx,
	})
	return res	
end
return _M
