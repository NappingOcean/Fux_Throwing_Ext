gdebug.log_info("Throwing_Ext: preload.")

local mod = game.mod_runtime[ game.current_mod ]

game.iuse_functions["THROW_EXT"] = function(...)
    return mod.iuse_function(...)
end