-- aseprite_backgrounds.lua
-- Generate 8 location backgrounds at 320x180 for King of Chicago
-- Noir pixel art cityscapes

local OUTPUT_DIR = "/Users/fcp/King of chicago/king_of_chicago/assets/backgrounds/"

local function rgba(r, g, b, a)
  return app.pixelColor.rgba(r, g, b, a or 255)
end

local function px(img, x, y, color)
  if x >= 0 and x < img.width and y >= 0 and y < img.height then
    img:drawPixel(x, y, color)
  end
end

local function fillRect(img, x1, y1, x2, y2, color)
  for y = math.max(0, y1), math.min(img.height - 1, y2) do
    for x = math.max(0, x1), math.min(img.width - 1, x2) do
      img:drawPixel(x, y, color)
    end
  end
end

local function drawLine(img, x0, y0, x1, y1, color)
  local dx = math.abs(x1 - x0)
  local dy = math.abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local err = dx - dy
  while true do
    px(img, x0, y0, color)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 > -dy then err = err - dy; x0 = x0 + sx end
    if e2 < dx then err = err + dx; y0 = y0 + sy end
  end
end

local function fillEllipse(img, cx, cy, rx, ry, color)
  for y = cy - ry, cy + ry do
    for x = cx - rx, cx + rx do
      local dxx = (x - cx) / rx
      local dyy = (y - cy) / ry
      if dxx * dxx + dyy * dyy <= 1.0 then
        px(img, x, y, color)
      end
    end
  end
end

-- Sky gradient
local function drawSkyGradient(img, topR, topG, topB, botR, botG, botB, horizonY)
  for y = 0, horizonY do
    local t = y / horizonY
    local r = math.floor(topR + (botR - topR) * t)
    local g = math.floor(topG + (botG - topG) * t)
    local b = math.floor(topB + (botB - topB) * t)
    for x = 0, img.width - 1 do
      img:drawPixel(x, y, rgba(r, g, b))
    end
  end
end

-- Stars
local function drawStars(img, count, maxY)
  math.randomseed(42)
  for _ = 1, count do
    local x = math.random(0, img.width - 1)
    local y = math.random(0, maxY)
    local brightness = math.random(60, 140)
    px(img, x, y, rgba(brightness, brightness, brightness + 20))
  end
end

-- Rain effect
local function drawRain(img, density)
  math.randomseed(123)
  for _ = 1, density do
    local x = math.random(0, img.width - 1)
    local y = math.random(0, img.height - 1)
    px(img, x, y, rgba(85, 85, 85))
    px(img, x + 1, y + 1, rgba(70, 70, 70))
  end
end

-- Window lights on a building
local function drawWindows(img, bx, by, bw, bh, color, density)
  math.randomseed(bx * 100 + by)
  for wy = by + 4, by + bh - 4, 6 do
    for wx = bx + 3, bx + bw - 4, 5 do
      if math.random() < density then
        fillRect(img, wx, wy, wx + 1, wy + 2, color)
      end
    end
  end
end

-- Streetlamp with glow
local function drawStreetlamp(img, x, groundY, glowColor, poleColor)
  -- Pole
  for y = groundY - 40, groundY do
    px(img, x, y, poleColor)
  end
  -- Lamp head
  fillRect(img, x - 2, groundY - 42, x + 2, groundY - 40, glowColor)
  -- Glow halo (radial)
  for dy = -12, 12 do
    for dx = -12, 12 do
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist < 12 and dist > 2 then
        local alpha = math.floor(80 * (1 - dist / 12))
        local gr = app.pixelColor.rgbaR(glowColor)
        local gg = app.pixelColor.rgbaG(glowColor)
        local gb = app.pixelColor.rgbaB(glowColor)
        local gx, gy = x + dx, groundY - 42 + dy
        if gx >= 0 and gx < img.width and gy >= 0 and gy < img.height then
          local existing = img:getPixel(gx, gy)
          local er = app.pixelColor.rgbaR(existing)
          local eg = app.pixelColor.rgbaG(existing)
          local eb = app.pixelColor.rgbaB(existing)
          local t = alpha / 255
          local nr = math.min(255, math.floor(er + (gr - er) * t))
          local ng = math.min(255, math.floor(eg + (gg - eg) * t))
          local nb = math.min(255, math.floor(eb + (gb - eb) * t))
          px(img, gx, gy, rgba(nr, ng, nb))
        end
      end
    end
  end
end

-- Building silhouette
local function drawBuilding(img, x, topY, w, groundY, dark, mid)
  fillRect(img, x, topY, x + w, groundY, dark)
  -- Slight edge highlight
  for y = topY, groundY do
    px(img, x, y, mid)
    px(img, x + w, y, mid)
  end
  drawLine(img, x, topY, x + w, topY, mid)
end

local function createBG(name, drawFunc)
  app.command.NewFile{ width=320, height=180, colorMode=ColorMode.RGB }
  local spr = app.activeSprite
  local img = app.activeCel.image
  drawFunc(img)
  spr:saveCopyAs(OUTPUT_DIR .. name .. ".png")
  spr:close()
  print("Exported: " .. name .. ".png")
end

------------------------------------------------------------------------
-- SOUTH SIDE - Night, rain, brownstones
------------------------------------------------------------------------
local function drawSouthSide(img)
  drawSkyGradient(img, 10, 10, 15, 21, 21, 32, 120)
  drawStars(img, 30, 60)

  local groundY = 140
  local streetColor = rgba(12, 12, 16)
  fillRect(img, 0, groundY, 319, 179, streetColor)

  -- Buildings (brownstones, varying heights)
  local buildings = {
    {x=0, h=70, w=40}, {x=42, h=85, w=35}, {x=79, h=60, w=38},
    {x=119, h=90, w=32}, {x=153, h=55, w=45}, {x=200, h=80, w=36},
    {x=238, h=65, w=42}, {x=282, h=75, w=38}
  }
  for _, b in ipairs(buildings) do
    local topY = groundY - b.h
    drawBuilding(img, b.x, topY, b.w, groundY, rgba(18, 16, 14), rgba(28, 24, 20))
    drawWindows(img, b.x, topY, b.w, b.h, rgba(200, 170, 80), 0.35)
  end

  -- Streetlamp
  drawStreetlamp(img, 160, groundY, rgba(210, 180, 80), rgba(50, 45, 35))

  -- Wet street reflections
  math.randomseed(999)
  for y = groundY + 2, 179 do
    for x = 0, 319 do
      local above = img:getPixel(x, groundY - (y - groundY))
      local r = app.pixelColor.rgbaR(above)
      local g = app.pixelColor.rgbaG(above)
      local b = app.pixelColor.rgbaB(above)
      if r > 50 or g > 50 then
        if math.random() < 0.15 then
          px(img, x, y, rgba(math.floor(r * 0.3), math.floor(g * 0.3), math.floor(b * 0.3)))
        end
      end
    end
  end

  -- Rain
  drawRain(img, 400)

  -- Sidewalk line
  drawLine(img, 0, groundY, 319, groundY, rgba(30, 28, 24))
end

------------------------------------------------------------------------
-- LITTLE ITALY - Narrow street, laundry, warm
------------------------------------------------------------------------
local function drawLittleItaly(img)
  drawSkyGradient(img, 12, 10, 15, 25, 22, 28, 110)
  drawStars(img, 20, 50)

  local groundY = 145
  fillRect(img, 0, groundY, 319, 179, rgba(15, 13, 11))

  -- Narrow buildings (closer, taller relative to width)
  local leftBuildings = {
    {x=0, h=100, w=55}, {x=57, h=110, w=45}, {x=104, h=95, w=50}
  }
  local rightBuildings = {
    {x=170, h=105, w=48}, {x=220, h=115, w=50}, {x=272, h=100, w=48}
  }
  for _, b in ipairs(leftBuildings) do
    drawBuilding(img, b.x, groundY - b.h, b.w, groundY, rgba(22, 18, 14), rgba(35, 28, 22))
    drawWindows(img, b.x, groundY - b.h, b.w, b.h, rgba(210, 175, 90), 0.5)
  end
  for _, b in ipairs(rightBuildings) do
    drawBuilding(img, b.x, groundY - b.h, b.w, groundY, rgba(24, 20, 16), rgba(38, 30, 24))
    drawWindows(img, b.x, groundY - b.h, b.w, b.h, rgba(210, 175, 90), 0.5)
  end

  -- Gap between buildings (narrow street perspective)
  fillRect(img, 154, 40, 169, groundY, rgba(14, 12, 18))

  -- Laundry lines
  local laundryColors = {
    rgba(180, 60, 50), rgba(80, 120, 180), rgba(220, 200, 140),
    rgba(140, 180, 80), rgba(200, 100, 80)
  }
  math.randomseed(77)
  for lineY = 55, 85, 15 do
    drawLine(img, 55, lineY, 170, lineY, rgba(60, 55, 45))
    for lx = 60, 165, 8 do
      if math.random() < 0.7 then
        local c = laundryColors[math.random(1, #laundryColors)]
        fillRect(img, lx, lineY + 1, lx + 2, lineY + 4, c)
      end
    end
  end

  -- Shop sign (illuminated)
  fillRect(img, 60, groundY - 20, 95, groundY - 12, rgba(180, 140, 60))
  fillRect(img, 62, groundY - 18, 93, groundY - 14, rgba(140, 100, 40))
  -- Squiggly text
  for tx = 64, 90, 2 do
    px(img, tx, groundY - 16, rgba(60, 45, 20))
  end

  -- Streetlamp
  drawStreetlamp(img, 162, groundY, rgba(200, 165, 75), rgba(45, 38, 28))

  drawLine(img, 0, groundY, 319, groundY, rgba(32, 28, 22))
end

------------------------------------------------------------------------
-- THE LOOP - Wide avenue, skyscrapers, neon, art deco
------------------------------------------------------------------------
local function drawTheLoop(img)
  drawSkyGradient(img, 8, 8, 14, 18, 18, 28, 130)
  drawStars(img, 15, 40)

  local groundY = 150
  fillRect(img, 0, groundY, 319, 179, rgba(16, 14, 18))

  -- Tall skyscrapers with art deco tops
  local skyscrapers = {
    {x=0, h=140, w=30}, {x=32, h=120, w=35}, {x=70, h=150, w=28},
    {x=100, h=130, w=32}, {x=140, h=145, w=25},
    {x=180, h=125, w=35}, {x=218, h=155, w=30}, {x=250, h=135, w=32},
    {x=284, h=140, w=36}
  }
  for _, b in ipairs(skyscrapers) do
    local topY = groundY - b.h
    if topY < 0 then topY = 0 end
    drawBuilding(img, b.x, topY, b.w, groundY, rgba(14, 13, 16), rgba(22, 20, 25))
    drawWindows(img, b.x, topY, b.w, b.h, rgba(220, 200, 120), 0.4)

    -- Art deco stepped tops (ziggurat)
    local step = 4
    for s = 1, 3 do
      local sx = b.x + s * step
      local sw = b.w - s * step * 2
      if sw > 2 then
        fillRect(img, sx, topY - s * 3, sx + sw, topY - (s - 1) * 3, rgba(18, 16, 20))
        drawLine(img, sx, topY - s * 3, sx + sw, topY - s * 3, rgba(30, 28, 35))
      end
    end
  end

  -- Neon signs
  fillRect(img, 105, 60, 130, 68, rgba(220, 40, 40))  -- Red neon
  fillRect(img, 106, 61, 129, 67, rgba(180, 30, 30))
  -- Neon glow (red sign)
  for dy = -3, 3 do
    for dx = -3, 3 do
      local dist = math.abs(dx) + math.abs(dy)
      if dist > 0 and dist < 5 then
        for nx = 105, 130 do
          local gx = nx + dx
          local gy = 64 + dy
          if gx >= 0 and gx < 320 and gy >= 0 and gy < 180 then
            local ep = img:getPixel(gx, gy)
            local er = app.pixelColor.rgbaR(ep)
            px(img, gx, gy, rgba(math.min(255, er + 30), 20, 20))
          end
        end
      end
    end
  end

  -- Green neon sign
  fillRect(img, 220, 50, 245, 56, rgba(40, 200, 60))
  fillRect(img, 221, 51, 244, 55, rgba(30, 160, 45))

  -- Elevated train track
  drawLine(img, 0, 100, 319, 100, rgba(40, 38, 35))
  drawLine(img, 0, 102, 319, 102, rgba(40, 38, 35))
  -- Train cars
  fillRect(img, 60, 94, 100, 100, rgba(50, 48, 42))
  fillRect(img, 102, 94, 140, 100, rgba(48, 46, 40))
  -- Train windows
  for wx = 64, 96, 6 do
    fillRect(img, wx, 95, wx + 2, 98, rgba(200, 190, 120))
  end

  -- Support pillars for train
  for px_x = 20, 300, 40 do
    drawLine(img, px_x, 102, px_x, groundY, rgba(35, 33, 30))
  end

  -- Street is wider, brighter
  fillRect(img, 0, groundY, 319, 155, rgba(25, 23, 28))
  drawLine(img, 0, groundY, 319, groundY, rgba(40, 38, 35))
end

------------------------------------------------------------------------
-- NORTH SIDE - Docks/waterfront, fog, industrial
------------------------------------------------------------------------
local function drawNorthSide(img)
  drawSkyGradient(img, 8, 10, 18, 16, 20, 32, 100)
  drawStars(img, 10, 40)

  local waterY = 120
  local groundY = 115

  -- Water (bottom third)
  for y = waterY, 179 do
    local t = (y - waterY) / 60
    local r = math.floor(8 + 6 * t)
    local g = math.floor(12 + 8 * t)
    local b = math.floor(28 + 12 * t)
    for x = 0, 319 do
      img:drawPixel(x, y, rgba(r, g, b))
    end
  end

  -- Water reflections (horizontal bright pixels)
  math.randomseed(55)
  for y = waterY + 2, 179, 3 do
    for _ = 1, 8 do
      local x = math.random(0, 319)
      local len = math.random(3, 12)
      for lx = x, x + len do
        if math.random() < 0.5 then
          px(img, lx, y, rgba(25, 35, 55))
        end
      end
    end
  end

  -- Industrial buildings on shore
  drawBuilding(img, 10, 40, 60, groundY, rgba(16, 15, 18), rgba(24, 22, 26))
  drawBuilding(img, 75, 55, 45, groundY, rgba(18, 16, 20), rgba(26, 24, 28))
  drawBuilding(img, 200, 45, 50, groundY, rgba(16, 15, 18), rgba(24, 22, 26))
  drawBuilding(img, 255, 60, 65, groundY, rgba(18, 16, 20), rgba(26, 24, 28))
  drawWindows(img, 10, 40, 60, 75, rgba(160, 145, 90), 0.2)
  drawWindows(img, 200, 45, 50, 70, rgba(160, 145, 90), 0.2)

  -- Cranes (angular shapes)
  -- Crane 1
  drawLine(img, 130, 20, 130, groundY, rgba(30, 28, 32))
  drawLine(img, 130, 20, 170, 35, rgba(30, 28, 32))
  drawLine(img, 130, 20, 110, 35, rgba(30, 28, 32))
  drawLine(img, 170, 35, 170, 60, rgba(28, 26, 30))
  -- Crane 2
  drawLine(img, 280, 30, 280, groundY, rgba(30, 28, 32))
  drawLine(img, 280, 30, 310, 42, rgba(30, 28, 32))
  drawLine(img, 280, 30, 260, 42, rgba(30, 28, 32))

  -- Ship silhouette
  fillRect(img, 140, waterY - 5, 195, waterY + 5, rgba(12, 11, 15))
  -- Hull curve
  for x = 135, 200 do
    local dx = (x - 167) / 35
    local dy = math.floor(3 * dx * dx)
    fillRect(img, x, waterY + 2, x, waterY + 2 + dy, rgba(12, 11, 15))
  end
  -- Cabin
  fillRect(img, 158, waterY - 15, 178, waterY - 5, rgba(15, 14, 18))
  -- Smokestack
  fillRect(img, 165, waterY - 22, 170, waterY - 15, rgba(18, 16, 20))

  -- Fog / mist bands
  for y = 85, 115, 8 do
    for x = 0, 319 do
      if math.random() < 0.3 then
        px(img, x, y, rgba(22, 25, 32))
        px(img, x, y + 1, rgba(20, 23, 30))
      end
    end
  end
end

------------------------------------------------------------------------
-- WEST SIDE - Desolate, dangerous, burned buildings
------------------------------------------------------------------------
local function drawWestSide(img)
  drawSkyGradient(img, 6, 6, 10, 14, 14, 18, 120)
  drawStars(img, 8, 50)

  local groundY = 145
  fillRect(img, 0, groundY, 319, 179, rgba(10, 9, 8))

  -- Damaged/burned buildings with jagged rooflines
  local buildings = {
    {x=10, h=80, w=45, damage=true},
    {x=60, h=65, w=35, damage=true},
    {x=120, h=90, w=40, damage=false},
    {x=200, h=70, w=50, damage=true},
    {x=260, h=85, w=55, damage=true}
  }
  for _, b in ipairs(buildings) do
    local topY = groundY - b.h
    drawBuilding(img, b.x, topY, b.w, groundY, rgba(12, 11, 10), rgba(18, 16, 14))
    -- Dark/empty windows
    drawWindows(img, b.x, topY, b.w, b.h, rgba(6, 5, 4), 0.4)

    if b.damage then
      -- Jagged roofline
      math.randomseed(b.x * 7)
      for jx = b.x, b.x + b.w, 3 do
        local jag = math.random(-6, 2)
        if jag < 0 then
          fillRect(img, jx, topY + jag, jx + 2, topY, rgba(6, 6, 10))
        end
      end
    end
  end

  -- Empty lot in foreground
  fillRect(img, 90, groundY + 5, 190, 165, rgba(8, 7, 6))
  -- Sparse ground detail
  math.randomseed(333)
  for _ = 1, 20 do
    local x = math.random(0, 319)
    local y = math.random(groundY, 179)
    px(img, x, y, rgba(16, 14, 12))
  end

  -- Distant fire (orange glow)
  local fireX, fireY = 240, groundY - 30
  fillRect(img, fireX - 2, fireY - 5, fireX + 2, fireY, rgba(200, 100, 20))
  fillRect(img, fireX - 1, fireY - 8, fireX + 1, fireY - 5, rgba(220, 140, 30))
  px(img, fireX, fireY - 10, rgba(240, 180, 40))
  -- Fire glow
  for dy = -15, 15 do
    for dx = -15, 15 do
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist < 15 and dist > 3 then
        local alpha = (1 - dist / 15) * 0.15
        local gx, gy = fireX + dx, fireY - 2 + dy
        if gx >= 0 and gx < 320 and gy >= 0 and gy < 180 then
          local ep = img:getPixel(gx, gy)
          local er = app.pixelColor.rgbaR(ep)
          local eg = app.pixelColor.rgbaG(ep)
          local eb = app.pixelColor.rgbaB(ep)
          px(img, gx, gy, rgba(
            math.min(255, math.floor(er + 80 * alpha)),
            math.min(255, math.floor(eg + 40 * alpha)),
            math.min(255, math.floor(eb + 5 * alpha))
          ))
        end
      end
    end
  end

  -- Broken fences
  for fx = 10, 80, 5 do
    if math.random() < 0.7 then
      local fh = math.random(4, 10)
      drawLine(img, fx, groundY - fh, fx, groundY, rgba(25, 22, 18))
    end
  end
  -- Horizontal bar (broken)
  drawLine(img, 10, groundY - 5, 50, groundY - 5, rgba(25, 22, 18))
  drawLine(img, 60, groundY - 5, 80, groundY - 5, rgba(25, 22, 18))
end

------------------------------------------------------------------------
-- STOCKYARDS - Industrial, smokestacks, rail yard, brown haze
------------------------------------------------------------------------
local function drawStockyards(img)
  -- Brown/sepia sky
  drawSkyGradient(img, 18, 14, 10, 35, 28, 20, 120)

  local groundY = 145
  fillRect(img, 0, groundY, 319, 179, rgba(14, 12, 9))

  -- Factory buildings
  drawBuilding(img, 0, 50, 80, groundY, rgba(20, 17, 13), rgba(30, 26, 20))
  drawBuilding(img, 85, 60, 60, groundY, rgba(22, 19, 15), rgba(32, 28, 22))
  drawBuilding(img, 180, 55, 70, groundY, rgba(20, 17, 13), rgba(30, 26, 20))
  drawBuilding(img, 260, 65, 60, groundY, rgba(22, 19, 15), rgba(32, 28, 22))
  -- Small windows
  drawWindows(img, 0, 50, 80, 95, rgba(120, 100, 60), 0.2)
  drawWindows(img, 180, 55, 70, 90, rgba(120, 100, 60), 0.2)

  -- Smokestacks (tall thin rectangles)
  local stacks = {45, 100, 155, 220, 290}
  for _, sx in ipairs(stacks) do
    fillRect(img, sx, 10, sx + 6, groundY, rgba(25, 22, 18))
    fillRect(img, sx + 1, 12, sx + 5, groundY, rgba(30, 26, 20))
    -- Smoke
    math.randomseed(sx * 13)
    for sy = 0, 15 do
      local drift = math.random(-8, 8)
      local spread = math.floor(sy * 0.5)
      for sdx = -spread, spread do
        if math.random() < 0.4 then
          px(img, sx + 3 + drift + sdx, 10 - sy, rgba(35 + sy, 30 + sy, 25 + sy))
        end
      end
    end
  end

  -- Rail yard (parallel tracks)
  for ty = groundY + 5, 175, 8 do
    drawLine(img, 0, ty, 319, ty, rgba(30, 26, 20))
    drawLine(img, 0, ty + 1, 319, ty + 1, rgba(35, 30, 24))
    -- Cross ties
    for tx = 0, 319, 6 do
      px(img, tx, ty - 1, rgba(25, 22, 16))
      px(img, tx, ty + 2, rgba(25, 22, 16))
    end
  end

  -- Cattle pen fences in foreground
  for fx = 0, 319, 4 do
    drawLine(img, fx, groundY - 2, fx, groundY + 4, rgba(40, 34, 25))
  end
  drawLine(img, 0, groundY, 319, groundY, rgba(40, 34, 25))
  drawLine(img, 0, groundY + 3, 319, groundY + 3, rgba(40, 34, 25))

  -- Brown/sepia haze overlay (dithered)
  for y = 0, 179 do
    for x = 0, 319 do
      if (x + y) % 4 == 0 and math.random() < 0.08 then
        px(img, x, y, rgba(30, 25, 18, 40))
      end
    end
  end
end

------------------------------------------------------------------------
-- GOLD COAST - Elegant mansions, gas lamps, trees
------------------------------------------------------------------------
local function drawGoldCoast(img)
  drawSkyGradient(img, 10, 12, 20, 18, 22, 35, 110)
  drawStars(img, 25, 50)

  local groundY = 148
  fillRect(img, 0, groundY, 319, 179, rgba(14, 14, 12))

  -- Elegant mansions (wider, lower, ornamental)
  local mansions = {
    {x=5, h=50, w=70}, {x=85, h=45, w=65},
    {x=165, h=52, w=72}, {x=248, h=48, w=72}
  }
  for _, m in ipairs(mansions) do
    local topY = groundY - m.h
    drawBuilding(img, m.x, topY, m.w, groundY, rgba(22, 20, 18), rgba(35, 32, 28))
    drawWindows(img, m.x, topY, m.w, m.h, rgba(220, 195, 120), 0.45)
    -- Ornamental top (small pediment)
    local cx = m.x + math.floor(m.w / 2)
    for i = 0, 5 do
      drawLine(img, cx - 10 + i, topY - (5 - i), cx + 10 - i, topY - (5 - i), rgba(28, 26, 22))
    end
    -- Columns (decorative)
    for col = m.x + 8, m.x + m.w - 8, 12 do
      drawLine(img, col, topY, col, groundY, rgba(40, 36, 32))
    end
  end

  -- Gas lamps (regular spacing)
  for lx = 30, 300, 50 do
    drawStreetlamp(img, lx, groundY, rgba(200, 170, 80), rgba(45, 40, 32))
  end

  -- Trees (round green shapes with trunks)
  local trees = {20, 75, 145, 210, 280}
  for _, tx in ipairs(trees) do
    -- Trunk
    fillRect(img, tx, groundY - 25, tx + 3, groundY, rgba(40, 30, 18))
    -- Canopy
    fillEllipse(img, tx + 1, groundY - 35, 10, 12, rgba(18, 35, 15))
    fillEllipse(img, tx + 1, groundY - 35, 8, 10, rgba(22, 42, 18))
    -- Highlight
    fillEllipse(img, tx, groundY - 38, 4, 5, rgba(28, 50, 22))
  end

  -- Iron fence in foreground
  for fx = 0, 319, 6 do
    drawLine(img, fx, groundY + 5, fx, groundY + 18, rgba(30, 30, 32))
  end
  -- Horizontal bars
  drawLine(img, 0, groundY + 8, 319, groundY + 8, rgba(30, 30, 32))
  drawLine(img, 0, groundY + 14, 319, groundY + 14, rgba(30, 30, 32))
  -- Ornamental tops
  for fx = 0, 319, 6 do
    px(img, fx, groundY + 4, rgba(38, 38, 40))
  end

  -- Cleaner sidewalk
  fillRect(img, 0, groundY, 319, groundY + 4, rgba(22, 22, 20))
end

------------------------------------------------------------------------
-- LEVEE DISTRICT - Vice, neon, silhouettes, saturated
------------------------------------------------------------------------
local function drawLeveeDistrict(img)
  drawSkyGradient(img, 12, 8, 16, 22, 16, 28, 120)

  local groundY = 145
  fillRect(img, 0, groundY, 319, 179, rgba(14, 10, 16))

  -- Buildings
  local buildings = {
    {x=0, h=85, w=45}, {x=48, h=95, w=40}, {x=92, h=80, w=38},
    {x=140, h=90, w=42}, {x=186, h=100, w=38},
    {x=228, h=85, w=44}, {x=276, h=90, w=44}
  }
  for _, b in ipairs(buildings) do
    drawBuilding(img, b.x, groundY - b.h, b.w, groundY, rgba(16, 12, 18), rgba(24, 20, 28))
    drawWindows(img, b.x, groundY - b.h, b.w, b.h, rgba(200, 140, 100), 0.4)
  end

  -- Bright neon signs (multiple colors)
  -- Red neon
  fillRect(img, 50, 58, 85, 66, rgba(230, 40, 60))
  fillRect(img, 51, 59, 84, 65, rgba(200, 30, 50))
  -- Pink neon
  fillRect(img, 145, 52, 175, 58, rgba(230, 80, 160))
  fillRect(img, 146, 53, 174, 57, rgba(200, 65, 140))
  -- Blue neon
  fillRect(img, 240, 55, 268, 62, rgba(60, 100, 230))
  fillRect(img, 241, 56, 267, 61, rgba(45, 80, 200))

  -- Marquee with running lights
  fillRect(img, 95, 68, 135, 78, rgba(25, 20, 28))
  -- Alternating bright pixels (running lights)
  for mx = 95, 135, 3 do
    local bright = (mx % 6 < 3)
    if bright then
      px(img, mx, 68, rgba(255, 220, 80))
      px(img, mx, 78, rgba(255, 220, 80))
    else
      px(img, mx, 68, rgba(120, 100, 40))
      px(img, mx, 78, rgba(120, 100, 40))
    end
  end
  for my = 68, 78, 3 do
    local bright = (my % 6 < 3)
    if bright then
      px(img, 95, my, rgba(255, 220, 80))
      px(img, 135, my, rgba(255, 220, 80))
    else
      px(img, 95, my, rgba(120, 100, 40))
      px(img, 135, my, rgba(120, 100, 40))
    end
  end

  -- Neon glow effects (simple approach: bright pixels around signs)
  math.randomseed(666)
  for _, neon in ipairs({{67, 62, 230, 40, 60}, {160, 55, 230, 80, 160}, {254, 58, 60, 100, 230}}) do
    local nx, ny, nr, ng, nb = neon[1], neon[2], neon[3], neon[4], neon[5]
    for dy = -5, 5 do
      for dx = -5, 5 do
        local dist = math.abs(dx) + math.abs(dy)
        if dist > 0 and dist < 6 then
          local gx, gy = nx + dx, ny + dy
          if gx >= 0 and gx < 320 and gy >= 0 and gy < 180 then
            local ep = img:getPixel(gx, gy)
            local er = app.pixelColor.rgbaR(ep)
            local eg = app.pixelColor.rgbaG(ep)
            local eb = app.pixelColor.rgbaB(ep)
            local t = 0.2 * (1 - dist / 6)
            px(img, gx, gy, rgba(
              math.min(255, math.floor(er + nr * t)),
              math.min(255, math.floor(eg + ng * t)),
              math.min(255, math.floor(eb + nb * t))
            ))
          end
        end
      end
    end
  end

  -- Silhouette figures in doorways
  local doorways = {25, 110, 195, 260}
  for _, dx in ipairs(doorways) do
    -- Doorway light
    fillRect(img, dx, groundY - 10, dx + 4, groundY, rgba(50, 35, 25))
    -- Figure silhouette (2x4 dark shape)
    fillRect(img, dx + 1, groundY - 8, dx + 2, groundY - 4, rgba(6, 4, 8))
  end

  -- Music notes (tiny floating symbols)
  local noteColor = rgba(200, 180, 120)
  -- Note 1
  px(img, 120, 45, noteColor); px(img, 121, 44, noteColor); px(img, 121, 43, noteColor)
  px(img, 120, 43, noteColor)
  -- Note 2
  px(img, 200, 42, noteColor); px(img, 201, 41, noteColor); px(img, 201, 40, noteColor)
  px(img, 200, 40, noteColor)
  -- Note 3
  px(img, 280, 48, noteColor); px(img, 281, 47, noteColor); px(img, 281, 46, noteColor)

  drawLine(img, 0, groundY, 319, groundY, rgba(28, 22, 30))
end

------------------------------------------------------------------------
-- Run all backgrounds
------------------------------------------------------------------------
print("=== Generating King of Chicago Backgrounds ===")
createBG("south_side", drawSouthSide)
createBG("little_italy", drawLittleItaly)
createBG("the_loop", drawTheLoop)
createBG("north_side", drawNorthSide)
createBG("west_side", drawWestSide)
createBG("stockyards", drawStockyards)
createBG("gold_coast", drawGoldCoast)
createBG("levee_district", drawLeveeDistrict)
print("=== All backgrounds complete ===")
