window.addEventListener 'load', () ->
    window.environ = environ = {}
    environ.canvas = canvas = document.getElementById('canvas')
    environ.ctx = ctx = canvas.getContext('2d')
    if location.hash == "#editor"
        enableEditor()
        canvas.style.height = "50%"

    environ.mouse = mouse = [0, 0]
    environ.mousemove = (x, y) ->
    environ.mousedown = () ->
    environ.mouseup = () ->
    environ.keydown = (code) ->
    environ.keyup = (code) ->

    canvas.tabIndex = 1
    canvas.addEventListener 'click', (e) -> e.target.focus()

    canvas.addEventListener 'keydown', (e) ->
        environ.keydown(e.keyCode)

    canvas.addEventListener 'keyup', (e) ->
        environ.keyup(e.keyCode)

    document.addEventListener 'mousemove', (e) ->
        rect = canvas.getBoundingClientRect()
        mouse[0] = (e.clientX - rect.left) / rect.width * canvas.width
        mouse[1] = (e.clientY - rect.top) / rect.height * canvas.height
        environ.mousemove(mouse...)

    canvas.addEventListener 'mousedown', (e) ->
        e.preventDefault()
        environ.mousedown(mouse...)

    canvas.addEventListener 'mouseup', (e) ->
        e.preventDefault()
        environ.mouseup(mouse...)

    environ.draw = (t) ->
        environ.clearScreen()
        ctx.fillRect 10, 10 + 20 + Math.sin(t)*20, 10, 10

    environ.clearScreen = () ->
        ctx.clearRect 0, 0, canvas.width, canvas.height
        
    canvas.width = canvas.offsetWidth
    canvas.height = canvas.offsetHeight

    window.addEventListener 'resize', () ->
        canvas.width = canvas.offsetWidth
        canvas.height = canvas.offsetHeight
        environ.draw(Date.now()/1000)

    environ.gameStep = (t) ->

    lastTick = Date.now()/1000
    gameTick = () ->
        currentTick = Date.now()/1000
        setTimeout gameTick, 1000/environ.gameRate
        environ.gameStep(currentTick, currentTick - lastTick)
        lastTick = currentTick
    gameTick()

    draw = () ->
        requestAnimationFrame draw
        environ.draw(Date.now()/1000)
    draw()

    window.startGame()
