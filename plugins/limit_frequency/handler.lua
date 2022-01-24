--liming10@leju.com
--限流，可以控制每个客户端的访问频次
local _M = {}
local utils = require("common.utils")
local redis = require "resty.redis"  --引入redis模块
local config 	= require ("conf.config")
local msgconfig = require ("conf.message")
local json  	= require "cjson";

local function close_redis(red)  
    if not red then  
        return
    end  
    --释放连接(连接池实现)  
    local pool_max_idle_time = 10000 --毫秒  
    local pool_size = 100 --连接池大小  
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)  
    if not ok then  
        utils.error_log("set keepalive error : "..err)  
    end  
end



function _M.wglimitip()

	local red = redis:new()  --创建一个对象，注意是用冒号调用的

	--设置超时（毫秒）  
	red:set_timeout(1000) 
	--建立连接  
	local host = config['redis_host']  
	local port = config['redis_port']
	local ok, err = red:connect(host, port)
	if not ok then  
		close_redis(red)
		utils.error_log("Cannot connect");
		return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)   
	end  

	local key = "limit:frequency:login:"..utils.get_ip();
		
	--得到此客户端IP的频次
	local resp, err = red:get(key)
	if not resp then  
		close_redis(red)
		return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR) --redis 获取值失败
	end 

	if resp == ngx.null then   
		red:set(key, 1) -- 单位时间 第一次访问
		red:expire(key, 10) --10秒时间 过期
	end  

	if type(resp) == "string" then 
		if tonumber(resp) > 10 then -- 超过10次
			close_redis(red)
			ngx.header.content_type = "text/html";
			ngx.status = 403
			ngx.say("<p style='font-size: 20px'>请求过快!</p>")
			ngx.exit(403)
		end
	end

	--调用API设置key  
	ok, err = red:incr(key)  
	if not ok then  
		close_redis(red)
		return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR) --redis 报错 
	end  

	close_redis(red)  
end

return _M
