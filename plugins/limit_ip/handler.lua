local utils = require("common.utils")
local redis = require "resty.redis"  --引入redis模块
local config 	= require ("conf.config")
local msgconfig = require ("conf.message")
local function close_redis(red)  
    if not red then  
        return
    end  
    --释放连接(连接池实现)  
    local pool_max_idle_time = 10000 --毫秒  
    local pool_size = 100 --连接池大小  
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)  
    if not ok then  
        utils.error_log("redis set keepalive error : "..err)  
    end  
end

function _M.wgbklimitip()
   
	local key = "limit:ip:blacklist";
	local user_ip = utils.get_ip();
	local shared_ip_blacklist = ngx.shared.shared_wg_application;
	
	--获得本地缓存的最新刷新时间
	local last_update_time = shared_ip_blacklist:get("last_update_time");
	
	if last_update_time ~= nil then 
		local dif_time = ngx.now() - last_update_time 
		if dif_time < 60 then --缓存1分钟,没有过期
			if shared_ip_blacklist:get(user_ip) then
				return ngx.exit(ngx.HTTP_FORBIDDEN) --直接返回403
			end
		end
	end
	
	local red = redis:new()  --创建一个对象，注意是用冒号调用的
	--设置超时（毫秒）  
	red:set_timeout(1000)  				---这些可以放到配置文件中
	--建立连接  
	local host = config['redis_host']  
	local port = config['redis_port']
	local ok, err = red:connect(host, port)
	
	if not ok then  
		utils.error_log("limit ip cannot connect redis");
	else
		local ip_blacklist, err = red:smembers(key);
		if err then
			utils.error_log("limit ip smembers");
		else
			--刷新本地缓存，重新设置
			shared_ip_blacklist:flush_all();
			for i,bip in ipairs(ip_blacklist) do
				--本地缓存redis中的黑名单
				shared_ip_blacklist:set(bip,true);
			end
			--设置本地缓存的最新更新时间
			shared_ip_blacklist:set("last_update_time",ngx.now());
		end
	end 
	
	close_redis(red)
	
	if shared_ip_blacklist:get(ip) then
		return ngx.exit(ngx.HTTP_FORBIDDEN) --直接返回403
	end
	
end

return _M
