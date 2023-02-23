-- Only allow symbols available in all Lua versions
std = "min"

-- Get rid of "unused argument self"-warnings
self = false

-- Include globals available in OBS
globals = {
    "bit",
    "unpack",
    "obslua",
    "script_description",
    "script_update",
    "script_load",
    "script_unload",
    "script_save",
    "script_properties",
    "_T"
}

-- Ignure unused arguments
unused_args = false
