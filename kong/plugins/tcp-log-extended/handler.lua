local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"

local serializer = require "kong.plugins.tcp-log-extended.serializer"
local cjson = require "cjson"
local req_read_body = ngx.req.read_body
local req_get_body_data = ngx.req.get_body_data
local ngx_decode_args = ngx.decode_args

local timer_at = ngx.timer.at

local TppLogHandler = BasePlugin:extend()

TppLogHandler.PRIORITY = 8
TppLogHandler.VERSION = "0.0.1"

local function parse_json(body)
  if body then
    local status, res = pcall(cjson.decode, body)
    if status then
      return res
    end
  end
end

local function decode_args(body)
  if body then
    return ngx_decode_args(body)
  end
  return ""
end

local function log(premature, conf, message)
  if premature then
    return
  end

  local ok, err
  local host = conf.host
  local port = conf.port
  local timeout = conf.timeout
  local keepalive = conf.keepalive

  local sock = ngx.socket.tcp()
  sock:settimeout(timeout)

  ok, err = sock:connect(host, port)
  if not ok then
    ngx.log(ngx.ERR, "[tcp-log-extended] failed to connect to " .. host .. ":" .. tostring(port) .. ": ", err)
    return
  end

  if conf.tls then
    ok, err = sock:sslhandshake(true, conf.tls_sni, false)
    if not ok then
      ngx.log(ngx.ERR, "[tcp-log-extended] failed to perform TLS handshake to ",
                       host, ":", port, ": ", err)
      return
    end
  end

  ok, err = sock:send(message .. "\r\n")
  if not ok then
    ngx.log(ngx.ERR, "[tcp-log-extended] failed to send data to " .. host .. ":" .. tostring(port) .. ": ", err)
  else
    ngx.log(ngx.DEBUG, "[tcp-log-extended] sent: ", message)
  end

  ok, err = sock:setkeepalive(keepalive)
  if not ok then
    ngx.log(ngx.ERR, "[tcp-log-extended] failed to keepalive to " .. host .. ":" .. tostring(port) .. ": ", err)
    return
  end
end

function TppLogHandler:new()
  TppLogHandler.super.new(self, "tcp-log-extended")
end

function TppLogHandler:access(conf)
  TppLogHandler.super.access(self)

  local ctx = ngx.ctx
  ctx.tcp_log_extended = { req_body = "", res_body = "" }

  if conf.req_body then
    req_read_body()
    ctx.tcp_log_extended.req_body = parse_json(req_get_body_data())
  end
end

function TppLogHandler:body_filter(conf)
  TppLogHandler.super.body_filter(self)

  if conf.res_body then
    local chunk = ngx.arg[1]
    local ctx = ngx.ctx
    local res_body = ctx.tcp_log_extended and ctx.tcp_log_extended.res_body or ""
    res_body = res_body .. (chunk or "")
    ctx.tcp_log_extended.res_body = res_body
  end
end

function TppLogHandler:log(conf)
  TppLogHandler.super.log(self)

  local ctx = ngx.ctx
  ctx.tcp_log_extended.res_body = parse_json(ctx.tcp_log_extended.res_body)

  local ok, err = timer_at(0, log, conf, cjson.encode(serializer.serialize(ngx)))
  if not ok then
    ngx.log(ngx.ERR, "[tcp-log-extended] could not create timer: ", err)
  end
end

return TppLogHandler