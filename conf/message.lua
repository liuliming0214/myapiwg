local config	= {};
local appid		= {} -- 定义appid相关错误
--网关系统相关提示信息
config["appid"]				= {code=1001,msg='appid is empty,非法请求!'}
config["sign"]				= {code=1002,msg='请求的sign不能为空!'}
config["timestamp"]			= {code=1003,msg='请求的timestamp不能为空!'}
config["appidErr"]			= {code=1004,msg='请求的appid不存在或者 未审核通过!'}
config["method"]			= {code=1005,msg='method is empty,非法请求!'}

config["signErr"]			= {code=1006,msg='sign error'}
config["rd"]				= {code=1011,msg='redis Cannot connect'}
config["request"]			= {code=1012,msg='请求的方式不规范！'}
config["result"]			= {code=1013,msg='数据不规范'}
config["other"]				= {code=1014,msg='系统请求错误'}

config["ok"]				= {code=200,msg='请求成功'}
return config;





