local sounds = {}
la = love.audio

function sounds.play(snd)
	local snd = la.newSource("sounds/" .. snd .. ".wav", "static")
	snd:play()
end

return sounds