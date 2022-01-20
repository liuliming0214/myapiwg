local config = {};
config['mysql_host'] = "127.0.0.1"
config['mysql_port'] = "3306"
config['mysql_user'] = "bch_user"
config['mysql_pass'] = "6vkGmybXx4"
config['mysql_db']	= "my_apiwg"

-- 如果开启限流需要正确配置redis
--config["redis_host"] = "127.0.0.1"
--config["redis_port"] = 6379


return config;
