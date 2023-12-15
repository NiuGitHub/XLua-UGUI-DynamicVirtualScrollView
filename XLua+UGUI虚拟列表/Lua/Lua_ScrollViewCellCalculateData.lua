Lua_ScrollViewCellCalculateData = Lua_Class("Lua_ScrollViewCellCalculateData")
function Lua_ScrollViewCellCalculateData:ctor(posX, posY, width, height, data, ownerList)
    self:setDynamicPosAndSize(posX, posY, width, height)
    self.data = data
    self.ownerList = ownerList
    self.cell = nil
    self.First = true
end
function Lua_ScrollViewCellCalculateData:init(posX, posY, width, height, data)
    self:setDynamicPosAndSize(posX, posY, width, height)
    self.data = data
    if self.cell ~= nil then
        self.cell:setData(self.data)
        if self.cell.onSelectChange ~= nil then
            self.cell:onSelectChange(self.ownerList.curSelectedIdx == self._index)
        end
    end
end

function Lua_ScrollViewCellCalculateData:setDynamicPosAndSize(posX, posY, width, height)
    self.itemX = posX
    self.itemY = posY
    self.width = width
    self.height = height
    self.minX = posX - width / 2
    self.minY = posY - height / 2
    self.maxX = posX + width / 2
    self.maxY = posY + height / 2
    self.showRect = Lua_Rectangle.new(self.minX, self.minY, width, height)
    if self.cell ~= nil then
        self.cell:setLocation(self.itemX, self.itemY)
    end
end

function Lua_ScrollViewCellCalculateData:setIndex(idx)
    self._index = idx
    self._sizeDelta = nil
end
function Lua_ScrollViewCellCalculateData:getSizeDelta()
    return self._sizeDelta
end
function Lua_ScrollViewCellCalculateData:checkInBound(px, py, viewRect)
    self.showRect.x = self.minX + px
    self.showRect.y = self.minY + py
    if self.showRect:intersects(viewRect) then
        return true
    else
        return false
    end
end
function Lua_ScrollViewCellCalculateData:returnCellToPool()
    if self.cell ~= nil then
        self.ownerList:returnCell(self.cell)
        self.cell = nil
        self.ownerList = nil
    end
end
function Lua_ScrollViewCellCalculateData:getCellFromPool(ownerList)
    self.ownerList = ownerList
    if self.cell == nil then
        self.cell = self.ownerList:createCellItem()
        self.cell:setCellSeqIndex(self._index)
        self.cell:setLocation(self.itemX, self.itemY)
        self.cell:setData(self.data)
        if self._sizeDelta == nil then
            self._sizeDelta = {}
            local size = self.cell:getSizeDelta()
            self._sizeDelta.x = size.x
            self._sizeDelta.y = size.y
        end
    end
    if self.cell.onSelectChange ~= nil then
        self.cell:onSelectChange(self.ownerList.curSelectedIdx == self._index)
    end
end

function Lua_ScrollViewCellCalculateData:clean()
    self:returnCellToPool()
    self.data = nil
end
function Lua_ScrollViewCellCalculateData:dispose()
    self.cell = nil
    self.ownerList = nil
    self.data = nil
end
