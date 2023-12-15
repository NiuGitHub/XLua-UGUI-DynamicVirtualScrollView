Lua_ScrollViewCell = Lua_Class("Lua_ScrollViewCell", Lua_DisplayObject)
function Lua_ScrollViewCell:ctor(go, skin, skinType)
    self:superCall("ctor", go, skin, skinType or Lua_DisplayObject.skinTypes.Prefab)
end
function Lua_ScrollViewCell:buildShowItem()
    self:superCall("buildShowItem")
    self.rectTransform = self.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
end
function Lua_ScrollViewCell:setCellSeqIndex(idx)
    self.cellSeqIndex = idx
    self.gameObject.name = self.classname .. "_" .. idx
end
function Lua_ScrollViewCell:setCallBack(func)
    self._clickCallBackFunc = func
end
function Lua_ScrollViewCell:onSelectChange(val)
    self.bSelect = val
end
function Lua_ScrollViewCell:setData(data)
end
function Lua_ScrollViewCell:getSizeDelta()
    return self.rectTransform.sizeDelta
end

--派发TabBar选中更新事件
function Lua_ScrollViewCell:dispatchCallBack()
    if self.bSelect ~= true and self._clickCallBackFunc then
        self._clickCallBackFunc(self.cellSeqIndex)
    end
end
function Lua_ScrollViewCell:onClick()
    self:dispatchCallBack()
end
