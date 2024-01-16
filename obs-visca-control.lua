local obs = obslua
local bit = require("bit")
local Visca = require("libvisca")

local plugin_info = {
    name = "Visca Camera Control",
    version = "2.4",
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
    program_scene = {},    -- List containing typically 1 scene name that is on program.
                           -- This datastructure is a list because the signals activate and deactivate are triggered
                           -- respectively before and after change to/from program. During the transition there are
                           -- thus two scenes that could be active on program.
    connections = {},
    reply_data = {},
    hotkeys = {},
    callback_queue = {},   -- List of callbacks: [camera_id][type][] = table(expire, f)
    suppress_scene_actions = false,
}

local plugin_actions = {
    Suppress_Scene_Actions = 0,
}

local scene_action_at = {
    Start = true,
    Stop = false,
}

local plugin_scene_type = {
    Program = 1,
    Preview = 2,
}

local camera_actions = {
    Camera_Off = 0,
    Camera_On = 1,
    Preset_Recall = 2,
    PanTilt = 3,
    Zoom_In = 4,
    Zoom_Out = 5,
    Focus_Auto = 6,
    Focus_Manual = 7,
    Focus_Near = 8,
    Focus_Far = 9,
    Focus_Refocus = 10,
    Focus_Infinity = 11,
    PanTiltZoom_Position = 12,
    PanTilt_Speed_Increase = 13,
    PanTilt_Speed_Decrease = 14,
    ZoomFocus_Speed_Increase = 15,
    ZoomFocus_Speed_Decrease = 16,
    Image_Settings = 17,
    ColorGain_Reset = 18,
    ColorGain_Increase = 19,
    ColorGain_Decrease = 20,
    Brightness_Increase = 21,
    Brightness_Decrease = 22,
    PanTilt_Stop = 23,  -- This action is a shorthand of action PanTilt, with direction 'stop', with the
                        -- difference that the action is immediately executed (on keydown instead of keyup)
    Zoom_Stop = 24,
    Focus_Stop = 25,
    Custom_Command = 26,
}

local camera_action_active = {
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
                local kvs
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

        print(string.format("%s (%d): %s", func, line, string.format(fmt, unpack(args or {})) or "-"))
    end
end

local function parse_preset_value(preset_value)
    local preset_name
    local preset_id
    local regex_patterns = {
        "^(%g+)%s*[:=-]%s*(%d+)$",
        "^(%d+)%s*[:=-]%s*(%g+)$"
    }

    for _, pattern in pairs(regex_patterns) do
        local v1, v2 = string.match(preset_value, pattern)
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

    if (preset_id ~= nil) and ((preset_id < 0) or (preset_id > 254)) then
        preset_name = nil
        preset_id = nil
    end

    return preset_name, preset_id
end

local function parse_custom_action(action)
    local action_cmd = nil
    local regex_pattern = "([0-9A-F][0-9A-F])"

    if action and #action > 0 then
        action_cmd = {}
        for b in string.gmatch(action, regex_pattern) do
            table.insert(action_cmd, tonumber(b, 16))
        end

        if bit.band(action_cmd[1], 0xF0) == 0x80 and action_cmd[#action_cmd] == 0xFF then
            table.remove(action_cmd,1)
            table.remove(action_cmd)
        end
    end

    return action_cmd
end

local function plugin_callback_queue_add(camera_id, id, f, validity_seconds)
    if type(plugin_data.callback_queue[camera_id]) ~= 'table' then
        plugin_data.callback_queue[camera_id] = {}
    end
    if type(plugin_data.callback_queue[camera_id][id]) ~= 'table' then
        plugin_data.callback_queue[camera_id][id] = {}
    end

    local expire = os.time() + (validity_seconds or 3)
    table.insert(plugin_data.callback_queue[camera_id][id], {expire=expire, f=f})
end

local function plugin_callback_queue_invoke_one(camera_id, id, val)
    if plugin_data.callback_queue[camera_id] then
        local valid_callback = false
        repeat
            local callback = table.remove(plugin_data.callback_queue[camera_id][id] or {})
            if not callback then
                break
            end

            if callback.expire >= os.time() and type(callback.f) == 'function' then
                valid_callback = true
                local status,result_or_error = pcall(callback.f, val)
                if not status then
                    log("Callback '%s' for camera %d failed: %s", id, camera_id, result_or_error)
                end
            end
        until valid_callback
    end
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

            obs.obs_data_release(preset)
        end
    end

    obs.obs_data_array_release(presets)
end

local function create_camera_controls(cam_props, camera_id, settings)
    local cams = obs.obs_properties_get(cam_props, "cameras")
    if cams then
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name_suffix = string.format(" (cam %d)", camera_id)

        local cam_name = obs.obs_data_get_string(settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end
        obs.obs_property_list_add_int(cams, cam_name, camera_id)

        local prop_grp = obs.obs_properties_get(cam_props, cam_prop_prefix .. "grp")
        if prop_grp == nil then
            local props = obs.obs_properties_create()
            local prop_name = obs.obs_properties_get(props, cam_prop_prefix .. "name")
            if prop_name == nil then
                obs.obs_properties_add_text(props, cam_prop_prefix .. "name", "Name", obs.OBS_TEXT_DEFAULT)
                obs.obs_data_set_default_string(settings, cam_prop_prefix .. "name", cam_name)
            end

            local prop_version_info = obs.obs_properties_get(props, cam_prop_prefix .. "version_info")
            if prop_version_info == nil then
                prop_version_info = obs.obs_properties_add_text(props, cam_prop_prefix .. "version_info",
                    "Version Info", obs.OBS_TEXT_DEFAULT)
                obs.obs_property_set_enabled(prop_version_info, false)
                obs.obs_data_set_default_string(settings, cam_prop_prefix .. "version_info", "Unknown (not detected)")
            end

            local prop_address = obs.obs_properties_get(props, cam_prop_prefix .. "address")
            if prop_address == nil then
                obs.obs_properties_add_text(props, cam_prop_prefix .. "address", "IP Address", obs.OBS_TEXT_DEFAULT)
            end

            local prop_port = obs.obs_properties_get(props, cam_prop_prefix .. "port")
            if prop_port == nil then
                obs.obs_properties_add_int(props, cam_prop_prefix .. "port", "UDP Port", 1025, 65535, 1)
                obs.obs_data_set_default_int(settings, cam_prop_prefix .. "port", Visca.default_port)
            end

            local prop_mode = obs.obs_properties_get(props, cam_prop_prefix .. "mode")
            if prop_mode == nil then
                prop_mode = obs.obs_properties_add_list(props, cam_prop_prefix .. "mode", "Mode",
                    obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
                obs.obs_property_list_add_int(prop_mode, "Generic", Visca.modes.generic)
                obs.obs_property_list_add_int(prop_mode, "PTZOptics", Visca.modes.ptzoptics)
                obs.obs_data_set_default_int(settings, cam_prop_prefix .. "mode", Visca.modes.generic)
            end

            local prop_hk_pt_speed = obs.obs_properties_get(props, cam_prop_prefix .. "hk_pt_speed")
            if prop_hk_pt_speed == nil then
                obs.obs_properties_add_int_slider(props, cam_prop_prefix .. "hk_pt_speed", "Hotkey Pan/Tilt Speed",
                    Visca.limits.PAN_MIN_SPEED, Visca.limits.PAN_MAX_SPEED, 1)
                obs.obs_data_set_default_int(settings, cam_prop_prefix .. "hk_pt_speed", 0x07)
            end

            local prop_hk_zf_speed = obs.obs_properties_get(props, cam_prop_prefix .. "hk_zf_speed")
            if prop_hk_zf_speed == nil then
                obs.obs_properties_add_int_slider(props, cam_prop_prefix .. "hk_zf_speed", "Hotkey Zoom/Focus Speed",
                    Visca.limits.ZOOM_MIN_SPEED, Visca.limits.ZOOM_MAX_SPEED, 1)
                obs.obs_data_set_default_int(settings, cam_prop_prefix .. "hk_zf_speed", 0x02)
            end

            local prop_presets = obs.obs_properties_get(props, cam_prop_prefix .. "presets")
            if prop_presets == nil then
                prop_presets = obs.obs_properties_add_editable_list(props, cam_prop_prefix .. "presets", "Presets",
                    obs.OBS_EDITABLE_LIST_TYPE_STRINGS, "", "")
            end
            obs.obs_property_set_modified_callback(prop_presets, prop_presets_validate)

            obs.obs_properties_add_group(cam_props, cam_prop_prefix .. "grp", "Camera configuration" .. cam_name_suffix,
                obs.OBS_GROUP_NORMAL, props)
        end
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

        local cam_props = { "grp", "name", "version_info", "address", "port", "mode", "presets", "preset_info" }
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

local function get_plugin_settings_from_scene(scene_type, camera_id)
    scene_type = scene_type or plugin_scene_type.Preview
    local p_settings = {}

    local scene_source = (scene_type == plugin_scene_type.Program) and obs.obs_frontend_get_current_scene() or
        obs.obs_frontend_get_current_preview_scene()

    if scene_source ~= nil then
        local scene_name = obs.obs_source_get_name(scene_source)
        local scene = obs.obs_scene_from_source(scene_source)
        local scene_items = obs.obs_scene_enum_items(scene)
        if scene_items ~= nil then
            for _, scene_item in pairs(scene_items) do
                local scene_item_source = obs.obs_sceneitem_get_source(scene_item)
                local scene_item_source_id = obs.obs_source_get_unversioned_id(scene_item_source)
                if scene_item_source_id == plugin_def.id then
                    local source_name = obs.obs_source_get_name(scene_item_source)
                    local source_settings = obs.obs_source_get_settings(scene_item_source)
                    local source_is_visible = obs.obs_source_showing(scene_item_source)

                    if source_settings then
                        local scene_camera_id = obs.obs_data_get_int(source_settings, "scene_camera")
                        if (camera_id == nil) or (camera_id == scene_camera_id) then
                            table.insert(p_settings, {scene_name, source_name, source_settings, source_is_visible})
                        else
                            obs.obs_data_release(source_settings)
                        end
                    end
                end
            end

            obs.sceneitem_list_release(scene_items)
        end

        obs.obs_source_release(scene_source)
    end

    local plugins_visitor = coroutine.create(function()
            for _,plugin_setting in pairs(p_settings) do
                coroutine.yield(unpack(plugin_setting))
            end
         end)

    return function()
        local result, scene_name, source_name, source_settings, source_is_visible = coroutine.resume(plugins_visitor)
        if result and scene_name and source_name then
            return scene_name, source_name, source_settings, source_is_visible
        else
            return nil, nil, nil, nil
        end
     end
end

local function close_visca_connection(camera_id)
    local connection = plugin_data.connections[camera_id]

    if connection ~= nil then
        connection:close()
        connection:unregister_on_ack_callback(camera_id)
        connection:unregister_on_completion_callback(camera_id)
        connection:unregister_on_error_callback(camera_id)
        connection:unregister_on_timeout_callback(camera_id)
        connection = nil
        plugin_data.connections[camera_id] = connection
    end
end

--- @return Connection
local function open_visca_connection(camera_id)
    local connection = plugin_data.connections[camera_id]

    if connection == nil then
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local camera_address = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "address")
        local camera_port = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "port")
        local camera_mode = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "mode")

        log("Setup new connection for cam %d at %s:%d", camera_id, camera_address, camera_port)

        local new_connection, connection_error = Visca.connect(camera_address, camera_port)
        if new_connection then
            connection = new_connection
            if camera_mode then
                connection:set_mode(camera_mode)
            end

            connection:register_on_completion_callback(camera_id, function(t)
                log("Connection Completion received for camera %d (seq_nr %d)", camera_id, t and t.send.seq_nr or -1)

                local t_data = t:inquiry_data()
                if t_data and type(t_data) == 'table' then
                    local reply_data = plugin_data.reply_data[camera_id] or {}

                    for k,v in pairs(t_data) do
                        reply_data[k] = v
                    end

                    plugin_data.reply_data[camera_id] = reply_data

                    if t_data.vendor_id or t_data.model_code or t_data.rom_version then
                        local version_info = string.format("Vendor: %s (%04X), Model: %s (%04X), Firmware: %04X",
                            Visca.CameraVendor[reply_data.vendor_id] or "Unknown",
                            reply_data.vendor_id or 0,
                            Visca.CameraModel[reply_data.vendor_id][reply_data.model_code] or "Unknown",
                            reply_data.model_code or 0,
                            reply_data.rom_version or 0)
                        local version_info_setting = string.format("cam_%d_version_info", camera_id)
                        obs.obs_data_set_string(plugin_settings, version_info_setting, version_info)
                        log("Set camera %d version info to %s", camera_id, version_info)

                        local compatibility = {}
                        if t_data.vendor_id == 0x0001 and t_data.model_code == 0x0513 then
                            -- NewTek PTZ1 NDI
                            compatibility = { fixed_sequence_number = 1 }
                        end

                        if next(compatibility) then
                            connection:set_compatibility(compatibility)

                            local compat_a = {}
                            for k, v in pairs (compatibility) do
                                table.insert(compat_a, string.format('%s = %s', k, v))
                            end
                            print(string.format("Set compatibility mode for camera %d: %s", camera_id,
                                table.concat(compat_a, ',')))
                        end
                    end

                    if t_data.zoom or t_data.pan or t_data.tilt then
                        local ptz_vals = {}

                        if reply_data.pan then
                            table.insert(ptz_vals, string.format("Pan %d (%04X)", reply_data.pan, reply_data.pan))
                        else
                            table.insert(ptz_vals, "Pan: n/a (-)")
                        end
                        if reply_data.tilt then
                            table.insert(ptz_vals, string.format("Tilt: %d (%04X)", reply_data.tilt, reply_data.tilt))
                        else
                            table.insert(ptz_vals, "Tilt: n/a (-)")
                        end
                        if reply_data.zoom then
                            table.insert(ptz_vals, string.format("Zoom: %d (%04X)", reply_data.zoom, reply_data.zoom))
                        else
                            table.insert(ptz_vals, "Zoom: n/a (-)")
                        end

                        for scene_name, source_name, source_settings, _ in
                            get_plugin_settings_from_scene(plugin_scene_type.Preview, camera_id) do
                            if source_settings then
                                local scene_camera_id = obs.obs_data_get_int(source_settings, "scene_camera")
                                if scene_camera_id == camera_id then
                                    local ptz_str = table.concat(ptz_vals, ", ")
                                    obs.obs_data_set_string(source_settings, "scene_ptz_position", ptz_str)
                                    log("PTZ values set for camera %d: %s", camera_id, ptz_str)
                                else
                                    print(string.format("Error setting PTZ values: callback camera %d does not match" ..
                                        " source '%s' camera %d in scene %s",
                                        camera_id, source_name, scene_camera_id, scene_name))
                                end

                                obs.obs_data_release(source_settings)
                            else
                                print(string.format("Error setting PTZ values: unable to find plugin settings for " ..
                                    "camera %d in scene %s", camera_id, scene_name))
                            end
                        end
                    end

                    if t_data.brightness then
                        plugin_callback_queue_invoke_one(camera_id, 'brightness', t_data.brightness)
                    end

                    if t_data.color_level then
                        plugin_callback_queue_invoke_one(camera_id, 'color_level', t_data.color_level)
                    end
                end
            end)

            connection:register_on_ack_callback(camera_id, function(t)
                log("Connection ACK received for camera %d (seq_nr %d)", camera_id, t and t.send.seq_nr or -1)
            end)
            connection:register_on_error_callback(camera_id, function(t)
                local error_msg = Visca.error_type_names[t.error.error_type] or 'Unknown'
                log("Connection ERROR received for camera %d (seq_nr %d): %s",
                    camera_id, t and t.send.seq_nr or -1, error_msg)
            end)
            connection:register_on_timeout_callback(camera_id, function(t)
                log("Connection Timeout for camera %d (seq_nr %d)", camera_id, t and t.send.seq_nr or -1)
            end)

            plugin_data.connections[camera_id] = connection

            connection:Cam_Software_Version_Inquiry()
        else
            log(connection_error)
        end
    end

    return connection
end

local function cb_plugin_hotkey(pressed, hotkey_data)
    if hotkey_data.action == plugin_actions.Suppress_Scene_Actions then
        plugin_data.suppress_scene_actions = pressed and true or false
    end
end

local function do_cam_action_start(camera_id, camera_action, action_args_in)
    local action_args = {}
    for k,v in pairs(action_args_in or {}) do
        action_args[k] = v
    end

    -- Force close connection before sending On-command to prevent usage of a dead connection
    if camera_action == camera_actions.Camera_On then
        close_visca_connection(camera_id)
    end

    log("Start cam %d action %d (args %s)", camera_id, camera_action, action_args)
    local cam_prop_prefix = string.format("cam_%d_", camera_id)

    local connection = open_visca_connection(camera_id)
    if connection then
        if camera_action == camera_actions.Camera_Off then
            connection:Cam_Power(false)

            -- Force close connection after sending Off-command.
            connection:close()
            plugin_data.connections[camera_id] = nil
        elseif camera_action == camera_actions.Camera_On then
            connection:Cam_Power(true)
        elseif camera_action == camera_actions.Preset_Recall and action_args.preset then
            connection:Cam_Preset_Recall(action_args.preset)
        elseif camera_action == camera_actions.PanTilt then
            if not action_args.speed then
                action_args.speed = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "hk_pt_speed") or
                    Visca.limits.PAN_MIN_SPEED
            end
            connection:Cam_PanTilt(action_args.direction or Visca.PanTilt_directions.stop, action_args.speed,
                action_args.speed)
        elseif camera_action == camera_actions.Zoom_In then
            if not action_args.speed then
                action_args.speed = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "hk_zf_speed") or
                    Visca.limits.ZOOM_MIN_SPEED
            end
            connection:Cam_Zoom_Tele(action_args.speed)
        elseif camera_action == camera_actions.Zoom_Out then
            if not action_args.speed then
                action_args.speed = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "hk_zf_speed") or
                    Visca.limits.ZOOM_MIN_SPEED
            end
            connection:Cam_Zoom_Wide(action_args.speed)
        elseif camera_action == camera_actions.Focus_Auto then
            connection:Cam_Focus_Mode(Visca.Focus_modes.auto)
        elseif camera_action == camera_actions.Focus_Manual then
            connection:Cam_Focus_Mode(Visca.Focus_modes.manual)
        elseif camera_action == camera_actions.Focus_Refocus then
            connection:Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection:Cam_Focus_Mode(Visca.Focus_modes.one_push_trigger)
        elseif camera_action == camera_actions.Focus_Infinity then
            connection:Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection:Cam_Focus_Mode(Visca.Focus_modes.infinity)
        elseif camera_action == camera_actions.Focus_Near then
            connection:Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection:Cam_Focus_Near()
        elseif camera_action == camera_actions.Focus_Far then
            connection:Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection:Cam_Focus_Far()
        elseif camera_action == camera_actions.PanTiltZoom_Position then
            if action_args.pan_position ~= nil and action_args.tilt_position ~= nil then
                if not action_args.speed then
                    action_args.speed = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. "hk_pt_speed") or
                        Visca.limits.PAN_MIN_SPEED
                end
                connection:Cam_PanTilt_Absolute(action_args.speed, action_args.pan_position, action_args.tilt_position)
            end
            if action_args.zoom_position ~= nil then
                connection:Cam_Zoom_To(action_args.zoom_position)
            end
        elseif camera_action == camera_actions.ColorGain_Reset then
            connection:Cam_Color_Gain_Reset()
        elseif camera_action == camera_actions.ColorGain_Increase then
            plugin_callback_queue_add(camera_id, 'color_level', function()
                local reply_data = plugin_data.reply_data[camera_id] or {}
                if reply_data.color_level then
                    connection:Cam_Color_Gain(reply_data.color_level + 1)
                end
            end)
            connection:Cam_Color_Gain_Inquiry()
        elseif camera_action == camera_actions.ColorGain_Decrease then
            plugin_callback_queue_add(camera_id, 'color_level', function()
                local reply_data = plugin_data.reply_data[camera_id] or {}
                if reply_data.color_level then
                    connection:Cam_Color_Gain(reply_data.color_level - 1)
                end
            end)
            connection:Cam_Color_Gain_Inquiry()
        elseif camera_action == camera_actions.Brightness_Increase then
            plugin_callback_queue_add(camera_id, 'brightness', function()
                local reply_data = plugin_data.reply_data[camera_id] or {}
                if reply_data.brightness then
                    connection:Cam_Color_Gain(reply_data.brightness + 1)
                end
            end)
            connection:Cam_Brightness_Inquiry()
        elseif camera_action == camera_actions.Brightness_Decrease then
            plugin_callback_queue_add(camera_id, 'brightness', function()
                local reply_data = plugin_data.reply_data[camera_id] or {}
                if reply_data.brightness then
                    connection:Cam_Color_Gain(reply_data.brightness - 1)
                end
            end)
            connection:Cam_Brightness_Inquiry()
        elseif camera_action == camera_actions.Image_Settings then
            if action_args.color_level then
                connection:Cam_Color_Gain(action_args.color_level)
            end
            if action_args.brightness then
                connection:Cam_Brightness(action_args.brightness)
            end
        elseif camera_action == camera_actions.PanTilt_Stop then
            connection:Cam_PanTilt(Visca.PanTilt_directions.stop)
        elseif camera_action == camera_actions.Zoom_Stop then
            connection:Cam_Zoom_Stop()
        elseif camera_action == camera_actions.Focus_Stop then
            connection:Cam_Focus_Stop()
        elseif camera_action == camera_actions.Custom_Command and action_args.custom_start then
            connection:Send_Raw_Command(action_args.custom_start)
        end
    end
end

local function do_cam_action_stop(camera_id, camera_action, action_args)
    action_args = action_args or {}

    log("Stop cam %d action %d (arg %s)", camera_id, camera_action, action_args)
    local connection = open_visca_connection(camera_id)
    if connection then
        if camera_action == camera_actions.PanTilt then
            connection:Cam_PanTilt(Visca.PanTilt_directions.stop)
        elseif camera_action == camera_actions.Zoom_In then
            connection:Cam_Zoom_Stop()
        elseif camera_action == camera_actions.Zoom_Out then
            connection:Cam_Zoom_Stop()
        elseif camera_action == camera_actions.Focus_Near then
            connection:Cam_Focus_Stop()
        elseif camera_action == camera_actions.Focus_Far then
            connection:Cam_Focus_Stop()
        elseif camera_action == camera_actions.Custom_Command and action_args.custom_stop then
            connection:Send_Raw_Command(action_args.custom_stop)
        end
    end
end

local function cb_camera_hotkey(pressed, hotkey_data)
    local camera_id = hotkey_data.camera_id
    local camera_action  = hotkey_data.action
    local cam_prop_prefix = string.format("cam_%d_", camera_id)

    local function _change_cam_data_value(data_name, value_delta, value_min, value_max)
        local value = obs.obs_data_get_int(plugin_settings, cam_prop_prefix .. data_name) or value_min
        value = math.min(math.max(value + value_delta, value_min), value_max)
        obs.obs_data_set_int(plugin_settings, cam_prop_prefix .. data_name, value)
    end

    if pressed then
        if camera_action == camera_actions.PanTilt_Speed_Increase then
            _change_cam_data_value("hk_pt_speed", 1, Visca.limits.PAN_MIN_SPEED, Visca.limits.PAN_MAX_SPEED)
        elseif camera_action == camera_actions.PanTilt_Speed_Decrease then
            _change_cam_data_value("hk_pt_speed", -1, Visca.limits.PAN_MIN_SPEED, Visca.limits.PAN_MAX_SPEED)
        elseif camera_action == camera_actions.ZoomFocus_Speed_Increase then
            _change_cam_data_value("hk_zf_speed", 1, Visca.limits.ZOOM_MIN_SPEED, Visca.limits.ZOOM_MAX_SPEED)
        elseif camera_action == camera_actions.ZoomFocus_Speed_Decrease then
            _change_cam_data_value("hk_zf_speed", -1, Visca.limits.ZOOM_MIN_SPEED, Visca.limits.ZOOM_MAX_SPEED)
        else
            do_cam_action_start(camera_id, camera_action, hotkey_data.action_args)
        end
    else
        if not (camera_action == camera_actions.PanTilt_Speed_Increase or
                camera_action == camera_actions.PanTilt_Speed_Decrease or
                camera_action == camera_actions.ZoomFocus_Speed_Increase or
                camera_action == camera_actions.ZoomFocus_Speed_Decrease) then
            do_cam_action_stop(camera_id, camera_action, hotkey_data.action_args)
        end
    end
end

local function cb_backup_restore(props, __property, __settings)
    local backup_file = obs.obs_data_get_string(plugin_settings, "backup_file") or ""
    if #backup_file > 0 then
        local backup_settings = obs.obs_data_create_from_json_file_safe(backup_file, "bak")
        if backup_settings ~= nil then
            local num_cameras = obs.obs_data_get_int(backup_settings, "num_cameras")

            for camera_id = 1, num_cameras do
                create_camera_controls(props, camera_id, backup_settings)

                local cam_prop_prefix = string.format("cam_%d_", camera_id)
                local cam_name = obs.obs_data_get_string(backup_settings, cam_prop_prefix .. "name")
                if cam_name then
                    obs.obs_data_set_string(plugin_settings, cam_prop_prefix .. "name", cam_name)
                end
                local cam_address = obs.obs_data_get_string(backup_settings, cam_prop_prefix .. "address")
                if cam_address then
                    obs.obs_data_set_string(plugin_settings, cam_prop_prefix .. "address", cam_address)
                end
                local cam_port = obs.obs_data_get_int(backup_settings, cam_prop_prefix .. "port")
                if cam_port then
                    obs.obs_data_set_int(plugin_settings, cam_prop_prefix .. "port", cam_port)
                end
                local cam_mode = obs.obs_data_get_int(backup_settings, cam_prop_prefix .. "mode")
                if cam_mode then
                    obs.obs_data_set_int(plugin_settings, cam_prop_prefix .. "mode", cam_mode)
                end
                local cam_settings = obs.obs_data_get_array(backup_settings, cam_prop_prefix .. "presets")
                if obs.obs_data_array_count(cam_settings) > 0 then
                    obs.obs_data_set_array(plugin_settings, cam_prop_prefix .. "presets", cam_settings)
                end
                obs.obs_data_array_release(cam_settings)
            end

            obs.obs_data_release(backup_settings)
            log("Settings restored from %s", backup_file)
            return true
        end
    else
        log("Unable to restore, 'backup_file' is not set.")
    end
end

local function cb_backup_save(__props, __property, __settings)
    local backup_file = obs.obs_data_get_string(plugin_settings, "backup_file")
    if #backup_file > 0 then
        obs.obs_data_set_string(plugin_settings, "backup_file", nil)
        obs.obs_data_save_json_safe(plugin_settings, backup_file, "tmp", "bak")
        log("Settings saved to %s", backup_file)
        obs.obs_data_set_string(plugin_settings, "backup_file", backup_file)
        return true
    else
        log("Unable to save, 'backup_file' property is not set.")
    end
end

local function handleViscaResponses()
    for camera_id, connection in pairs(plugin_data.connections) do
        local success, msg, err, num = pcall(function() return connection:receive() end)
        if not success then
            log("Poll camera %d failed: %s", camera_id, msg)
        else
            if msg then
                log("Poll camera %d (%s): %s", camera_id, tostring(connection), msg:as_string(connection.mode))
                if plugin_data.debug then
                    msg:dump()
                end
            elseif err ~= "timeout" then
                log("Poll camera %d (%s) failed: %s (%d)", camera_id, tostring(connection), err, num)
                if num == 22 or num == 10022 then
                    close_visca_connection(camera_id)
                end
            end
        end
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

    print(string.format("%s version %s", plugin_info.name, plugin_info.version))

    local plugin_hotkey_actions = {
        { name = "suppress_scene_actions", descr = "Suppress actions on scenes",
            action = plugin_actions.Suppress_Scene_Actions },
    }

    for _, v in pairs(plugin_hotkey_actions) do
        local hotkey_name = "visca_" .. v.name
        local hotkey_id = obs.obs_hotkey_register_frontend(hotkey_name, v.descr .. " for Visca cams",
            function(pressed)
                cb_plugin_hotkey(pressed, { name = hotkey_name, action = v.action, action_args = v.action_args })
            end)

        local a = obs.obs_data_get_array(settings, hotkey_name .. "_hotkey")
        obs.obs_hotkey_load(hotkey_id, a)
        obs.obs_data_array_release(a)

        table.insert(plugin_data.hotkeys, {
            name = hotkey_name,
            id = hotkey_id,
            action = v.action
        })
    end

    local camera_hotkey_actions = {
        { name = "pan_left", descr = "Pan Left", action = camera_actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.left } },
        { name = "pan_right", descr = "Pan Right", action = camera_actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.right } },
        { name = "tilt_up", descr = "Tilt Up", action = camera_actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.up } },
        { name = "tilt_down", descr = "Tilt Down", action = camera_actions.PanTilt,
            action_args = { direction = Visca.PanTilt_directions.down } },
        { name = "pantilt_speed_incr", descr = "Increase Pan/Tilt speed",
            action = camera_actions.PanTilt_Speed_Increase },
        { name = "pantilt_speed_decr", descr = "Decrease Pan/Tilt speed",
            action = camera_actions.PanTilt_Speed_Decrease },
        { name = "pantilt_stop", descr = "Stop Pan/Tilt motion", action = camera_actions.PanTilt_Stop },
        { name = "zoom_in", descr = "Zoom In", action = camera_actions.Zoom_In },
        { name = "zoom_out", descr = "Zoom Out", action = camera_actions.Zoom_Out },
        { name = "zoom_stop", descr = "Stop Zoom change", action = camera_actions.Zoom_Stop },
        { name = "color_gain_reset", descr = "Color Gain (Saturation) Reset", action = camera_actions.ColorGain_Reset },
        { name = "color_gain_increment", descr = "Color Gain (Saturation) Increment",
            action = camera_actions.ColorGain_Increase },
        { name = "color_gain_decrement", descr = "Color Gain (Saturation) Decrement",
            action = camera_actions.ColorGain_Decrease },
        { name = "brightness_increment", descr = "Brightness Increment", action = camera_actions.Brightness_Increase },
        { name = "brightness_decrement", descr = "Brightness Decrement", action = camera_actions.Brightness_Decrease },
        { name = "focus_auto", descr = "Focus mode Automatic", action = camera_actions.Focus_Auto },
        { name = "focus_manual", descr = "Focus mode Manual", action = camera_actions.Focus_Manual },
        { name = "focus_trigger", descr = "Focus trigger Refocus", action = camera_actions.Focus_Refocus },
        { name = "focus_near", descr = "Focus to Near", action = camera_actions.Focus_Near },
        { name = "focus_far", descr = "Focus to Far", action = camera_actions.Focus_Far },
        { name = "focus_infinity", descr = "Focus to Infinity", action = camera_actions.Focus_Infinity },
        { name = "zoomfocus_speed_incr", descr = "Increase Zoom/Focus speed",
            action = camera_actions.ZoomFocus_Speed_Increase },
        { name = "zoomfocus_speed_decr", descr = "Decrease Zoom/Focus speed",
            action = camera_actions.ZoomFocus_Speed_Decrease },
        { name = "focus_stop", descr = "Stop Focus change", action = camera_actions.Focus_Stop },
        { name = "preset_0", descr = "Preset 0", action = camera_actions.Preset_Recall, action_args = { preset = 0 } },
        { name = "preset_1", descr = "Preset 1", action = camera_actions.Preset_Recall, action_args = { preset = 1 } },
        { name = "preset_2", descr = "Preset 2", action = camera_actions.Preset_Recall, action_args = { preset = 2 } },
        { name = "preset_3", descr = "Preset 3", action = camera_actions.Preset_Recall, action_args = { preset = 3 } },
        { name = "preset_4", descr = "Preset 4", action = camera_actions.Preset_Recall, action_args = { preset = 4 } },
        { name = "preset_5", descr = "Preset 5", action = camera_actions.Preset_Recall, action_args = { preset = 5 } },
        { name = "preset_6", descr = "Preset 6", action = camera_actions.Preset_Recall, action_args = { preset = 6 } },
        { name = "preset_7", descr = "Preset 7", action = camera_actions.Preset_Recall, action_args = { preset = 7 } },
        { name = "preset_8", descr = "Preset 8", action = camera_actions.Preset_Recall, action_args = { preset = 8 } },
        { name = "preset_9", descr = "Preset 9", action = camera_actions.Preset_Recall, action_args = { preset = 9 } },
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

        for _, v in pairs(camera_hotkey_actions) do
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

    obs.timer_add(handleViscaResponses, 100)
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

    local backup_props = obs.obs_properties_create()
    local backup_file = obs.obs_data_get_string(plugin_settings, "backup_file")
    obs.obs_properties_add_path(backup_props, "backup_file", "Backup file", obs.OBS_PATH_FILE_SAVE,
        "Configuration backup (*.json)", backup_file)
    obs.obs_properties_add_button(backup_props, "backup_save", "Create backup", cb_backup_save)
    obs.obs_properties_add_button(backup_props, "backup_restore", "Restore from backup", cb_backup_restore)
    obs.obs_properties_add_group(props, "backup_grp", "Backup and restore", obs.OBS_GROUP_NORMAL, backup_props)

    obs.obs_properties_add_bool(props, "debug_logging", "Enable verbose (debug) logging")

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
    local trigger_prop_name = obs.obs_property_name(property)
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    local scene_camera = obs.obs_data_get_int(data, "scene_camera")
    local scene_action = obs.obs_data_get_int(data, "scene_action")
    if num_cameras == 0 then
        scene_camera = 0
    end

    local reply_data = plugin_data.reply_data[scene_camera] or {}
    if trigger_prop_name == "scene_action" then
        if not reply_data.color_level or reply_data.brightness then
            if scene_action == camera_actions.Image_Settings then
                local connection = open_visca_connection(scene_camera)
                if connection then
                    connection:Cam_Color_Gain_Inquiry()
                    connection:Cam_Brightness_Inquiry()
                end
            end
        end
    end

    for camera_id = 1, num_cameras do
        local visible = scene_camera == camera_id
        if scene_action ~= camera_actions.Preset_Recall then
            visible = false
        end

        changed = set_property_visibility(props, string.format("scene_cam_%d_preset", camera_id), visible) or changed
    end

    changed = set_property_visibility(props, "scene_config_grp", not ((scene_action == camera_actions.Camera_On) or
        (scene_action == camera_actions.Camera_Off) or (scene_action == camera_actions.Zoom_Stop))) or changed

    changed = set_property_visibility(props, "scene_ptz_position",
        scene_action == camera_actions.PanTiltZoom_Position) or changed
    changed = set_property_visibility(props, "scene_get_ptz_position",
        scene_action == camera_actions.PanTiltZoom_Position) or changed
    changed = set_property_visibility(props, "scene_direction", scene_action == camera_actions.PanTilt) or changed

    changed = set_property_visibility(props, "scene_image_color_level",
        scene_action == camera_actions.Image_Settings) or changed
    local show_image_color_level = (scene_action == camera_actions.Image_Settings) and
        (obs.obs_data_get_bool(data, "scene_image_color_level") or false)
    changed = set_property_visibility(props, "scene_image_color_level_val", show_image_color_level) or changed
    if show_image_color_level and (trigger_prop_name == "scene_image_color_level") and reply_data.color_level then
        if obs.obs_data_get_default_int(data, "scene_image_color_level_val") ~= reply_data.color_level then
            obs.obs_data_set_default_int(data, "scene_image_color_level_val", reply_data.color_level)
            changed = true
        end
    end

    changed = set_property_visibility(props, "scene_image_brightness",
        scene_action == camera_actions.Image_Settings) or changed
    local show_scene_image_brightness = (scene_action == camera_actions.Image_Settings) and
        (obs.obs_data_get_bool(data, "scene_image_brightness") or false)
    changed = set_property_visibility(props, "scene_image_brightness_val", show_scene_image_brightness) or changed
    if show_scene_image_brightness and (trigger_prop_name == "scene_image_brightness") and reply_data.brightness then
        if obs.obs_data_get_default_int(data, "scene_image_brightness_val") ~= reply_data.brightness then
            obs.obs_data_set_default_int(data, "scene_image_brightness_val", reply_data.brightness)
            changed = true
        end
    end

    local need_speed = (scene_action == camera_actions.PanTilt) or (scene_action == camera_actions.Zoom_In) or
        (scene_action == camera_actions.Zoom_Out) or (scene_action == camera_actions.PanTiltZoom_Position)
    changed = set_property_visibility(props, "scene_speed", need_speed) or changed

    local is_custom_command = scene_action == camera_actions.Custom_Command
    changed = set_property_visibility(props, "scene_custom_info", is_custom_command) or changed
    changed = set_property_visibility(props, "scene_custom_start", is_custom_command) or changed
    changed = set_property_visibility(props, "scene_custom_stop", is_custom_command) or changed

    return changed
end

local function camera_active_in_scene(scene_type, camera_id)
    local active = false

    for scene_name, _, source_settings, source_is_visible in get_plugin_settings_from_scene(scene_type, camera_id) do
        if scene_name then
            log("Current %s scene is %s", (scene_type == plugin_scene_type.Program) and "program" or "preview",
                scene_name or "?")

            if source_settings and source_is_visible then
                local source_camera_id = obs.obs_data_get_int(source_settings, "scene_camera")
                log("Camera ref: %d active on %s: %d", camera_id,
                    (scene_type == plugin_scene_type.Program) and "program" or "preview", source_camera_id)
                if camera_id == source_camera_id then
                    active = true
                end
            end
        end

        if source_settings then
            obs.obs_data_release(source_settings)
        end
    end

    return active
end

local function do_cam_scene_action(settings, action_at)
    local camera_id = obs.obs_data_get_int(settings, "scene_camera")
    local scene_action = obs.obs_data_get_int(settings, "scene_action")
    local cam_prop_prefix = string.format("cam_%d_", camera_id)

    if not plugin_data.suppress_scene_actions then
        local scene_ptz_position = obs.obs_data_get_string(settings, "scene_ptz_position")
        local pan_position, tilt_position, zoom_position
        if scene_ptz_position and (scene_ptz_position ~= '') then
            local ptz_values = {}

            -- Capture P,T,Z from 'Pan-value (hex-val), Tilt-value (hex-val), Zoom-value (hex-val)
            for val in scene_ptz_position:gmatch("%((%x+)%)") do
                table.insert(ptz_values, tonumber(val, 16))
            end

            pan_position, tilt_position, zoom_position = unpack(ptz_values)
        end

        local action_args = {
            preset = scene_action == camera_actions.Preset_Recall
                       and obs.obs_data_get_int(settings, "scene_" .. cam_prop_prefix .. "preset")
                       or nil,
            direction = obs.obs_data_get_int(settings, "scene_direction"),
            speed = obs.obs_data_get_double(settings, "scene_speed"),
            pan_position = pan_position,
            tilt_position = tilt_position,
            zoom_position = zoom_position,
            color_level = obs.obs_data_get_bool(settings, "scene_image_color_level")
                            and obs.obs_data_get_int(settings, "scene_image_color_level_val")
                            or nil,
            brightness = obs.obs_data_get_bool(settings, "scene_image_brightness")
                            and obs.obs_data_get_int(settings, "scene_image_brightness_val")
                            or nil,
            custom_start = parse_custom_action(obs.obs_data_get_string(settings, "scene_custom_start")),
            custom_stop = parse_custom_action(obs.obs_data_get_string(settings, "scene_custom_stop")),
        }

        if action_at == scene_action_at.Start then
            local delay = obs.obs_data_get_int(settings, "scene_action_delay") or 0
            if delay > 0 then
                obs.timer_add(function()
                    obs.remove_current_callback()
                    do_cam_action_start(camera_id, scene_action, action_args)
                end, delay)
            else
                do_cam_action_start(camera_id, scene_action, action_args)
            end
        else
            do_cam_action_stop(camera_id, scene_action, action_args)
        end
    else
        log("Suppressed action for cam %d action %d", camera_id, scene_action)
    end
end

local function source_signal_processor(source_settings, source_name, signal)
    local do_action = false
    local active = obs.obs_data_get_int(source_settings, "scene_active")
    local camera_id = obs.obs_data_get_int(source_settings, "scene_camera")

    -- Signals signal.activate and signal.deactivate are triggered when the source is active/inactive on program
    if signal.activate or signal.deactivate then
        if (active == camera_action_active.Program) or (active == camera_action_active.Always) then
            do_action = true
        end
    end

    -- Signals signal.show and signal.hide should not trigger an action.
    -- These signals also trigger when multiview is activated, so do not reliably represent preview status.
    -- In addition, the signals are not re-triggered when the scene is already active on preview (or multiview)
    -- TODO: Remove handling of signal.hide when signal.hide_fe_event is send by fe_callback
    if signal.show_fe_event or signal.hide_fe_event or signal.hide then
        if (active == camera_action_active.Preview) or (active == camera_action_active.Always) then
            do_action = true
        end
    end

    log("%s visca source '%s' (camera %d): %s",
        signal.activate and "Activate" or
        signal.deactivate and "Deactivate" or
        signal.show and "Show" or
        signal.show_fe_event and "Show (FE)" or
        signal.hide and "Hide" or
        signal.hide_fe_event and "Hide (FE)" or "?",
        source_name,
        camera_id,
        do_action and "process" or "no action")

    if do_action then
        if signal.show or signal.show_fe_event then
            local current_preview_scene = obs.obs_frontend_get_current_preview_scene()
            if current_preview_scene ~= nil then
                local current_preview_scene_name = obs.obs_source_get_name(current_preview_scene)

                if plugin_data.program_scene[current_preview_scene_name] ~= nil then
                    do_action = false
                    log("Not running start action on preview for source '%s', " ..
                        "because it transitioned from program in scene %s", source_name or "?", current_preview_scene_name)
                end

                obs.obs_source_release(current_preview_scene)
            end
        end
    end

    if signal.activate then
        local current_program_scene = obs.obs_frontend_get_current_scene()
        if current_program_scene ~= nil then
            local current_program_scene_name = obs.obs_source_get_name(current_program_scene)

            plugin_data.program_scene[current_program_scene_name] = true

            obs.obs_source_release(current_program_scene)
        end
    end

    if signal.deactivate then
        local current_preview_scene = obs.obs_frontend_get_current_preview_scene()
        if current_preview_scene ~= nil then
            local current_preview_scene_name = obs.obs_source_get_name(current_preview_scene)

            plugin_data.program_scene[current_preview_scene_name] = nil

            obs.obs_source_release(current_preview_scene)
        end
    end

    if do_action then
        if signal.show or signal.show_fe_event then
            local preview_exclusive = obs.obs_data_get_bool(source_settings, "preview_exclusive")
            if preview_exclusive then
                if camera_active_in_scene(plugin_scene_type.Program, camera_id) then
                    do_action = false
                    log("Not running start action on preview for source '%s', " ..
                        "because it is currently active on program", source_name or "?")
                end
            end
        end

        if signal.deactivate or signal.hide_fe_event or signal.hide then
            if camera_active_in_scene(plugin_scene_type.Program, camera_id) then
                do_action = false
                log("Not running stop action for source '%s', " ..
                    "because it is currently active on program", source_name or "?")
            end
            if (active == camera_action_active.Preview) and
                camera_active_in_scene(plugin_scene_type.Preview, camera_id) then
                do_action = false
                log("Not running stop action on preview for source '%s', " ..
                    "because it is currently active on preview", source_name or "?")
            end
        end
    end

    if do_action then
        if signal.activate or signal.show or signal.show_fe_event then
            do_cam_scene_action(source_settings, scene_action_at.Start)
        end
        if signal.deactivate or signal.hide or signal.hide_fe_event then
            do_cam_scene_action(source_settings, scene_action_at.Stop)
        end
    end
end

local function fe_callback(event, data)
    if event == obs.OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED then
        local unset_preview_scene = true
        local activate_sources = false

        local first = true
        for scene_name, source_name, source_settings, source_is_visible in
            get_plugin_settings_from_scene(plugin_scene_type.Preview) do

            if first then
                if (plugin_data.preview_scene ~= scene_name) then
                    log("OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED to '%s' for '%s'",
                        scene_name or "?", source_name or "?")
                    plugin_data.preview_scene = scene_name
                    activate_sources = true
                end

                if (plugin_data.preview_scene == scene_name) then
                    unset_preview_scene = false
                end

                first = false
            end

            -- TODO: Filter events for scene transitioning back to preview to prevent start action execution

            -- Activate the Visca sources in the now visible scene
            if activate_sources then
                if source_settings and source_is_visible then
                    source_signal_processor(source_settings, source_name, { show_fe_event = true })
                end
            end

            if source_settings then
                obs.obs_data_release(source_settings)
            end
        end

        if unset_preview_scene and plugin_data.preview_scene ~= nil then
            log("OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED unset from '%s'", plugin_data.preview_scene)
            -- TODO: Trigger artificial event { hide_fe_event = true }
            -- This even should replace the signal 'hide' that is not properly lauched when multiview is active
            plugin_data.preview_scene = nil
        end
    end
end

local function source_signal_handler(calldata, signal)
    local source = obs.calldata_source(calldata, "source")
    if source ~= nil then
        local source_settings = obs.obs_source_get_settings(source)
        local source_name = obs.obs_source_get_name(source)

        source_signal_processor(source_settings, source_name, signal)

        obs.obs_data_release(source_settings)
    end
end

local function cb_scene_get_ptz_position(scene_props, btn_prop)
    for _, _, source_settings, _ in get_plugin_settings_from_scene(plugin_scene_type.Preview) do
        if source_settings then
            local camera_id = obs.obs_data_get_int(source_settings, "scene_camera")
            local connection = open_visca_connection(camera_id)
            if connection then
                connection:Cam_Pantilt_Position_Inquiry()
                connection:Cam_Zoom_Position_Inquiry()
            end

            obs.obs_data_release(source_settings)
        end
    end

    return true
end

plugin_def.get_name = function()
    return plugin_info.name
end

plugin_def.create = function(_settings, source)
    local data = {}
    local source_sh = obs.obs_source_get_signal_handler(source)
    obs.signal_handler_connect(source_sh, "show",
        function(calldata) source_signal_handler(calldata, { show = true }) end)
    obs.signal_handler_connect(source_sh, "hide",
        function(calldata) source_signal_handler(calldata, { hide = true }) end)
    obs.signal_handler_connect(source_sh, "activate",
        function(calldata) source_signal_handler(calldata, { activate = true }) end)
    obs.signal_handler_connect(source_sh, "deactivate",
        function(calldata) source_signal_handler(calldata, { deactivate = true }) end)

    -- The ideal handling of signals on preview is via the signals 'show' and 'hide.
    -- These however are not properly fired when Multiview is active.
    -- The active preview scene is for that reason monitored via the OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED event.
    obs.obs_frontend_add_event_callback(fe_callback)

    return data
end

plugin_def.destroy = function(_data)
    for camera_id, connection in pairs(plugin_data.connections) do
        if connection ~= nil then
            connection:close()
            plugin_data.connections[camera_id] = nil
        end
    end
    plugin_data.connections = {}
    Visca.ReplyServer.shutdown()
end

plugin_def.get_properties = function(data)
    local props = obs.obs_properties_create()

    local action_props = obs.obs_properties_create()
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    local prop_camera = obs.obs_properties_add_list(action_props, "scene_camera", "Camera", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)

    local prop_action = obs.obs_properties_add_list(action_props, "scene_action", "Action", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_action, "Camera Off", camera_actions.Camera_Off)
    obs.obs_property_list_add_int(prop_action, "Camera On", camera_actions.Camera_On)
    obs.obs_property_list_add_int(prop_action, "Image Settings", camera_actions.Image_Settings)
    obs.obs_property_list_add_int(prop_action, "Preset Recall", camera_actions.Preset_Recall)
    obs.obs_property_list_add_int(prop_action, "Pan/Tilt/Zoom Absolute position", camera_actions.PanTiltZoom_Position)
    obs.obs_property_list_add_int(prop_action, "Pan/Tilt Direction", camera_actions.PanTilt)
    obs.obs_property_list_add_int(prop_action, "Zoom In", camera_actions.Zoom_In)
    obs.obs_property_list_add_int(prop_action, "Zoom Out", camera_actions.Zoom_Out)
    obs.obs_property_list_add_int(prop_action, "Zoom Stop", camera_actions.Zoom_Stop)
    obs.obs_property_list_add_int(prop_action, "Custom Command", camera_actions.Custom_Command)
    obs.obs_properties_add_group(props, "scene_action_group", "Action", obs.OBS_GROUP_NORMAL, action_props)

    -- Action configuration
    local direction_names = {}
    for direction_name in pairs(Visca.PanTilt_directions) do
        table.insert(direction_names, direction_name)
    end
    table.sort(direction_names)

    local config_props = obs.obs_properties_create()
    local prop_pantilt_direction = obs.obs_properties_add_list(config_props, "scene_direction", "Animation Direction",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_pantilt_direction, "None", 0)
    for _, direction_name in ipairs(direction_names) do
        obs.obs_property_list_add_int(prop_pantilt_direction, direction_name:gsub("^%l", string.upper),
            Visca.PanTilt_directions[direction_name])
    end
    obs.obs_properties_add_int_slider(config_props, "scene_speed", "Animation Speed",
        Visca.limits.PAN_MIN_SPEED, Visca.limits.PAN_MAX_SPEED, 1)
    local ptz_position = obs.obs_properties_add_text(config_props, "scene_ptz_position", "Position",
        obs.OBS_TEXT_DEFAULT)
    obs.obs_property_set_enabled(ptz_position, false)
    obs.obs_properties_add_button(config_props, "scene_get_ptz_position", "Retrieve current position",
        cb_scene_get_ptz_position)

    for camera_id = 1, num_cameras do
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name_suffix = string.format(" (cam %d)", camera_id)

        local cam_name = obs.obs_data_get_string(plugin_settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end
        obs.obs_property_list_add_int(prop_camera, cam_name, camera_id)

        local prop_presets = obs.obs_properties_add_list(config_props, "scene_" .. cam_prop_prefix .. "preset",
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

                obs.obs_data_release(preset)
            end
        end

        obs.obs_data_array_release(presets)
    end

    local prop_image_color_level =
        obs.obs_properties_add_bool(config_props, "scene_image_color_level", "Set Color Gain (Saturation)")
    obs.obs_properties_add_int_slider(config_props, "scene_image_color_level_val", "Level",
        Visca.limits.COLOR_GAIN_MIN_LEVEL, Visca.limits.COLOR_GAIN_MAX_LEVEL, 1)
    local prop_image_brightness =
        obs.obs_properties_add_bool(config_props, "scene_image_brightness", "Set Brightness")
    obs.obs_properties_add_int_slider(config_props, "scene_image_brightness_val", "Level",
        Visca.limits.BRIGHTNESS_MIN, Visca.limits.BRIGHTNESS_MAX, 1)

    -- Use OBS_TEXT_INFO only when OBS version >= 28
    if obslua.obs_get_version() / 255 ^ 3 >= 28 then
        obs.obs_properties_add_text(config_props, "scene_custom_info",
            "In the start and stop command entries, enter the Visca command that must be sent to the camera when a " ..
            "scene loads (start) or unloads (stop), as sequence of hexadecimal values. \n" ..
            "The command codes can be camera specific and usually are found in the manual of the camera. \n" ..
            "Example: \n- Set tally light on: '01 7E 01 0A 00 02' \n" ..
            "The hexadecimal values may be space separated and may use 0x prefixes, but this is not required. \n" ..
            "The command values should not include the (first) address (8x) and the (last) termination (FF) byte.",
            obs.OBS_TEXT_INFO)
    else
        local prop_custom_info = obs.obs_properties_add_text(config_props, "scene_custom_info",
            "See plugin documentation for details", obslua.OBS_TEXT_DEFAULT)
        obs.obs_property_set_enabled(prop_custom_info, false)
    end
    obs.obs_properties_add_text(config_props, "scene_custom_start", "Start command", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(config_props, "scene_custom_stop", "Stop command", obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_add_group(props, "scene_config_grp", "Action configuration", obs.OBS_GROUP_NORMAL, config_props)

    -- Action options
    local option_props = obs.obs_properties_create()
    local prop_active = obs.obs_properties_add_list(option_props, "scene_active", "Action Active",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_active, "On Program", camera_action_active.Program)
    obs.obs_property_list_add_int(prop_active, "On Preview", camera_action_active.Preview)
    obs.obs_property_list_add_int(prop_active, "Always", camera_action_active.Always)
    obs.obs_properties_add_bool(option_props, "preview_exclusive",
        "Run action on preview only when the camera is exclusive on preview, not active on program")
    obs.obs_properties_add_int(option_props, "scene_action_delay", "Delay Action (ms)", 0, 777333, 1)
    obs.obs_properties_add_group(props, "scene_option_grp", "Action options", obs.OBS_GROUP_NORMAL, option_props)

    --obs.obs_properties_add_button(props, "run_action", "Perform action now", cb_run_action)

    obs.obs_property_set_modified_callback(prop_image_color_level, cb_camera_action_changed)
    obs.obs_property_set_modified_callback(prop_image_brightness, cb_camera_action_changed)
    obs.obs_property_set_modified_callback(prop_camera, cb_camera_action_changed)
    obs.obs_property_set_modified_callback(prop_action, cb_camera_action_changed)

    return props
end

obs.obs_register_source(plugin_def)

if _G._UNITTEST then
    _T = {}
    _T.plugin_def = plugin_def

    -- Internal locals
    _T._plugin_settings = plugin_settings
    _T._plugin_data = plugin_data
    _T._camera_actions = camera_actions
    _T._parse_preset_value = parse_preset_value
    _T._parse_custom_action = parse_custom_action
    _T._do_cam_action_start = do_cam_action_start
end
