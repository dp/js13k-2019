// Generated by CoffeeScript 1.12.5
(function() {
  var Typer;

  Typer = {
    command: null,
    commandPos: 0,
    display: function(commands, callback) {
      this.commands = commands;
      this.callback = callback;
      return this.execNextCommand();
    },
    execNextCommand: function() {
      var command;
      if (this.commands.length === 0) {
        if (typeof this.callback === "function") {
          this.callback();
        }
        return;
      }
      command = this.commands.shift().split(':');
      this.commandText = command[1];
      this.command = command[0];
      this.commandPos = 0;
      return this.execCommand();
    },
    execCommand: function() {
      if (this.command === 'd') {
        Cursor.hide();
        Screen.println(this.commandText);
        return setTimeout(((function(_this) {
          return function() {
            return Typer.execNextCommand();
          };
        })(this)), 50);
      } else if (this.command === 'w') {
        Cursor.show();
        return setTimeout(((function(_this) {
          return function() {
            return Typer.execNextCommand();
          };
        })(this)), parseInt(this.commandText));
      } else if (this.command === 't') {
        Cursor.show();
        if (this.commandPos < this.commandText.length) {
          Screen.print(this.commandText.charAt(this.commandPos));
          this.commandPos += 1;
          return setTimeout(((function(_this) {
            return function() {
              return Typer.execCommand();
            };
          })(this)), 50);
        } else {
          Cursor.newLine();
          return setTimeout(((function(_this) {
            return function() {
              return Typer.execNextCommand();
            };
          })(this)), 800);
        }
      } else if (this.command === 'p') {
        Cursor.hide();
        return setTimeout(((function(_this) {
          return function() {
            return Typer.execNextCommand();
          };
        })(this)), parseInt(this.commandText));
      } else if (this.command === 'x') {
        Screen.clear();
        return setTimeout(((function(_this) {
          return function() {
            return Typer.execNextCommand();
          };
        })(this)), 50);
      } else if (this.command === 'c') {
        Screen.textColour = Colours[this.commandText];
        return setTimeout(((function(_this) {
          return function() {
            return Typer.execNextCommand();
          };
        })(this)), 50);
      }
    },
    clear: function() {
      this.commands = [];
      this.command = null;
      this.commandText = '';
      return this.callback = null;
    }
  };

  window.Typer = Typer;

}).call(this);

//# sourceMappingURL=typer.js.map
