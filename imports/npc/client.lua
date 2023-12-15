local CreatePed <const> = CreatePed
local DoesEntityExist <const> = DoesEntityExist
local DeleteEntity <const> = DeleteEntity
local joaat <const> = joaat
local SetBlockingOfNonTemporaryEvents <const> = SetBlockingOfNonTemporaryEvents
local SetEntityInvincible <const> = SetEntityInvincible
local FreezeEntityPosition <const> = FreezeEntityPosition
local SetPedComponentVariation <const> = SetPedComponentVariation
local SetPedDefaultComponentVariation <const> = SetPedDefaultComponentVariation
local GiveWeaponToPed <const> = GiveWeaponToPed

---@class NpcWeaponsProps
---@field model string|number
---@field ammo? number-0
---@field visible? boolean-true
---@field hand? boolean-false

---@class DataNpcProps
---@field network? boolean-true
---@field blockevent? boolean-true
---@field godmode? boolean-true
---@field freeze? boolean-true
---@field variation? number
---@field weapon? NpcWeaponsProps

---@return nil
local function Remove(self)
    if DoesEntityExist(self.ped) then
        DeleteEntity(self.ped)
        return nil, collectgarbage()
    end
end

---@param useVec4? boolean
---@return vec3 | vec4
local function GetCoords(self, useVec4)
    if DoesEntityExist(self.ped) then
        local coords <const> = GetEntityCoords(self.ped)
        self.vec3 = coords
        if not useVec4 then return self.vec3 end
        local heading <const> = GetEntityHeading(self.ped)
        self.vec4 = vec4(coords.x, coords.y, coords.z, heading)
        return self.vec4
    end
end

---@param targetCoords vec3
---@return integer
local function Distance(self, targetCoords, useVec4)
    local coords <const> = self:getCoords(useVec4)
    return coords and #(coords - targetCoords)
end

---@param model string|number
---@param coords vec4
---@param data? DataNpcProps
---@return table
local function New(model, coords, data)
    local self = {}

    self.model = model
    self.vec3 = vec3(coords.x, coords.y, coords.z)
    self.vec4 = vec4(coords.x, coords.y, coords.z, coords.w or coords.h or 0.0)
    self.network = data.network or true
    self.blockevent = data.blockevent or true
    self.godmode = data.godmode or true
    self.freeze = data.freeze or true
    self.variation = data.variation
    self.weapon = data.weapon
    self.distance = Distance
    self.getCoords = GetCoords
    self.remove = Remove

    local p = promise.new()

    CreateThread(function()
        local FlushModel <const> = supv.request({ type = 'model', name = self.model })

        self.ped = CreatePed(_, self.model, self.vec4.x, self.vec4.y, self.vec4.z, self.vec4.w, self.network, false)
        FlushModel(self.model)

        if DoesEntityExist(self.ped) then
            SetBlockingOfNonTemporaryEvents(self.ped, self.blockevent or true)
            SetEntityInvincible(self.ped, self.godmode or true)
            FreezeEntityPosition(self.ped, self.freeze or true)
            if self.variation then SetPedComponentVariation(self.ped, self.variation) else SetPedDefaultComponentVariation(self.ped) end
            if type(self.weapon) == 'table' and self.weapon.model then
                local weapon <const> = type(self.weapon.model) == 'number' and self.weapon.model or joaat(self.weapon.model)
                GiveWeaponToPed(self.ped, weapon, self.weapon.ammo or 0, self.weapon.visible or true, self.weapon.hand or false)
            end
            p:resolve(self)
        else
            p:reject(('Failed to create ped in %s'):format(supv.env))
        end
    end)

    return supv.await(p)
end

---@deprecated Use new method instead
---@param model string|number
---@param coords vec4
---@param cb? function
---@param network? boolean-true
local function Create(model, coords, cb, network)
    model = type(model) == 'number' and model or joaat(model)
    local flushModel <const> = supv.request({ type = 'model', name = model })
    local ped = CreatePed(_, model, coords.x, coords.y, coords.z, coords.w or coords.h or 0.0, network or true, false)
    flushModel(model)
    if cb then cb(ped) end
end

return {
    new = New,
    create = Create ---@deprecated Use new method instead
}