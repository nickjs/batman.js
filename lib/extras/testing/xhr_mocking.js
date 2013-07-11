(function() {
  Batman.XhrMocking = {
    xhrSetup: function() {
      var testCase;
      testCase = this;
      this._requests = {};
      this._savedSend = Batman.Request.prototype.send;
      return Batman.Request.prototype.send = function(data) {
        var beforeResponse, mockedResponse, response, status;
        data || (data = this.get('data'));
        this.fire('loading');
        mockedResponse = testCase.fetchMockedResponse(this.get('url'), this.get('method'));
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
    },
    xhrTeardown: function() {
      return Batman.Request.prototype.send = this._savedSend;
    },
    fetchMockedResponse: function(url, method) {
      var expectationCallback, id;
      id = "" + method + "::" + url;
      expectationCallback = this._requests[id];
      if (!expectationCallback) {
        return;
      }
      delete this._requests[id];
      return expectationCallback();
    },
    setMockedResponse: function(url, method, cb) {
      return this._requests["" + method + "::" + url] = cb;
    },
    assertGET: function(url, params) {
      return this._assertXHR('GET', url, params);
    },
    assertPOST: function(url, params) {
      return this._assertXHR('POST', url, params);
    },
    assertPUT: function(url, params) {
      return this._assertXHR('PUT', url, params);
    },
    assertDELETE: function(url, params) {
      return this._assertXHR('DELETE', url, params);
    },
    _assertXHR: function(method, url, params) {
      var id,
        _this = this;
      id = "" + method + " to " + url;
      this.addExpectation(id);
      return this.setMockedResponse(url, method, function() {
        _this.completeExpectation(id);
        params || (params = {});
        params.status || (params.status = 200);
        params.response || (params.response = {});
        return params;
      });
    }
  };

}).call(this);
