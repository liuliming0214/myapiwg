local _M = {}

-- 获取http get/post 请求参数
function _M.getArgs()
    local request_method = ngx.var.request_method
	local receiveHeaders = ngx.req.get_headers()
	local upload = require "resty.upload"
    local args = ngx.req.get_uri_args()
    -- 参数获取
    if "POST" == request_method then
        ngx.req.read_body()
		if string.sub(receiveHeaders["content-type"],1,20) == "multipart/form-data;" then
				--local form, err = upload:new(4096)
                --args = _M:post_form_data(form, err)
		else
			local postArgs = ngx.req.get_post_args()
			if postArgs then
				for k, v in pairs(postArgs) do
					args[k] = v
				end
			end
		end
			
        
    end
    return args
end


function _M.post_form_data(form,err)
 
    if not form then
        ngx.log(ngx.ERR, "failed to new upload: ", err)
        return {}
    end
 
    --form:set_timeout(1000) -- 1 sec
    local paramTable = {["s"]=1}
    local tempkey = ""
    while true do
        local typ, res, err = form:read()
        if not typ then
            ngx.log(ngx.ERR, "failed to read: ", err)
            return {}
        end
        local key = ""
        local value = ""
        if typ == "header" then
            local key_res = _M:split(res[2],";")
            key_res = key_res[2]
            key_res = _M:split(key_res,"=")
            key = (string.gsub(key_res[2],"\"",""))
            paramTable[key] = ""
            tempkey = key
        end
        if typ == "body" then
            value = res
            if paramTable.s ~= nil then paramTable.s = nil end
            paramTable[tempkey] = value
        end
        if typ == "eof" then
            break
        end
    end
    return paramTable
end

function _M.split(s, delim)
 
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return nil
    end
  
    local start = 1
    local t = {}
 
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
         
        if not pos then
            break
        end
  
        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
 
    table.insert (t, string.sub (s, start))
  
    return t
end


function _M.getReqtable(intable)
	local keys, tmp = {}, {}
    --提出所有的键名并按字符顺序排序
    for k, _ in pairs(intable) do 
            keys[#keys+1] = k
    end
	table.sort(keys)
    for _, k in pairs(keys) do
        if type(intable[k]) == "string" or type(intable[k]) == "number" then 
            tmp[#tmp+1] = k .. "=" .. tostring(intable[k])
        end
    end
    local reqstr = table.concat(tmp, "&") 

    return reqstr
end

return _M

        
        