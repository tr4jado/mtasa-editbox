Editbox = {}
Editbox.__index = Editbox
Editbox.instances = {}
Editbox.focus = false

local list_properties = {
    ['font'] = 'userdata',
    ['align'] = 'string',
    ['wordbreak'] = 'boolean',
    ['mask'] = 'boolean',
    ['maskchar'] = 'string',
    ['isnumber'] = 'boolean',
    ['max'] = 'number',
    ['cursor'] = 'boolean',
    ['parent'] = 'table'
}

function Editbox.new(properties)
    local self = setmetatable({}, Editbox)

    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0

    self.text = ''
    self.selected = false

    self.backspace = {
        press = false,
        last = 0
    }

    self.properties = {
        font = 'default-bold',
        align = 'left',
        max = 9999,
        cursor = true,
        parent = {0, 0, 0, 0}
    }

    table.insert(Editbox.instances, self)

    if properties then
        assert(type(properties) == 'table', 'bad argument #1 to \'new\' (table expected, got ' .. type(properties) .. ')')
        self:setProperties(properties)
    end

    return self
end

function Editbox:draw(display, x, y, width, height, color)
    self.x, self.y, self.width, self.height = x, y, width, height

    local font = self.properties.font
    local align = self.properties.align
    local wordbreak = self.properties.wordbreak
    local mask = self.properties.mask

    local tick = getTickCount()

    if self.backspace.press then
        if tick - self.backspace.press >= 500 and tick - self.backspace.last >= 50 then
            self.text = self.text:sub(1, #self.text - 1)
            self.backspace.last = tick
        end
    end

    local text = mask and string.rep(self.properties.maskchar, #self.text) or self.text
    local textW, textH = dxGetTextSize(text, width, 1, 1, font, wordbreak)

    dxDrawText(
        (self.text:len() > 0 or Editbox.focus == self) and
        text .. ((wordbreak and self.properties.cursor) and '|' or '') or display,
        x, y, width + x, height + y,
        color, 1, font,
        wordbreak and align or (textW > width and 'right' or align),
        wordbreak and (textH > height and 'bottom' or 'top') or 'top',
        true, wordbreak
    )

    if Editbox.focus == self then
        if self.properties.cursor and not wordbreak then
            local cursorX = x

            if align == 'center' then
                cursorX = x + (width + textW) / 2
            elseif align == 'right' then
                cursorX = x + width - 2
            elseif align == 'left' then
                cursorX = x + textW
            end

            cursorX = math.min(cursorX, x + width)

            local r, g, b = bitExtract(color, 0, 8), bitExtract(color, 8, 8), bitExtract(color, 16, 8)
            dxDrawRectangle(cursorX, y, 1, height, tocolor(r, g, b, math.abs(math.sin(tick / 255) * 200)))
        end

        if self.selected then
            if align == 'center' and textW <= width then
                local centerX, centerY = (width - textW) / 2, (height - textH) / 2
                x, y = x + centerX, y + centerY
            end

            dxDrawRectangle(x, y, math.min(width, textW), height, tocolor(29, 161, 242, 50))
        end
    else
        self.selected = false
    end
end

function Editbox:setProperties(propertie, value)
    assert(propertie, 'bad argument #1 to \'setProperties\' (got nil)')

    if type(propertie) == 'table' then
        for k, v in pairs(propertie) do
            self:setProperties(k, v)
        end

        return
    end

    assert(list_properties[propertie], 'bad argument #1 to \'setProperties\' (invalid propertie \'' .. propertie .. '\')')
    assert(type(value) == list_properties[propertie], 'bad argument #2 to \'setProperties\': ' .. propertie .. ' (' .. list_properties[propertie] .. ' expected, got \'' .. type(value) .. '\')')

    self.properties[propertie] = value
    return true
end

function Editbox:destroy()
    for i, v in ipairs(Editbox.instances) do
        if v == self then
            table.remove(Editbox.instances, i)
            self = nil

            collectgarbage()
            return true
        end
    end

    return false
end

-- Events

addEventHandler('onClientCharacter', root, function(char)
    if not Editbox.focus then
        return
    end

    local self = Editbox.focus

    if self.properties.isnumber and not tonumber(char) then
        return
    end

    if self.selected then
        self.text = char
        self.selected = false
    else
        if #self.text >= self.properties.max then
            return
        end

        self.text = self.text .. char
    end
end)

addEventHandler('onClientKey', root, function(key, state)
    if not Editbox.focus then
        return
    end

    local self = Editbox.focus

    if key == 'backspace' then
        if state then
            if self.selected then
                self.text = ''
                self.selected = false
            else
                self.text = self.text:sub(1, #self.text - 1)

                self.backspace.press = getTickCount()
                self.backspace.last = getTickCount()
            end
        else
            self.backspace.press = false
        end
    else
        if getKeyState('lctrl') then
            if key == 'a' then
                self.selected = true
            elseif key == 'c' then
                if self.selected then
                    setClipboard(self.text)
                end
            elseif key == 'x' then
                if self.selected then
                    setClipboard(self.text)
                    self.text = ''
                    self.selected = false
                end
            end
        end
    end

    if not (getKeyState('lctrl') and key == 'v') then
        cancelEvent()
    end
end)

addEventHandler('onClientPaste', root, function(text)
    if not Editbox.focus then
        return
    end

    local self = Editbox.focus

    if self.selected then
        self.text = text
        self.selected = false
    else
        if #self.text + #text > self.properties.max then
            return
        end

        self.text = self.text .. text
    end
end)

addEventHandler('onClientClick', root, function(button, state)
    if button ~= 'left' or state ~= 'down' then
        return
    end

    local focus = false

    for _, self in ipairs(Editbox.instances) do
        self.selected = false

        if cursor.box(unpack(self.properties.parent)) then
            focus = self
        end
    end

    Editbox.focus = focus
end)
