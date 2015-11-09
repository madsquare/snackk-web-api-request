require.config(
    baseUrl: '/assets/src'
    waitSeconds: 0
    paths:
        'jquery': '../vendor/jquery.min'
        'jquery-cookie': '../vendor/jquery.cookie.min'
        'jquery-iframe-transport': '../vendor/jquery.iframe-transport'
        'lodash': '../vendor/lodash.compat.min'
    shim:
        'jquery':
            exports: '$'
        'jquery-iframe-transport':
            deps: ['jquery']
        'jquery-cookie': 
            deps: ['jquery']
            exports: '$.fn.cookie'
        'lodash': 
            exports: '_'
)