obs = obslua
Visca = require("libvisca")

plugin_info = {
    name = "Visca Camera Control",
    version = "1.1",
    url = "https://github.com/vwout/obs-visca-control",
    description = "Camera control via Visca over IP",
    author = "vwout"
}

plugin_settings = {}
plugin_def = {}
plugin_def.id = "Visca_Control"
plugin_def.type = obs.OBS_SOURCE_TYPE_INPUT;
plugin_def.output_flags = bit.bor(obs.OBS_SOURCE_CUSTOM_DRAW)
plugin_data = {}
plugin_data.debug = false
plugin_data.active_scene = nil
plugin_data.preview_scene = nil

local actions = {
    Camera_Off = 0,
    Camera_On  = 1,
    Preset_Recal = 2,
}

local action_active = {
    Program = 1,
    Preview = 2,
    Always = 3,
}


local function log(fmt, ...)
    if plugin_data.debug then
        local info = debug.getinfo(2, "nl")
        local func = info.name or "?"
        local line = info.currentline
        print(string.format("%s (%d): %s", func, line, string.format(fmt, unpack(arg or {...}))))
    end
end

local function create_camera_controls(props, camera_id, settings)
    local cams = obs.obs_properties_get(props, "cameras")
    if cams then
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name_suffix = string.format(" (cam %d)", camera_id)
        
        local cam_name = obs.obs_data_get_string(settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end
        obs.obs_property_list_add_int(cams, cam_name, camera_id)
        
        local prop_name = obs.obs_properties_get(props, cam_prop_prefix .. "name")
        if prop_name == nil then
            obs.obs_properties_add_text(props, cam_prop_prefix .. "name", "Name" .. cam_name_suffix, obs.OBS_TEXT_DEFAULT)
            obs.obs_data_set_default_string(plugin_settings, cam_prop_prefix .. "name", cam_name)
        end
        local prop_address = obs.obs_properties_get(props, cam_prop_prefix .. "address")
        if prop_address == nil then
            obs.obs_properties_add_text(props, cam_prop_prefix .. "address", "IP Address" .. cam_name_suffix, obs.OBS_TEXT_DEFAULT)
        end
        local prop_presets = obs.obs_properties_get(props, cam_prop_prefix .. "presets")
        if prop_presets == nil then
            prop_presets = obs.obs_properties_add_editable_list(props, cam_prop_prefix .. "presets", "Presets" .. cam_name_suffix, obs.OBS_EDITABLE_LIST_TYPE_STRINGS, "", "")
        end
        obs.obs_property_set_modified_callback(prop_presets, prop_presets_validate)
    end
end

function script_description()
    return "<b>" .. plugin_info.description .. "</b><br>" ..
           "Version: " .. plugin_info.version .. "<br>" ..
           "<a href=\"" .. plugin_info.url .. "\">" .. plugin_info.url .. "</a><br><br>" ..
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
        create_camera_controls(props, camera_id, plugin_settings)
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
                create_camera_controls(props, camera_id, settings)
            end
            cam_added = true
        end
    end
    
    return cam_added
end

function prop_set_attrs_values(props, property, settings)
    local changed = false
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    local cam_idx = obs.obs_data_get_int(settings, "cameras")
    if cnt == 0 then
        cam_idx = 0
    end
    
    for camera_id = 1, num_cameras do
        local visible = cam_idx == camera_id
        log("%d %d %d", camera_id, cam_idx, visible and 1 or 0)
        
        local cam_prop_prefix = string.format("cam_%d_", camera_id)

        local cam_props = {"name", "address", "presets", "preset_info"}
        for _,cam_prop_name in pairs(cam_props) do
            local cam_prop = obs.obs_properties_get(props, cam_prop_prefix .. cam_prop_name)
            if cam_prop then
                if obs.obs_property_visible(cam_prop) ~= visible then
                    obs.obs_property_set_visible(cam_prop, visible)
                    changed = true
                end
            end
        end
    end
    
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
            --log("check %s", preset_value)
            
            local preset_name, preset_id = parse_preset_value(preset_value)
            if (preset_name == nil) or (preset_id == nil) then
                print("Warning: preset '" .. preset_value .. "' has an unsupported syntax and cannot be used.")
            end
        end
    end
    
    obs.obs_data_array_release(presets)
end

plugin_def.get_name = function()
    return plugin_info.name
end

plugin_def.create = function(settings, source)
    local data = {}
    local source_sh = obs.obs_source_get_signal_handler(source)
	obs.signal_handler_connect(source_sh, "activate", signal_on_activate)
    obs.obs_frontend_add_event_callback(fe_callback)
    return data
end

plugin_def.destroy = function(source)
end

plugin_def.get_properties = function (data)
	local props = obs.obs_properties_create()
    
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
	local prop_camera = obs.obs_properties_add_list(props, "scene_camera", "Camera:", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)

	local prop_action = obs.obs_properties_add_list(props, "scene_action", "Action:", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
	obs.obs_property_list_add_int(prop_action, "Camera Off", actions.Camera_Off)
	obs.obs_property_list_add_int(prop_action, "Camera On", actions.Camera_On)
	obs.obs_property_list_add_int(prop_action, "Preset Recall", actions.Preset_Recal)
    
    for camera_id = 1, num_cameras do
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name_suffix = string.format(" (cam %d)", camera_id)

        local cam_name = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end
        obs.obs_property_list_add_int(prop_camera, cam_name, camera_id)
        
        local prop_presets = obs.obs_properties_add_list(props, "scene_" .. cam_prop_prefix .. "preset", "Presets" .. cam_name_suffix, obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
        local presets = obs.obs_data_get_array(plugin_settings, cam_prop_prefix .. "presets")
        local num_presets = obs.obs_data_array_count(presets)
        log("get_properties %s %d", cam_prop_prefix .. "preset", num_presets)

        if num_presets > 0 then
            local first_preset = true
            for i = 0, num_presets-1 do
                local preset = obs.obs_data_array_item(presets, i)
                --log(obs.obs_data_get_json(preset))
                local preset_value = obs.obs_data_get_string(preset, "value")
                --log("check %s", preset_value)
                
                local preset_name, preset_id = parse_preset_value(preset_value)
                if (preset_name ~= nil) and (preset_id ~= nil) then
                    obs.obs_property_list_add_int(prop_presets, preset_name, preset_id)
                    if first_preset then
                        obs.obs_data_set_default_int(plugin_settings, "scene_" .. cam_prop_prefix .. "preset", preset_id)
                        first_preset = false
                    end
                end
            end
        end
        
        obs.obs_data_array_release(presets)
    end

	local prop_active = obs.obs_properties_add_list(props, "scene_active", "Action Active:", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
	obs.obs_property_list_add_int(prop_active, "On Program", action_active.Program)
	obs.obs_property_list_add_int(prop_active, "On Preview", action_active.Preview)
	obs.obs_property_list_add_int(prop_active, "Always", action_active.Always)

	obs.obs_properties_add_bool(props, "preview_exclusive", "Run action on preview only when the camera is not active on program")

    --obs.obs_properties_add_button(props, "run_action", "Perform action now", cb_run_action)

    obs.obs_property_set_modified_callback(prop_camera, cb_camera_changed)

	return props
end

local function do_cam_action(settings)
    local camera_id = obs.obs_data_get_int(settings, "scene_camera")
    local action = obs.obs_data_get_int(settings, "scene_action")
    
    local cam_prop_prefix = string.format("cam_%d_", camera_id)
    local camera_address = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "address")
    local preset_id = obs.obs_data_get_int(settings, "scene_".. cam_prop_prefix .. "preset")
    
    log("Set cam %d @%s action %d (preset %d)", camera_id, camera_address, action, preset_id)
    local connection = Visca.connect(camera_address)
    if action == actions.Camera_Off then
        connection.Cam_Power(false)
    elseif action == actions.Camera_On then
        connection.Cam_Power(true)
    elseif action == actions.Preset_Recal then
        connection.Cam_Preset_Recall(preset_id)
    end
    connection.close()
end

function cb_camera_changed(props, property, data)
    local changed = false
    local num_cameras = obs.obs_property_list_item_count(property)
    local cam_idx = obs.obs_data_get_int(data, obs.obs_property_name(property))
    if cnt == 0 then
        cam_idx = 0
    end
    
    for camera_id = 1, num_cameras do
        local visible = cam_idx == camera_id
        log("cb_camera_changed %d %d %d", camera_id, cam_idx, visible and 1 or 0)
        
        local cam_prop_prefix = string.format("scene_cam_%d_", camera_id)

        local cam_props = {"preset"}
        for _,cam_prop_name in pairs(cam_props) do
            local cam_prop = obs.obs_properties_get(props, cam_prop_prefix .. cam_prop_name)
            if cam_prop then
                if obs.obs_property_visible(cam_prop) ~= visible then
                    obs.obs_property_set_visible(cam_prop, visible)
                    changed = true
                end
            end
        end
    end
    
    return changed
end

local function camera_active_on_program(preview_camera_id)
    local active = false

    local program_source = obs.obs_frontend_get_current_scene()
    if program_source ~= nil then
        local program_scene = obs.obs_scene_from_source(program_source)
        local program_scene_name = obs.obs_source_get_name(program_source)
        log("Current program scene is %s", program_scene_name or "?")

        local program_scene_items = obs.obs_scene_enum_items(program_scene)
        if program_scene_items ~= nil then
            for _, program_scene_item in ipairs(program_scene_items) do
                local program_scene_item_source = obs.obs_sceneitem_get_source(program_scene_item)
                local program_scene_item_source_id = obs.obs_source_get_unversioned_id(program_scene_item_source)
                if program_scene_item_source_id == plugin_def.id then
                    local visible = obs.obs_source_showing(program_scene_item_source)
                    if visible then
                        local program_item_source_settings = obs.obs_source_get_settings(program_scene_item_source)
                        if program_item_source_settings ~= nil then
                            local program_camera_id = obs.obs_data_get_int(program_item_source_settings, "scene_camera")
                            log("Camera active on preview: %d active on program: %d", preview_camera_id, program_camera_id)
                            if preview_camera_id == program_camera_id then
                                active = true
                                break
                            end

                            obs.obs_data_release(program_item_source_settings)
                        end
                    end
                end
            end

            obs.sceneitem_list_release(program_scene_items)
        end

        obs.obs_source_release(program_source)
    end

    return active
end

function fe_callback(event, data)
    if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED then
        --local scenesource = obs.obs_frontend_get_current_scene()
        --log("fe_callback OBS_FRONTEND_EVENT_SCENE_CHANGED to %s", plugin_data.active_scene or "?")
        --obs.obs_source_release(scenesource)
    elseif event == obs.OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED then
        local scenesource = obs.obs_frontend_get_current_preview_scene()
        if scenesource ~= nil then
            local scene = obs.obs_scene_from_source(scenesource)
            local scene_name = obs.obs_source_get_name(scenesource)
            if plugin_data.preview_scene ~= scene_name then
                plugin_data.preview_scene = scene_name
                log("OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED to %s", scene_name or "?")

                local scene_items = obs.obs_scene_enum_items(scene)
                if scene_items ~= nil then
                    for _, scene_item in ipairs(scene_items) do
                        local source = obs.obs_sceneitem_get_source(scene_item)
                        local source_id = obs.obs_source_get_unversioned_id(source)
                        if source_id == plugin_def.id then
                            local settings = obs.obs_source_get_settings(source)
                            local source_name = obs.obs_source_get_name(source)
                            local visible = obs.obs_source_showing(source)

                            if visible then
                                local do_action = false
                                local active = obs.obs_data_get_int(settings, "scene_active")

                                if (active == action_active.Preview) or (active == action_active.Always) then
                                    do_action = true

                                    local preview_exclusive = obs.obs_data_get_bool(settings, "preview_exclusive")
                                    if preview_exclusive then
                                        local preview_camera_id = obs.obs_data_get_int(settings, "scene_camera")
                                        if camera_active_on_program(preview_camera_id) then
                                            do_action = false
                                        end
                                    end
                                end

                                if do_action then
                                    log("Running Visca for source '%s'", source_name or "?")
                                    do_cam_action(settings)
                                end
                            end

                            obs.obs_data_release(settings)
                        end
                    end
                end

                obs.sceneitem_list_release(scene_items)
            end

            obs.obs_source_release(scenesource)
        end
    end
end

function signal_on_activate(calldata)
    local source = obs.calldata_source(calldata, "source")
	local settings = obs.obs_source_get_settings(source)

    local do_preset = false
    local active = obs.obs_data_get_int(settings, "scene_active")
    if (active == action_active.Program) or (active == action_active.Always) then
        do_preset = true
    end

    if do_preset then
        do_cam_action(settings)
    end

	obs.obs_data_release(settings)
end

obs.obs_register_source(plugin_def)
