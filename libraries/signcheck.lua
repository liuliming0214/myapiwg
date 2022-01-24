local _M = {}

--liming10@leju.com
--检验请求的sign签名是否正确
--intable:传入的参数值组成的table，不含传入的签名值
--secret:加入到签名字符串中的混杂字符
--insign:请求中传入进来的签名值

function _M.checkSign(intable, secret, insign)
	local keys, tmp = {}, {}
	--secret为空  默认签字字符串
	local secret = secret and secret or '_5jN;+Y-0^?Miw/W'
    --提出所有的键名并按字符顺序排序
    for k, _ in pairs(intable) do 
        if k ~= "sign" then
            keys[#keys+1] = k
        end
    end
	
	table.sort(keys)
	
    --根据排序好的键名依次读取值并拼接字符串成key=value&key=value
    for _, k in pairs(keys) do
        if type(intable[k]) == "string" or type(intable[k]) == "number" then 
            tmp[#tmp+1] = k .. "=" .. tostring(intable[k])
        end
    end
	
    --将salt添加到最后，计算正确的签名sign值并与传入的sign签名对比，
    local signchar = table.concat(tmp, "&") .. "&" ..secret
    local rightsign = ngx.md5(signchar)
	ngx.say(rightsign)
    if insign ~= rightsign then
        --如果签名错误返回错误信息并记录日志，
        --local mess="sign error: insign,"..insign .. " right sign:" ..rightsign.. " sign_char:" .. signchar
        return false,mess
    end
    return true
end


function _M.getSign(intable, secret)
	local keys, tmp = {}, {}
	--secret为空  默认签字字符串
	local secret = secret and secret or '_5jN;+Y-0^?Miw/W'
    --提出所有的键名并按字符顺序排序
    for k, _ in pairs(intable) do 
        if k ~= "sign" then
            keys[#keys+1] = k
        end
    end
	
	table.sort(keys)
	
    --根据排序好的键名依次读取值并拼接字符串成key=value&key=value
    for _, k in pairs(keys) do
        if type(intable[k]) == "string" or type(intable[k]) == "number" then 
            tmp[#tmp+1] = k .. "=" .. tostring(intable[k])
        end
    end
	
    --将salt添加到最后，计算正确的签名sign值并与传入的sign签名对比，
    local signchar = table.concat(tmp, "&") .. "&" ..secret
    local rightsign = ngx.md5(signchar)
	
    return rightsign
end

return _M
