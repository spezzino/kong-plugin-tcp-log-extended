return {
  fields = {
    host = { required = true, type = "string" },
    port = { required = true, type = "number" },
    timeout = { default = 10000, type = "number" },
    req_body = { type = "boolean", default = false },
    res_body = { type = "boolean", default = false },
    server_name = { type = "string", default = "unassigned" }
  }
}