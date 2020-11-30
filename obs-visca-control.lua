obs = obslua

plugin_settings = {}
plugin_def = {}
plugin_def.id = "Visca_Control"
plugin_def.type = obs.OBS_SOURCE_TYPE_INPUT;
plugin_def.output_flags = bit.bor(obs.OBS_SOURCE_CUSTOM_DRAW)
plugin_debug = true


local function log(fmt, ...)
    if plugin_debug then
        local info = debug.getinfo(2, "nl")
        local func = info.name or "?"
        local line = info.currentline
        print(string.format("%s (%d): %s", func, line, string.format(fmt, unpack(arg or {...}))))
    end
end

local function create_camera_controls(props, camera_id)
    log("entry - %d", camera_id)
    local cams = obs.obs_properties_get(props, "cameras")
    if cams then
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end
        obs.obs_property_list_add_int(cams, cam_name, camera_id)
        
        local prop_name = obs.obs_properties_get(props, cam_prop_prefix .. "name")
        if prop_name == nil then
            obs.obs_properties_add_text(props, cam_prop_prefix .. "name", "Name", obs.OBS_TEXT_DEFAULT)
            obs.obs_data_set_default_string(plugin_settings, cam_prop_prefix .. "name", cam_name)
        end
        local prop_address = obs.obs_properties_get(props, cam_prop_prefix .. "address")
        if prop_address == nil then
            obs.obs_properties_add_text(props, cam_prop_prefix .. "address", "IP Address", obs.OBS_TEXT_DEFAULT)
        end
        local prop_presets = obs.obs_properties_get(props, cam_prop_prefix .. "presets")
        if prop_presets == nil then
            prop_presets= obs.obs_properties_add_editable_list(props, cam_prop_prefix .. "presets", "Presets", obs.OBS_EDITABLE_LIST_TYPE_STRINGS, "", "")
        end
        obs.obs_property_set_modified_callback(prop_presets, prop_presets_validate)
    end
    log("done")
end

function script_description()
    return "<b>Camera control via Visca over IP</b><br>" ..
           "<a href=\"https://github.com/vwout/obs-visca-control\">https://github.com/vwout/obs-visca-control</a><br><br>" ..
           "Usage:<br>" ..
           "To add a preset in the list, use one the following naming conventions:<ul>" ..
           "<li>&lt;name&gt;&lt;separator&gt;&lt;preset id&gt;, e.g. 'Stage: 6'</li>" .. 
           "<li>&lt;preset id&gt;&lt;separator&gt;&lt;name&gt;, e.g. '5 = Pastor'</li>" ..
           "</ul>where &lt;separator&gt; is one of ':', '=' or '-'."
end

function script_update(settings)
    plugin_settings = settings
end

function script_properties()
    local props = obs.obs_properties_create()
    
    local num_cams = obs.obs_properties_add_int(props, "num_cameras", "Number of cameras", 0, 8, 1)
    obs.obs_property_set_modified_callback(num_cams, prop_num_cams)
    
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    log("num_cameras %d", num_cameras)
    
    local cams = obs.obs_properties_add_list(props, "cameras", "Camera", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    for camera_id = 1, num_cameras do
        create_camera_controls(props, camera_id)
    end
    
    obs.obs_property_set_modified_callback(cams, prop_set_attrs_values)
    --obs.obs_properties_apply_settings(props, settings)

    return props
end

function prop_num_cams(props, property, settings)
    local cam_added = false
    
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    log("num_cameras %d", num_cameras)
    local cams = obs.obs_properties_get(props, "cameras")
    if cams then
        local camera_count = obs.obs_property_list_item_count(cams)
        if num_cameras > camera_count then
            for camera_id = camera_count+1, num_cameras do
                create_camera_controls(props, camera_id)
            end
            cam_added = true
        end
    end
    
    return cam_added
end

--function prop_add_camera(props, property, settings)
--    local cams = obs.obs_properties_get(props, "cameras")
--    local num_cameras = obs.obs_property_list_item_count(cams)
--    --local num_cameras = obs.obs_data_get_int(settings, "num_cameras")
--    num_cameras = num_cameras + 1
--    obs.obs_data_set_int(settings, "num_cameras", num_cameras)
--    print(num_cameras)
--    
--    --local camera = {
--    --    id = num_cameras,
--    --    name = string.format("Camera %d", num_cameras),
--    --    address = "",
--    --    presets = {}
--    --}
--
--    create_camera_controls(props, num_cameras)
--    --obs.obs_property_list_add_int(cams, string.format("Camera %d", num_cameras), num_cameras)
--    --    
--    --local cam_prop_prefix = string.format("cam_%d_", num_cameras)
--    --
--    --obs.obs_properties_add_text(props, cam_prop_prefix .. "name", "Name", obs.OBS_TEXT_DEFAULT)
--    ----obs.obs_data_set_string(settings, cam_prop_prefix .. "name", camera.name)
--    --
--    --obs.obs_properties_add_text(props, cam_prop_prefix .. "address", "IP Address", obs.OBS_TEXT_DEFAULT)
--    --local presets = obs.obs_properties_add_editable_list(props, cam_prop_prefix .. "presets", "Presets", obs.OBS_EDITABLE_LIST_TYPE_STRINGS, "", "")
--    --obs.obs_property_set_modified_callback(presets, prop_set_preset_id)
--    ----obs.obs_properties_add_int(props, "preset_id", "Preset Id", 0, 127, 1)
--    --
--    ----table.insert(plugin_data.cameras, camera)
--    --obs.obs_properties_apply_settings(props, settings)
--
--    --return true
--end

function prop_set_attrs_values(props, property, settings)
    log("entry")
    local changed = false
    local num_cameras = obs.obs_property_list_item_count(property)
    local cam_idx = obs.obs_data_get_int(settings, "cameras")
    if cnt == 0 then
        cam_idx = 0
    end
    
    for camera_id = 1, num_cameras do
        local visible = cam_idx == camera_id
        log("%d %d %d", camera_id, cam_idx, visible and 1 or 0)
        
        local cam_prop_prefix = string.format("cam_%d_", camera_id)

        cam_props = {"name", "address", "presets"}
        for _,cam_prop_name in pairs(cam_props) do
            local cam_prop = obs.obs_properties_get(props, cam_prop_prefix .. cam_prop_name)
            if cam_prop then
                if obs.obs_property_visible(cam_prop) ~= visible then
                    obs.obs_property_set_visible(cam_prop, visible)
                    changed = true
                end
            end
        end
        --obs.obs_property_set_visible(obs.obs_properties_get(props, cam_prop_prefix .. "preset_id"), cam_idx == camera_id)
    end
    log("done %d", changed and 1 or 0)
    
    return changed
end

local function parse_preset_value(preset_value)
    local preset_name = nil
    local preset_id = nil
    local regex_patterns = {
        "^(.+)%s*[:=-]%s*(%d+)$",
        "^(%d+)%s*[:=-]%s*(.+)$"
    }
    
    for _,pattern in pairs(regex_patterns) do
        local v1 = nil
        local v2 = nil
        v1,v2 = string.match(preset_value, pattern)
        log("match '%s', '%s'", tostring(v1), tostring(v2))
        if (v1 ~= nil) and (v2 ~= nil) then
            if (tonumber(v1) == nil) and (tonumber(v2) ~= nil) then
                preset_name = v1
                preset_id = tonumber(v2)
                break
            elseif (tonumber(v2) == nil) and (tonumber(v1) ~= nil) then
                preset_name = v2
                preset_id = tonumber(v1)
                break
            end
        end
    end
    
    return preset_name, preset_id
end

function prop_presets_validate(props, property, settings)
    local presets = obs.obs_data_get_array(settings, obs.obs_property_name(property))
    local num_presets = obs.obs_data_array_count(presets)
    log("prop_presets_validate %s %d", obs.obs_property_name(property), num_presets)

    if num_presets > 0 then
        for i = 0, num_presets-1 do
            local preset = obs.obs_data_array_item(presets, i)
            --log(obs.obs_data_get_json(preset))
            local preset_value = obs.obs_data_get_string(preset, "value")
            log("check %s", preset_value)
            
            local preset_name, preset_id = parse_preset_value(preset_value)
            if (preset_name == nil) or (preset_id == nil) then
                print("Warning: preset '" .. preset_value .. "' has an unsupported syntax and cannot be used.")
            end
        end
    end
    
    obs.obs_data_array_release(presets)
end

plugin_def.get_name = function()
    return "Visca Camera Control"
end
