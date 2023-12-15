Lua_Rectangle = Lua_Class("Lua_Rectangle");
function Lua_Rectangle:ctor(x,y,width,height)
	self.x = x;  
	self.y = y;  --x，y表示矩阵最下定点
	self.width = width;
	self.height = height;
end
function Lua_Rectangle:setRect(x,y,width,height)
	self.x = x;  
	self.y = y;  
	self.width = width;
	self.height = height;
end
function Lua_Rectangle:containPoint(px, py) --点（px,py）在区域内
	return px >= self.x
		and px <= self.x + self.width
		and py >= self.y
		and py <= self.y + self.height;
end
function Lua_Rectangle:intersects(rect) --两个区域是否相交

	return self.x < rect.x + rect.width
		and rect.x < self.x + self.width
		and self.y < rect.y + rect.height
		and rect.y < self.y + self.height;
end
function Lua_Rectangle:intersectRectangle(rect) --相交的小矩阵
	local rec = Lua_Rectangle.new();
	local x1 = math.max(self.x, rect.x);
	local x2 = math.min(self.x + self.width, rect.x + rect.width);
	local y1 = math.max(self.y, rect.y);
	local y2 = math.min(self.y + self.height, rect.y + rect.height);
	if x2 >= x1 and y2 >= y1 then
		rec.x = x1;
		rec.y = y1;
		rec.width = x2 - x1;
		rec.height = y2 - y1;
	end
	return rec;
end
function Lua_Rectangle:containeRect(rect)
	return self.x <= rect.x and self.x + self.width >= rect.x + rect.width and self.y <= rect.y and self.y + self.height >= rect.y + rect.height
end
function Lua_Rectangle:toString()
	return "["..self.x..","..self.y..","..self.width..","..self.height.."]";
end