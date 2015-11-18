# snackk-web-api-request
requirejs base ajax wrapper for snackk api


* snackk access-token management
* request timeout
* file input


## Dependencies

* jquery
* jquery-iframe-transport
* lodash


## Usage

```coffee
# init
server = new SnackkReqeust
  'clientId': C.CLIENT_ID
  'clientSecret': C.CLIENT_SECRET
  'versionCode': C.RELEASE_VERSION_CODE
  'baseUrl': 'http://api.snackk.tv'
  'tokenModule': tokenModule

# how to use
server.request server.TAG.user.user, _.assign(
  'data': options
, callback)
```
