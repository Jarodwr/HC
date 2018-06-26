--[[
Copyright (c) 2011 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local _NAME, common_local = ..., common
if not (type(common) == 'table' and common.class and common.instance) then
	assert(common_class ~= false, 'No class commons specification available.')
	require(_NAME .. '.class')
end
local Shapes      = require(_NAME .. '.shapes')
local Spatialhash = require(_NAME .. '.spatialhash')

-- reset global table `common' (required by class commons)
if common_local ~= common then
	common_local, common = common, common_local
end

local HC = {}
function HC:init(cell_size)
	self.hash = common_local.instance(Spatialhash, cell_size or 100)
	self._shapes = {}
end

-- spatial hash management
function HC:resetHash(cell_size)
	local hash = self.hash
	self.hash = common_local.instance(Spatialhash, cell_size or 100)
	for shape in pairs(hash:shapes()) do
		self.hash:register(shape, shape:bbox())
	end
	return self
end

function HC:register(shape)
	self.hash:register(shape, shape:bbox())
	self._shapes[shape] = true
	return shape
end

function HC:remove(shape)
	self.hash:remove(shape, shape:bbox())
	self._shapes[shape] = false
	return self
end

-- collision detection
function HC:neighbors(shape)
	local neighbors = self.hash:inSameCells(shape:bbox())
	rawset(neighbors, shape, nil)
	return neighbors
end

function HC:collisions(shape)
	local candidates = self:neighbors(shape)
	for other in pairs(candidates) do
		local collides, dx, dy = shape:collidesWith(other)
		if collides then
			rawset(candidates, other, {dx,dy, x=dx, y=dy})
		else
			rawset(candidates, other, nil)
		end
	end
	return candidates
end

-- the class and the instance
HC = common_local.class('HardonCollider', HC)
local instance = common_local.instance(HC)

return {
	instance = function(...) return common_local.instance(HC, ...) end,
	shapes = Shapes
}