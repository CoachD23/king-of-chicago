-- aseprite_portraits.lua
-- Generate 6 character portraits at 64x64 for King of Chicago
-- Noir pixel art style with rim lighting

local OUTPUT_DIR = "/Users/fcp/King of chicago/king_of_chicago/assets/portraits/"

-- Helper: fill rect
local function fillRect(img, x1, y1, x2, y2, color)
  for y = y1, y2 do
    for x = x1, x2 do
      if x >= 0 and x < img.width and y >= 0 and y < img.height then
        img:drawPixel(x, y, color)
      end
    end
  end
end

-- Helper: draw single pixel safely
local function px(img, x, y, color)
  if x >= 0 and x < img.width and y >= 0 and y < img.height then
    img:drawPixel(x, y, color)
  end
end

-- Helper: draw ellipse outline
local function drawEllipse(img, cx, cy, rx, ry, color)
  for angle = 0, 360, 1 do
    local rad = angle * math.pi / 180
    local x = math.floor(cx + rx * math.cos(rad) + 0.5)
    local y = math.floor(cy + ry * math.sin(rad) + 0.5)
    px(img, x, y, color)
  end
end

-- Helper: filled ellipse
local function fillEllipse(img, cx, cy, rx, ry, color)
  for y = cy - ry, cy + ry do
    for x = cx - rx, cx + rx do
      local dx = (x - cx) / rx
      local dy = (y - cy) / ry
      if dx * dx + dy * dy <= 1.0 then
        px(img, x, y, color)
      end
    end
  end
end

-- Helper: dither (checkerboard) rect
local function ditherRect(img, x1, y1, x2, y2, color1, color2)
  for y = y1, y2 do
    for x = x1, x2 do
      if (x + y) % 2 == 0 then
        px(img, x, y, color1)
      else
        px(img, x, y, color2)
      end
    end
  end
end

-- Helper: dither ellipse
local function ditherEllipse(img, cx, cy, rx, ry, color1, color2)
  for y = cy - ry, cy + ry do
    for x = cx - rx, cx + rx do
      local dx = (x - cx) / rx
      local dy = (y - cy) / ry
      if dx * dx + dy * dy <= 1.0 then
        if (x + y) % 2 == 0 then
          px(img, x, y, color1)
        else
          px(img, x, y, color2)
        end
      end
    end
  end
end

-- Helper: draw a line (Bresenham)
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

local function rgba(r, g, b, a)
  return app.pixelColor.rgba(r, g, b, a or 255)
end

-- Create a new sprite, draw, export, close
local function createPortrait(name, drawFunc)
  app.command.NewFile{ width=64, height=64, colorMode=ColorMode.RGB }
  local spr = app.activeSprite
  local img = app.activeCel.image

  drawFunc(img)

  spr:saveCopyAs(OUTPUT_DIR .. name .. ".png")
  spr:close()
  print("Exported: " .. name .. ".png")
end

------------------------------------------------------------------------
-- VINCE (protagonist) - 3/4 right, fedora, gold rim lighting
------------------------------------------------------------------------
local function drawVince(img)
  local bg = rgba(13, 11, 8)
  local black = rgba(0, 0, 0)
  local darkSkin = rgba(45, 35, 25)
  local midSkin = rgba(75, 58, 42)
  local lightSkin = rgba(105, 82, 60)
  local rimGold = rgba(201, 168, 76)
  local rimGoldDim = rgba(160, 130, 60)
  local eyeBright = rgba(232, 213, 163)
  local stubble = rgba(35, 28, 20)
  local suitDark = rgba(20, 18, 15)
  local suitMid = rgba(35, 30, 25)
  local hatDark = rgba(30, 25, 18)
  local hatMid = rgba(50, 40, 30)

  -- Background
  fillRect(img, 0, 0, 63, 63, bg)

  -- Suit/shoulders (bottom area)
  fillRect(img, 14, 52, 50, 63, suitDark)
  fillRect(img, 18, 50, 46, 52, suitDark)
  -- Collar
  fillRect(img, 24, 48, 40, 52, suitMid)
  -- Collar V
  drawLine(img, 32, 48, 30, 52, bg)
  drawLine(img, 33, 48, 35, 52, bg)

  -- Neck
  fillRect(img, 27, 44, 37, 50, darkSkin)

  -- Head shape (oval, slightly right-facing)
  fillEllipse(img, 33, 30, 13, 16, darkSkin)
  -- Mid-tone face area (right side lighter for 3/4 view)
  fillEllipse(img, 35, 30, 10, 13, midSkin)
  -- Lighter area on right cheek
  fillEllipse(img, 37, 32, 6, 8, lightSkin)
  -- Dither transition zones
  ditherEllipse(img, 34, 30, 11, 14, darkSkin, midSkin)

  -- Jaw definition (strong jawline)
  drawLine(img, 22, 38, 28, 42, black)
  drawLine(img, 28, 42, 38, 43, black)
  drawLine(img, 38, 43, 44, 38, black)

  -- Stubble area (lower face dithering)
  for y = 36, 42 do
    for x = 26, 40 do
      local dx = (x - 33) / 10
      local dy = (y - 38) / 5
      if dx * dx + dy * dy <= 1.0 and (x + y) % 3 == 0 then
        px(img, x, y, stubble)
      end
    end
  end

  -- Eyes
  px(img, 30, 28, eyeBright)
  px(img, 31, 28, eyeBright)
  px(img, 37, 28, eyeBright)
  px(img, 38, 28, eyeBright)
  -- Brow ridge
  drawLine(img, 28, 26, 33, 25, darkSkin)
  drawLine(img, 35, 25, 40, 26, darkSkin)
  -- Dark above eyes
  drawLine(img, 28, 26, 33, 25, rgba(25, 20, 15))
  drawLine(img, 35, 25, 40, 26, rgba(25, 20, 15))

  -- Nose (subtle)
  px(img, 34, 32, lightSkin)
  px(img, 35, 32, rgba(120, 95, 70))
  px(img, 34, 33, midSkin)

  -- Mouth
  drawLine(img, 31, 37, 37, 37, rgba(55, 40, 30))

  -- Ear (right side, partially visible)
  px(img, 45, 28, midSkin)
  px(img, 46, 29, midSkin)
  px(img, 46, 30, midSkin)
  px(img, 45, 31, midSkin)

  -- FEDORA
  -- Brim
  fillRect(img, 16, 16, 48, 18, hatDark)
  fillRect(img, 18, 15, 46, 16, hatDark)
  -- Crown
  fillRect(img, 22, 8, 44, 16, hatDark)
  fillRect(img, 24, 6, 42, 8, hatDark)
  -- Hat band
  fillRect(img, 22, 14, 44, 15, rgba(80, 65, 45))
  -- Hat mid-tone
  fillRect(img, 26, 9, 40, 13, hatMid)
  -- Hat crease
  drawLine(img, 28, 8, 38, 8, rgba(20, 16, 12))

  -- RIGHT-SIDE RIM LIGHTING (gold) - 1-2 pixel edge
  for y = 8, 46 do
    -- Find rightmost filled pixel in this row
    for x = 50, 20, -1 do
      local p = img:getPixel(x, y)
      local r = app.pixelColor.rgbaR(p)
      local g = app.pixelColor.rgbaG(p)
      local b = app.pixelColor.rgbaB(p)
      local a = app.pixelColor.rgbaA(p)
      if a > 0 and not (r == 13 and g == 11 and b == 8) then
        px(img, x, y, rimGold)
        if x > 20 then
          px(img, x - 1, y, rimGoldDim)
        end
        break
      end
    end
  end

  -- Re-draw eyes on top of rim lighting
  px(img, 30, 28, eyeBright)
  px(img, 31, 28, eyeBright)
  px(img, 37, 28, eyeBright)
  px(img, 38, 28, eyeBright)

  -- Black outline around silhouette
  for y = 0, 63 do
    for x = 0, 63 do
      local p = img:getPixel(x, y)
      local a = app.pixelColor.rgbaA(p)
      local r = app.pixelColor.rgbaR(p)
      local g = app.pixelColor.rgbaG(p)
      local b = app.pixelColor.rgbaB(p)
      if a > 0 and not (r == 13 and g == 11 and b == 8) then
        -- Check if any neighbor is background
        for _, d in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
          local nx, ny = x + d[1], y + d[2]
          if nx >= 0 and nx < 64 and ny >= 0 and ny < 64 then
            local np = img:getPixel(nx, ny)
            local nr = app.pixelColor.rgbaR(np)
            local ng = app.pixelColor.rgbaG(np)
            local nb = app.pixelColor.rgbaB(np)
            if nr == 13 and ng == 11 and nb == 8 then
              px(img, nx, ny, black)
            end
          end
        end
      end
    end
  end
end

------------------------------------------------------------------------
-- ENZO (mentor, 60s) - rounder, glasses, warm amber
------------------------------------------------------------------------
local function drawEnzo(img)
  local bg = rgba(13, 11, 8)
  local black = rgba(0, 0, 0)
  local darkSkin = rgba(55, 42, 30)
  local midSkin = rgba(85, 68, 50)
  local lightSkin = rgba(115, 92, 68)
  local rimAmber = rgba(212, 165, 76)
  local rimAmberDim = rgba(170, 130, 60)
  local eyeBright = rgba(200, 185, 150)
  local greyHair = rgba(150, 145, 138)
  local whiteHair = rgba(190, 185, 178)
  local vestDark = rgba(25, 22, 18)
  local vestMid = rgba(42, 36, 28)

  fillRect(img, 0, 0, 63, 63, bg)

  -- Vest/shirt
  fillRect(img, 16, 52, 48, 63, vestDark)
  fillRect(img, 20, 49, 44, 53, vestDark)
  -- Vest lighter panel
  fillRect(img, 26, 52, 38, 63, vestMid)
  -- Buttons
  px(img, 32, 55, rgba(80, 70, 55))
  px(img, 32, 59, rgba(80, 70, 55))

  -- Neck (thicker, older)
  fillRect(img, 26, 44, 38, 50, darkSkin)

  -- Head (rounder, wider)
  fillEllipse(img, 32, 28, 14, 16, darkSkin)
  fillEllipse(img, 33, 30, 11, 13, midSkin)
  fillEllipse(img, 34, 31, 7, 9, lightSkin)
  ditherEllipse(img, 32, 29, 12, 14, darkSkin, midSkin)

  -- Higher forehead (receding hairline)
  fillEllipse(img, 32, 24, 13, 8, darkSkin)

  -- Grey hair at temples
  for y = 18, 24 do
    px(img, 19, y, greyHair)
    px(img, 20, y, whiteHair)
    px(img, 44, y, greyHair)
    px(img, 45, y, whiteHair)
  end
  -- Thin hair on top
  for x = 24, 40 do
    if x % 2 == 0 then
      px(img, x, 13, greyHair)
      px(img, x, 14, whiteHair)
    end
  end

  -- Eyes (gentler, slightly smaller)
  px(img, 28, 28, eyeBright)
  px(img, 29, 28, eyeBright)
  px(img, 36, 28, eyeBright)
  px(img, 37, 28, eyeBright)

  -- Reading glasses (small bright rectangles)
  local glassBright = rgba(180, 200, 220)
  local glassFrame = rgba(100, 90, 75)
  -- Left lens
  drawLine(img, 26, 26, 31, 26, glassFrame)
  drawLine(img, 26, 30, 31, 30, glassFrame)
  px(img, 26, 27, glassFrame); px(img, 26, 28, glassFrame); px(img, 26, 29, glassFrame)
  px(img, 31, 27, glassFrame); px(img, 31, 28, glassFrame); px(img, 31, 29, glassFrame)
  px(img, 27, 27, glassBright); px(img, 30, 27, glassBright)
  -- Right lens
  drawLine(img, 34, 26, 39, 26, glassFrame)
  drawLine(img, 34, 30, 39, 30, glassFrame)
  px(img, 34, 27, glassFrame); px(img, 34, 28, glassFrame); px(img, 34, 29, glassFrame)
  px(img, 39, 27, glassFrame); px(img, 39, 28, glassFrame); px(img, 39, 29, glassFrame)
  px(img, 35, 27, glassBright); px(img, 38, 27, glassBright)
  -- Bridge
  drawLine(img, 31, 28, 34, 28, glassFrame)

  -- Nose (larger, rounder)
  fillRect(img, 32, 32, 34, 34, lightSkin)
  px(img, 35, 34, rgba(130, 105, 78))

  -- Mouth (slight smile)
  drawLine(img, 29, 37, 35, 37, rgba(65, 48, 35))
  px(img, 28, 36, rgba(65, 48, 35))
  px(img, 36, 36, rgba(65, 48, 35))

  -- Rim lighting (right side, warm amber)
  for y = 13, 48 do
    for x = 50, 18, -1 do
      local p = img:getPixel(x, y)
      local r = app.pixelColor.rgbaR(p)
      local g = app.pixelColor.rgbaG(p)
      local b = app.pixelColor.rgbaB(p)
      local a = app.pixelColor.rgbaA(p)
      if a > 0 and not (r == 13 and g == 11 and b == 8) then
        px(img, x, y, rimAmber)
        if x > 18 then px(img, x - 1, y, rimAmberDim) end
        break
      end
    end
  end

  -- Re-draw eyes and glasses
  px(img, 28, 28, eyeBright); px(img, 29, 28, eyeBright)
  px(img, 36, 28, eyeBright); px(img, 37, 28, eyeBright)
  px(img, 27, 27, glassBright); px(img, 30, 27, glassBright)
  px(img, 35, 27, glassBright); px(img, 38, 27, glassBright)
end

------------------------------------------------------------------------
-- TOMMY (right hand, 30s) - messy hair, no hat, nervous energy
------------------------------------------------------------------------
local function drawTommy(img)
  local bg = rgba(13, 11, 8)
  local black = rgba(0, 0, 0)
  local darkSkin = rgba(60, 48, 36)
  local midSkin = rgba(95, 78, 58)
  local lightSkin = rgba(130, 108, 82)
  local rimWarm = rgba(200, 160, 90)
  local rimWarmDim = rgba(160, 125, 70)
  local eyeBright = rgba(220, 210, 185)
  local hairDark = rgba(25, 20, 15)
  local hairMid = rgba(40, 32, 24)
  local shirtDark = rgba(35, 30, 25)

  fillRect(img, 0, 0, 63, 63, bg)

  -- Shirt (open collar, no tie)
  fillRect(img, 16, 52, 48, 63, shirtDark)
  fillRect(img, 20, 49, 44, 53, shirtDark)
  -- Open collar V (wider than Vince)
  for i = 0, 6 do
    px(img, 29 - i, 49 + i, bg)
    px(img, 30 - i, 49 + i, bg)
    px(img, 35 + i, 49 + i, bg)
    px(img, 36 + i, 49 + i, bg)
  end
  -- Skin visible in collar
  fillRect(img, 29, 47, 35, 52, darkSkin)

  -- Neck (thinner, younger)
  fillRect(img, 28, 43, 36, 49, darkSkin)

  -- Head
  fillEllipse(img, 32, 28, 12, 15, darkSkin)
  fillEllipse(img, 33, 29, 10, 12, midSkin)
  fillEllipse(img, 34, 30, 7, 9, lightSkin)
  ditherEllipse(img, 32, 28, 11, 13, darkSkin, midSkin)

  -- Messy dark hair (no hat)
  fillEllipse(img, 32, 18, 13, 8, hairDark)
  fillRect(img, 20, 14, 44, 22, hairDark)
  -- Messy spikes
  px(img, 22, 12, hairDark); px(img, 26, 11, hairMid)
  px(img, 30, 10, hairDark); px(img, 34, 11, hairMid)
  px(img, 38, 10, hairDark); px(img, 42, 12, hairMid)
  px(img, 24, 13, hairMid); px(img, 36, 12, hairDark)
  px(img, 40, 13, hairDark)
  -- Side hair
  for y = 20, 30 do
    px(img, 20, y, hairDark)
    px(img, 21, y, hairMid)
    if y < 26 then
      px(img, 43, y, hairDark)
      px(img, 44, y, hairMid)
    end
  end

  -- Wider eyes (nervous energy)
  px(img, 28, 27, eyeBright); px(img, 29, 27, eyeBright); px(img, 28, 28, eyeBright); px(img, 29, 28, eyeBright)
  px(img, 36, 27, eyeBright); px(img, 37, 27, eyeBright); px(img, 36, 28, eyeBright); px(img, 37, 28, eyeBright)
  -- Pupils
  px(img, 28, 28, rgba(40, 30, 20)); px(img, 36, 28, rgba(40, 30, 20))

  -- Eyebrows (raised, surprised look)
  drawLine(img, 27, 24, 31, 24, rgba(30, 24, 18))
  drawLine(img, 35, 24, 39, 24, rgba(30, 24, 18))

  -- Nose
  px(img, 33, 32, lightSkin)
  px(img, 34, 33, midSkin)

  -- Mouth (slightly open, nervous)
  drawLine(img, 30, 37, 36, 37, rgba(60, 45, 32))
  px(img, 32, 38, rgba(40, 28, 20)); px(img, 33, 38, rgba(40, 28, 20))

  -- LEFT-side rim lighting (warm)
  for y = 10, 48 do
    for x = 14, 46 do
      local p = img:getPixel(x, y)
      local r = app.pixelColor.rgbaR(p)
      local g = app.pixelColor.rgbaG(p)
      local b = app.pixelColor.rgbaB(p)
      local a = app.pixelColor.rgbaA(p)
      if a > 0 and not (r == 13 and g == 11 and b == 8) then
        px(img, x, y, rimWarm)
        if x < 46 then px(img, x + 1, y, rimWarmDim) end
        break
      end
    end
  end

  -- Re-draw eyes
  px(img, 28, 27, eyeBright); px(img, 29, 27, eyeBright)
  px(img, 28, 28, eyeBright); px(img, 29, 28, eyeBright)
  px(img, 36, 27, eyeBright); px(img, 37, 27, eyeBright)
  px(img, 36, 28, eyeBright); px(img, 37, 28, eyeBright)
  px(img, 28, 28, rgba(40, 30, 20)); px(img, 36, 28, rgba(40, 30, 20))
end

------------------------------------------------------------------------
-- ROSA (sister, 20s) - sharp features, earring, warm palette
------------------------------------------------------------------------
local function drawRosa(img)
  local bg = rgba(16, 14, 10)
  local black = rgba(0, 0, 0)
  local darkSkin = rgba(70, 52, 38)
  local midSkin = rgba(105, 82, 58)
  local lightSkin = rgba(140, 112, 80)
  local warmHigh = rgba(170, 135, 95)
  local rimAmber = rgba(200, 155, 80)
  local eyeBright = rgba(220, 200, 165)
  local hairDark = rgba(18, 14, 10)
  local hairMid = rgba(35, 28, 20)
  local scarfDark = rgba(80, 30, 25)
  local scarfMid = rgba(110, 45, 35)

  fillRect(img, 0, 0, 63, 63, bg)

  -- High collar / scarf
  fillRect(img, 18, 50, 46, 63, scarfDark)
  fillRect(img, 22, 48, 42, 52, scarfDark)
  fillRect(img, 24, 50, 40, 58, scarfMid)
  -- Scarf folds
  drawLine(img, 28, 50, 28, 58, scarfDark)
  drawLine(img, 36, 50, 36, 58, scarfDark)

  -- Neck (slender)
  fillRect(img, 28, 44, 36, 50, darkSkin)

  -- Head (slightly narrower, more oval)
  fillEllipse(img, 32, 28, 11, 15, darkSkin)
  fillEllipse(img, 32, 29, 9, 12, midSkin)
  fillEllipse(img, 33, 30, 6, 9, lightSkin)
  ditherEllipse(img, 32, 28, 10, 13, darkSkin, midSkin)

  -- Defined cheekbones
  drawLine(img, 22, 30, 25, 34, warmHigh)
  drawLine(img, 42, 30, 39, 34, warmHigh)
  px(img, 23, 31, warmHigh); px(img, 41, 31, warmHigh)

  -- Hair pulled back (dark, tight to head)
  fillEllipse(img, 32, 18, 12, 8, hairDark)
  fillRect(img, 20, 14, 44, 22, hairDark)
  -- Hair pulled back behind
  for y = 14, 40 do
    if y < 20 then
      px(img, 19, y, hairDark); px(img, 45, y, hairDark)
    end
    px(img, 20, y, hairDark); px(img, 44, y, hairDark)
  end
  -- Top of hair bun suggestion
  fillEllipse(img, 42, 18, 4, 4, hairDark)
  fillEllipse(img, 42, 18, 3, 3, hairMid)

  -- Expressive eyes (2x2 clusters)
  px(img, 28, 27, eyeBright); px(img, 29, 27, eyeBright)
  px(img, 28, 28, eyeBright); px(img, 29, 28, eyeBright)
  px(img, 36, 27, eyeBright); px(img, 37, 27, eyeBright)
  px(img, 36, 28, eyeBright); px(img, 37, 28, eyeBright)
  -- Eyelids/lashes
  drawLine(img, 27, 26, 30, 26, rgba(30, 22, 16))
  drawLine(img, 35, 26, 38, 26, rgba(30, 22, 16))
  -- Dark pupil centers
  px(img, 29, 28, rgba(35, 25, 18)); px(img, 37, 28, rgba(35, 25, 18))

  -- Nose (defined but delicate)
  px(img, 32, 31, lightSkin); px(img, 33, 32, warmHigh)

  -- Lips (defined)
  drawLine(img, 29, 36, 35, 36, rgba(140, 65, 55))
  drawLine(img, 30, 37, 34, 37, rgba(120, 55, 45))

  -- Earring (single bright pixel, left ear)
  px(img, 20, 30, rgba(255, 220, 120))
  px(img, 20, 31, rgba(255, 240, 150))

  -- Rim lighting (right side, warm amber)
  for y = 14, 48 do
    for x = 50, 20, -1 do
      local p = img:getPixel(x, y)
      local r = app.pixelColor.rgbaR(p)
      local g = app.pixelColor.rgbaG(p)
      local b = app.pixelColor.rgbaB(p)
      local a = app.pixelColor.rgbaA(p)
      if a > 0 and not (r == 16 and g == 14 and b == 10) then
        px(img, x, y, rimAmber)
        break
      end
    end
  end

  -- Re-draw eyes
  px(img, 28, 27, eyeBright); px(img, 29, 27, eyeBright)
  px(img, 28, 28, eyeBright); px(img, 29, 28, eyeBright)
  px(img, 36, 27, eyeBright); px(img, 37, 27, eyeBright)
  px(img, 36, 28, eyeBright); px(img, 37, 28, eyeBright)
  px(img, 29, 28, rgba(35, 25, 18)); px(img, 37, 28, rgba(35, 25, 18))
  px(img, 20, 30, rgba(255, 220, 120)); px(img, 20, 31, rgba(255, 240, 150))
end

------------------------------------------------------------------------
-- MICKEY (rival, Irish) - cold, angular, steel blue rim
------------------------------------------------------------------------
local function drawMickey(img)
  local bg = rgba(13, 11, 8)
  local black = rgba(0, 0, 0)
  local darkSkin = rgba(50, 48, 45)
  local midSkin = rgba(80, 75, 68)
  local lightSkin = rgba(115, 108, 98)
  local coldHigh = rgba(145, 138, 128)
  local rimBlue = rgba(65, 105, 225)
  local rimBlueDim = rgba(50, 80, 170)
  local eyeBright = rgba(180, 195, 210)
  local hairDark = rgba(30, 28, 25)
  local tieDark = rgba(60, 55, 50)
  local suitDark = rgba(28, 26, 24)
  local suitMid = rgba(45, 42, 38)

  fillRect(img, 0, 0, 63, 63, bg)

  -- Well-dressed suit
  fillRect(img, 14, 52, 50, 63, suitDark)
  fillRect(img, 18, 49, 46, 53, suitDark)
  fillRect(img, 22, 52, 24, 63, suitMid)
  fillRect(img, 40, 52, 42, 63, suitMid)
  -- Collar
  fillRect(img, 26, 48, 38, 52, rgba(200, 195, 185))
  -- Tie
  fillRect(img, 31, 49, 33, 63, tieDark)
  -- Tie knot
  fillRect(img, 30, 48, 34, 50, tieDark)

  -- Neck
  fillRect(img, 28, 43, 36, 49, darkSkin)

  -- Head (angular, narrower jaw)
  fillEllipse(img, 32, 27, 12, 15, darkSkin)
  fillEllipse(img, 32, 28, 10, 12, midSkin)
  fillEllipse(img, 33, 29, 7, 9, lightSkin)
  -- Angular jaw
  drawLine(img, 21, 34, 27, 42, darkSkin)
  drawLine(img, 43, 34, 37, 42, darkSkin)

  -- Slicked hair
  fillRect(img, 20, 12, 44, 20, hairDark)
  fillEllipse(img, 32, 15, 13, 6, hairDark)
  -- Hair sheen (single bright line)
  drawLine(img, 26, 14, 38, 14, rgba(55, 50, 45))
  -- Side-parted
  drawLine(img, 28, 12, 28, 18, rgba(20, 18, 14))

  -- Cold eyes (narrower)
  px(img, 28, 28, eyeBright); px(img, 29, 28, eyeBright)
  px(img, 36, 28, eyeBright); px(img, 37, 28, eyeBright)
  -- Narrowed lids
  drawLine(img, 27, 27, 30, 27, darkSkin)
  drawLine(img, 35, 27, 38, 27, darkSkin)
  drawLine(img, 27, 29, 30, 29, darkSkin)
  drawLine(img, 35, 29, 38, 29, darkSkin)

  -- Slight asymmetric smile
  drawLine(img, 29, 36, 35, 36, rgba(65, 58, 50))
  px(img, 36, 35, rgba(65, 58, 50))  -- Smirk up on right

  -- Nose (sharp, angular)
  drawLine(img, 32, 30, 33, 34, lightSkin)
  px(img, 34, 34, coldHigh)

  -- Steel blue rim lighting (right side)
  for y = 12, 48 do
    for x = 50, 20, -1 do
      local p = img:getPixel(x, y)
      local r = app.pixelColor.rgbaR(p)
      local g = app.pixelColor.rgbaG(p)
      local b = app.pixelColor.rgbaB(p)
      local a = app.pixelColor.rgbaA(p)
      if a > 0 and not (r == 13 and g == 11 and b == 8) then
        px(img, x, y, rimBlue)
        if x > 20 then px(img, x - 1, y, rimBlueDim) end
        break
      end
    end
  end

  -- Re-draw eyes
  px(img, 28, 28, eyeBright); px(img, 29, 28, eyeBright)
  px(img, 36, 28, eyeBright); px(img, 37, 28, eyeBright)
end

------------------------------------------------------------------------
-- NARRATOR (typewriter icon)
------------------------------------------------------------------------
local function drawNarrator(img)
  local bg = rgba(13, 11, 8)
  local bodyDark = rgba(35, 30, 25)
  local bodyMid = rgba(60, 52, 42)
  local bodyLight = rgba(85, 72, 58)
  local gold = rgba(201, 168, 76)
  local goldDim = rgba(160, 130, 60)
  local paper = rgba(210, 200, 175)
  local paperDark = rgba(180, 170, 148)
  local textPx = rgba(40, 35, 28)
  local keyDark = rgba(25, 22, 18)
  local keyLight = rgba(50, 44, 36)

  fillRect(img, 0, 0, 63, 63, bg)

  -- Paper coming out the top
  fillRect(img, 20, 6, 44, 28, paper)
  fillRect(img, 22, 4, 42, 6, paper)
  -- Paper curl
  fillRect(img, 22, 4, 42, 5, paperDark)
  -- Tiny text lines on paper
  for y = 10, 24, 3 do
    local lineLen = 16 + (y % 5)
    local startX = 24
    for x = startX, startX + lineLen do
      if x % 2 == 0 then
        px(img, x, y, textPx)
      end
    end
  end

  -- Typewriter body (main frame)
  fillRect(img, 12, 26, 52, 42, bodyDark)
  fillRect(img, 14, 24, 50, 28, bodyMid)
  -- Platen (roller) at top
  fillRect(img, 16, 24, 48, 27, bodyLight)
  drawLine(img, 16, 25, 48, 25, goldDim)

  -- Carriage
  fillRect(img, 10, 28, 54, 30, bodyMid)
  -- Carriage return lever
  drawLine(img, 10, 28, 10, 22, bodyLight)
  px(img, 9, 22, gold); px(img, 10, 22, gold)

  -- Key rows
  for row = 0, 2 do
    local y = 34 + row * 4
    local startX = 16 + row * 2
    for k = 0, 8 - row do
      local x = startX + k * 4
      fillRect(img, x, y, x + 2, y + 2, keyDark)
      px(img, x + 1, y + 1, keyLight)
    end
  end

  -- Space bar
  fillRect(img, 22, 46, 42, 48, keyDark)
  fillRect(img, 24, 47, 40, 47, keyLight)

  -- Typewriter feet
  fillRect(img, 14, 50, 18, 52, bodyDark)
  fillRect(img, 46, 50, 50, 52, bodyDark)

  -- Gold accent outlines
  drawLine(img, 12, 26, 52, 26, gold)
  drawLine(img, 12, 42, 52, 42, goldDim)
  -- Side accents
  drawLine(img, 12, 26, 12, 42, goldDim)
  drawLine(img, 52, 26, 52, 42, goldDim)

  -- Brand text area
  fillRect(img, 26, 30, 38, 32, bodyMid)
  drawLine(img, 28, 31, 36, 31, gold)
end

------------------------------------------------------------------------
-- Run all portraits
------------------------------------------------------------------------
print("=== Generating King of Chicago Portraits ===")
createPortrait("vince", drawVince)
createPortrait("enzo", drawEnzo)
createPortrait("tommy", drawTommy)
createPortrait("rosa", drawRosa)
createPortrait("mickey", drawMickey)
createPortrait("narrator", drawNarrator)
print("=== All portraits complete ===")
