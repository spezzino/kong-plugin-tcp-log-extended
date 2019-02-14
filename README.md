# TCP Log Plugin

### Configuration
```
curl -X POST \
  http://KONG_ADMIN_URL/plugins \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'name=tcp-log-extended&config.host=LOG_SERVER_URL&config.port=LOG_SERVER_PORT&config.req_body=true&config.res_body=true&config.server_name=SERVERNAME'
```

KONG_ADMIN_URL: Kong admin url
SERVER_NAME: Server name to identify the requests

params

- name: tcp-log-extended
- config.host: LOG_SERVER_URL
- config.port: LOG_SERVER_PORT
- config.req_body: true|false (default: false)
- config.res_body: true|false (default: false)

## Installation

Generate files

`luarocks make`

Pack the rockfile

`luarocks pack kong-plugin-tcp-log-extended 0.0.1-1`

Install

`luarocks install kong-plugin-tcp-log-extended`

Don't forget to enable this plugin in the kong configuration, or by exporting
`KONG_CUSTOM_PLUGINS` variable

```
export KONG_CUSTOM_PLUGINS="tcp-log-extended"
```
