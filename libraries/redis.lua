local redis 	= require "resty.redis"
local utils 	= require("common.utils")
local config 	= require ("conf.config")


local _M = {}


function _M.new(self)
    local red = redis:new()
    red:set_timeout(1000) -- 1 second
    local res = red:connect(config['redis_host'], config['redis_port'])
    if not res then
        return nil
    end
    if config['pass'] ~= nil then
		res = red:auth(config['pass'])
	    if not res then
	        return nil
	    end
    end
    return red
end


function _M.close_redis(red)  
    if not red then  
        return
    end  
    --释放连接(连接池实现)  
    local pool_max_idle_time = 10000 --毫秒  
    local pool_size = 1000 --连接池大小  
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)  
    if not ok then  
        utils.error_log("set keepalive error : "..err)  
    end  
end


return _M