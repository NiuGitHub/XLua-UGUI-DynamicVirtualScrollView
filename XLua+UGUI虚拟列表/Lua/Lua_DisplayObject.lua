Lua_DisplayObject = Lua_Class("Lua_DisplayObject")
Lua_DisplayObject.skinTypes = {}
Lua_DisplayObject.skinTypes.Path = 1
Lua_DisplayObject.skinTypes.Prefab = 2
Lua_DisplayObject.skinTypes.GameObject = 3
--skin  skinType 1 预制体路径 2 预制体 3 现有GameObject
function Lua_DisplayObject:ctor(go, skin, skinType)
    self:superCall("ctor")
    self.skinType = skinType and skinType or Lua_DisplayObject.skinTypes.GameObject
    if skin ~= nil then
        if self.skinType == Lua_DisplayObject.skinTypes.Path then
            self:buildFormSkinPath(skin, go)
        elseif self.skinType == Lua_DisplayObject.skinTypes.Prefab then
            self:buildFormSkinPrefab(skin, go)
        elseif self.skinType == Lua_DisplayObject.skinTypes.GameObject then
            self:bindGameObject(skin)
        end
    end
end
--通过预制体路径
function Lua_DisplayObject:buildFormSkinPath(skin, go)
    local skinPrefab = AssetLoader:LoadAsset(skin, typeof(GameObject))
    self:buildFormSkinPrefab(skinPrefab, go)
end
--通过预制体
function Lua_DisplayObject:buildFormSkinPrefab(skinPrefab, go)
    local p = go and go.transform or nil
    self:bindGameObject(Instantiate(skinPrefab, p))
end
--绑定现有
function Lua_DisplayObject:bindGameObject(go)
    self.gameObject = go
    if self.skinType == Lua_DisplayObject.skinTypes.Path or self.skinType == Lua_DisplayObject.skinTypes.Prefab then
        self.gameObject.name = self.classname
    end
    self.transform = self.gameObject.transform
    self:buildShowItem()
end
function Lua_DisplayObject:buildShowItem()
end

function Lua_DisplayObject:setLocation(x, y, z)
    z = z or 0
    self.transform.localPosition = Vector3(x, y, z)
end

function Lua_DisplayObject.Get:x()
    return self.transform.localPosition.x
end
function Lua_DisplayObject.Get:y()
    return self.transform.localPosition.y
end
function Lua_DisplayObject:setEnable(val)
    if self.gameObject ~= nil then
        self.gameObject:SetActive(val)
    end
end
function Lua_DisplayObject:dispose()
end
function Lua_DisplayObject:get(str, ...)
    if (IsNull(self.transform)) then
        return
    end
    local tf = self.transform:Find(str)

    if not tf then
        logError("can not find child " .. str)
        return
    end
    local obj = LuaClass(tf.gameObject)
    obj = UnityObjBase(obj)
    local typeNames = {...}
    for _, typeName in pairs(typeNames) do
        local comp = tf:GetComponent(typeName)
        if comp then
            if type(typeName) == "userdata" then
                obj[typeName.Name] = comp
            else
                obj[typeName] = comp
            end
        else
            logError("can not find compnent " .. typeName .. " for " .. str)
        end
    end
    return obj
end
