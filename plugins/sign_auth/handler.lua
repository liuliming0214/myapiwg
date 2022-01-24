--liming10@leju.com
--签名验证插件
local _M = {}
local utils 	= require("common.utils")
local msgconfig = require("conf.message")
local json  	= require "cjson";
local redis		= require("libraries.redis")
local result 	= require("libraries.result")
local cachekey 	= require ("conf.cachekey")


--liming10@leju.com
--检验请求的sign签名是否正确
--params:传入的参数值组成的table
--secret:项目secret，根据appid找到secret
local function signcheck(params,secret)
	--判断参数是否为空，为空报异常
	if utils.isTableEmpty(params) then
		local mess="params table is empty"
        utils.error_log(mess)
        return false,mess
	end
	
	--判断是否有签名参数
	local sign = params["sign"]
	if sign == nil then
		local mess="params sign is nil"
        utils.error_log(mess)
        return false,mess
	end
	
	--是否存在时间戳的参数
	local timestamp = params["timestamp"]
	if timestamp == nil then
		local mess="params timestamp is nil"
        utils.error_log(mess)
        return false,mess
	end
	--时间戳有没有过期，10秒过期
	local now_mill = ngx.now() * 1000 --毫秒级
	if now_mill - timestamp > 10000 then
		local mess="params timestamp is 过期"
        utils.error_log(mess)
        --return false,mess
	end
	
	local keys, tmp = {}, {}

    --提出所有的键名并按字符顺序排序
    for k, _ in pairs(params) do 
		if k ~= "sign" then --去除掉
			keys[#keys+1]= k
		end
    end
	table.sort(keys)
	--根据排序好的键名依次读取值并拼接字符串成key=value&key=value
    for _, k in pairs(keys) do
        if type(params[k]) == "string" or type(params[k]) == "number" then 
            tmp[#tmp+1] = k .. "=" .. tostring(params[k])
        end
    end
	--将salt添加到最后，计算正确的签名sign值并与传入的sign签名对比，
	if secret == nil then
		local shared_wg_application	= ngx.shared.shared_wg_application;
		secret = shared_wg_application:get(cachekey['wg_app_id']..params['appid']);
	end
	
    local signchar = table.concat(tmp, "&") .."&"..secret
    local rightsign = ngx.md5(signchar);
	if sign ~= rightsign then
        --如果签名错误返回错误信息并记录日志，
        local mess="sign error: sign,"..sign .. " right sign:" ..rightsign.. " sign_char:" .. signchar
        utils.error_log(mess)
        return false,mess
    end
    return true
end

function _M.wghandleinfo(params)
  
	local appid = params["appid"];
	
	if appid == nil or appid =='' then
		return result.resultData(msgconfig['appid']['code'],msgconfig['appid']['msg'],{}) 
	end	
	-- 先获取Nginx缓存数据
	local shared_wg_application	= ngx.shared.shared_wg_application;
	--获得本地缓存的值
    local resp		= shared_wg_application:get(cachekey['wg_app_id']..appid);
	-- 判断一下逻辑
	if resp == nil then
		local red 	  = redis:new() --创建一个对象，注意是用冒号调用的
		if not red then  
			redis.close_redis(red)
			utils.error_log("Cannot connect");
			return result.resultData(msgconfig['rd']['code'],msgconfig['rd']['msg'],{}) 
		end  
		--得到此appid对应的secret
		local resp, err = red:hGet(cachekey['wg_application']..appid,'secret')
		if not resp or (resp == ngx.null) then  
			return result.resultData(msgconfig['rd']['code'],'未获取配置相关信息',{})
		end 
		redis.close_redis(red) -- 使用连接池
		-- 如果获取到缓存  存入本地缓存
        shared_wg_application:set(cachekey['wg_app_id']..appid,resp,cachekey['wg_app_time']);
	end
	--ttl, err = shared_wg_application:ttl(cachekey['wg_app_id']..appid)
	--ngx.say(ttl)
	--ngx.say(resp)
	--resp存放着就是appid对应的secret
	local checkResult,mess = signcheck(params,resp)

	if not checkResult then
		return result.resultData(msgconfig['timestamp']['code'],mess,{}) 
	end
	return true
end

return _M


