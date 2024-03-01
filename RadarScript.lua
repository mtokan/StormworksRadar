w = 64
h = 64
maxDistance = 500
minDistance = 50
targets = {}
targetDisplayDuration = 60

-- Tick function that will be executed every logic tick
function onTick()
	radarRotation = input.getNumber(29)
	radarRotationRadian = math.rad(radarRotation*360)

	-- sweep line
	x1 = w/2 + 32 * math.cos(math.rad(-90)+radarRotationRadian)
	y1 = h/2 + 32 * math.sin(math.rad(-90)+radarRotationRadian)

	-- Decrement timers and remove expired targets
    for i = #targets, 1, -1 do
        targets[i].timer = targets[i].timer - 1
        if targets[i].timer <= 0 then
            table.remove(targets, i)
        end
    end

	-- get target information
	for i = 1, 7 do
		if input.getBool(i) then
			distance = input.getNumber(1 + (i - 1) * 4)
			yaw = input.getNumber(2 + (i - 1) * 4)

			if distance > minDistance then
				yawAngle = math.rad(yaw*360)
				distancePixel = (distance/maxDistance) * 32

				x2 = w/2 + distancePixel * math.sin(yawAngle)
				y2 = w/2 - distancePixel * math.cos(yawAngle)

				table.insert(targets, {x = x2, y = y2, timer = targetDisplayDuration})
			end
		end
	end

end

-- Draw function that will be executed when this script renders to a screen
function onDraw()
    local sweepWidthDegrees = 100 -- Total width of the sweep area in degrees
    local numLines = 100 -- Number of lines to simulate the sweep area
	local maxOpacity = 200 -- Maximum opacity
	local minOpacity = 50 -- Minimum opacity
    local opacityDelta = (maxOpacity - minOpacity) / numLines



	-- draw radar display lines,circles
	screen.setColor(3,86,102,100)
	screen.drawRectF(0,0, 64, 64)
	screen.setColor(3,86,102)
	screen.drawCircle(w/2,h/2,32)
	screen.drawCircle(w/2,h/2,24)
	screen.drawCircle(w/2,h/2,16)
	screen.drawCircle(w/2,h/2,8)
	screen.drawLine(0,h/2,w,h/2)
	screen.drawLine(w/2,0,w/2,h)

	-- Calculate the angular width of each line in the sweep area
    local lineAngularWidth = math.rad(sweepWidthDegrees / numLines)

	for i = 0, numLines - 1 do

    	-- Calculate start and end angle for each line
        local angleStart = radarRotationRadian - math.rad(sweepWidthDegrees) / 2 + (i * lineAngularWidth)
        local angleEnd = angleStart + lineAngularWidth

        -- Calculate start and end points for each line based on its angle
        local xStart = w / 2
        local yStart = h / 2
        local xEnd = w / 2 + 32 * math.cos(angleEnd)
        local yEnd = h / 2 + 32 * math.sin(angleEnd)

        -- Set color with increasing opacity for each successive line
        local opacity = minOpacity + (opacityDelta * i)
        screen.setColor(3, 86, 102, math.floor(opacity))

        screen.drawLine(xStart, yStart, xEnd, yEnd)
    end

	-- draw targets
	if next(targets) ~= nil then
		for _, target in ipairs(targets) do

		    -- Calculate alpha based on the remaining timer
        	local alpha = math.floor((target.timer / targetDisplayDuration) * 255)

        	-- Ensure alpha does not drop below a minimum visibility threshold
			alpha = math.max(alpha, 50)

            screen.setColor(255,0,0,alpha)
            screen.drawCircleF(target.x, target.y, 2)
        end
	end

end