window.startGame = () ->
    {ctx, canvas} = environ

    environ.messageHide = null
    environ.message = ""

    environ.sendMessage = (message, t) ->
        environ.messageHide = if t? then Date.now()/1000 + t else null
        environ.message = message

# drop dark colors if necessary
    environ.randomColor = (lives) ->
        '#'+Math.floor(Math.random()*16777215).toString(16)

    environ.resetGame = () ->
        environ.score = 0
        
        environ.player = {
            position: [50, 50]
            velocity: [50, 0]
            control: [0, 0]
            speed: 600
            steering: 2000
            dead: false
        }
        
        environ.enemies = [
            {
                position: [150, 150]
                velocity: [150, 150]
                radius: 75
                lives: 7
                active: true
                color: environ.randomColor(10)
            }
        ]
        
        environ.bullets = [
        ]
        
        environ.sendMessage "Destroy it", 4
    environ.resetGame()

    environ.keydown = (code) ->
        switch code
            when 37 then environ.player.control[0] = -1.0
            when 38 then environ.player.control[1] = -1.0
            when 39 then environ.player.control[0] = +1.0
            when 40 then environ.player.control[1] = +1.0

    environ.shootBullet = (player, target) ->
        return if player.dead
        [x, y] = target
        [px, py] = player.position
        dx = x-px
        dy = y-py
        mag = magnitude dx, dy
        if mag > 0
            dx /= mag
            dy /= mag
        
        environ.bullets.push {
            position: [px, py]
            velocity: [dx*500, dy*500]
            t: Date.now()/1000
            hit: false
        }

    environ.keyup = (code) ->
        switch code
            when 37 then environ.player.control[0] = -0.0
            when 38 then environ.player.control[1] = -0.0
            when 39 then environ.player.control[0] = +0.0
            when 40 then environ.player.control[1] = +0.0

    environ.mousedown = (x, y) ->
        environ.shootBullet(environ.player, environ.mouse)

    normalized = (vec) ->
        [x, y] = vec
        if (m = magnitude(x, y)) > 0
            x /= m
            y /= m
        return [x, y]

    environ.enemyGain = 1.2
    environ.deathZone = (position, velocity) ->
        [x, y] = position
        for enemy in environ.enemies
            [px, py] = enemy.position
            [vx, vy] = enemy.velocity
            if magnitude(x - px, y - py) < enemy.radius
                k = magnitude(vx, vy) * environ.enemyGain
                [nx, ny] = normalized(velocity)
                nx += Math.random() - 0.5
                ny += Math.random() - 0.5
                [nx, ny] = normalized([nx, ny])
                enemy.active = false
                environ.score += 1
                return true if enemy.lives <= 1
                environ.enemies.push {
                    position: [px, py]
                    velocity: [-ny*k, nx*k]
                    radius: enemy.radius - 10
                    lives: enemy.lives - 1
                    active: true
                    color: environ.randomColor(enemy.lives - 1)
                }
                environ.enemies.push {
                    position: [px, py]
                    velocity: [ny*k, -nx*k]
                    radius: enemy.radius - 10
                    lives: enemy.lives - 1
                    active: true
                    color: environ.randomColor(enemy.lives - 1)
                }
                return true
        return false

    environ.playerDeathZone = (player) ->
        [x, y] = player.position
        for enemy in environ.enemies
            [px, py] = enemy.position
            [vx, vy] = enemy.velocity
            if magnitude(x - px, y - py) < enemy.radius
                player.dead = true
                environ.sendMessage "Busted. #{environ.score} kills.", 4
                setTimeout environ.resetGame, 4000

    magnitude = (x, y) ->
        return Math.sqrt(x*x + y*y)

    environ.victory = false
    environ.gameStep = (t, dt) ->
        return if environ.player.dead
        return if environ.victory
        if environ.enemies.length == 0
            environ.victory = true
            environ.sendMessage "The end. It took #{environ.score} hits.", null
        
        [x, y]   = environ.mouse
        environ.updatePlayer(environ.player, dt)
        
        for enemy in environ.enemies
            environ.updateEnemy(enemy, dt)
        environ.enemies = environ.enemies.filter (enemy) -> enemy.active
        
        for bullet in environ.bullets
            environ.updateBullet(bullet, dt)
            bullet.hit = environ.deathZone(bullet.position, bullet.velocity)
        environ.bullets = environ.bullets.filter (bullet) -> t < bullet.t + 1 and not bullet.hit
        
        environ.playerDeathZone(environ.player)

    environ.updateEnemy = (enemy, dt) ->
        [px, py] = enemy.position
        [vx, vy] = environ.noEscape(enemy.position, enemy.velocity, enemy.radius)
        radius = enemy.radius

        px += vx * dt
        py += vy * dt
        enemy.velocity = [vx, vy]
        enemy.position = [px, py]

    environ.noEscape = ([px, py], [vx, vy], radius) ->
        if vx < 0 and px - radius < 0
            vx = -vx
        if vx > 0 and canvas.width < px + radius
            vx = -vx

        if vy < 0 and py - radius < 0
            vy = -vy
        if vy > 0 and canvas.height < py + radius
            vy = -vy
        return [vx, vy]

    environ.updateBullet = (bullet, dt) ->
        [px, py] = bullet.position
        [vx, vy] = bullet.velocity
        px += vx * dt
        py += vy * dt
        bullet.velocity = [vx, vy]
        bullet.position = [px, py]
        
    environ.updatePlayer = (player, dt) ->
        [px, py] = player.position
        [vx, vy] = environ.noEscape(player.position, player.velocity, 10)
        [cx, cy] = player.control
        
        #dx = x - px
        #dy = y - py
        #mag = magnitude(dx, dy)
        #sl = 20
        #if mag < sl
        #    dx /= sl
        #    dy /= sl
        #else
        #    dx /= mag
        #    dy /= mag
            
        sx = (cx * player.speed - vx)
        sy = (cy * player.speed - vy)
        smag = magnitude(sx, sy)
        acc = player.steering*dt
        if smag > acc
            sx = sx / smag * acc
            sy = sy / smag * acc
        vx = vx + sx
        vy = vy + sy
        
        px += vx * dt
        py += vy * dt
        player.velocity = [vx, vy]
        player.position = [px, py]


    environ.drawMessage = (t) ->
        return null if environ.messageHide? and environ.messageHide < t
        ctx.textAlign = 'center'
        ctx.fillText environ.message, canvas.width/2, canvas.height/2

    environ.draw = (t) ->
        environ.clearScreen()

        unless environ.player.dead
            [x, y] = environ.mouse
            ctx.fillStyle = 'red'
            environ.fillCircle(x, y, 7)
            ctx.fillStyle = 'white'
            environ.fillCircle(x, y, 5)
            ctx.fillStyle = 'black'
        
            [x,y] = environ.player.position
            environ.fillCircle(x, y, 10+1*Math.sin(t))
        
        ctx.fillStyle = 'black'
        for bullet in environ.bullets
            [x,y] = bullet.position
            environ.fillCircle(x, y, 5)
        
        for enemy in environ.enemies
            [x,y] = enemy.position
            ctx.fillStyle = enemy.color
            environ.fillCircle(x, y, enemy.radius)
        
        ctx.fillStyle = 'black'
        ctx.font = "20px sans-serif"
        environ.drawMessage(t)

    environ.fillCircle = (x, y, radius) ->
        ctx.beginPath()
        ctx.arc(x, y, radius, 0, 2*Math.PI, false)
        ctx.fill()
