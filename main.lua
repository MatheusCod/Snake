function love.load()

  -- Window configuration
  windowWidth = 600
  windowHeight = 600
  love.window.setMode(windowWidth, windowHeight)
  love.window.setTitle("Snake")

  -- Attetion!
  -- This must me true: windowWidth % snake_size == 0
  -- This must me true: windowheight % snake_size == 0

  -- Global variables
  snake_size = 20
  time_update = 0.06
  time_limit = 0.06
  score = 0
  moveUp = false
  moveDown = false
  moveRight = false
  moveLeft = false

  -- Creat arrays of points's possible positions
  possible_Xpos = {}
  possible_Xpos[1] = 0
  for i=2,windowWidth/snake_size do
    possible_Xpos[i] = possible_Xpos[i-1] + snake_size
  end
  possible_Ypos = {}
  possible_Ypos[1] = 0
  for i=2,windowHeight/snake_size do
    possible_Ypos[i] = possible_Ypos[i-1] + snake_size
  end

  -- Creates a new snake
  snake = {}
  snake = newSnake()
  -- Calculate the cell position that the last snake cell was before it changes
  -- (Do snakes have tails?)
  snake_tail = {}
  snake_tail.x = 0
  snake_tail.y = 0
  snake_tail.directionX = 1
  snake_tail.directionY = 0

  -- Creates a point
  point = {}
  point = newPoint()

end

function love.update(dt)

  --Updates timer
  time_update = time_update + dt

  if (time_update > time_limit) then

    -- Computes tails last position
    snake_tail.x = snake[table.getn(snake)].x
    snake_tail.y = snake[table.getn(snake)].y
    snake_tail.directionX = snake[table.getn(snake)].directionX
    snake_tail.directionY = snake[table.getn(snake)].directionY

    -- Computes next position
    for i=table.getn(snake),2,-1 do
      snake[i].x = snake[i-1].x
      snake[i].y = snake[i-1].y
    end
    snake[1].x = snake[1].x + snake_size * snake[1].directionX
    snake[1].y = snake[1].y + snake_size * snake[1].directionY

    moveUp = false
    moveDown = false
    moveRight = false
    moveLeft = false

    -- Part of game movement logic
    if (snake[1].directionX == 0 and snake[1].directionY == -1) then
      moveUp = true
    elseif (snake[1].directionX == 0 and snake[1].directionY == 1) then
      moveDown = true
    elseif (snake[1].directionX == 1 and snake[1].directionY == 0) then
      moveRight = true
    elseif (snake[1].directionX == -1 and snake[1].directionY == 0) then
      moveLeft = true
    end

    -- Resets timer
    time_update = time_update - time_limit
  end

  -- Checks self collision
  for i=2,table.getn(snake) do
    if (snake[1].x == snake[i].x and snake[1].y == snake[i].y) then
      love.window.showMessageBox("Game Over", "Game Over\nScore: " .. tostring(score) .. "\nClick 'Ok' or press Enter to start a new game.", "info", true)
      love.load()
      break
    end
  end

  -- Checks scores
  if ((snake[1].x == point.x) and (snake[1].y == point.y)) then
    score = score + 1
    snake[table.getn(snake)+1] = {}
    snake[table.getn(snake)].x = snake_tail.x
    snake[table.getn(snake)].y = snake_tail.y
    snake[table.getn(snake)].directionX = snake_tail.directionX
    snake[table.getn(snake)].directionY = snake_tail.directionY
    point = newPoint()
  end

  -- When reach a wall, teleport to the other side of the screen
  if snake[1].x > windowWidth - snake_size then
    snake[1].x = 0
  elseif snake[1].x < 0 then
    snake[1].x = windowWidth - snake_size
  elseif snake[1].y > windowHeight - snake_size then
    snake[1].y = 0
  elseif snake[1].y < 0 then
    snake[1].y = windowHeight - snake_size
  end

  -- Checks wall collision
  --[[
  if ((snake[1].x >= windowWidth + snake_size) or (snake[1].x <= 0 - snake_size) or
      (snake[1].y >= windowHeight + snake_size) or (snake[1].y <= 0 - snake_size)) then
    love.window.showMessageBox("Game Over", "Game Over\nScore: " .. tostring(score) .. "\nClick 'Ok' or press Enter to start a new game.", "info", true)
    snake = newSnake()
    point = newPoint()
  end ]]--

end

function love.draw()

  -- Draws snake
  for i=1,table.getn(snake) do
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", snake[i].x, snake[i].y, snake_size, snake_size)
  end

  -- Draws point
  for i=1,table.getn(snake) do
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.rectangle("fill", point.x, point.y, snake_size, snake_size)
  end

end


-- It is called whenever a key is pressed
-- Override
function love.keypressed(key, scancode, isrepeat)

  if ((key == "w" or key =="up") and (not moveDown)) then
    snake[1].directionX = 0
    snake[1].directionY = -1
  elseif ((key == "s" or key =="down") and (not moveUp)) then
    snake[1].directionX = 0
    snake[1].directionY = 1
  elseif ((key == "d" or key =="right") and (not moveLeft)) then
    snake[1].directionX = 1
    snake[1].directionY = 0
  elseif ((key == "a" or key =="left") and (not moveRight)) then
    snake[1].directionX = -1
    snake[1].directionY = 0
  end

end

-- Creates a new snake. It is called at the game's start and after a game over.
function newSnake()
  local snake = {}
  for i=1,3 do
    snake[i] = {}
    snake[i].x = 200 - snake_size * i
    snake[i].y = 200
    snake[i].directionX = 1
    snake[i].directionY = 0
  end

  moveUp = false
  moveDown = false
  moveRight = false
  moveLeft = false

  time_update = 0.06
  score = 0

  return snake
end

-- Creates a new colectable point
function newPoint()
  local point = {}
  point.x = possible_Xpos[love.math.random(1, table.getn(possible_Xpos))]
  point.y = possible_Ypos[love.math.random(1, table.getn(possible_Ypos))]
  local i = 1
  local j = 1
  local k = 1
  while (i <= table.getn(snake)) do
    if ((point.x == snake[i].x) and (point.y == snake[i].y)) then
      point.x = possible_Xpos[love.math.random(1, table.getn(possible_Xpos))]
      point.y = possible_Ypos[love.math.random(1, table.getn(possible_Ypos))]
      i = 1
    else
      i = i + 1
    end
  end

  return point

end
