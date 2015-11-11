define [
], (
) ->

    _token = null
    _sid = null

    $.cookie.defaults.path = '/'

    Token = {
        TAG: 
            accessToken: 'access_token'
            refreshToken: 'refresh_token'
            remember: 'snackk_remember'
            sid: 'snackk_sid'


        # init token data
        init: (token) ->
            if typeof token != 'undefiend'
                token = {
                    access_token: $.cookie(@TAG.accessToken) || ''
                    refresh_token: $.cookie(@TAG.refreshToken) || ''
                }

            @setToken(token)


        # return access token
        getAccessToken: () ->
            return if _token != null then _token.accessToken else null


        # return refresh token
        getRefreshToken: () ->
            return if _token != null then _token.refreshToken else null


        # return sid
        getSid: () ->
            # init sid
            if _sid == null
                _sid = $.cookie(@TAG.sid) || @generateSid()
                $.cookie @TAG.sid, _sid, { path: '/', expires: 365 }

            return _sid


        # update token data & save to storage
        setToken: (token) ->
            return if token == null || ! token.access_token || ! token.refresh_token
            _token = {
                accessToken: token.access_token
                refreshToken: token.refresh_token
            }

            options = { path: '/' }
            remember = parseInt($.cookie(@TAG.remember) || 0, 10)

            if remember == 1
                options.expires = 7

            $.cookie(@TAG.accessToken, _token.accessToken, options)
            $.cookie(@TAG.refreshToken, _token.refreshToken, options)
            $.cookie(@TAG.remember, remember, options)


        # clear token data
        clear: () ->
            _token = null

            $.removeCookie(@TAG.accessToken)
            $.removeCookie(@TAG.refreshToken)
            $.removeCookie(@TAG.remember)

        
        # enable remember token data
        enableRemember: () ->
            $.cookie(@TAG.remember, 1, { expires: 7 })

            # refresh current token
            @setToken(_token)


        # disable remember token data
        disableRemember: () ->
            $.removeCookie($TAG.remember)

            # refresh current token
            @setToken(_token)

        
        generateSid: () ->
            sid = ""
            map = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
            num = 6

            while num -= 1
                sid += map.charAt(Math.floor(Math.random() * map.length));

            sid

    }