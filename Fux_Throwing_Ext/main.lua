gdebug.log_info("Throwing_Ext: main.")

local mod = game.mod_runtime[ game.current_mod ]

mod.item_name = "Fux 긴급소화기"

-- 이것은 불꽃 필드여...!
-- 분명 이거보다 더 쉽게 하는 방법이 있을 것 같은데 잘 모르겠다.
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

-- FieldTypeIntId 가 어떤 식으로 생성되는지 확인하기 위한 코드
gdebug.log_info(tostring(fire_field1).."is fd_fire IntId")

-- 이 타일에는 불꽃이 있다vs없다를 반환하는 함수
mod.fire_alert = function (map, pos)
    for _, v in ipairs(mod.field_type_fire) do
        if map:has_field_at(pos, v) then
            return true
        end
    end
    return false
end

-- 던지긴 했는데 주위에 불꽃이 어디있나? 를 보는 함수
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

-- 불꽃을 지우는 함수
mod.extinguish = function (map, pos)

    for _, v in ipairs(mod.field_type_fire) do
        if map:has_field_at(pos, v) then
            map:remove_field_at(pos, v)
        end
    end
    
end

-- 이 아이템은 던져서 작동시키니까, 아이템의 위치 pos를 보고 그 주변 9칸에 있는 불꽃 필드를 소멸시킨다.
mod.iuse_function = function(who, item, item_pos)
    
    local map = gapi.get_map()
    local fire = mod.get_where_is_fire(map, item_pos)

    -- next(fire) == nil: 
    -- fire가 비어있는 경우(던진 아이템의 주위에 불꽃이 없음)에 대한 부정을 의미한다.
    if next(fire) ~= nil then
        for _, v in ipairs(fire) do
            mod.extinguish(map, v)
        end
        gapi.add_msg(locale.gettext(mod.item_name.."가 터지며 화재를 덮는다!"))
    end
    -- iuse_function도 return이 필요하다! 마지막에 이거 빼먹을 뻔했어.
    return 1
end