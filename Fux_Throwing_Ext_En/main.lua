gdebug.log_info("Throwing_Ext: main.")

local mod = game.mod_runtime[ game.current_mod ]

mod.item_name = "Fux 긴급소화기"

-- This is fields for fire.
-- There must be an easier way to do this, but I'm not sure.
local fire_field1 = FieldTypeIntId.new(FieldTypeId.new("fd_fire"))
local fire_field2 = FieldTypeIntId.new(FieldTypeId.new("fd_fire_vent"))
local fire_field3 = FieldTypeIntId.new(FieldTypeId.new("fd_flame_burst"))
local fire_field4 = FieldTypeIntId.new(FieldTypeId.new("fd_incendiary"))

mod.field_type_fire = {
    fire_field1,
    fire_field2,
    fire_field3,
    fire_field4
}

-- Code to see how a FieldTypeIntId is generated
gdebug.log_info(tostring(fire_field1).."is fd_fire IntId")

-- Returns whether this tile has a flame or not
mod.fire_alert = function (map, pos)
    for _, v in ipairs(mod.field_type_fire) do
        if map:has_field_at(pos, v) then
            return true
        end
    end
    return false
end

-- I threw it, but where are the flames?
mod.get_where_is_fire = function (map, pos)
    local around = Tripoint.new(0,0,0)
    local place_fire = {}
    for x = 1, 3, 1 do
        for y = 1, 3, 1 do
            local p = Tripoint.new(x-2, y-2, 0)
            around = p + pos
            if mod.fire_alert(map, around) then
                place_fire [#place_fire+1] = around
            end
        end
    end
    
    return place_fire
end

-- Extinguish the fire!
mod.extinguish = function (map, pos)

    for _, v in ipairs(mod.field_type_fire) do
        if map:has_field_at(pos, v) then
            map:remove_field_at(pos, v)
        end
    end
    
end

-- This item is activated by throwing it, so it looks at the pos of the item's location and extinguishes the flame field in the 9 tiles around it.
mod.iuse_function = function(who, item, item_pos)
    
    local map = gapi.get_map()
    local fire = mod.get_where_is_fire(map, item_pos)

    -- next(fire) == nil: 
    -- Negative for when 'fire' table is empty (no flames around the thrown item).
    if next(fire) ~= nil then
        for _, v in ipairs(fire) do
            mod.extinguish(map, v)
        end
        gapi.add_msg(locale.gettext(mod.item_name.."가 터지며 화재를 덮는다!"))
    end
    -- iuse_function also needs a return! I almost forgot this at the end.
    return 1
end