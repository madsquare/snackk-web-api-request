/**
 * snackk-web-api-request module.
 * v1.0.0
 * https://github.com/madsquare/snackk-web-api-request.git
**/
(function (root, factory) {
  if (typeof define === 'function') {
    define(['jquery', 'jquery-cookie', 'jquery-iframe-transport', 'lodash'], factory);
  } else if (typeof exports === 'object') {
    module.exports = factory();
  } else {
    root.request = factory();
  }
}(this, function () {