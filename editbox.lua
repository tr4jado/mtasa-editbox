-- Utils

local screenW, screenH = guiGetScreenSize()

local cursor = {
    state = false,
    x = 0,
    y = 0
}

function cursor:update()
    local state = isCursorShowing()

    if state then
        local x, y = getCursorPosition()
        self.x, self.y = x * screenW, y * screenH
    end

    self.state = state
end

function cursor:box(x, y, width, height)
    return self.x >= x and self.x <= x + width and self.y >= y and self.y <= y + height
end

local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

local _dxDrawText = dxDrawText
function dxDrawText(text, x, y, width, height, ...)
    return _dxDrawText(text, x, y, x + width, y + height, ...)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Class

Editbox = {}
Editbox.__index = Editbox

function Editbox.new(properties)
    local self = setmetatable({}, Editbox)

    self.text = ""

    -- Properties
    self.focus = false
    self.font = "default"
    self.mask = false
    self.isNumber = false
    self.maxLength = 0
    self.parent = {-1, -1, 0, 0}
    -- Properties

    self.x = 0
    self.y = 0
    self.width = false
    self.height = false

    self.renderTarget = nil

    if properties then
        for i, v in pairs(properties) do
            self[i] = v
        end
    end

    self.keys = {}

    for i in pairs({
        ["arrow_l"] = true,
        ["arrow_r"] = true,
        ["backspace"] = true,
        ["delete"] = true
    }) do
        self.keys[i] = {
            state = false,
            last = 0
        }
    end

    self.textW = 0
    self.textH = 0
    self.caretX = 0

    self.caretPosition = 0
    self.offset = 0
    self.offsetView = 0
    self.lastUpdate = getTickCount()

    self.allSelected = false

    addEventHandler("onClientClick", root, function(...) self:onClick(...) end)
    addEventHandler("onClientCharacter", root, function(...) self:onCharacter(...) end)
    addEventHandler("onClientKey", root, function(...) self:onKey(...) end)
    addEventHandler("onClientPaste", root, function(...) self:onPaste(...) end)

    if self.mask then
        assert(type(self.mask) == "string", "Bad argument @ 'Editbox.new' [expected string at argument 1, got " .. type(self.mask) .. "]")
    end

    return self
end

function Editbox:draw(placeholder, x, y, width, height, color)
    cursor:update()

    local now = getTickCount()

    self.x = x
    self.y = y

    if not isElement(self.renderTarget) or (not self.width or self.width ~= width or not self.height or self.height ~= height) then
        self.width = width
        self.height = height

        if isElement(self.rendertarget) then
            destroyElement(self.rendertarget)
        end

        self.renderTarget = dxCreateRenderTarget(width, height, true)
    end

    for i, v in pairs(self.keys) do
        if v.state and now - v.state >= 500 and now - v.last >= 30 then
            self:onKey(i, true)
        end
    end

    self.offsetView = lerp(self.offsetView, self.offset, 0.2)

    if self.offsetView ~= self.offset then
        self:updateRenderTarget()
    end

    if self.text:len() == 0 and not self.focus then
        dxDrawText(placeholder, x, y, width, height, color, 1, self.font, "left", "center")
    else
        dxSetBlendMode("add")
        dxDrawImage(x, y, width, height, self.renderTarget, 0, 0, 0, color)
        dxSetBlendMode("blend")
    end

    if self.focus and (now % 1000 < 500 or now - self.lastUpdate < 500) then
        dxDrawRectangle(x + clamp(self.width - 1, 0, self.caretX + self.offsetView), y + (height - self.textH) / 2, 1, self.textH, color)
    end

    if self.allSelected then
        local rectangleWidth = math.min(self.width, self.textW + self.offsetView)
        dxDrawRectangle(x, y + (height - self.textH) / 2, rectangleWidth, self.textH, self.focus and tocolor(0, 170, 255, 100) or tocolor(0, 0, 0, 100))
    end
end

function Editbox:updateRenderTarget()
    dxSetRenderTarget(self.renderTarget, true)
        dxDrawText(self.mask and self.mask:rep(utf8.len(self.text)) or self.text, self.offset, 0, self.width, self.height, tocolor(255, 255, 255), 1, self.font, "left", "center")
    dxSetRenderTarget()
end

function Editbox:updateOffset()
    local text = self.mask and self.mask:rep(utf8.len(self.text)) or self.text

    self.textW = dxGetTextWidth(text, 1, self.font)
    self.textH = dxGetFontHeight(1, self.font)
    self.caretX = dxGetTextWidth(utf8.sub(text, 1, self.caretPosition), 1, self.font)

    if self.caretX + self.offset < 0 then
        self.offset = -self.caretX
    elseif self.caretX + self.offset > self.width then
        self.offset = self.width - self.caretX
    elseif self.caretX <= self.width then
        self.offset = 0
    end

    self.lastUpdate = getTickCount()
end

function Editbox:setText(text)
    self.text = text
    self.caretPosition = #text

    self:updateOffset()
    self:updateRenderTarget()
end

function Editbox:destroy()
    if isElement(self.renderTarget) then
        destroyElement(self.renderTarget)
    end

    removeEventHandler("onClientClick", root, function(...) self:onClick(...) end)
    removeEventHandler("onClientCharacter", root, function(...) self:onCharacter(...) end)
    removeEventHandler("onClientKey", root, function(...) self:onKey(...) end)
    removeEventHandler("onClientPaste", root, function(...) self:onPaste(...) end)

    self = nil
end

function Editbox:onClick(button, state)
    if not (button == "left" and state == "down") then return end

    if cursor:box(unpack(self.parent)) then
        if self.focus then
            local text = self.mask and self.mask:rep(utf8.len(self.text)) or self.text
            local x = cursor.x - self.x - self.offset
            local new

            for i = 1, utf8.len(text) do
                local width = dxGetTextWidth(utf8.sub(text, 1, i), 1, self.font)

                if width > x then
                    new = i
                    break
                end
            end

            if new then
                self.caretPosition = new
            else
                self.caretPosition = utf8.len(text)
            end

            self.allSelected = false
            self:updateOffset()
            self:updateRenderTarget()
        end

        self.focus = true
        guiSetInputMode("no_binds")
    else
        self.focus = false
        guiSetInputMode("allow_binds")
    end
end

function Editbox:onCharacter(char)
    if
        not self.focus or
        (self.isNumber and not tonumber(char)) or
        (self.maxLength > 0 and utf8.len(self.text) >= self.maxLength) or
        not utf8.len(char)
    then return end

    if self.allSelected then
        self.text = char
        self.caretPosition = 1
        self.allSelected = false
    else
        self.text = utf8.sub(self.text, 1, self.caretPosition) .. char .. utf8.sub(self.text, self.caretPosition + 1)
        self.caretPosition = self.caretPosition + 1
    end

    self:updateOffset()
    self:updateRenderTarget()
end

function Editbox:onKey(key, press)
    if not self.focus then return end

    if press then
        local ctrl = getKeyState("lctrl") or getKeyState("rctrl")

        if key == "arrow_l" then
            if self.allSelected or ctrl then
                self.caretPosition = 0
                self.allSelected = false
            else
                self.caretPosition = clamp(self.caretPosition - 1, 0, utf8.len(self.text))
            end
        elseif key == "arrow_r" then
            if self.allSelected or ctrl then
                self.caretPosition = utf8.len(self.text)
                self.allSelected = false
            else
                self.caretPosition = clamp(self.caretPosition + 1, 0, utf8.len(self.text))
            end
        elseif key == "backspace" then
            if self.allSelected then
                self.text = ""
                self.caretPosition = 0
                self.allSelected = false
            elseif self.caretPosition > 0 then
                self.text = utf8.sub(self.text, 1, self.caretPosition - 1) .. utf8.sub(self.text, self.caretPosition + 1)
                self.caretPosition = self.caretPosition - 1
            end
        elseif key == "delete" then
            if self.allSelected then
                self.text = ""
                self.caretPosition = 0
                self.allSelected = false
            elseif self.caretPosition < utf8.len(self.text) then
                self.text = utf8.sub(self.text, 1, self.caretPosition) .. utf8.sub(self.text, self.caretPosition + 2)
            end
        elseif key == "c" and ctrl then
            if self.allSelected then
                setClipboard(self.text)
            end
        elseif key == "x" and ctrl then
            if self.allSelected then
                setClipboard(self.text)

                self.text = ""
                self.caretPosition = 0
                self.allSelected = false
            end
        elseif key == "a" and ctrl then
            self.allSelected = true
        end

        self:updateOffset()
        self:updateRenderTarget()

        if self.keys[key] then
            if self.keys[key].state then
                self.keys[key].last = getTickCount()
            else
                self.keys[key].state = getTickCount()
                self.keys[key].last = getTickCount()
            end
        end
    else
        if self.keys[key] then
            self.keys[key].state = false
        end
    end
end

function Editbox:onPaste(text)
    if not self.focus then return end
    if self.isNumber and not tonumber(text) then return end
    if self.maxLength > 0 and utf8.len(self.text) + #text >= self.maxLength then return end

    if self.allSelected then
        self.text = text
        self.caretPosition = #text
        self.allSelected = false
    else
        self.text = utf8.sub(self.text, 1, self.caretPosition) .. text .. utf8.sub(self.text, self.caretPosition + 1)
        self.caretPosition = self.caretPosition + #text
    end

    self:updateOffset()
    self:updateRenderTarget()
end
