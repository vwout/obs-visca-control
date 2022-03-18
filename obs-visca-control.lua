local obs = obslua
local Visca = require("libvisca")

local plugin_info = {
    name = "Visca Camera Control",
    version = "1.6",
    url = "https://github.com/vwout/obs-visca-control",
    description = "Camera control via Visca over IP",
    author = "vwout"
}

local plugin_def = {
    id = "Visca_Control",
    type = obs.OBS_SOURCE_TYPE_INPUT,
    output_flags = bit.bor(obs.OBS_SOURCE_CUSTOM_DRAW),
}

local plugin_settings = {}
local plugin_data = {
    debug = false,
    active_scene = nil,
    preview_scene = nil,
    connections = {},
    hotkeys = {},
}

local actions = {
    Camera_Off = 0,
    Camera_On = 1,
    Preset_Recal = 2,
    PanTilt = 3,
    Zoom_In = 4,
    Zoom_Out = 5,
    Focus_Auto = 6,
    Focus_Manual = 7,
    Focus_Near = 8,
    Focus_Far = 9,
    Focus_Refocus = 10,
    Focus_Infinity = 11,
}

local action_active = {
    Program = 1,
    Preview = 2,
    Always = 3,
}

local function log(fmt, ...)
    if plugin_data.debug or obs.obs_data_get_bool(plugin_settings, "debug_logging") then
        local info = debug.getinfo(2, "nl")
        local func = info.name or "?"
        local line = info.currentline

        local args = {}
        for i, a in ipairs(arg or { ... }) do
            if type(a) == "table" then
                local kvs = nil
                for k, v in pairs(a) do
                    if kvs then
                        kvs = string.format("%s, %s=%s", kvs, k, tostring(v))
                    else
                        kvs = string.format("%s=%s", k, tostring(v))
                    end
                end
                args[i] = kvs or "-"
            else
                args[i] = a
            end
        end

        print(string.format("%s (%d): %s", func, line, string.format(fmt, unpack(args))))
    end
end

local function parse_preset_value(preset_value)
    local preset_name = nil
    local preset_id = nil
    local regex_patterns = {
        "^(.+)%s*[:=-]%s*(%d+)$",
        "^(%d+)%s*[:=-]%s*(.+)$"
    }

    for _, pattern in pairs(regex_patterns) do
        local v1, v2 = string.match(preset_value, pattern)
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

local function prop_presets_validate(props, property, settings)
    local presets = obs.obs_data_get_array(settings, obs.obs_property_name(property))
    local num_presets = obs.obs_data_array_count(presets)
    log("prop_presets_validate %s %d", obs.obs_property_name(property), num_presets)

    if num_presets > 0 then
        for i = 0, num_presets - 1 do
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
            obs.obs_properties_add_text(props, cam_prop_prefix .. "name", "Name" .. cam_name_suffix,
                obs.OBS_TEXT_DEFAULT)
            obs.obs_data_set_default_string(settings, cam_prop_prefix .. "name", cam_name)
        end
        local prop_address = obs.obs_properties_get(props, cam_prop_prefix .. "address")
        if prop_address == nil then
            obs.obs_properties_add_text(props, cam_prop_prefix .. "address", "IP Address" .. cam_name_suffix,
                obs.OBS_TEXT_DEFAULT)
        end
        local prop_port = obs.obs_properties_get(props, cam_prop_prefix .. "port")
        if prop_port == nil then
            obs.obs_properties_add_int(props, cam_prop_prefix .. "port", "UDP Port" .. cam_name_suffix, 1025, 65535, 1)
            obs.obs_data_set_default_int(settings, cam_prop_prefix .. "port", Visca.default_port)
        end
        local prop_mode = obs.obs_properties_add_list(props, cam_prop_prefix .. "mode", "Mode" .. cam_name_suffix,
            obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
        obs.obs_property_list_add_int(prop_mode, "Generic", Visca.modes.generic)
        obs.obs_property_list_add_int(prop_mode, "PTZOptics", Visca.modes.ptzoptics)
        obs.obs_data_set_default_int(settings, cam_prop_prefix .. "mode", Visca.modes.generic)
        local prop_presets = obs.obs_properties_get(props, cam_prop_prefix .. "presets")
        if prop_presets == nil then
            prop_presets = obs.obs_properties_add_editable_list(props, cam_prop_prefix .. "presets",
                "Presets" .. cam_name_suffix, obs.OBS_EDITABLE_LIST_TYPE_STRINGS, "", "")
        end
        obs.obs_property_set_modified_callback(prop_presets, prop_presets_validate)
    end
end

local function prop_set_attrs_values(props, property, settings)
    local changed = false
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    local cam_idx = obs.obs_data_get_int(settings, "cameras")
    if num_cameras == 0 then
        cam_idx = 0
    end

    for camera_id = 1, num_cameras do
        local visible = cam_idx == camera_id
        log("%d %d %d", camera_id, cam_idx, visible and 1 or 0)

        local cam_prop_prefix = string.format("cam_%d_", camera_id)

        local cam_props = { "name", "address", "port", "mode", "presets", "preset_info" }
        for _, cam_prop_name in pairs(cam_props) do
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

local function prop_num_cams(props, property, settings)
    local cam_added = false

    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    log("num_cameras %d", num_cameras)
    local cams = obs.obs_properties_get(props, "cameras")
    if cams then
        local camera_count = obs.obs_property_list_item_count(cams)
        if num_cameras > camera_count then
            for camera_id = camera_count + 1, num_cameras do
                create_camera_controls(props, camera_id, settings)
            end
            cam_added = true
        end
    end

    return cam_added
end

local function close_visca_connection(camera_id)
    local connection = plugin_data.connections[camera_id]

    if connection ~= nil then
        connection.close()
        connection = nil
        plugin_data.connections[camera_id] = connection
    end
end

local function open_visca_connection(camera_id, camera_address, camera_port, camera_mode)
    local connection = plugin_data.connections[camera_id]

    if connection == nil then
        local new_connection, connection_error = Visca.connect(camera_address, camera_port)
        if new_connection then
            connection = new_connection
            if camera_mode then
                connection.set_mode(camera_mode)
            end
            plugin_data.connections[camera_id] = connection
        else
            log(connection_error)
        end
    end

    return connection
end

local function do_cam_action_start(camera_id, camera_action, action_args)
    local cam_prop_prefix = string.format("cam_%d_", camera_id)
    local camera_address = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "address")
    local camera_port = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "port")
    local camera_mode = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "mode")
    action_args = action_args or {}

    log("Start cam %d @%s:%d action %d (args %s)", camera_id, camera_address, camera_port, camera_action, action_args)

    -- Force close connection before sending On-command to prevent usage of a dead connection
    if camera_action == actions.Camera_On then
        close_visca_connection(camera_id)
    end

    local connection = open_visca_connection(camera_id, camera_address, camera_port, camera_mode)

    if connection then
        if camera_action == actions.Camera_Off then
            connection.Cam_Power(false)

            -- Force close connection after sending Off-command.
            connection.close()
            plugin_data.connections[camera_id] = nil
        elseif camera_action == actions.Camera_On then
            connection.Cam_Power(true)
        elseif camera_action == actions.Preset_Recal and action_args.preset then
            connection.Cam_Preset_Recall(action_args.preset)
        elseif camera_action == actions.PanTilt then
            connection.Cam_PanTilt(action_args.direction or Visca.PanTilt_directions.stop, action_args.speed or 0x03,
                action_args.speed or 0x03)
        elseif camera_action == actions.Zoom_In then
            connection.Cam_Zoom_Tele(action_args.speed)
        elseif camera_action == actions.Zoom_Out then
            connection.Cam_Zoom_Wide(action_args.speed)
        elseif camera_action == actions.Focus_Auto then
            connection.Cam_Focus_Mode(Visca.Focus_modes.auto)
        elseif camera_action == actions.Focus_Manual then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
        elseif camera_action == actions.Focus_Refocus then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Mode(Visca.Focus_modes.one_push_trigger)
        elseif camera_action == actions.Focus_Infinity then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Mode(Visca.Focus_modes.infinity)
        elseif camera_action == actions.Focus_Near then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Near()
        elseif camera_action == actions.Focus_Far then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Far()
        end
    end
end

local function do_cam_action_stop(camera_id, camera_action, action_args)
    local cam_prop_prefix = string.format("cam_%d_", camera_id)
    local camera_address = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "address")
    local camera_port = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "port")
    local camera_mode = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "mode")
    action_args = action_args or {}

    log("Stop cam %d @%s action %d (arg %s)", camera_id, camera_address, camera_action, action_args)
    local connection = open_visca_connection(camera_id, camera_address, camera_port, camera_mode)

    if connection then
        if camera_action == actions.PanTilt then
            connection.Cam_PanTilt(Visca.PanTilt_directions.stop)
        elseif camera_action == actions.Zoom_In then
            connection.Cam_Zoom_Stop()
        elseif camera_action == actions.Zoom_Out then
            connection.Cam_Zoom_Stop()
        elseif camera_action == actions.Focus_Near then
            connection.Cam_Focus_Stop()
        elseif camera_action == actions.Focus_Far then
            connection.Cam_Focus_Stop()
        end
    end
end

local function cb_camera_hotkey(pressed, hotkey_data)
    if pressed then
        do_cam_action_start(hotkey_data.camera_id, hotkey_data.action, hotkey_data.action_args)
    else
        do_cam_action_stop(hotkey_data.camera_id, hotkey_data.action, hotkey_data.action_args)
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

function script_save(settings)
    for _, hotkey in pairs(plugin_data.hotkeys) do
        local a = obs.obs_hotkey_save(hotkey.id)
        obs.obs_data_set_array(settings, hotkey.name .. "_hotkey", a)
        obs.obs_data_array_release(a)
    end
end

function script_load(settings)
    plugin_settings = settings

    local hotkey_actions = {
        { name = "pan_left", descr = "Pan Left", action = actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.left } },
        { name = "pan_right", descr = "Pan Right", action = actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.right } },
        { name = "tilt_up", descr = "Tilt Up", action = actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.up } },
        { name = "tilt_down", descr = "Tilt Down", action = actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.down } },
        { name = "zoom_in", descr = "Zoom In", action = actions.Zoom_In },
        { name = "zoom_out", descr = "Zoom Out", action = actions.Zoom_Out },
        { name = "focus_auto", descr = "Focus mode Automatic", action = actions.Focus_Auto },
        { name = "focus_manual", descr = "Focus mode Manual", action = actions.Focus_Manual },
        { name = "focus_trigger", descr = "Focus trigger Refocus", action = actions.Focus_Refocus },
        { name = "focus_near", descr = "Focus to Near", action = actions.Focus_Near },
        { name = "focus_far", descr = "Focus to Far", action = actions.Focus_Far },
        { name = "focus_infinity", descr = "Focus to Infinity", action = actions.Focus_Infinity },
        { name = "preset_0", descr = "Preset 0", action = actions.Preset_Recal, action_args = { preset = 0 } },
        { name = "preset_1", descr = "Preset 1", action = actions.Preset_Recal, action_args = { preset = 1 } },
        { name = "preset_2", descr = "Preset 2", action = actions.Preset_Recal, action_args = { preset = 2 } },
        { name = "preset_3", descr = "Preset 3", action = actions.Preset_Recal, action_args = { preset = 3 } },
        { name = "preset_4", descr = "Preset 4", action = actions.Preset_Recal, action_args = { preset = 4 } },
        { name = "preset_5", descr = "Preset 5", action = actions.Preset_Recal, action_args = { preset = 5 } },
        { name = "preset_6", descr = "Preset 6", action = actions.Preset_Recal, action_args = { preset = 6 } },
        { name = "preset_7", descr = "Preset 7", action = actions.Preset_Recal, action_args = { preset = 7 } },
        { name = "preset_8", descr = "Preset 8", action = actions.Preset_Recal, action_args = { preset = 8 } },
        { name = "preset_9", descr = "Preset 9", action = actions.Preset_Recal, action_args = { preset = 9 } },
    }

    local num_cameras = obs.obs_data_get_int(settings, "num_cameras")
    for camera_id = 1, num_cameras do
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name = obs.obs_data_get_string(settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end

        obs.obs_data_set_default_string(settings, cam_prop_prefix .. "name", cam_name)
        obs.obs_data_set_default_int(settings, cam_prop_prefix .. "port", Visca.default_port)
        obs.obs_data_set_default_int(settings, cam_prop_prefix .. "mode", Visca.modes.generic)

        for _, v in pairs(hotkey_actions) do
            local hotkey_name = cam_prop_prefix .. v.name
            local hotkey_id = obs.obs_hotkey_register_frontend(hotkey_name, v.descr .. " on " .. cam_name,
                function(pressed)
                    cb_camera_hotkey(pressed, { name = hotkey_name, camera_id = camera_id, action = v.action,
                        action_args = v.action_args })
                end)

            local a = obs.obs_data_get_array(settings, hotkey_name .. "_hotkey")
            obs.obs_hotkey_load(hotkey_id, a)
            obs.obs_data_array_release(a)

            table.insert(plugin_data.hotkeys, {
                name = hotkey_name,
                id = hotkey_id,
                camera_id = camera_id,
                action = v.action
            })
        end
    end
end

function script_properties()
    local props = obs.obs_properties_create()

    local num_cams = obs.obs_properties_add_int(props, "num_cameras", "Number of cameras", 0, 42, 1)
    obs.obs_property_set_modified_callback(num_cams, prop_num_cams)

    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    log("num_cameras %d", num_cameras)

    local cams = obs.obs_properties_add_list(props, "cameras", "Camera", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)
    for camera_id = 1, num_cameras do
        create_camera_controls(props, camera_id, plugin_settings)
    end
    obs.obs_property_set_modified_callback(cams, prop_set_attrs_values)

    obs.obs_properties_add_bool(props, "debug_logging", "Enable verbose logging (debug)")

    return props
end

local function set_property_visibility(props, name, visible)
    local changed = false

    local prop = obs.obs_properties_get(props, name)
    if prop then
        if obs.obs_property_visible(prop) ~= visible then
            obs.obs_property_set_visible(prop, visible)
            changed = true
        end
    end

    return changed
end

local function cb_camera_action_changed(props, property, data)
    local changed = false
    local num_cameras = obs.obs_property_list_item_count(property)
    local scene_camera = obs.obs_data_get_int(data, "scene_camera")
    local scene_action = obs.obs_data_get_int(data, "scene_action")
    if num_cameras == 0 then
        scene_camera = 0
    end

    for camera_id = 1, num_cameras do
        local visible = scene_camera == camera_id
        if scene_action ~= actions.Preset_Recal then
            visible = false
        end

        changed = set_property_visibility(props, string.format("scene_cam_%d_preset", camera_id), visible) or changed
    end

    changed = set_property_visibility(props, "scene_direction", scene_action == actions.PanTilt) or changed
    local need_speed = (scene_action == actions.PanTilt) or (scene_action == actions.Zoom_In) or
        (scene_action == actions.Zoom_Out)
    changed = set_property_visibility(props, "scene_speed", need_speed) or changed

    return changed
end

local function camera_active_in_scene(program, camera_id)
    local active = false

    local scene_source = program and obs.obs_frontend_get_current_scene() or
        obs.obs_frontend_get_current_preview_scene()
    if scene_source ~= nil then
        local scene = obs.obs_scene_from_source(scene_source)
        local scene_name = obs.obs_source_get_name(scene_source)
        log("Current %s scene is %s", program and "program" or "preview", scene_name or "?")

        local scene_items = obs.obs_scene_enum_items(scene)
        if scene_items ~= nil then
            for _, scene_item in ipairs(scene_items) do
                local scene_item_source = obs.obs_sceneitem_get_source(scene_item)
                local scene_item_source_id = obs.obs_source_get_unversioned_id(scene_item_source)
                if scene_item_source_id == plugin_def.id then
                    local visible = obs.obs_source_showing(scene_item_source)
                    if visible then
                        local item_source_settings = obs.obs_source_get_settings(scene_item_source)
                        if item_source_settings ~= nil then
                            local item_source_camera_id = obs.obs_data_get_int(item_source_settings, "scene_camera")
                            log("Camera ref: %d active on %s: %d", camera_id, program and "program" or "preview",
                                item_source_camera_id)
                            if camera_id == item_source_camera_id then
                                active = true
                                break
                            end

                            obs.obs_data_release(item_source_settings)
                        end
                    end
                end
            end

            obs.sceneitem_list_release(scene_items)
        end

        obs.obs_source_release(scene_source)
    end

    return active
end

local function do_cam_scene_action(settings, start)
    local camera_id = obs.obs_data_get_int(settings, "scene_camera")
    local scene_action = obs.obs_data_get_int(settings, "scene_action")
    local cam_prop_prefix = string.format("cam_%d_", camera_id)

    local action_args = {
        preset = obs.obs_data_get_int(settings, "scene_" .. cam_prop_prefix .. "preset"),
        direction = obs.obs_data_get_int(settings, "scene_direction"),
        speed = obs.obs_data_get_double(settings, "scene_speed")
    }
    local active = obs.obs_data_get_int(settings, "scene_active")
    local delay = obs.obs_data_get_int(settings, "scene_action_delay") or 0

    if start then
        if delay > 0 then
            obs.timer_add(function()
                obs.remove_current_callback()
                do_cam_action_start(camera_id, scene_action, action_args)
            end, delay)
        else
            do_cam_action_start(camera_id, scene_action, action_args)
        end
    else
        if not camera_active_in_scene(true, camera_id) and (active == action_active.Program or
            not camera_active_in_scene(false, camera_id)) then
            do_cam_action_stop(camera_id, scene_action, action_args)
        end
    end
end

local function fe_callback(event, data)
    if event == obs.OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED then
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
                                        if camera_active_in_scene(true, preview_camera_id) then
                                            do_action = false
                                            log("Not running action for source '%s', " ..
                                                "because it is currently active on program",
                                                source_name or "?")
                                        end
                                    end
                                end

                                if do_action then
                                    log("Preview source '%s'", source_name or "?")
                                    do_cam_scene_action(settings, true)
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

local function source_signal_handler(calldata, signal)
    local source = obs.calldata_source(calldata, "source")
    local settings = obs.obs_source_get_settings(source)
    local source_name = obs.obs_source_get_name(source)

    log("%s source %s", signal.activate and "Activate" or
                        signal.deactivate and "Deactivate" or
                        signal.hide and "Hide" or
                        "?", source_name)

    local do_action = false
    local active = obs.obs_data_get_int(settings, "scene_active")
    if (active == action_active.Program) or (active == action_active.Always) then
        do_action = true
    end

    if do_action then
        if signal.activate then do_cam_scene_action(settings, true) end
        if signal.deactivate or signal.hide then do_cam_scene_action(settings, false) end
    end

    obs.obs_data_release(settings)
end

plugin_def.get_name = function()
    return plugin_info.name
end

plugin_def.create = function(settings, source)
    local data = {}
    local source_sh = obs.obs_source_get_signal_handler(source)
    obs.signal_handler_connect(source_sh, "hide",
        function(calldata) source_signal_handler(calldata, { hide = true }) end)
    obs.signal_handler_connect(source_sh, "activate",
        function(calldata) source_signal_handler(calldata, { activate = true }) end)
    obs.signal_handler_connect(source_sh, "deactivate",
        function(calldata) source_signal_handler(calldata, { deactivate = true }) end)
    obs.obs_frontend_add_event_callback(fe_callback)
    return data
end

plugin_def.destroy = function(source)
    for camera_id, connection in pairs(plugin_data.connections) do
        if connection ~= nil then
            connection.close()
            plugin_data.connections[camera_id] = nil
        end
    end
    plugin_data.connections = {}
end

plugin_def.get_properties = function(data)
    local props = obs.obs_properties_create()

    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    local prop_camera = obs.obs_properties_add_list(props, "scene_camera", "Camera", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)

    local prop_action = obs.obs_properties_add_list(props, "scene_action", "Action", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_action, "Camera Off", actions.Camera_Off)
    obs.obs_property_list_add_int(prop_action, "Camera On", actions.Camera_On)
    obs.obs_property_list_add_int(prop_action, "Preset Recall", actions.Preset_Recal)
    obs.obs_property_list_add_int(prop_action, "Pan/Tilt", actions.PanTilt)
    obs.obs_property_list_add_int(prop_action, "Zoom In", actions.Zoom_In)
    obs.obs_property_list_add_int(prop_action, "Zoom Out", actions.Zoom_Out)

    for camera_id = 1, num_cameras do
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name_suffix = string.format(" (cam %d)", camera_id)

        local cam_name = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end
        obs.obs_property_list_add_int(prop_camera, cam_name, camera_id)

        local prop_presets = obs.obs_properties_add_list(props, "scene_" .. cam_prop_prefix .. "preset",
            "Presets" .. cam_name_suffix, obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
        local presets = obs.obs_data_get_array(plugin_settings, cam_prop_prefix .. "presets")
        local num_presets = obs.obs_data_array_count(presets)
        log("get_properties %s %d", cam_prop_prefix .. "preset", num_presets)

        if num_presets > 0 then
            local first_preset = true
            for i = 0, num_presets - 1 do
                local preset = obs.obs_data_array_item(presets, i)
                --log(obs.obs_data_get_json(preset))
                local preset_value = obs.obs_data_get_string(preset, "value")
                --log("check %s", preset_value)

                local preset_name, preset_id = parse_preset_value(preset_value)
                if (preset_name ~= nil) and (preset_id ~= nil) then
                    obs.obs_property_list_add_int(prop_presets, preset_name, preset_id)
                    if first_preset then
                        obs.obs_data_set_default_int(plugin_settings, "scene_" .. cam_prop_prefix .. "preset",
                            preset_id)
                        first_preset = false
                    end
                end
            end
        end

        obs.obs_data_array_release(presets)
    end

    local direction_names = {}
    for direction_name in pairs(Visca.PanTilt_directions) do
        table.insert(direction_names, direction_name)
    end
    table.sort(direction_names)

    local prop_pantilt_direction = obs.obs_properties_add_list(props, "scene_direction", "Animation Direction",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_pantilt_direction, "None", 0)
    for _, direction_name in ipairs(direction_names) do
        obs.obs_property_list_add_int(prop_pantilt_direction, direction_name:gsub("^%l", string.upper),
            Visca.PanTilt_directions[direction_name])
    end
    obs.obs_properties_add_int_slider(props, "scene_speed", "Animation Speed",
        Visca.limits.PAN_MIN_SPEED, Visca.limits.PAN_MAX_SPEED, 1)

    local prop_active = obs.obs_properties_add_list(props, "scene_active", "Action Active", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_active, "On Program", action_active.Program)
    obs.obs_property_list_add_int(prop_active, "On Preview", action_active.Preview)
    obs.obs_property_list_add_int(prop_active, "Always", action_active.Always)

    obs.obs_properties_add_bool(props, "preview_exclusive",
        "Run action on preview only when the camera is not active on program")

    obs.obs_properties_add_int(props, "scene_action_delay", "Delay Action (ms)", 0, 777333, 1)

    --obs.obs_properties_add_button(props, "run_action", "Perform action now", cb_run_action)

    obs.obs_property_set_modified_callback(prop_camera, cb_camera_action_changed)
    obs.obs_property_set_modified_callback(prop_action, cb_camera_action_changed)

    return props
end

obs.obs_register_source(plugin_def)
