# snackk-web-api-request
requirejs base ajax wrapper for snackk api


* snackk access-token management
* request timeout
* file input

## require 
* jquery
* jquery-cookie
* jquery-iframe-transport
* lodash

## example
#### init
```
server = new SnackkReqeust 
  'clientId': C.CLIENT_ID
  'clientSecret': C.CLIENT_SECRET
  'versionCode': C.RELEASE_VERSION_CODE
  'baseUrl': BaseUrl
```

#### how to use
```
server.request server.TAG.user.user, _.assign(
  'data': options
, callback)
```
