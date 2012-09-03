(function() {

  // Expose
  document.querySelectorAll = window.Element.prototype.querySelectorAll = function querySelectorAll(selector) {
    return jQuery.find(selector, this);
  };
  document.querySelector = window.Element.prototype.querySelector = function querySelector(selector) {
    return (document.querySelectorAll.call(this, selector)[0] || null);
  };

}());
