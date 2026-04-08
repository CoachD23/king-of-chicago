-- aseprite_motifs.lua
-- Generate 7 Veil motif icons at 32x32 for King of Chicago

local OUTPUT_DIR = "/Users/fcp/King of chicago/king_of_chicago/assets/motifs/"

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
      local dxx = (x - cx) / math.max(rx, 0.1)
      local dyy = (y - cy) / math.max(ry, 0.1)
      if dxx * dxx + dyy * dyy <= 1.0 then
        px(img, x, y, color)
      end
    end
  end
end

local function createMotif(name, drawFunc)
  app.command.NewFile{ width=32, height=32, colorMode=ColorMode.RGB }
  local spr = app.activeSprite
  local img = app.activeCel.image
  drawFunc(img)
  spr:saveCopyAs(OUTPUT_DIR .. name .. ".png")
  spr:close()
  print("Exported: " .. name .. ".png")
end

------------------------------------------------------------------------
-- DREAD - Knife/blade, blood red
------------------------------------------------------------------------
local function drawDread(img)
  local bg = rgba(13, 11, 8)
  local red = rgba(139, 26, 26)
  local darkRed = rgba(90, 15, 15)
  local blade = rgba(160, 155, 145)
  local bladeDark = rgba(100, 95, 88)
  local handle = rgba(50, 35, 25)
  local handleDark = rgba(35, 25, 18)

  fillRect(img, 0, 0, 31, 31, bg)

  -- Blade (angled, going from bottom-left to upper-right)
  -- Blade body
  drawLine(img, 8, 24, 24, 4, blade)
  drawLine(img, 9, 24, 25, 4, blade)
  drawLine(img, 10, 24, 26, 4, bladeDark)
  -- Blade tip
  px(img, 24, 3, blade)
  px(img, 25, 3, bladeDark)
  -- Blade edge highlight
  drawLine(img, 7, 24, 23, 4, rgba(200, 195, 185))

  -- Handle
  fillRect(img, 6, 24, 12, 29, handle)
  fillRect(img, 7, 25, 11, 28, handleDark)
  -- Guard
  drawLine(img, 5, 23, 13, 23, rgba(80, 70, 55))
  drawLine(img, 5, 24, 13, 24, rgba(70, 60, 48))

  -- Blood drip
  px(img, 18, 12, red)
  px(img, 18, 13, red)
  px(img, 18, 14, darkRed)
  px(img, 19, 15, darkRed)
  px(img, 19, 16, red)
  -- Blood on blade
  px(img, 15, 16, red)
  px(img, 16, 15, darkRed)
  px(img, 20, 9, red)
  px(img, 21, 8, darkRed)

  -- Dark edge outline
  drawLine(img, 7, 25, 23, 3, rgba(0, 0, 0))
  drawLine(img, 11, 25, 27, 5, rgba(0, 0, 0))
end

------------------------------------------------------------------------
-- RESPECT - Handshake, gold
------------------------------------------------------------------------
local function drawRespect(img)
  local bg = rgba(13, 11, 8)
  local gold = rgba(201, 168, 76)
  local goldDark = rgba(140, 115, 50)
  local goldLight = rgba(230, 200, 110)
  local skin = rgba(120, 95, 65)
  local skinDark = rgba(80, 62, 42)
  local outline = rgba(0, 0, 0)

  fillRect(img, 0, 0, 31, 31, bg)

  -- Left hand (coming from left)
  -- Wrist/arm
  fillRect(img, 2, 14, 10, 18, skinDark)
  -- Hand
  fillRect(img, 10, 12, 16, 20, skin)
  -- Fingers (extended right)
  fillRect(img, 16, 13, 19, 15, skin)
  fillRect(img, 16, 16, 19, 18, skin)

  -- Right hand (coming from right)
  fillRect(img, 22, 14, 30, 18, skinDark)
  fillRect(img, 16, 12, 22, 20, skin)
  -- Fingers (extended left, overlapping)
  fillRect(img, 13, 13, 16, 15, skin)
  fillRect(img, 13, 16, 16, 18, skin)

  -- Clasp area (interlocking)
  fillRect(img, 14, 13, 18, 19, gold)
  fillRect(img, 15, 14, 17, 18, goldLight)

  -- Gold accent lines
  drawLine(img, 14, 12, 18, 12, goldDark)
  drawLine(img, 14, 20, 18, 20, goldDark)

  -- Outline
  -- Left arm outline
  drawLine(img, 2, 13, 10, 13, outline)
  drawLine(img, 2, 19, 10, 19, outline)
  drawLine(img, 1, 14, 1, 18, outline)
  -- Right arm outline
  drawLine(img, 22, 13, 30, 13, outline)
  drawLine(img, 22, 19, 30, 19, outline)
  drawLine(img, 31, 14, 31, 18, outline)
  -- Hand outlines
  drawLine(img, 10, 11, 22, 11, outline)
  drawLine(img, 10, 21, 22, 21, outline)

  -- Shine sparkle
  px(img, 16, 10, goldLight)
  px(img, 15, 9, gold)
  px(img, 17, 9, gold)
end

------------------------------------------------------------------------
-- SWAY - Gavel, steel blue
------------------------------------------------------------------------
local function drawSway(img)
  local bg = rgba(13, 11, 8)
  local blue = rgba(65, 105, 225)
  local blueDark = rgba(40, 65, 140)
  local blueLight = rgba(100, 140, 245)
  local wood = rgba(90, 65, 40)
  local woodDark = rgba(60, 42, 25)
  local outline = rgba(0, 0, 0)

  fillRect(img, 0, 0, 31, 31, bg)

  -- Gavel handle (diagonal)
  drawLine(img, 10, 26, 22, 10, wood)
  drawLine(img, 11, 26, 23, 10, wood)
  drawLine(img, 12, 26, 24, 10, woodDark)

  -- Gavel head (horizontal block at top)
  fillRect(img, 15, 6, 28, 13, blue)
  fillRect(img, 16, 7, 27, 12, blueDark)
  -- Highlight on head
  fillRect(img, 17, 7, 26, 8, blueLight)
  -- Head bands
  drawLine(img, 15, 6, 28, 6, blueLight)
  drawLine(img, 15, 13, 28, 13, blueDark)

  -- Sound block / base
  fillRect(img, 4, 26, 20, 29, wood)
  fillRect(img, 5, 27, 19, 28, woodDark)
  -- Base top
  fillRect(img, 6, 24, 18, 26, wood)
  drawLine(img, 6, 24, 18, 24, rgba(110, 85, 55))

  -- Outline
  drawLine(img, 14, 5, 29, 5, outline)
  drawLine(img, 14, 14, 29, 14, outline)
  drawLine(img, 14, 5, 14, 14, outline)
  drawLine(img, 29, 5, 29, 14, outline)

  -- Impact lines (motion)
  px(img, 12, 22, blueLight)
  px(img, 8, 23, blue)
  px(img, 22, 23, blue)
end

------------------------------------------------------------------------
-- EMPIRE - Stack of coins, green with gold edges
------------------------------------------------------------------------
local function drawEmpire(img)
  local bg = rgba(13, 11, 8)
  local green = rgba(34, 139, 34)
  local greenDark = rgba(22, 100, 22)
  local greenLight = rgba(50, 170, 50)
  local gold = rgba(201, 168, 76)
  local goldDark = rgba(160, 130, 50)
  local outline = rgba(0, 0, 0)

  fillRect(img, 0, 0, 31, 31, bg)

  -- Bottom coin (widest)
  fillEllipse(img, 16, 24, 10, 4, greenDark)
  fillEllipse(img, 16, 23, 10, 4, green)
  fillEllipse(img, 16, 22, 9, 3, greenLight)
  -- Edge
  for a = 0, 360, 3 do
    local rad = a * math.pi / 180
    local ex = math.floor(16 + 10 * math.cos(rad) + 0.5)
    local ey = math.floor(24 + 4 * math.sin(rad) + 0.5)
    px(img, ex, ey, gold)
  end

  -- Second coin
  fillEllipse(img, 16, 19, 10, 4, greenDark)
  fillEllipse(img, 16, 18, 10, 4, green)
  fillEllipse(img, 16, 17, 9, 3, greenLight)
  for a = 0, 360, 3 do
    local rad = a * math.pi / 180
    local ex = math.floor(16 + 10 * math.cos(rad) + 0.5)
    local ey = math.floor(19 + 4 * math.sin(rad) + 0.5)
    px(img, ex, ey, gold)
  end

  -- Third coin
  fillEllipse(img, 16, 14, 10, 4, greenDark)
  fillEllipse(img, 16, 13, 10, 4, green)
  fillEllipse(img, 16, 12, 9, 3, greenLight)
  for a = 0, 360, 3 do
    local rad = a * math.pi / 180
    local ex = math.floor(16 + 10 * math.cos(rad) + 0.5)
    local ey = math.floor(14 + 4 * math.sin(rad) + 0.5)
    px(img, ex, ey, gold)
  end

  -- Top coin (highlight)
  fillEllipse(img, 16, 9, 10, 4, greenDark)
  fillEllipse(img, 16, 8, 10, 4, green)
  fillEllipse(img, 16, 7, 8, 3, greenLight)
  for a = 0, 360, 3 do
    local rad = a * math.pi / 180
    local ex = math.floor(16 + 10 * math.cos(rad) + 0.5)
    local ey = math.floor(9 + 4 * math.sin(rad) + 0.5)
    px(img, ex, ey, gold)
  end
  -- $ symbol on top coin
  px(img, 16, 6, goldDark)
  px(img, 16, 7, goldDark)
  px(img, 15, 6, goldDark)
  px(img, 17, 8, goldDark)

  -- Stack sides (fill between coins)
  for y = 9, 24 do
    px(img, 6, y, goldDark)
    px(img, 26, y, goldDark)
  end

  -- Shine
  px(img, 12, 5, rgba(255, 240, 150))
  px(img, 13, 4, gold)
end

------------------------------------------------------------------------
-- GUILE - Chess knight, purple
------------------------------------------------------------------------
local function drawGuile(img)
  local bg = rgba(13, 11, 8)
  local purple = rgba(139, 0, 139)
  local purpleDark = rgba(90, 0, 90)
  local purpleLight = rgba(180, 40, 180)
  local outline = rgba(0, 0, 0)

  fillRect(img, 0, 0, 31, 31, bg)

  -- Knight base
  fillRect(img, 8, 25, 24, 28, purpleDark)
  fillRect(img, 9, 26, 23, 27, purple)
  drawLine(img, 8, 25, 24, 25, purpleLight)

  -- Knight body (horse neck going up-right)
  fillRect(img, 12, 10, 20, 25, purpleDark)
  fillRect(img, 13, 11, 19, 24, purple)

  -- Horse head profile (facing right)
  -- Ears
  px(img, 15, 5, purple); px(img, 16, 4, purpleLight)
  px(img, 17, 5, purple); px(img, 18, 4, purpleLight)
  -- Top of head
  fillRect(img, 14, 6, 20, 9, purple)
  fillRect(img, 15, 6, 19, 8, purpleLight)
  -- Forehead to nose
  fillRect(img, 18, 9, 24, 12, purple)
  fillRect(img, 20, 10, 25, 11, purple)
  -- Nose/muzzle
  fillRect(img, 22, 12, 26, 15, purple)
  fillRect(img, 23, 13, 27, 14, purpleDark)
  -- Nostril
  px(img, 26, 14, purpleDark)
  -- Jaw curve
  drawLine(img, 22, 15, 18, 20, purpleDark)
  fillRect(img, 18, 16, 22, 18, purpleDark)

  -- Eye
  px(img, 19, 9, rgba(220, 200, 255))
  px(img, 20, 9, rgba(200, 180, 240))

  -- Mane
  for my = 6, 14 do
    px(img, 13, my, purpleDark)
    px(img, 12, my, purpleDark)
    if my % 2 == 0 then px(img, 11, my, purpleDark) end
  end

  -- Outline
  drawLine(img, 14, 5, 18, 4, outline)
  drawLine(img, 20, 6, 20, 9, outline)
  drawLine(img, 20, 9, 25, 9, outline)
  drawLine(img, 25, 9, 27, 12, outline)
  drawLine(img, 27, 12, 27, 15, outline)
  drawLine(img, 27, 15, 22, 16, outline)
  drawLine(img, 11, 6, 11, 25, outline)
  drawLine(img, 7, 25, 7, 29, outline)
  drawLine(img, 25, 25, 25, 29, outline)
  drawLine(img, 7, 29, 25, 29, outline)

  -- Purple glow accent
  px(img, 16, 3, purpleLight)
end

------------------------------------------------------------------------
-- LEGEND - Newspaper, orange
------------------------------------------------------------------------
local function drawLegend(img)
  local bg = rgba(13, 11, 8)
  local paper = rgba(210, 200, 175)
  local paperDark = rgba(180, 170, 148)
  local orange = rgba(255, 140, 0)
  local orangeDark = rgba(200, 110, 0)
  local textColor = rgba(40, 35, 28)
  local outline = rgba(0, 0, 0)

  fillRect(img, 0, 0, 31, 31, bg)

  -- Newspaper rectangle
  fillRect(img, 4, 4, 27, 27, paper)
  fillRect(img, 5, 5, 26, 26, paperDark)
  -- Slightly folded (diagonal crease)
  drawLine(img, 4, 4, 27, 27, rgba(170, 160, 138))

  -- Headline (bold orange bar at top)
  fillRect(img, 6, 6, 25, 9, orange)
  fillRect(img, 7, 7, 24, 8, orangeDark)

  -- Headline text (tiny dark pixels)
  for tx = 8, 22, 2 do
    px(img, tx, 7, textColor)
    px(img, tx, 8, textColor)
  end

  -- Column separator
  drawLine(img, 16, 11, 16, 25, rgba(160, 150, 128))

  -- Text lines (left column)
  for ty = 11, 25, 2 do
    for tx = 7, 14, 2 do
      px(img, tx, ty, textColor)
    end
  end

  -- Text lines (right column)
  for ty = 11, 25, 2 do
    for tx = 18, 24, 2 do
      px(img, tx, ty, textColor)
    end
  end

  -- "Photo" placeholder
  fillRect(img, 18, 14, 24, 19, rgba(120, 110, 95))

  -- Outline
  drawLine(img, 3, 3, 28, 3, outline)
  drawLine(img, 3, 28, 28, 28, outline)
  drawLine(img, 3, 3, 3, 28, outline)
  drawLine(img, 28, 3, 28, 28, outline)

  -- Orange accent glow
  px(img, 5, 5, orange); px(img, 26, 5, orange)
end

------------------------------------------------------------------------
-- KINSHIP - House with heart, amber
------------------------------------------------------------------------
local function drawKinship(img)
  local bg = rgba(13, 11, 8)
  local amber = rgba(139, 69, 19)
  local amberDark = rgba(100, 48, 12)
  local amberLight = rgba(180, 100, 40)
  local heartRed = rgba(180, 40, 40)
  local heartLight = rgba(220, 70, 70)
  local outline = rgba(0, 0, 0)

  fillRect(img, 0, 0, 31, 31, bg)

  -- House body
  fillRect(img, 7, 15, 24, 27, amber)
  fillRect(img, 8, 16, 23, 26, amberDark)

  -- Roof (triangle)
  for i = 0, 8 do
    drawLine(img, 16 - i, 7 + i, 16 + i, 7 + i, amber)
  end
  -- Roof peak
  px(img, 16, 6, amberLight)
  drawLine(img, 15, 7, 17, 7, amberLight)
  -- Roof edge highlight
  drawLine(img, 7, 15, 16, 6, amberLight)

  -- Door
  fillRect(img, 13, 21, 18, 27, amberDark)
  fillRect(img, 14, 22, 17, 26, rgba(70, 35, 15))
  px(img, 17, 24, amberLight)  -- Doorknob

  -- Window (left)
  fillRect(img, 9, 17, 12, 20, rgba(200, 170, 80))
  -- Window (right)
  fillRect(img, 19, 17, 22, 20, rgba(200, 170, 80))
  -- Window frames
  drawLine(img, 9, 17, 12, 17, outline)
  drawLine(img, 9, 20, 12, 20, outline)
  drawLine(img, 19, 17, 22, 17, outline)
  drawLine(img, 19, 20, 22, 20, outline)

  -- Heart inside (center of house)
  -- Simple 5x5 heart shape
  local hx, hy = 16, 14  -- Center above door
  -- Top bumps
  px(img, hx - 2, hy - 1, heartRed)
  px(img, hx - 1, hy - 2, heartRed)
  px(img, hx - 1, hy - 1, heartLight)
  px(img, hx, hy - 1, heartRed)
  px(img, hx + 1, hy - 2, heartRed)
  px(img, hx + 1, hy - 1, heartLight)
  px(img, hx + 2, hy - 1, heartRed)
  -- Middle
  px(img, hx - 2, hy, heartRed)
  px(img, hx - 1, hy, heartLight)
  px(img, hx, hy, heartLight)
  px(img, hx + 1, hy, heartLight)
  px(img, hx + 2, hy, heartRed)
  -- Lower
  px(img, hx - 1, hy + 1, heartRed)
  px(img, hx, hy + 1, heartRed)
  px(img, hx + 1, hy + 1, heartRed)
  -- Point
  px(img, hx, hy + 2, heartRed)

  -- House outline
  drawLine(img, 6, 15, 6, 28, outline)
  drawLine(img, 25, 15, 25, 28, outline)
  drawLine(img, 6, 28, 25, 28, outline)
  -- Roof outline
  drawLine(img, 5, 16, 16, 5, outline)
  drawLine(img, 16, 5, 26, 16, outline)

  -- Chimney
  fillRect(img, 21, 7, 23, 12, amberDark)
  drawLine(img, 20, 7, 20, 12, outline)
  drawLine(img, 24, 7, 24, 12, outline)
  -- Smoke
  px(img, 22, 5, rgba(60, 55, 50))
  px(img, 21, 3, rgba(50, 45, 40))
  px(img, 23, 2, rgba(45, 40, 35))
end

------------------------------------------------------------------------
-- Run all motifs
------------------------------------------------------------------------
print("=== Generating King of Chicago Motif Icons ===")
createMotif("dread", drawDread)
createMotif("respect", drawRespect)
createMotif("sway", drawSway)
createMotif("empire", drawEmpire)
createMotif("guile", drawGuile)
createMotif("legend", drawLegend)
createMotif("kinship", drawKinship)
print("=== All motifs complete ===")
