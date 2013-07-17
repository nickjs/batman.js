(function() {
  Batman.Request.setupMockedResponse = function() {
    return Batman.Request.mockedResponses = {};
  };

  Batman.Request.addMockedResponse = function(method, url, callback) {
    var _base, _name;
    (_base = Batman.Request.mockedResponses)[_name = "" + method + "::" + url] || (_base[_name] = []);
    return Batman.Request.mockedResponses["" + method + "::" + url].push(callback);
  };

  Batman.Request.fetchMockedResponse = function(method, url) {
    var callback, callbackList, _ref;
    callbackList = (_ref = Batman.Request.mockedResponses) != null ? _ref["" + method + "::" + url] : void 0;
    if (!callbackList || callbackList.length === 0) {
      return;
    }
    callback = callbackList.pop();
    return callback();
  };

  Batman.Request.prototype.send = function(data) {
    var beforeResponse, mockedResponse, response, status;
    data || (data = this.get('data'));
    this.fire('loading');
    mockedResponse = Batman.Request.fetchMockedResponse(this.get('method'), this.get('url'));
    if (!mockedResponse) {
      return;
    }
    status = mockedResponse.status, response = mockedResponse.response, beforeResponse = mockedResponse.beforeResponse;
    this.mixin({
      status: status,
      response: JSON.stringify(response)
    });
    if (typeof beforeResponse === "function") {
      beforeResponse(this);
    }
    if (status < 400) {
      this.fire('success', response);
    } else {
      this.fire('error', {
        response: response,
        status: status,
        request: this
      });
    }
    return this.fire('loaded');
  };

}).call(this);
