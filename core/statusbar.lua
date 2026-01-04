setfenv(1, DFRL:GetEnv())

local animations = {}
local pulses = {}
local cutouts = {}

local ANIMATION_SPEED = 0.1
local PULSE_DURATION = 0.3
local PULSE_FADE_IN = 0.1
local PULSE_CURVE = 0.7
local PULSE_SCALE = 1.05
local CUTOUT_DURATION = .3
local CUTOUT_ALPHA = 1

-- public
function CreateStatusBar(parent, width, height, animConfig)
    local bar = CreateFrame('Frame', nil, parent)
    bar:SetWidth(width or 200)
    bar:SetHeight(height or 20)

    bar.bg = bar:CreateTexture(nil, 'BACKGROUND')
    bar.bg:SetPoint('TOPLEFT', bar, 'TOPLEFT', 0, 0)
    bar.bg:SetPoint('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 0, 0)
    bar.bg:SetTexture('Interface\\Buttons\\WHITE8X8')
    bar.bg:SetVertexColor(0, 0, 0, 0.5)

    bar.fill = bar:CreateTexture(nil, 'ARTWORK')
    bar.fill:SetPoint('TOPLEFT', bar, 'TOPLEFT', 0, 0)
    bar.fill:SetTexture('Interface\\TargetingFrame\\UI-StatusBar')
    bar.fill:SetVertexColor(0, 0.9, 0.2, 1)

    bar.val = 0
    bar.val_ = 0
    bar.max = 1
    bar.baseColor = {0, 0.9, 0.2, 1}
    bar.pulseColor = {1, 1, 1, 1}
    bar.cutoutColor = {0, 0.9, 0.2, 1}
    bar.bgColor = {0, 0, 0, 0.5}
    bar.cutoutDuration = CUTOUT_DURATION
    bar.cutoutTexture = 'Interface\\TargetingFrame\\UI-StatusBar'
    bar.fillDirection = 'LEFT_TO_RIGHT'
    bar.cutoutSuppressed = 0

    animConfig = animConfig or {}
    bar.enableBarAnim = animConfig.barAnim ~= false
    bar.enablePulse = animConfig.pulse ~= false
    bar.enableCutout = animConfig.cutout ~= false

    function bar:Update()
        local pct = self.val_ / self.max
        if pct <= 0.001 then
            pct = 0.001
        end
        if self.fillDirection == 'RIGHT_TO_LEFT' then
            self.fill:SetTexCoord(1-pct, 1, 0, 1)
        else
            self.fill:SetTexCoord(0, pct, 0, 1)
        end
        self.fill:SetWidth(self:GetWidth() * pct)
        self.fill:SetHeight(self:GetHeight())
    end

    function bar:SetValue(val, instant)
        -- only process if value actually changed
        if self.val ~= val then
            local currentTime = GetTime()
            if val < self.val and not instant and self.enableCutout and currentTime > self.cutoutSuppressed then
                -- calculate old and new percentages
                local oldPct = self.val / self.max
                local newPct = val / self.max
                local cutWidth = self:GetWidth() * (oldPct - newPct)

                -- create cutout texture to show lost value
                local cutout = self:CreateTexture(nil, 'ARTWORK')
                cutout:SetTexture(self.cutoutTexture)
                cutout:SetVertexColor(self.cutoutColor[1], self.cutoutColor[2], self.cutoutColor[3], CUTOUT_ALPHA)
                -- set texture coordinates for cutout portion
                if self.cutoutTexCoord then
                    cutout:SetTexCoord(self.cutoutTexCoord[1], self.cutoutTexCoord[2], self.cutoutTexCoord[3], self.cutoutTexCoord[4])
                else
                    if self.fillDirection == 'RIGHT_TO_LEFT' then
                        cutout:SetTexCoord(1-oldPct, 1-newPct, 0, 1)
                    else
                        cutout:SetTexCoord(newPct, oldPct, 0, 1)
                    end
                end
                -- constrain cutout width to bar boundaries
                local maxCutWidth = self:GetWidth() * (self.fillDirection == 'RIGHT_TO_LEFT' and oldPct or (1 - newPct))
                cutWidth = math.min(cutWidth, maxCutWidth)
                -- position cutout at the lost value area
                if self.fillDirection == 'RIGHT_TO_LEFT' then
                    cutout:SetPoint('TOPLEFT', self, 'TOPLEFT', self:GetWidth() * (1-oldPct), 0)
                else
                    cutout:SetPoint('TOPLEFT', self, 'TOPLEFT', self:GetWidth() * newPct, 0)
                end
                cutout:SetWidth(cutWidth)
                cutout:SetHeight(self:GetHeight())

                -- register cutout for fade animation
                cutouts[cutout] = {endTime = GetTime() + self.cutoutDuration, duration = self.cutoutDuration}
            end

            -- determine if we should use instant update
            local useInstant = instant or self.instant or (currentTime <= self.cutoutSuppressed)
            self.val = val
            -- handle animated vs instant updates
            if not useInstant and (self.enableBarAnim or self.enablePulse) then
                -- register for smooth value animation
                if self.enableBarAnim then
                    animations[self] = true
                end
                -- register for pulse color animation
                if self.enablePulse then
                    pulses[self] = GetTime() + PULSE_DURATION
                end
                -- if no bar animation, update display value immediately
                if not self.enableBarAnim then
                    self.val_ = val
                    self:Update()
                end
            else
                -- instant update - no animations
                pulses[self] = nil
                self.fill:SetVertexColor(self.baseColor[1], self.baseColor[2], self.baseColor[3], self.baseColor[4])
                self.val_ = val
                self:Update()
            end
        end
    end

    function bar:SetInstant(instant)
        self.instant = instant
    end

    function bar:SetBarAnimation(enabled)
        self.enableBarAnim = enabled
        if not enabled then animations[self] = nil end
    end

    function bar:SetPulseAnimation(enabled)
        self.enablePulse = enabled
        if not enabled then pulses[self] = nil end
    end

    function bar:SetCutoutAnimation(enabled)
        self.enableCutout = enabled
    end

    function bar:SuppressCutout(duration)
        self.cutoutSuppressed = GetTime() + (duration or 0.1)
    end

    function bar:SetTextures(fillTex, bgTex)
        self.fill:SetTexture(fillTex)
        self.bg:SetTexture(bgTex)
        self.cutoutTexture = fillTex
    end

    function bar:SetFillColor(r, g, b, a)
        self.baseColor = {r, g, b, a}
        self.fill:SetVertexColor(r, g, b, a)
    end

    function bar:SetCutoutColor(r, g, b, a)
        self.cutoutColor = {r, g, b, a}
    end

    function bar:SetPulseColor(r, g, b, a)
        self.pulseColor = {r, g, b, a}
    end

    function bar:SetBgColor(r, g, b, a)
        self.bgColor = {r, g, b, a}
        self.bg:SetVertexColor(r, g, b, a)
    end

    function bar:SetFillDirection(direction)
        self.fillDirection = direction
        if direction == 'RIGHT_TO_LEFT' then
            self.fill:ClearAllPoints()
            self.fill:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 0, 0)
        else
            self.fill:ClearAllPoints()
            self.fill:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
        end
        self:Update()
    end

    return bar
end

-- update functions
local function UpdateBarAnimations()
    for bar in pairs(animations) do
        if bar.enableBarAnim then
            -- check if animation is complete
            if bar.instant or bar.val_ == bar.val then
                -- snap to final value
                bar.val_ = bar.val
                -- remove from animation table
                animations[bar] = nil
            else
                -- lerp current value toward target value
                bar.val_ = bar.val_ + (bar.val - bar.val_) * ANIMATION_SPEED
            end
            -- update bar visual width
            bar:Update()
        else
            -- remove disabled bars
            animations[bar] = nil
        end
    end
end

local function UpdatePulseAnimations(now)
    for bar, endTime in pairs(pulses) do
        if bar.enablePulse then
            -- check if pulse is finished
            if now >= endTime then
                -- reset to base color
                bar.fill:SetVertexColor(bar.baseColor[1], bar.baseColor[2], bar.baseColor[3], bar.baseColor[4])
                bar:Update()
                -- remove from pulse table
                pulses[bar] = nil
            else
            -- calculate remaining time
            local timeLeft = endTime - now
            local progress
            -- determine fade phase
            if timeLeft > PULSE_DURATION * (1 - PULSE_FADE_IN) then
                -- fade in phase
                progress = 1 - ((timeLeft - PULSE_DURATION * (1 - PULSE_FADE_IN)) / (PULSE_DURATION * PULSE_FADE_IN))
            else
                -- fade out phase
                progress = (timeLeft / (PULSE_DURATION * (1 - PULSE_FADE_IN))) ^ PULSE_CURVE
            end
            -- interpolate between base and pulse colors
            local r = bar.baseColor[1] + (bar.pulseColor[1] - bar.baseColor[1]) * progress
            local g = bar.baseColor[2] + (bar.pulseColor[2] - bar.baseColor[2]) * progress
            local b = bar.baseColor[3] + (bar.pulseColor[3] - bar.baseColor[3]) * progress
            -- apply interpolated color
            bar.fill:SetVertexColor(r, g, b, 1)

            -- calculate pulse scale effect
            local scale = 1 + (PULSE_SCALE - 1) * progress
            local pct = bar.val_ / bar.max
            -- apply scaled dimensions
            if bar.fillDirection == 'RIGHT_TO_LEFT' then
                bar.fill:SetTexCoord(1-pct, 1, 0, 1)
            else
                bar.fill:SetTexCoord(0, pct, 0, 1)
            end
            bar.fill:SetWidth(bar:GetWidth() * pct * scale)
            bar.fill:SetHeight(bar:GetHeight() * scale)
            end
        else
            -- remove disabled pulses
            pulses[bar] = nil
        end
    end
end

local function UpdateCutoutAnimations(now)
    for cutout, data in pairs(cutouts) do
        -- check if cutout fade is complete
        if now >= data.endTime then
            -- destroy cutout texture
            cutout:SetTexture(nil)
            -- remove from cutouts table
            cutouts[cutout] = nil
        else
            -- calculate fade progress
            local progress = (data.endTime - now) / data.duration
            -- apply fading alpha
            cutout:SetAlpha(CUTOUT_ALPHA * progress)
        end
    end
end

-- handler
local animate = CreateFrame'Frame'
animate:SetScript('OnUpdate', function()
    local now = GetTime()
    UpdateBarAnimations()
    UpdatePulseAnimations(now)
    UpdateCutoutAnimations(now)
end)
