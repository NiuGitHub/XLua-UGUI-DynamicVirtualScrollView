checkRequire("UI/_Base/NZh/Lua_ScrollViewCell")
checkRequire("UI/_Base/NZh/Lua_Rectangle")
checkRequire("UI/_Base/NZh/Lua_ScrollViewCellCalculateData")
Lua_ScrollView = Lua_Class("Lua_ScrollView", Lua_DisplayObject)
--go 挂载Lua_ScrollView组件的GameObject
--viewCellClass extend Lua_ScrollViewCell
function Lua_ScrollView:ctor(go, viewCellClass)
    self.viewCellClass = viewCellClass
    self:superCall("ctor", nil, go, Lua_DisplayObject.skinTypes.GameObject)
end
function Lua_ScrollView:buildShowItem()
    self:superCall("buildShowItem")
    self.scrollRect = self:get("", "Lua_ScrollView").Lua_ScrollView
    self.scrollRectTransform = self.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
    self.contentRectTransform = self.scrollRect.content
    self.contentGameObject = self.contentRectTransform.gameObject
    self.scrollRect.onValueChanged:AddListener(functional.bind1(self.onScrollMove, self))
    self.viewRectTransform = self.scrollRect.viewport
    self.viewGameObject = self.scrollRect.viewport.gameObject
    local sPivot = self.viewRectTransform.pivot
    self.viewSizeDelta = {x = self.viewRectTransform.rect.width, y = self.viewRectTransform.rect.height}
    -- print("Lua_ScrollView_buildShowItem", self.viewSizeDelta.x, self.viewSizeDelta.y, self.scrollRectTransform.rect.width, self.scrollRectTransform.rect.height)
    self.viewRectangle = Lua_Rectangle.new(-self.viewSizeDelta.x * sPivot.x, -self.viewSizeDelta.y * sPivot.y, self.viewSizeDelta.x, self.viewSizeDelta.y)
    -- self.viewRectangle = Lua_Rectangle.new(-self.viewSizeDelta.x / 2, -self.viewSizeDelta.y / 2, self.viewSizeDelta.x, self.viewSizeDelta.y)
    local cellRectTransform = self.itemPrefab:GetComponent(typeof(CS.UnityEngine.RectTransform))
    --0是左边
    self.cellPivotX = 1 - cellRectTransform.pivot.x
    --0是下边
    self.cellPivotY = cellRectTransform.pivot.y
    self.cellWidth = cellRectTransform.sizeDelta.x
    self.cellHeight = cellRectTransform.sizeDelta.y
    self.showCellArr = {}
    self.hideCellArr = {}
    self.showDragDataList = {}
    self._isDynamicCellSize = false
    self.curSelectedIdx = 0
end

function Lua_ScrollView.Get:layoutType()
    return self.scrollRect.layoutType
end
function Lua_ScrollView.Set:layoutType(val)
    self.scrollRect.layoutType = val
end
function Lua_ScrollView.Get:itemPrefab()
    return self.scrollRect.itemPrefab
end
function Lua_ScrollView.Set:itemPrefab(val)
    self.scrollRect.itemPrefab = val
end
function Lua_ScrollView.Get:perLineItemNum()
    return self.scrollRect.perLineItemNum
end
function Lua_ScrollView.Set:perLineItemNum(val)
    self.scrollRect.perLineItemNum = val
end
function Lua_ScrollView.Get:spacingX()
    return self.scrollRect.spacingX
end
function Lua_ScrollView.Set:spacingX(val)
    self.scrollRect.spacingX = val
end
function Lua_ScrollView.Get:spacingY()
    return self.scrollRect.spacingY
end
function Lua_ScrollView.Set:spacingY(val)
    self.scrollRect.spacingY = val
end
--子项是否是动态的size 只支持计算单行/单列动态大小
function Lua_ScrollView:setIsDynamicCellSize(val)
    if self.layoutType == 0 then
        self._isDynamicCellSize = val
    else
        self._isDynamicCellSize = val and self.perLineItemNum == 1
    end
    self._isDynamicCheck = true
end
--滑动回调
function Lua_ScrollView:setOnValueChangedFunc(val)
    self._onValueChangedFunc = val
end
--重新设置显示区域大小
function Lua_ScrollView:setScrollSizeDelta(w, h)
    self:clearShow()
    -- print("Lua_ScrollView setScrollSizeDelta", w, h)
    self.viewSizeDelta = Vector2(w, h)
    local sPivot = self.viewRectTransform.pivot
    self.viewRectangle = Lua_Rectangle.new(-self.viewSizeDelta.x * sPivot.x, -self.viewSizeDelta.y * sPivot.y, self.viewSizeDelta.x, self.viewSizeDelta.y)
    -- self.viewRectangle = Lua_Rectangle.new(-self.viewSizeDelta.x / 2, -self.viewSizeDelta.y / 2, self.viewSizeDelta.x, self.viewSizeDelta.y)
    self.scrollRectTransform.sizeDelta = self.viewSizeDelta
    if self.data ~= nil then
        self:setLuaArrayData(self.data)
    end
end
function Lua_ScrollView:setSelectIdx(idx)
    self:onCellClick(idx)
end
function Lua_ScrollView:setLuaArrData(data)
    if self._isDynamicCellSize then
        self:clearShow()
    end
    self.data = data
    self._isDynamicCheck = true
    local len = #data
    local perLineItemNum = self.perLineItemNum
    local cellWidth = self.cellWidth
    local cellHeight = self.cellHeight
    local cellPivotX = self.cellPivotX
    local cellPivotY = self.cellPivotY
    local spacingX = self.spacingX
    local spacingY = self.spacingY
    if self.layoutType == 0 then
        local mw = math.min(perLineItemNum, len)
        local maxWidth = math.max(0, mw * cellWidth + (mw - 1) * spacingX)
        self.contentRectTransform.sizeDelta = Vector2(maxWidth, self.viewSizeDelta.y)
    else
        local mh = math.ceil(len / perLineItemNum)
        local maxHeight = math.max(0, mh * cellHeight + (mh - 1) * spacingY)
        self.contentRectTransform.sizeDelta = Vector2(self.viewSizeDelta.x, maxHeight)
    end
    local num = #self.showDragDataList - len
    while (num > 0) do
        local l = self.showDragDataList[1]
        l:clean()
        num = num - 1
        table.remove(self.showDragDataList, 1)
    end
    while (num < 0) do
        local l = Lua_ScrollViewCellCalculateData.new(0, 0, 0, 0, nil, self)
        num = num + 1
        table.insert(self.showDragDataList, l)
    end
    for i = 1, len do
        local h_index = math.floor((i - 1) / perLineItemNum)
        local w_index = math.floor((i - 1) % perLineItemNum)
        l = self.showDragDataList[i]
        l:init(cellWidth * cellPivotX + cellWidth * w_index + w_index * spacingX, -cellHeight * cellPivotY - cellHeight * h_index - h_index * spacingY, cellWidth, cellHeight, data[i])
        l:setIndex(i)
        l.cellWidth = cellWidth
        l.cellHeight = cellHeight
    end
    self:_updateShowPos()
end

function Lua_ScrollView:onScrollMove(v2)
    self:_updateShowPos()
end
function Lua_ScrollView:_updateShowPos()
    local px = self.contentRectTransform.localPosition.x
    local py = self.contentRectTransform.localPosition.y
    local len = #self.showDragDataList
    for i = 1, len do
        local ll = self.showDragDataList[i]:checkInBound(px, py, self.viewRectangle)
        if ll then
            self.showDragDataList[i]:getCellFromPool(self)
        else
            self.showDragDataList[i]:returnCellToPool()
        end
    end
    --根据最新显示数据 重置item的坐标位置
    if self._isDynamicCellSize and self._isDynamicCheck then
        self:_calculateDynamicSize()
    end
    if self._onValueChangedFunc ~= nil then
        self._onValueChangedFunc()
    end
end

function Lua_ScrollView:_calculateDynamicSize()
    local maxWidthOrHeight = 0
    local perLineItemNum = self.perLineItemNum
    local cellWidth = self.cellWidth
    local cellHeight = self.cellHeight
    local cellPivotX = self.cellPivotX
    local cellPivotY = self.cellPivotY
    local spacingX = self.spacingX
    local spacingY = self.spacingY
    local len = #self.showDragDataList
    local offsetWidthOrHeight = 0
    local hasNull = false
    for i = 1, len do
        local showData = self.showDragDataList[i]
        local sizeDelta = showData:getSizeDelta()
        if sizeDelta == nil then
            sizeDelta = {x = cellWidth, y = cellWidth}
        else
            hasNull = true
        end
        local h_index = math.floor((i - 1) / perLineItemNum)
        local w_index = math.floor((i - 1) % perLineItemNum)
        local px = cellWidth * cellPivotX + cellWidth * w_index + w_index * spacingX
        local py = -cellHeight * cellPivotY - cellHeight * h_index - h_index * spacingY
        if i > 1 then
            local lastShowItem = self.showDragDataList[i - 1]
            if self.layoutType == 0 then
                px = lastShowItem.itemX + lastShowItem.width * cellPivotX + spacingX + sizeDelta.x * cellPivotX
            else
                py = lastShowItem.itemY - lastShowItem.height * cellPivotX - spacingY - sizeDelta.y * cellPivotY
            end
        end
        if self.layoutType == 0 then
            local offset = sizeDelta.x - cellWidth
            offsetWidthOrHeight = offsetWidthOrHeight + offset
        else
            local offset = sizeDelta.y - cellHeight
            offsetWidthOrHeight = offsetWidthOrHeight + offset
        end
        self.showDragDataList[i]:setDynamicPosAndSize(px, py, sizeDelta.x, sizeDelta.y)
    end
    self._isDynamicCheck = hasNull
    if self.layoutType == 0 then
        local mw = math.min(perLineItemNum, len)
        local maxWidth = mw * cellWidth + (mw - 1) * spacingX + offsetWidthOrHeight
        self.contentRectTransform.sizeDelta = Vector2(maxWidth, self.viewSizeDelta.y)
    else
        local mh = math.ceil(len / perLineItemNum)
        local maxHeight = mh * cellHeight + (mh - 1) * spacingY + offsetWidthOrHeight
        self.contentRectTransform.sizeDelta = Vector2(self.viewSizeDelta.x, maxHeight)
    end
end

function Lua_ScrollView:createCellItem()
    local len = #self.hideCellArr
    local item = nil
    if len > 0 then
        item = self.hideCellArr[1]
        table.remove(self.hideCellArr, 1)
    end
    if item == nil then
        item = self.viewCellClass.new(self.contentGameObject, self.itemPrefab, Lua_DisplayObject.skinTypes.Prefab)
        item:setCallBack(functional.bind(self.onCellClick, self))
    end
    item:setEnable(true)
    table.insert(self.showCellArr, item)
    return item
end
function Lua_ScrollView:onCellClick(idx)
    self.curSelectedIdx = idx
    local len = #self.showCellArr
    for i = 1, len do
        local cell = self.showCellArr[i]
        self.showCellArr[i]:onSelectChange(cell.cellSeqIndex == idx)
    end
end

function Lua_ScrollView:returnCell(cell)
    if cell == nil then
        return
    end
    local len = #self.showCellArr
    for i = 1, len do
        if self.showCellArr[i] == cell then
            cell:setEnable(false)
            table.remove(self.showCellArr, i)
            table.insert(self.hideCellArr, cell)
            break
        end
    end
end

function Lua_ScrollView:clearShow()
    self.curSelectedIdx = 0
    self.scrollRect.horizontalNormalizedPosition = 0
    self.scrollRect.verticalNormalizedPosition = 1
    self.scrollRect:StopMovement()
    -- CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.scrollRect.content)
    local item
    local len = #self.showCellArr
    while (len > 0) do
        item = self.showCellArr[len]
        table.remove(self.showCellArr, len)
        if item ~= nil then
            item:setEnable(false)
            table.insert(self.hideCellArr, item)
        end
        len = len - 1
    end
    self.showCellArr = {}
    if self.data ~= nil then
        self.data = nil
    end
    self.showDragDataList = {}
end

function Lua_ScrollView:dispose()
    self.viewCellClass = nil
    if self.dataArr ~= nil then
        self.dataArr = nil
    end
    if self.showCellArr ~= nil then
        self.showCellArr = nil
    end
    if self.hideCellArr ~= nil then
        self.hideCellArr = nil
    end
    self:superCall("dispose")
end
