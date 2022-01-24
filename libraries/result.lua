-- liming10@leju.com
-- 统一返回数据格式
-- 
local json 		= require("common.json")
local _M = {}

-- 根据参数 验证相关字段
-- code	返回code参数
-- msg	相关处理信息
-- data	处理数据
function  _M.resultData(code,msg,data)
	local return_info = {
		code 	= code,
		msg 	= msg,
		data   	= data
	}
	--处理返回结果
	--ngx.say(json.encode(return_info))
	return return_info
end

return _M
