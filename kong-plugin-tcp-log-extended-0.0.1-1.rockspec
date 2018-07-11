package = "kong-plugin-tcp-log-extended"
version = "0.0.1-1"

source = {
  url = "git+https://github.com/spezzino/kong-plugin-tcp-log-extended.git",
  tag = "v0.0.1"
}

description = {
  homepage = "https://github.com/spezzino/kong-plugin-tcp-log-extended.git"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.tcp-log-extended.handler"] = "kong/plugins/tcp-log-extended/handler.lua",
    ["kong.plugins.tcp-log-extended.schema"] = "kong/plugins/tcp-log-extended/schema.lua",
    ["kong.plugins.tcp-log-extended.serializer"] = "kong/plugins/tcp-log-extended/serializer.lua",
  }
}