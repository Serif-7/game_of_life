-- TODO: Spacebar to pause
-- TODO: Click to toggle a cell
-- TODO: Fullscreen
-- TODO: rewind to previous boards

local TICK_TIME = 5
local acc_time = 0

local paused = false

-- pause/unpause on spacebar
function love.keypressed(key)
  if key == 'space' then paused = not paused end
end

function love.load()

  --set window size
  love.window.setMode(512, 512)

  -- white square 8x8
  W = love.graphics.newImage("white_square.png")
  B = love.graphics.newImage("black_square.png")

  --64x64 table, + 2 extra for sentinel values
  Board = {}
  for i=1,66 do
    Board[i] = {}
      for j=1,66 do
        Board[i][j] = 0
      end
  end

  Board = SetRandomTiles(Board)

end

function love.update(dt)

  if paused then return end

  acc_time = acc_time + dt

  if acc_time >= TICK_TIME then
    Board = UpdateBoard(Board)
    acc_time = acc_time - TICK_TIME
  end

  -- love.timer.sleep(3)

end

function love.draw()

  DrawTable(Board)

end

function DrawTable(b)

  local x = 2
  for _,v in ipairs(b) do

    local y = 2
    for _,s in ipairs(v) do
      if s == 1 then love.graphics.draw(W, x, y) end
      if s == 0 then love.graphics.draw(B, x, y) end
      y = y + 8

    end
    x = x + 8
    --if x == 64 then return end
  end

end

function GetLiveNeighbors(b, x, y)

  local n = 0

  if x == 1 or x == 66 then return 0 end
  if y == 1 or y == 66 then return 0 end

  if b[x][y + 1] == 1 then n = n + 1 end
  if b[x][y - 1] == 1 then n = n + 1 end
  if b[x + 1][y] == 1 then n = n + 1 end
  if b[x - 1][y] == 1 then n = n + 1 end
  if b[x + 1][y + 1] == 1 then n = n + 1 end
  if b[x + 1][y - 1] == 1 then n = n + 1 end
  if b[x - 1][y + 1] == 1 then n = n + 1 end
  if b[x - 1][y - 1] == 1 then n = n + 1 end

  return n
end

function UpdateBoard(board)

  local b = DeepCopy(board)

  for i,v in ipairs(b) do
    for j,s in ipairs(v) do
      -- read from current board, not the new board
      local n = GetLiveNeighbors(board, i, j)

      if s == 1 and n < 2 then b[i][j] = 0 end
      if s == 1 and n > 3 then b[i][j] = 0 end
      if s == 0 and n == 3 then b[i][j] = 1 end

    end
  end
  return b
end

function SetRandomTiles(board)

  local b = DeepCopy(board)

    for i,v in ipairs(b) do
      for j,_ in ipairs(v) do
        local n = love.math.random(2)
          if n == 1 then b[i][j] = 1 end
          if n == 2 then b[i][j] = 0 end
    end

  end
  return b
end

function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
