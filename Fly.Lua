-- Flying
_G.FLYING = false
local LP = game:service('Players').LocalPlayer
local T = LP.Character.UpperTorso
local CONTROL = {F = 0, B = 0, L = 0, R = 0}
local lCONTROL = {F = 0, B = 0, L = 0, R = 0}
local SPEED = 5
local MOUSE = LP:GetMouse()


local function FLY()
    _G.FLYING = true
    local BG = Instance.new('BodyGyro', T)
    local BV = Instance.new('BodyVelocity', T)
    BG.P = 9e4
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.cframe = T.CFrame
    BV.velocity = Vector3.new(0, 0.1, 0)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)


    spawn(function()
      repeat wait()
        LP.Character.Humanoid.PlatformStand = true
        if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then
          SPEED = 50
        elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0) and SPEED ~= 0 then
          SPEED = 0
        end
        if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 then
          BV.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
          lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
        elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and SPEED ~= 0 then
          BV.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
        else
          BV.velocity = Vector3.new(0, 0.1, 0)
        end
        BG.cframe = game.Workspace.CurrentCamera.CoordinateFrame
      until not _G.FLYING
      CONTROL = {F = 0, B = 0, L = 0, R = 0}
      lCONTROL = {F = 0, B = 0, L = 0, R = 0}
      SPEED = 0
      BG:destroy()
      BV:destroy()
      LP.Character.Humanoid.PlatformStand = false
    end)
  end
  
  MOUSE.KeyDown:connect(function(KEY)
    if KEY:lower() == 'w' then
      CONTROL.F = 1
    elseif KEY:lower() == 's' then
      CONTROL.B = -1
    elseif KEY:lower() == 'a' then
      CONTROL.L = -1 
    elseif KEY:lower() == 'd' then 
      CONTROL.R = 1
    end
  end)
  
  MOUSE.KeyUp:connect(function(KEY)
    if KEY:lower() == 'w' then
      CONTROL.F = 0
    elseif KEY:lower() == 's' then
      CONTROL.B = 0
    elseif KEY:lower() == 'a' then
      CONTROL.L = 0
    elseif KEY:lower() == 'd' then
      CONTROL.R = 0
    end
  end)




  FLY()
