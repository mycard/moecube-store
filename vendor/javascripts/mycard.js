// Generated by CoffeeScript 1.4.0
(function() {

  this.mycard = {};

  this.mycard.room_name = function(name, password, pvp, rule, mode, start_lp, start_hand, draw_count) {
    var result;
    if (pvp == null) {
      pvp = false;
    }
    if (rule == null) {
      rule = 0;
    }
    if (mode == null) {
      mode = 0;
    }
    if (start_lp == null) {
      start_lp = 8000;
    }
    if (start_hand == null) {
      start_hand = 5;
    }
    if (draw_count == null) {
      draw_count = 1;
    }
    if (rule !== 0 || start_lp !== 8000 || start_hand !== 5 || draw_count !== 1) {
      result = "" + rule + mode + "FFF" + start_lp + "," + start_hand + "," + draw_count + ",";
    } else if (mode === 2) {
      result = "T#";
    } else if (pvp && mode === 1) {
      result = "PM#";
    } else if (pvp) {
      result = "P#";
    } else if (mode === 1) {
      result = "M#";
    } else {
      result = "";
    }
    result += name;
    if (password) {
      result += '$' + password;
    }
    return result;
  };

  this.mycard.room_string = function(ip, port, room, username, password, _private, server_auth) {
    var result;
    result = '';
    if (username) {
      result += encodeURIComponent(username);
      if (password) {
        result += ':' + encodeURIComponent(password);
      }
      result += '@';
    }
    result += ip + ':' + port + '/' + encodeURIComponent(room);
    if (_private) {
      result += '?private=true';
      if (server_auth) {
        result += '&server_auth=true';
      }
    } else if (server_auth) {
      result += '?server_auth=true';
    }
    return result;
  };

  this.mycard.room_url = function(ip, port, room, username, password, _private, server_auth) {
    var result;
    return result = 'http://my-card.in/rooms/' + this.room_string(ip, port, room, username, password, _private, server_auth);
  };

  this.mycard.room_url_mycard = function(ip, port, room, username, password, _private, server_auth) {
    var result;
    return result = 'mycard://' + this.room_string(ip, port, room, username, password, _private, server_auth);
  };

  this.mycard.join = function(ip, port, room, username, password, _private, server_auth) {
    return window.location.href = this.room_url_mycard(ip, port, room, username, password, _private, server_auth);
  };

}).call(this);
