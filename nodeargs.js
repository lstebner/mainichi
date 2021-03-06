// Generated by CoffeeScript 1.7.1
var NodeArgs;

NodeArgs = (function() {
  function NodeArgs() {
    var arg, sp, _i, _len, _ref;
    this.args = {};
    this.flags = [];
    this.keys = [];
    _ref = process.argv;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      arg = _ref[_i];
      if (arg.indexOf("=") > -1) {
        sp = arg.split("=");
        this.args[sp[0]] = sp[1];
        this.keys.push(sp[0]);
      } else {
        this.args[arg] = 1;
        this.flags.push(arg);
      }
    }
  }

  NodeArgs.prototype.on = function(flag_or_key, fn) {
    var found_flag, found_key;
    if (fn == null) {
      fn = null;
    }
    found_flag = this.flags.indexOf(flag_or_key) > -1;
    found_key = this.keys.indexOf(flag_or_key) > -1;
    if (found_flag) {
      return typeof fn === "function" ? fn() : void 0;
    } else if (found_key) {
      return typeof fn === "function" ? fn(this.args[flag_or_key]) : void 0;
    }
  };

  NodeArgs.prototype.has_flag = function(flag, strict) {
    var f, found_flag, has_flag, _i, _len;
    if (strict == null) {
      strict = false;
    }
    found_flag = flag;
    if (typeof flag === "object") {
      for (_i = 0, _len = flag.length; _i < _len; _i++) {
        f = flag[_i];
        if (!has_flag) {
          has_flag = this.args.hasOwnProperty(f);
          if (has_flag) {
            found_flag = f;
          }
        }
      }
    } else {
      has_flag = this.args.hasOwnProperty(flag);
    }
    if (!has_flag || (has_flag && !strict)) {
      return has_flag;
    }
    return this.args[found_flag] === 1;
  };

  NodeArgs.prototype.has_val = function(key) {
    return this.has_flag(key);
  };

  NodeArgs.prototype.val = function(key) {
    if (this.args.hasOwnProperty(key)) {
      return this.args[key];
    } else {
      return false;
    }
  };

  NodeArgs.prototype.arg_equals = function(key, val) {
    return this.val(key) === val;
  };

  NodeArgs.prototype.data = function() {
    return this.args;
  };

  return NodeArgs;

})();

module.exports = NodeArgs;
