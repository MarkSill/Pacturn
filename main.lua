version = "1.0"
lg = love.graphics
lf = love.filesystem
map = nil
entities = nil
ghostPositions = nil
isSuper = false
superTurns = 0
currentTurn = "starting"
moves = 10
score = 0
sound = require("sounds")
restartcount = 340

function love.load()
	math.randomseed(os.time())
	isSuper = false
	superTurns = 0
	currentTurn = "starting"
	moves = math.random(10)
	score = 0
	local items = lf.getDirectoryItems("maps/")
	local m = math.random(#items);
	map = lf.load("maps/" .. items[m])()
	entities = {}
	ghostPositions = {}
	for y = 1, #map do
		for x = 1, #map[y] do
			if map[y][x] == 'c' then
				local entity = makeEntity("pacman", x, y, 0)
				table.insert(entities, entity)
			elseif map[y][x] == 'g' then
				table.insert(ghostPositions, {x, y})
			end
		end
	end
	local numg = 0
	while numg < 4 and #ghostPositions > 0 do
		numg = numg + 1
		local r = math.random(#ghostPositions)
		local entity = makeEntity("ghost", ghostPositions[r][1], ghostPositions[r][2], 0)
		entity.ghost = numg
		table.insert(entities, entity)
		table.remove(ghostPositions, r)
	end
	sound.play("begin")
	restartcount = 300
end

function love.update(dt)
	--this is where the magic happens (not really)
	if currentTurn == "restarting" then
		restartcount = restartcount - 1
		if restartcount <= 0 then
			currentTurn = "waiting"
			restartcount = 340
			sound.play("intermission")
		end
	elseif currentTurn == "waiting" then
		restartcount = restartcount - 1
		if restartcount <= 0 then
			love.load()
		end
	elseif currentTurn == "starting" then
		restartcount = restartcount - 1
		if restartcount <= 0 then
			setTurn("pacman")
		end
	end
end

function love.draw()
	--draw the map itself
	for y = 1, #map do
		for x = 1, #map[y] do
			if map[y][x] == '.' then --dot
				lg.setColor(255, 255, 0)
				lg.circle("fill", x*20, y*20, 2, 100)
			elseif map[y][x] == 's' then --super dot
				lg.setColor(255, 255, 0)
				lg.circle("fill", x*20, y*20, 5, 100)
			elseif map[y][x] == 'h' then --horizontal wall
				lg.setColor(0, 0, 255)
				lg.line(x*20-10, y*20-3, x*20+10, y*20-3)
				lg.line(x*20-10, y*20+3, x*20+10, y*20+3)
			elseif map[y][x] == 'v' then --vertical wall
				lg.setColor(0, 0, 255)
				lg.line(x*20-3, y*20-10, x*20-3, y*20+10)
				lg.line(x*20+3, y*20-10, x*20+3, y*20+10)
			elseif map[y][x] == '1' then --bottom-right corner
				lg.setColor(0, 0, 255)
				lg.line(x*20+10, y*20-3, x*20-3, y*20+10)
				lg.line(x*20+10, y*20+3, x*20+3, y*20+10)
			elseif map[y][x] == '2' then --bottom-left corner
				lg.setColor(0, 0, 255)
				lg.line(x*20-10, y*20-3, x*20+3, y*20+10)
				lg.line(x*20-10, y*20+3, x*20-3, y*20+10)
			elseif map[y][x] == '3' then --top-right corner
				lg.setColor(0, 0, 255)
				lg.line(x*20+10, y*20+3, x*20-3, y*20-10)
				lg.line(x*20+10, y*20-3, x*20+3, y*20-10)
			elseif map[y][x] == '4' then --top-left corner
				lg.setColor(0, 0, 255)
				lg.line(x*20-10, y*20+3, x*20+3, y*20-10)
				lg.line(x*20-10, y*20-3, x*20-3, y*20-10)
			elseif map[y][x] == '5' then --T down
				lg.setColor(0, 0, 255)
				lg.line(x*20-10, y*20-3, x*20+10, y*20-3)
				lg.line(x*20-10, y*20+3, x*20-3, y*20+10)
				lg.line(x*20+10, y*20+3, x*20+3, y*20+10)
			elseif map[y][x] == '6' then --T up
				lg.setColor(0, 0, 255)
				lg.line(x*20-10, y*20+3, x*20+10, y*20+3)
				lg.line(x*20-10, y*20-3, x*20-3, y*20-10)
				lg.line(x*20+10, y*20-3, x*20+3, y*20-10)
			elseif map[y][x] == '7' then --T right
				lg.setColor(0, 0, 255)
				lg.line(x*20-3, y*20-10, x*20-3, y*20+10)
				lg.line(x*20+10, y*20-3, x*20+3, y*20-10)
				lg.line(x*20+10, y*20+3, x*20+3, y*20+10)
			elseif map[y][x] == '8' then --T left
				lg.setColor(0, 0, 255)
				lg.line(x*20+3, y*20-10, x*20+3, y*20+10)
				lg.line(x*20-10, y*20-3, x*20-3, y*20-10)
				lg.line(x*20-10, y*20+3, x*20-3, y*20+10)
			elseif map[y][x] == 'r' then --right ending
				lg.setColor(0, 0, 255)
				lg.line(x*20-10, y*20-3, x*20+8, y*20)
				lg.line(x*20-10, y*20+3, x*20+8, y*20)
			elseif map[y][x] == 'l' then --left ending
				lg.setColor(0, 0, 255)
				lg.line(x*20+10, y*20-3, x*20-8, y*20)
				lg.line(x*20+10, y*20+3, x*20-8, y*20)
			elseif map[y][x] == 'u' then --up ending
				lg.setColor(0, 0, 255)
				lg.line(x*20-3, y*20+10, x*20, y*20-8)
				lg.line(x*20+3, y*20+10, x*20, y*20-8)
			elseif map[y][x] == 'd' then --down ending
				lg.setColor(0, 0, 255)
				lg.line(x*20-3, y*20-10, x*20, y*20+8)
				lg.line(x*20+3, y*20-10, x*20, y*20+8)
			elseif map[y][x] == '9' then --horizontal ghost door
				lg.setColor(255, 0, 0)
				lg.line(x*20-12, y*20, x*20+12, y*20)
			end
		end
	end
	--draw the entities
	local pacman = nil
	for _, v in pairs(entities) do
		if v.type == "pacman" then
			if isSuper then
				lg.setColor(math.random(255), math.random(255), math.random(255))
			else
				lg.setColor(255, 255, 0)
			end
			drawPacman(v.pos[1], v.pos[2], v.rot)

		elseif "ghost" then
			local n = v.ghost
			if n == 1 then
				lg.setColor(255, 0, 0)
				secondColor = {255, 0, 0}
			elseif n == 2 then
				lg.setColor(255, 0, 128)
				secondColor = {255, 0, 128}
			elseif n == 3 then
				lg.setColor(0, 255, 255)
				secondColor = {0, 255, 255}
			elseif n == 4 then
				lg.setColor(255, 200, 0)
				secondColor = {255, 200, 0}
			end
			if isSuper then
				lg.setColor(0, 0, 255)
			end
			drawGhost(v.pos[1], v.pos[2], v.rot)
		end
	end
	--draw the ui
	local str = ""
	local s = "S"
	if currentTurn == "pacman" then
		lg.setColor(255, 255, 0)
		str = "PAK"
	elseif currentTurn == "ghost1" then
		lg.setColor(255, 0, 0)
		str = "STROBE"
	elseif currentTurn == "ghost2" then
		lg.setColor(255, 0, 128)
		str = "GONZALES"
		s = ""
	elseif currentTurn == "ghost3" then
		lg.setColor(0, 255, 255)
		str = "MARKER"
	elseif currentTurn == "ghost4" then
		lg.setColor(255, 200, 0)
		str = "CLIVE"
	end
	lg.print(str .. "'" .. s .. " TURN!", 450, 50, math.rad(10))
	lg.print(moves .. " MOVES REMAINING", 450, 65, math.rad(10))
	lg.setColor(255, 255, 0)
	lg.print("SCORE: " .. score .. " POINTS", 450, 80, math.rad(10))

end

function love.keypressed(key)
	if currentTurn == "pacman" then
		local pacman = nil
		for _, v in pairs(entities) do
			if v.type == "pacman" then
				pacman = v
				break
			end
		end
		if key == "w" or key == "up" then
			move(pacman, 'y', -1)
		elseif key == "s" or key == "down" then
			move(pacman, 'y', 1)
		elseif key == "a" or key == "left" then
			move(pacman, 'x', -1)
		elseif key == "d" or key == "right" then
			move(pacman, 'x', 1)
		end
		if superTurns <= 0 then
			isSuper = false
		end
		if moves <= 0 then
			setTurn("ghost1")
			superTurns = superTurns - 1
		end
	elseif string.sub(currentTurn, 1, 5) == "ghost" then
		local n = string.sub(currentTurn, 6)
		local ghost = nil
		for _, v in pairs(entities) do
			if v.type == "ghost" and v.ghost == tonumber(n) then
				ghost = v
			end
		end
		if key == "w" or key == "up" then
			move(ghost, 'y', -1)
		elseif key == "s" or key == "down" then
			move(ghost, 'y', 1)
		elseif key == "a" or key == "left" then
			move(ghost, 'x', -1)
		elseif key == "d" or key == "right" then
			move(ghost, 'x', 1)
		end
		if moves <= 0 then
			if tonumber(n) < 4 then
				setTurn("ghost" .. tonumber(n)+1)
			else
				setTurn("pacman")
			end
		end
	end
end

function love.keyreleased(key)

end

function makeEntity(etype, posx, posy, rot)
	local entity = {}
	entity.type = etype
	entity.pos = {posx, posy}
	entity.rot = rot
	return entity
end

function drawPacman(x, y, rot)
	x = x*20
	y = y*20
	lg.circle("fill", x, y, 10, 100)
	lg.setColor(0, 0, 0)
	local coords = {}
	if rot == 0 then
		coords = {x+10, y-10, x+10, y+10, x, y}
	elseif rot == 90 then
		coords = {x-10, y-10, x+10, y-10, x, y}
	elseif rot == 180 then
		coords = {x-10, y-10, x-10, y+10, x, y}
	elseif rot == 270 then
		coords = {x-10, y+10, x+10, y+10, x, y}
	end
	lg.polygon("fill", coords)
end

function drawGhost(x, y, rot)
	x = x*20
	y = y*20
	lg.circle("fill", x, y, 10, 100)
	lg.rectangle("fill", x-10, y, 20, 10)
	lg.setColor(secondColor)
	lg.circle("fill", x-5, y-5, 2, 100)
	lg.circle("fill", x+5, y-5, 2, 100)
end

function move(entity, xORy, amnt)
	local posx = entity.pos[1]
	local posy = entity.pos[2]
	local newx = nil
	local newy = nil
	if xORy == 'y' then
		newx = posx
		newy = posy + amnt
		if amnt > 0 then
			entity.rot = 270
		elseif amnt < 0 then
			entity.rot = 90
		end
	else
		newx = posx + amnt
		newy = posy
		if amnt > 0 then
			entity.rot = 0
		elseif amnt < 0 then
			entity.rot = 180
		end
	end
	if map[newy][newx] ~= '.' and map[newy][newx] ~= ' ' and map[newy][newx] ~= 's' and map[newy][newx] ~= 'c' then
		if entity.type == "ghost" and (map[newy][newx] == 'g' or map[newy][newx] == '9') then
			--do nothing
		else
			newx = posx
			newy = posy
		end
	end
	if entity.type == "pacman" then
		if map[newy][newx] == '.' then
			map[newy][newx] = ' '
			score = score + 10
			sound.play("chomp")
		elseif map[newy][newx] == 's' then
			map[newy][newx] = ' '
			score = score + 50
			isSuper = true
			superTurns = 5
			sound.play("chomp")
		end
	end
	if newx == posx and newy == posy then
		return false
	end
	moves = moves - 1
	entity.pos = {newx, newy}
	for _, v in pairs(entities) do
		if v.pos[1] == entity.pos[1] and v.pos[2] == entity.pos[2] then
			if (v.type == "ghost" and entity.type == "pacman") or (v.type == "pacman" and entity.type == "ghost") then
				if not isSuper then
					sound.play("death")
					currentTurn = "restarting"
					restartcount = 120
				else
					sound.play("eatghost")
					if v.type == "ghost" then
						for y = 1, #map do
							for x = 1, #map[y] do
								if map[y][x] == 'g' then
									v.pos = {x, y}
								end
							end
						end
					elseif entity.type == "ghost" then
						for y = 1, #map do
							for x = 1, #map[y] do
								if map[y][x] == 'g' then
									entity.pos = {x, y}
								end
							end
						end
						moves = 0
					end
				end
			end
		end
	end
	return true
end

function setTurn(player)
	currentTurn = player
	if player == "pacman" then
		moves = math.random(10)
	elseif string.sub(player, 1, 5) == "ghost" then
		moves = math.random(6)
	end
end

function reload()
	love.load()
end
