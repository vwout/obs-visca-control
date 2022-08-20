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
    reply_data = {},
    hotkeys = {},
    suppress_scene_actions = false,
}

local plugin_actions = {
    Suppress_Scene_Actions = 0,
}

local scene_action_at = {
    Start = true,
    Stop = false,
}

local camera_actions = {
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
    PanTiltZoom_Position = 12,
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

        print(string.format("%s (%d): %s", func, line, string.format(fmt, unpack(args or {}))))
    end
end

local function parse_preset_value(preset_value)
    local preset_name
    local preset_id
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

            obs.obs_data_release(preset)
        end
    end

    obs.obs_data_array_release(presets)
end

local function create_camera_controls(cam_props, camera_id, settings)
    local cams = obs.obs_properties_get(cam_props, "cameras")
    if cams then
        local props = obs.obs_properties_create()
        local cam_prop_prefix = string.format("cam_%d_", camera_id)
        local cam_name_suffix = string.format(" (cam %d)", camera_id)

        local cam_name = obs.obs_data_get_string(settings, cam_prop_prefix .. "name")
        if #cam_name == 0 then
            cam_name = string.format("Camera %d", camera_id)
        end
        obs.obs_property_list_add_int(cams, cam_name, camera_id)

        local prop_grp = obs.obs_properties_get(props, cam_prop_prefix .. "grp")
        if prop_grp == nil then
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
            local prop_mode = obs.obs_properties_add_list(props, cam_prop_prefix .. "mode", "Mode",
                obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
            obs.obs_property_list_add_int(prop_mode, "Generic", Visca.modes.generic)
            obs.obs_property_list_add_int(prop_mode, "PTZOptics", Visca.modes.ptzoptics)
            obs.obs_data_set_default_int(settings, cam_prop_prefix .. "mode", Visca.modes.generic)
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

local function get_plugin_settings_from_scene(program, camera_id)
    program = program or false
    local p_settings = {}

    local scene_source = program and obs.obs_frontend_get_current_scene() or
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
        if result then
            return scene_name, source_name, source_settings, source_is_visible
        else
            -- Ensure source_settings refcounted copy is released
            for _,plugin_setting in pairs(p_settings) do
                _, _, source_settings, _ = unpack(plugin_setting)
                obs.obs_data_release(source_settings)
            end
            return nil
        end
     end
end

local function close_visca_connection(camera_id)
    local connection = plugin_data.connections[camera_id]

    if connection ~= nil then
        connection.close()
        connection.unregister_on_ack_callback(camera_id)
        connection.unregister_on_completion_callback(camera_id)
        connection.unregister_on_error_callback(camera_id)
        connection.unregister_on_timeout_callback(camera_id)
        connection = nil
        plugin_data.connections[camera_id] = connection
    end
end

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
                connection.set_mode(camera_mode)
            end

            connection.register_on_completion_callback(camera_id, function(t)
                log("Connection Completion received for camera %d (seq_nr %d)", camera_id, t and t.send.seq_nr or -1)

                local t_data = t.inquiry_data()
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
                            Visca.CameraModel[reply_data.vendor_id or 0][reply_data.model_code] or "Unknown",
                            reply_data.model_code or 0,
                            reply_data.rom_version or 0)
                        local version_info_setting = string.format("cam_%d_version_info", camera_id)
                        obs.obs_data_set_string(plugin_settings, version_info_setting, version_info)
                        log("Set setting %s to %s", version_info_setting, version_info)
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
                            get_plugin_settings_from_scene(false, camera_id) do
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
                end
            end)

            if plugin_data.debug then
                connection.register_on_ack_callback(camera_id, function(t)
                    log("Connection ACK received for camera %d (seq_nr %d)", camera_id, t and t.send.seq_nr or -1)
                end)
                connection.register_on_error_callback(camera_id, function(t)
                    log("Connection ERROR received for camera %d (seq_nr %d)", camera_id, t and t.send.seq_nr or -1)
                end)
                connection.register_on_timeout_callback(camera_id, function(t)
                    log("Connection Timeout for camera %d (seq_nr %d)", camera_id, t and t.send.seq_nr or -1)
                end)
            end

            plugin_data.connections[camera_id] = connection

            connection.Cam_Software_Version_Inquiry()
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

local function do_cam_action_start(camera_id, camera_action, action_args)
    action_args = action_args or {}

    -- Force close connection before sending On-command to prevent usage of a dead connection
    if camera_action == camera_actions.Camera_On then
        close_visca_connection(camera_id)
    end

    log("Start cam %d action %d (args %s)", camera_id, camera_action, action_args)

    local connection = open_visca_connection(camera_id)
    if connection then
        if camera_action == camera_actions.Camera_Off then
            connection.Cam_Power(false)

            -- Force close connection after sending Off-command.
            connection.close()
            plugin_data.connections[camera_id] = nil
        elseif camera_action == camera_actions.Camera_On then
            connection.Cam_Power(true)
        elseif camera_action == camera_actions.Preset_Recal and action_args.preset then
            connection.Cam_Preset_Recall(action_args.preset)
        elseif camera_action == camera_actions.PanTilt then
            connection.Cam_PanTilt(action_args.direction or Visca.PanTilt_directions.stop, action_args.speed or 0x03,
                action_args.speed or 0x03)
        elseif camera_action == camera_actions.Zoom_In then
            connection.Cam_Zoom_Tele(action_args.speed)
        elseif camera_action == camera_actions.Zoom_Out then
            connection.Cam_Zoom_Wide(action_args.speed)
        elseif camera_action == camera_actions.Focus_Auto then
            connection.Cam_Focus_Mode(Visca.Focus_modes.auto)
        elseif camera_action == camera_actions.Focus_Manual then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
        elseif camera_action == camera_actions.Focus_Refocus then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Mode(Visca.Focus_modes.one_push_trigger)
        elseif camera_action == camera_actions.Focus_Infinity then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Mode(Visca.Focus_modes.infinity)
        elseif camera_action == camera_actions.Focus_Near then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Near()
        elseif camera_action == camera_actions.Focus_Far then
            connection.Cam_Focus_Mode(Visca.Focus_modes.manual)
            connection.Cam_Focus_Far()
        elseif camera_action == camera_actions.PanTiltZoom_Position then
            if action_args.pan_position ~= nil and action_args.tilt_position ~= nil then
                connection.Cam_PanTilt_Absolute(action_args.speed or 1,
                    action_args.pan_position, action_args.tilt_position)
            end
            if action_args.zoom_position ~= nil then
                connection.Cam_Zoom_To(action_args.zoom_position)
            end
        end
    end
end

local function do_cam_action_stop(camera_id, camera_action, action_args)
    action_args = action_args or {}

    log("Stop cam %d action %d (arg %s)", camera_id, camera_action, action_args)
    local connection = open_visca_connection(camera_id)
    if connection then
        if camera_action == camera_actions.PanTilt then
            connection.Cam_PanTilt(Visca.PanTilt_directions.stop)
        elseif camera_action == camera_actions.Zoom_In then
            connection.Cam_Zoom_Stop()
        elseif camera_action == camera_actions.Zoom_Out then
            connection.Cam_Zoom_Stop()
        elseif camera_action == camera_actions.Focus_Near then
            connection.Cam_Focus_Stop()
        elseif camera_action == camera_actions.Focus_Far then
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

local function handleViscaResponses()
    for camera_id, connection in pairs(plugin_data.connections) do
        local success, msg, err, num = pcall(connection.receive)
        if not success then
            log("Poll camera %d failed: %s", camera_id, msg)
        else
            if msg then
                log("Poll camera %d (%s): %s", camera_id, tostring(connection), msg.as_string(connection.mode))
                if plugin_data.debug then
                    msg.dump()
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
        { name = "zoom_in", descr = "Zoom In", action = camera_actions.Zoom_In },
        { name = "zoom_out", descr = "Zoom Out", action = camera_actions.Zoom_Out },
        { name = "focus_auto", descr = "Focus mode Automatic", action = camera_actions.Focus_Auto },
        { name = "focus_manual", descr = "Focus mode Manual", action = camera_actions.Focus_Manual },
        { name = "focus_trigger", descr = "Focus trigger Refocus", action = camera_actions.Focus_Refocus },
        { name = "focus_near", descr = "Focus to Near", action = camera_actions.Focus_Near },
        { name = "focus_far", descr = "Focus to Far", action = camera_actions.Focus_Far },
        { name = "focus_infinity", descr = "Focus to Infinity", action = camera_actions.Focus_Infinity },
        { name = "preset_0", descr = "Preset 0", action = camera_actions.Preset_Recal, action_args = { preset = 0 } },
        { name = "preset_1", descr = "Preset 1", action = camera_actions.Preset_Recal, action_args = { preset = 1 } },
        { name = "preset_2", descr = "Preset 2", action = camera_actions.Preset_Recal, action_args = { preset = 2 } },
        { name = "preset_3", descr = "Preset 3", action = camera_actions.Preset_Recal, action_args = { preset = 3 } },
        { name = "preset_4", descr = "Preset 4", action = camera_actions.Preset_Recal, action_args = { preset = 4 } },
        { name = "preset_5", descr = "Preset 5", action = camera_actions.Preset_Recal, action_args = { preset = 5 } },
        { name = "preset_6", descr = "Preset 6", action = camera_actions.Preset_Recal, action_args = { preset = 6 } },
        { name = "preset_7", descr = "Preset 7", action = camera_actions.Preset_Recal, action_args = { preset = 7 } },
        { name = "preset_8", descr = "Preset 8", action = camera_actions.Preset_Recal, action_args = { preset = 8 } },
        { name = "preset_9", descr = "Preset 9", action = camera_actions.Preset_Recal, action_args = { preset = 9 } },
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
        if scene_action ~= camera_actions.Preset_Recal then
            visible = false
        end

        changed = set_property_visibility(props, string.format("scene_cam_%d_preset", camera_id), visible) or changed
    end

    changed = set_property_visibility(props, "scene_ptz_position",
        scene_action == camera_actions.PanTiltZoom_Position) or changed
    changed = set_property_visibility(props, "scene_get_ptz_position",
        scene_action == camera_actions.PanTiltZoom_Position) or changed
    changed = set_property_visibility(props, "scene_direction", scene_action == camera_actions.PanTilt) or changed
    local need_speed = (scene_action == camera_actions.PanTilt) or (scene_action == camera_actions.Zoom_In) or
        (scene_action == camera_actions.Zoom_Out) or (scene_action == camera_actions.PanTiltZoom_Position)
    changed = set_property_visibility(props, "scene_speed", need_speed) or changed

    return changed
end

local function camera_active_in_scene(program, camera_id)
    local active = false

    for scene_name, _, source_settings, source_is_visible in get_plugin_settings_from_scene(program, camera_id) do
        if scene_name then
            log("Current %s scene is %s", program and "program" or "preview", scene_name or "?")

            if source_settings and source_is_visible then
                local source_camera_id = obs.obs_data_get_int(source_settings, "scene_camera")
                log("Camera ref: %d active on %s: %d", camera_id, program and "program" or "preview", source_camera_id)
                if camera_id == source_camera_id then
                    active = true
                end
            end

            if source_settings then
                obs.obs_data_release(source_settings)
            end
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
            preset = obs.obs_data_get_int(settings, "scene_" .. cam_prop_prefix .. "preset"),
            direction = obs.obs_data_get_int(settings, "scene_direction"),
            speed = obs.obs_data_get_double(settings, "scene_speed"),
            pan_position = pan_position,
            tilt_position = tilt_position,
            zoom_position = zoom_position,
        }

        local active = obs.obs_data_get_int(settings, "scene_active")
        local delay = obs.obs_data_get_int(settings, "scene_action_delay") or 0

        if action_at == scene_action_at.Start then
            if delay > 0 then
                obs.timer_add(function()
                    obs.remove_current_callback()
                    do_cam_action_start(camera_id, scene_action, action_args)
                end, delay)
            else
                do_cam_action_start(camera_id, scene_action, action_args)
            end
        else
            if not camera_active_in_scene(true, camera_id) and (active == camera_action_active.Program or
                not camera_active_in_scene(false, camera_id)) then
                do_cam_action_stop(camera_id, scene_action, action_args)
            end
        end
    else
        log("Suppressed action for cam %d action %d", camera_id, scene_action)
    end
end

local function fe_callback(event, data)
    if event == obs.OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED then
        for scene_name, source_name, source_settings, source_is_visible in get_plugin_settings_from_scene(false) do
            if plugin_data.preview_scene ~= scene_name then
                plugin_data.preview_scene = scene_name
                log("OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED to %s", scene_name or "?")

                if source_settings and source_is_visible then
                    local do_action = false
                    local active = obs.obs_data_get_int(source_settings, "scene_active")

                    if (active == camera_action_active.Preview) or
                       (active == camera_action_active.Always) then
                        do_action = true

                        local preview_exclusive = obs.obs_data_get_bool(source_settings, "preview_exclusive")
                        if preview_exclusive then
                            local preview_camera_id = obs.obs_data_get_int(source_settings, "scene_camera")
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
                        do_cam_scene_action(source_settings, scene_action_at.Start)
                    end
                end

                if source_settings then
                    obs.obs_data_release(source_settings)
                end
            end
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
    if (active == camera_action_active.Program) or (active == camera_action_active.Always) then
        do_action = true
    end

    if do_action then
        if signal.activate then do_cam_scene_action(settings, scene_action_at.Start) end
        if signal.deactivate or signal.hide then do_cam_scene_action(settings, scene_action_at.Stop) end
    end

    obs.obs_data_release(settings)
end

local function cb_scene_get_ptz_position(scene_props, btn_prop)
    for _, _, source_settings, _ in get_plugin_settings_from_scene(false) do
        if source_settings then
            local camera_id = obs.obs_data_get_int(source_settings, "scene_camera")
            local connection = open_visca_connection(camera_id)
            if connection then
                connection.Cam_Pantilt_Position_Inquiry()
                connection.Cam_Zoom_Position_Inquiry()
            end

            obs.obs_data_release(source_settings)
        end
    end

    return true
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

    local action_props = obs.obs_properties_create()
    local num_cameras = obs.obs_data_get_int(plugin_settings, "num_cameras")
    local prop_camera = obs.obs_properties_add_list(action_props, "scene_camera", "Camera", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)

    local prop_action = obs.obs_properties_add_list(action_props, "scene_action", "Action", obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_action, "Camera Off", camera_actions.Camera_Off)
    obs.obs_property_list_add_int(prop_action, "Camera On", camera_actions.Camera_On)
    obs.obs_property_list_add_int(prop_action, "Preset Recall", camera_actions.Preset_Recal)
    obs.obs_property_list_add_int(prop_action, "Pan/Tilt/Zoom Absolute position", camera_actions.PanTiltZoom_Position)
    obs.obs_property_list_add_int(prop_action, "Pan/Tilt Direction", camera_actions.PanTilt)
    obs.obs_property_list_add_int(prop_action, "Zoom In", camera_actions.Zoom_In)
    obs.obs_property_list_add_int(prop_action, "Zoom Out", camera_actions.Zoom_Out)
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

    obs.obs_properties_add_group(props, "scene_config_grp", "Action configuration", obs.OBS_GROUP_NORMAL, config_props)

    -- Action options
    local option_props = obs.obs_properties_create()
    local prop_active = obs.obs_properties_add_list(option_props, "scene_active", "Action Active",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    obs.obs_property_list_add_int(prop_active, "On Program", camera_action_active.Program)
    obs.obs_property_list_add_int(prop_active, "On Preview", camera_action_active.Preview)
    obs.obs_property_list_add_int(prop_active, "Always", camera_action_active.Always)
    obs.obs_properties_add_bool(option_props, "preview_exclusive",
        "Run action on preview only when the camera is not active on program")
    obs.obs_properties_add_int(option_props, "scene_action_delay", "Delay Action (ms)", 0, 777333, 1)
    obs.obs_properties_add_group(props, "scene_option_grp", "Action options", obs.OBS_GROUP_NORMAL, option_props)

    --obs.obs_properties_add_button(props, "run_action", "Perform action now", cb_run_action)

    obs.obs_property_set_modified_callback(prop_camera, cb_camera_action_changed)
    obs.obs_property_set_modified_callback(prop_action, cb_camera_action_changed)

    return props
end

obs.obs_register_source(plugin_def)
