--- === AudioSwap ===
---
--- Let users swap between audio outputs ---
local wf = hs.window.filter.defaultCurrentSpace

local obj = {}
obj.__index = obj

-- luacheck: globals utf8

-- Metadata
obj.name = "AudioSwap"
obj.version = "1.0"
obj.author = "Sean Slater <seanslater@whatno.io>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/spslater/AudioSwapSpoon"

--- Variables
obj.swapHotkey = nil
obj.addHotkey = nil
obj.delHotkey = nil

obj.swapShow = nil
obj.addShow = nil
obj.delShow = nil

obj.addChooser = nil
obj.delChooser = nil

obj.devices = {}
obj.index = 1

local map = function (tbl, f)
    local t = {}
    for k,v in ipairs(tbl) do
        local res = f(v)
        if res ~= nil then
            t[k] = res
        end
    end
    return t
end

local printAll = function (tbl, pre, idx)
    if pre == nil then pre = "" end
    for i,v in ipairs(tbl) do
        if idx ~= nil then
            print(i, pre, v)
        else
            print(pre, v)
        end
    end
end

function obj:init()
    print("current default", hs.audiodevice.defaultOutputDevice())
    printAll(hs.audiodevice.allOutputDevices(), "available", true)

    self.addChooser = hs.chooser.new(self.addCallback)
    self.addChooser:rows(5)
    self.addChooser:searchSubText(true)

    self.delChooser = hs.chooser.new(self.delCallback)
    self.delChooser:rows(5)
    self.delChooser:searchSubText(true)

    return self
end

function obj.addCallback(choice)
    local lastFocused = wf:getWindows(wf.sortByFocusedLast)
    if #lastFocused > 0 then
        lastFocused[1]:focus()
    end
    if not choice then
        return
    end
    obj:addDevice(choice["name"])
end

function obj.delCallback(choice)
    local lastFocused = wf:getWindows(wf.sortByFocusedLast)
    if #lastFocused > 0 then
        lastFocused[1]:focus()
    end
    if not choice then
        return
    end
    obj:delDevice(choice["name"])
end

function obj:inDevices(dev)
    for _,d in ipairs(self.devices) do
        if d:name() == dev:name() then return true end
    end
    return false
end

function obj:rotateIndex()
    if #self.devices > 1 then
        self.index = self.index + 1
        if self.index > #self.devices then
            self.index = 1
        end
    end
end

function obj:swap()
    print("swapping")
    printAll(self.devices)
    if #self.devices then
        self:rotateIndex()
        local current = hs.audiodevice.defaultOutputDevice()
        local nextDev = self.devices[self.index]
        if #self.devices > 1 and current:uid() == nextDev:uid() then
            self:rotateIndex()
            nextDev = self.devices[self.index]
        end
        nextDev:setDefaultOutputDevice()
        print("current index", self.index)
    end

    return self
end

--- AudioSwap:addDevice(name)
--- Method
--- Add device to swap between
---
--- Parameters:
---  * name - name of device to add
---
--- Returns:
---  * The AudioSwap object
function obj:addDevice(name)
    print("looking to add device", name)
    local device = hs.audiodevice.findOutputByName(name)
    if device and not self:inDevices(device) then
        table.insert(self.devices, device)
    end
    print(name, device)

    return self
end

function obj:delDevice(name)
    print("looking to delete device", name)
    for i, device in ipairs(self.devices) do
        if device:name() == name then
            table.remove(self.devices, i)
            print("removing", device:name())
            return self
        end
    end
    print("no device name", name, "found")
   return self
end

--- AudioSwap:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for AudioSwap
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---    * swap - swaping hotkey
---    * add  - add new device to rotation
---    * del  - delete existing device from rotation
---
--- Returns:
---  * The AudioSwap object
function obj:bindHotkeys(mapping)
    if mapping["swap"] ~= nil then
        local swapMods = mapping["swap"][1]
        local swapKey = mapping["swap"][2]
        local swapShow = mapping["swap"][3] or nil

        if self.swapHotkey then
            self.swapHotkey:delete()
        end

        self.swapHotkey = hs.hotkey.new(
            swapMods,
            swapKey,
            function()
                self:swap()
            end
        ):enable()
    end

    if mapping["add"] ~= nil then
        local addMods = mapping["add"][1]
        local addKey = mapping["add"][2]
        local addShow = mapping["add"][3] or nil

        if self.addHotkey then
            self.addHotkey:delete()
        end

        self.addHotkey = hs.hotkey.new(
            addMods,
            addKey,
            function()
                if self.addChooser:isVisible() then
                    self.addChooser:hide()
                else
                    local names = map(
                        hs.audiodevice.allOutputDevices(),
                        function(d)
                            return {text=d:name(),name=d:name()}
                        end
                    )
                    self.addChooser:choices(names)
                    self.addChooser:show()
                end
            end
        ):enable()
    end

    if mapping["del"] ~= nil then
        local delMods = mapping["del"][1]
        local delKey = mapping["del"][2]
        local delShow = mapping["add"][3] or nil

        if self.delHotkey then
            self.delHotkey:delete()
        end


        self.delHotkey = hs.hotkey.new(
            delMods,
            delKey,
            function()
                if self.delChooser:isVisible() then
                    self.delChooser:hide()
                else
                    local names = map(
                        self.devices,
                        function(d)
                            return {text=d:name(),name=d:name()}
                        end
                    )
                    self.delChooser:choices(names)
                    self.delChooser:show()
                end
            end
        ):enable()
    end

    return self
end

return obj
