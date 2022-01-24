-- liming10@leju.com
-- 验证相关操作
-- 
local json 		= require("common.json")
local msgconfig = require ("conf.message")
local result 	= require ("libraries.result")
local _M = {}

-- 根据参数 验证相关字段
-- req 请求的相关参数
-- cktable 需要验证的字段
function  _M.checkField(req,cktable)

	-- 判断cktable 是否存在    如果存在  验证相关字段
	if cktable ~= nil then
		for k, v in pairs(cktable) do 
			if req[k] == nil or req[k] == '' then
				return result.resultData(msgconfig[k]['code'],msgconfig[k]['msg'],{})
			end
		end
	end
	return 

end

return _M
