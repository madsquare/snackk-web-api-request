define [
    'token'
], (
    tokenMgr
) ->
    _version = 'v2'

    _headerObj = 
        'X-SNACKK-CLIENT-ID': null
        'X-SNACKK-CLIENT-SECRET': null
        'X-SNACKK-TZ-OFFSET': null
        'X-SNACKK-COUNTRY': null
        'X-SNACKK-APP-VER': null

    _baseUrl = null
    
    _AUTH_STATE =
        REFRESHING: 'token.refresh'
        NOT_EXIST_TOKEN: 'token.not_exist'

    class Request
        options: null
        state: null
        hasRequest: {}
        requestData: {}
        # timeout 시간.
        timeoutDuration: 7000

        constructor: (opts) ->
            tokenMgr.init()
            @setHeaderObj opts
            _baseUrl = opts.baseUrl


        ###
         * header set.
         * @param {object} opts header내용.
        ###
        setHeaderObj: (opts) ->
            _headerObj['X-SNACKK-CLIENT-ID'] = opts.clientId
            _headerObj['X-SNACKK-CLIENT-SECRET'] = opts.clientSecret
            _headerObj['X-SNACKK-TZ-OFFSET'] = new Date().getTimezoneOffset()
            _headerObj['X-SNACKK-COUNTRY'] = 'KR'
            _headerObj['X-SNACKK-APP-VER'] = Number(opts.versionCode)

            if location.hostname.indexOf('cn') != -1
                _headerObj['X-SNACKK-COUNTRY'] = 'CN'
            else if location.hostname.indexOf('snackk.me') != -1
                _headerObj['X-SNACKK-COUNTRY'] = 'TW'
                _headerObj['Accept-Language'] = 'zh-TW';


        ###
         * 실제 ajax call.
         * @param  {[type]} url [description]
         * @return {[type]}     [description]
        ###
        request: (url, opts) ->
            options = 
                url: _baseUrl + url
                type: 'GET'
                headers: _headerObj
                dataType: 'json'
                contentType: 'application/json; charset=utf-8'

            reqId = url + JSON.stringify opts.data
            # base url을 제거한 url을 남김.
            reqUrl = url

            # ignore duplicated request
            if @hasRequest[reqId]
                console.info 'server] request ignore :' + reqId
                return @hasRequest[reqId]

            # when refreshing 
            if @state == _AUTH_STATE.REFRESHING && reqUrl != 'auth/refresh'
                console.debug 'token-expired] queue.push : '+reqUrl+' / '+JSON.stringify(opts)
                @refreshRequestQueue.push { url: reqUrl, data: opts } 
                return 

            options.type = opts.type if typeof opts.type != 'undefined'
            options.dataType = opts.dataType if typeof opts.dataType != 'undefined'

            if typeof opts.data != 'undefined' && opts.type
                options.data = JSON.stringify(opts.data)
            else 
                if opts.data 
                    options.data = opts.data
                    for k,v of opts.data
                        options.data[k] = JSON.stringify v if typeof v == 'object' || typeof v == 'array'
                else
                    options.data = opts.data

            # header 추가.
            options.headers = _.assign(options.headers, opts.headers) if opts.headers

            # POST, PUT, DELETE
            if $.inArray(options.type, ['PUT', 'DELETE']) > -1
                options.headers['X-HTTP-Method-Override'] = options.type
                options.type = 'POST'

            options.headers['Authorization'] = 'Bearer '+ac_token if (ac_token = (tokenMgr.getAccessToken())) && (@state != _AUTH_STATE.REFRESHING)

            @requestData[reqId] = opts

            # success
            done = (res, status, response) =>
                clearTimeout timeoutThisRequest if timeoutThisRequest
                @repeatTokenRequestCount = 0
                @deleteCache reqId
                res.nonce = JSON.parse res.nonce if typeof res.nonce is 'string'
                @done res, status, response
                opts.success && opts.success res, status, response

            #error
            fail = (res) =>
                clearTimeout timeoutThisRequest if timeoutThisRequest
                if !res
                    console.error 'server-error] 반환된 error객체가 없음.' 
                    debugger
                    return false 
                    
                @deleteCache reqId
                return false if res.readyState is 0 or res.statusText is 'abort' or res.statusText is 'No Transport'
                
                if res.responseText
                    tempError = JSON.parse res.responseText
                    error = tempError.error if tempError


                # token
                if error && error.type is 'common.expired_access_token'
                    if reqUrl isnt 'auth/refresh'
                        console.debug 'token-expired] queue.push : '+reqUrl+' / '+JSON.stringify(opts)
                        @refreshRequestQueue.push { url: reqUrl, data: opts } 
                    if @state isnt _AUTH_STATE.REFRESHING
                        @state = _AUTH_STATE.REFRESHING
                        @refreshToken {
                            success: (res) =>
                                @state = null
                                try
                                    res = JSON.parse(res.responseText) if typeof res is 'string'
                                    tokenMgr.setToken(res.token)
                                    i = 0
                                    while i < @refreshRequestQueue.length
                                        console.debug 'token-expired] queue.실행 : '+@refreshRequestQueue[i].url
                                        @request @refreshRequestQueue[i].url, @refreshRequestQueue[i].data
                                        @refreshRequestQueue.shift()
                                catch error
                                    debugger
                            error: (er) =>
                                debugger
                            }
                        return res
                else if error and error.type is 'common.not_exist_token'
                    if @state isnt _AUTH_STATE.NOT_EXIST_TOKEN and url isnt 'auth/refresh'
                        @state = _AUTH_STATE.NOT_EXIST_TOKEN
                        debugger
                        @repeatTokenRequestCount++
                        @request url, opts
                        return res
                    else
                        # 잘못된 token
                        @responseInvalidToken()
                        return
                else 
                    if (opts.error and opts.error error) isnt false
                        if error and error.code isnt 500
                            setTimeout (=>
                                @responseError error.message
                                ), 100
                
                @fail res

                return res

            # fileInput
            if options.dataType.indexOf('iframe') isnt -1
                originDone = done
                done = (res, status, response) ->
                   if !res || typeof res.error isnt 'undefined'
                      return fail res

                   originDone res, status, response

                options.method = 'POST'
                options.formData = []
                options.data = {} if !options.data

                if typeof options.headers['Authorization'] != 'undefined'
                    options.data['access_token'] = options.headers['Authorization']
                    options.data['x_snackk_country'] = options.headers['X-SNACKK-COUNTRY']
                else
                    options.data['client_id'] = options.headers['X-SNACKK-CLIENT-ID']
                    options.data['client_secret'] = options.headers['X-SNACKK-CLIENT-SECRET']
                    options.data['x_snackk_country'] = options.headers['X-SNACKK-COUNTRY']

                
                # cross-domain 때문에 file upload후 document결과를 받을 수 없으므로 result.html로 redirect시켜 결과값을 애초에 그쪽으로 받음.
                options.data['redirect'] = [location.protocol, '//', location.host].join('') + '/result?%s'
                if parseInt(location.port, 10) is 8000
                    options.data['redirect'] = [location.protocol, '//', location.host].join('') + '/result.html?%s'

                _.forEach options.data, (val, key) ->
                    options.formData.push {
                        name: key
                        value: val
                    }

                options.fileInput = opts.fileInput  

            timeoutThisRequest = setTimeout (=>
                @timeoutReqeust()
            ), @timeoutDuration

            @beforeRequest()

            # set callback
            options.success = done
            options.error = fail
            options.complete = opts.complete

            # user request관리
            @hasRequest[url] = {}
            @hasRequest[url].reqId = reqId

            @hasRequest[url].request = @hasRequest[reqId] = $.ajax options

            $.ajax options


        deleteCache = (reqId) =>
            delete @hasRequest[reqId]
            delete @requestData[reqId]


        # request refresh access token
        refreshToken: (_callback) ->
            # @sendErrorSlack '[refresh-CALL:' + name + '] current accessToken: '+tokenMgr.getAccessToken()
            @request 'auth/refresh', {
                type: 'POST'
                data: { 'refresh_token': tokenMgr.getRefreshToken() }
                success: (res) =>
                    # @sendErrorSlack '[refresh-RESPONSE:' + name + '] current accessToken: '+tokenMgr.getAccessToken()
                    (_callback && _callback.success) && _callback.success(res)

                error: (res) ->
                    (_callback && _callback.error) && _callback.error(res)

                complete: (res) ->
                    (_callback && _callback.complete) && _callback.complete(res)
                }


        beforeRequest: (options) ->



        fail: (res) ->        


        done: (res, status, response) =>


        timeoutReqeust: ->


        responseInvalidToken: ->


        responseError: (message) ->
            



