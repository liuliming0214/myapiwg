-- liming10@leju.com
-- 插件相关操作
local plugins	= require ("conf.plugins")--签名插件
local _M = {}

-- 获取加载相关插件信息
-- 请求相关参数
function  _M.getHandler(params)
	local handlerinfo 	= ''
	-- 根据配置文件 获取插件配置
	for k, v in pairs(plugins) do 
		if k ~= nil then
			local handler		= require ("plugins."..k..".handler")--签名插件
			local handlerinfo 	= handler.wghandleinfo(params)
			-- 验证插件是否有错误信息
			if handlerinfo ~= true and handlerinfo['code'] ~= nil then
				--有错误信息 返回数据
				return handlerinfo
			end
			
		end
	end
end


return _M
