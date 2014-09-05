// Generated by CoffeeScript 1.6.3
(function() {
  window.addEventListener('load', function() {
    var canvas, ctx, draw, environ, gameTick, lastTick, mouse;
    window.environ = environ = {};
    environ.canvas = canvas = document.getElementById('canvas');
    environ.ctx = ctx = canvas.getContext('2d');
    if (location.hash === "#editor") {
      enableEditor();
      canvas.style.height = "50%";
    }
    environ.mouse = mouse = [0, 0];
    environ.mousemove = function(x, y) {};
    environ.mousedown = function() {};
    environ.mouseup = function() {};
    environ.keydown = function(code) {};
    environ.keyup = function(code) {};
    canvas.tabIndex = 1;
    canvas.addEventListener('click', function(e) {
      return e.target.focus();
    });
    canvas.addEventListener('keydown', function(e) {
      return environ.keydown(e.keyCode);
    });
    canvas.addEventListener('keyup', function(e) {
      return environ.keyup(e.keyCode);
    });
    document.addEventListener('mousemove', function(e) {
      var rect;
      rect = canvas.getBoundingClientRect();
      mouse[0] = (e.clientX - rect.left) / rect.width * canvas.width;
      mouse[1] = (e.clientY - rect.top) / rect.height * canvas.height;
      return environ.mousemove.apply(environ, mouse);
    });
    canvas.addEventListener('mousedown', function(e) {
      e.preventDefault();
      return environ.mousedown.apply(environ, mouse);
    });
    canvas.addEventListener('mouseup', function(e) {
      e.preventDefault();
      return environ.mouseup.apply(environ, mouse);
    });
    environ.draw = function(t) {
      environ.clearScreen();
      return ctx.fillRect(10, 10 + 20 + Math.sin(t) * 20, 10, 10);
    };
    environ.clearScreen = function() {
      return ctx.clearRect(0, 0, canvas.width, canvas.height);
    };
    canvas.width = canvas.offsetWidth;
    canvas.height = canvas.offsetHeight;
    window.addEventListener('resize', function() {
      canvas.width = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
      return environ.draw(Date.now() / 1000);
    });
    environ.gameStep = function(t) {};
    lastTick = Date.now() / 1000;
    gameTick = function() {
      var currentTick;
      currentTick = Date.now() / 1000;
      setTimeout(gameTick, 1000 / environ.gameRate);
      environ.gameStep(currentTick, currentTick - lastTick);
      return lastTick = currentTick;
    };
    gameTick();
    draw = function() {
      requestAnimationFrame(draw);
      return environ.draw(Date.now() / 1000);
    };
    draw();
    return window.startGame();
  });

}).call(this);