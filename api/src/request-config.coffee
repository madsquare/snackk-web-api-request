require.config(
    baseUrl: '/assets/src'
    waitSeconds: 0
    paths:
        'jquery': '../vendor/jquery.min'
        'jquery-iframe-transport': '../vendor/jquery.iframe-transport'
        'lodash': '../vendor/lodash.compat.min'
    shim:
        'jquery':
            exports: '$'
        'jquery-iframe-transport':
            deps: ['jquery']
        'lodash': 
            exports: '_'
)