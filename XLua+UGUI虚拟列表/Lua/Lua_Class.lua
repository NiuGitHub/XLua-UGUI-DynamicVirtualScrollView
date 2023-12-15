local platform = CS.UnityEngine.Application.platform
local runtimePlatform = CS.UnityEngine.RuntimePlatform
function checkRequire(name)
    if rmodules == nil then
        rmodules = {}
    end
    if rmodules[name] == nil then
        local lastIdx = name:find("/[^/]*$") or 1
        local moduleName = name:sub(lastIdx + 1);
        local e = load('require "' .. name .. '"; return ' .. moduleName .. ";")
        local b = e()
        if b == nil then
            local f = load('require "' .. name .. '"; return ' .. name .. ";")
            local c = f()
            rmodules[name] = c
        else
            rmodules[name] = b
        end
    end
    -- local bRefresh = string.EndsWith(name, "Window") or string.EndsWith(name, "_skin") or string.EndsWith(name, "Panel") or string.EndsWith(name, "Cell") or string.EndsWith(name, "Item")
    -- if bRefresh and platform == runtimePlatform.WindowsEditor then
    --     updateRequire(name)
    -- end
    -- rmodules[name] = require(name)
    return rmodules[name]
end
function updateRequire(name)
    if rmodules == nil then
        return
    end

    if rmodules[name] ~= nil then
        rmodules[name] = nil
        local package = package
        package.loaded[name] = nil
        package.preload[name] = nil
        local f = load('require "' .. name .. '"; return ' .. name .. ";")
        local c = f()
        rmodules[name] = c
    end
end

function Lua_Class(classname, super)
    local cls = {}
    cls.classname = classname
    cls.class = cls
    cls.Get = {}
    cls.Set = {}

    local Get = cls.Get
    local Set = cls.Set

    if super then
        -- copy super method
        for key, value in pairs(super) do
            if type(value) == "function" and key ~= "ctor" then
                cls[key] = value
            end
        end

        -- copy super getter
        for key, value in pairs(super.Get) do
            Get[key] = value
        end

        -- copy super setter
        for key, value in pairs(super.Set) do
            Set[key] = value
        end

        cls.super = super
    end
    function cls.__index(self, key)
        local func = cls[key]
        if func then
            return func
        end

        local getter = Get[key]
        if getter then
            return getter(self)
        end

        return nil
    end

    function cls.__newindex(self, key, value)
        local setter = Set[key]
        if setter then
            setter(self, value)
            return
        end

        if Get[key] then
            assert(false, "readonly property")
        end
        rawset(self, key, value)
    end
    function cls.new(...)
        local self = setmetatable({}, cls)
        local function create(cls, ...)
            if cls.ctor ~= nil then
                cls.ctor(self, ...)
            else
                self:superCall("ctor", ...)
            end
        end
        create(cls, ...)

        return self
    end
    function cls:superCall(funStr, ...)
        if self.superCalled == nil then
            self.superCalled = {}
        end
        local s = self
        local s_fun = nil
        while true do
            if s ~= nil then
                s = s.super
                if s ~= nil then
                    local hasRun = false
                    for i, v in pairs(self.superCalled) do
                        if v == s[funStr] then
                            hasRun = true
                            break
                        end
                    end
                    if s[funStr] == self[funStr] then
                        hasRun = true
                    end
                    if hasRun == false then
                        s_fun = s[funStr]
                        if s_fun ~= nil then
                            self.superCalled[s.classname] = s_fun
                            break
                        end
                    end
                end
            else
                break
            end
        end
        if s_fun ~= nil then
            s_fun(self, ...)
        end
        self.superCalled = nil
    end
    -- compat
    cls.dtor = nil
    function cls.delete(self)
        if tracebacks[self] < 0 then
            return
        end
        local destroy
        destroy = function(cls)
            if cls.dtor then
                cls.dtor(self)
            end
            if cls.super then
                destroy(cls.super)
            end
        end
        destroy(cls)
        tracebacks[self] = -tracebacks[self]
    end
    return cls
end
