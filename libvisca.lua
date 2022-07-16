local bit = require("bit")
local socket = require("ljsocket")

local Visca = {}

Visca.default_port = 52381
Visca.default_camera_nr = 1
Visca.debug = false

Visca.modes = {
    generic = 0,
    ptzoptics = 1
}

-- Payload type
-- Stores the value (Byte 0 and Byte 1) of the following table on the payload division
Visca.payload_types = {
    visca_command   = 0x0100,  -- VISCA command, Stores the VISCA command.
    visca_inquiry   = 0x0110,  -- VISCA inquiry, Stores the VISCA inquiry.
    visca_reply     = 0x0111,  -- VISCA reply, Stores the reply for the VISCA command and VISCA inquiry,
                               -- or VISCA device setting command.
    visca_setting   = 0x0120,  -- VISCA device setting command, Stores the VISCA device setting command.
    control_command = 0x0200,  -- Control command, Stores the control command.
    control_reply   = 0x0201   -- Control reply, Stores the reply for the control command.
}
Visca.payload_type_names = {
    [Visca.payload_types.visca_command]   = "VISCA Command",
    [Visca.payload_types.visca_inquiry]   = "VISCA Inquiry",
    [Visca.payload_types.visca_reply]     = "VISCA Reply",
    [Visca.payload_types.visca_setting]   = "VISCA Device Setting Command",
    [Visca.payload_types.control_command] = "Control Comand",
    [Visca.payload_types.control_reply]   = "Control Reply"
}

Visca.packet_consts = {
    req_addr_base    = 0x80,
    command          = 0x01,
    inquiry          = 0x09,
    reply_ack        = 0x40,
    reply_completion = 0x50,
    reply_error      = 0x60,
    reply            = 0x90,
    terminator       = 0xFF
}

Visca.error_type_names = {
    [0x01] = "Message length error",
    [0x02] = "Syntax error",
    [0x03] = "Command buffer full",
    [0x04] = "Command canceled",
    [0x05] = "No socket",              -- To be cancelled
    [0x41] = "Command not executable",
}

Visca.categories = {
    interface    = 0x00,
    camera       = 0x04,
    exposure     = 0x04,
    focus        = 0x04,
    exposure_ext = 0x05,
    pan_tilter   = 0x06,
    camera_ext   = 0x07
}
Visca.category_names = {
    [Visca.categories.interface]    = "Interface",
    [Visca.categories.camera]       = "Exposure/Focus/Camera/Zoom",
    [Visca.categories.exposure]     = "Exposure/Focus/Camera/Zoom",
    [Visca.categories.focus]        = "Exposure/Focus/Camera/Zoom",
    [Visca.categories.exposure_ext] = "Exposure",
    [Visca.categories.pan_tilter]   = "Pan/Tilt",
    [Visca.categories.camera_ext]   = "Exposure/Camera",
}

Visca.commands = {
    power                   = 0x00,
    pantilt_drive           = 0x01,
    pantilt_absolute        = 0x02,
    pantilt_home            = 0x04,
    pantilt_reset           = 0x05,
    zoom                    = 0x07,
    focus                   = 0x08,
    exposure_gain           = 0x0C,
    pantilt_position        = 0x12,
    preset                  = 0x3F,
    zoom_direct             = 0x47,
    focus_direct            = 0x48,
    exposure_auto           = 0x49,
    exposure_shutter_direct = 0x4A,
    exposure_iris_direct    = 0x4B,
    exposure_gain_direct    = 0x4B,
}
Visca.command_names = {
    [Visca.commands.power]                   = "Power",
    [Visca.commands.pantilt_drive]           = "Pan/Tilt (Direction)",
    [Visca.commands.pantilt_absolute]        = "Pan/Tilt (Absolute)",
    [Visca.commands.pantilt_home]            = "Pan/Tilt (Home)",
    [Visca.commands.pantilt_reset]           = "Pan/Tilt (Reset)",
    [Visca.commands.zoom]                    = "Zoom",
    [Visca.commands.focus]                   = "Focus",
    [Visca.commands.exposure_gain]           = "Gain",
    [Visca.commands.pantilt_position]        = "Pan/Tilt (Position)",
    [Visca.commands.preset]                  = "Preset",
    [Visca.commands.zoom_direct]             = "Zoom (Direct)",
    [Visca.commands.focus_direct]            = "Focus (Direct)",
    [Visca.commands.exposure_auto]           = "Auto Exposure",
    [Visca.commands.exposure_iris_direct]    = "Iris Absolute",
    [Visca.commands.exposure_shutter_direct] = "Shutter Absolute",
    [Visca.commands.exposure_gain_direct]    = "Gain Absolute",
}

Visca.command_arguments = {
    preset_recall    = 0x02,
    power_on         = 0x02,
    power_standby    = 0x03,
    focus_stop       = 0x00,
    focus_far_std    = 0x02,
    focus_near_std   = 0x03,
    focus_far_var    = 0x20,
    focus_near_var   = 0x30,
}

local function ca_key(command, argument)
    return bit.lshift(command or 0, 8) + (argument or 0)
end

Visca.command_argument_names = {
    [ca_key(Visca.commands.preset,  Visca.command_arguments.preset_recall)]   = "Absolute Position (Preset)",
    [ca_key(Visca.commands.power,   Visca.command_arguments.power_on)]        = "On",
    [ca_key(Visca.commands.power,   Visca.command_arguments.power_standby)]   = "Standby",
    [ca_key(Visca.commands.focus,   Visca.command_arguments.focus_stop)]      = "Stop",
    [ca_key(Visca.commands.focus,   Visca.command_arguments.focus_far_std)]   = "Far (standard speed)",
    [ca_key(Visca.commands.focus,   Visca.command_arguments.focus_near_std)]  = "Near (standard speed)",
    [ca_key(Visca.commands.focus,   Visca.command_arguments.focus_far_var)]   = "Far (variable speed)",
    [ca_key(Visca.commands.focus,   Visca.command_arguments.focus_near_var)]  = "Near (variable speed)",
}

Visca.Focus_modes = {
    auto             = 0x3802,
    manual           = 0x3803,
    toggle           = 0x3810,
    one_push_trigger = 0x1801,
    infinity         = 0x1802,
}

Visca.PanTilt_directions = {
    upleft    = 0x0101,
    upright   = 0x0201,
    up        = 0x0301,
    downleft  = 0x0102,
    downright = 0x0202,
    down      = 0x0302,
    left      = 0x0103,
    right     = 0x0203,
    stop      = 0x0303,
}

Visca.Zoom_subcommand = {
    stop = 0x00,
    tele_standard = 0x02,
    wide_standard = 0x03,
    tele_variable = 0x20,
    wide_variable = 0x30,
}

Visca.limits = {
    PAN_MIN_SPEED   = 0x01,
    PAN_MAX_SPEED   = 0x18,
    FOCUS_MIN_SPEED = 0x00,
    FOCUS_MAX_SPEED = 0x07,
    PAN_MIN_VALIE   = 0x00000,
    PAN_MAX_VALUE   = 0xFFFFF,
    TILT_MIN_VALUE  = 0x0000,
    TILT_MAX_VALUE  = 0xFFFF,
    TILT_MIN_SPEED  = 0x01,
    TILT_MAX_SPEED  = 0x18,
    ZOOM_MIN_SPEED  = 0x00,
    ZOOM_MAX_SPEED  = 0x07,
    ZOOM_MIN_VALUE  = 0x0000,
    ZOOM_MAX_VALUE  = 0x4000,
}

-- A Visca message is binary data with a message header (8 bytes) and payload (1 to 16 bytes).
-- mode=generic uses this header, mode=PTZoptics skips this header
--
-- Byte:                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
-- Payload type (byte 0-1):   |
-- Payload length (byte 2-3):       |
-- Sequence number (byte 4-7):            |
-- Payload (byte 8 - max 23):                         |
--
-- The wire format is big-endian (LSB first)
function Visca.Message()
    local self = {
        payload_type = 0x0000,
        payload_size = 0x0000,
        seq_nr       = 0x00000000,
        payload      = {},
        message      = {},
    }

    function self.lsb(v)
      return bit.band(v, 0x00FF)
    end

    function self.msb(v)
      return bit.rshift(v, 8)
    end

    local function message_payload_command(command_inquiry, category, command, arguments)
        local _self = {
            command_inquiry = command_inquiry or 0x00,
            category        = category or 0x00,
            command         = command or 0x00,
            arguments       = arguments or {}
        }

        function _self.from_payload(payload)
            _self.command_inquiry = payload[2]
            _self.category        = payload[3] or 0
            _self.command         = payload[4] or 0

            for i = 5, #payload do
                if not ((i == #payload) and (payload[i] == Visca.packet_consts.terminator)) then
                    table.insert(_self.arguments, payload[i])
                end
            end

            return _self
        end

        function _self.is_command()
            return _self.command_inquiry == Visca.packet_consts.command
        end

        function _self.is_inquiry()
            return _self.command_inquiry == Visca.packet_consts.inquiry
        end

        function _self.is_reply()
            return _self.command_inquiry == Visca.packet_consts.reply
        end

        function _self.as_string()
            local args = '- (no arguments)'
            if #_self.arguments > 0 then
                local descr = Visca.command_argument_names[ca_key(_self.command, _self.arguments[1])]

                local str_a = {}
                for i = descr and 2 or 1, #_self.arguments do
                    table.insert(str_a, string.format('%02X', _self.arguments[i]))
                end

                args = (descr or 'arguments') .. ' ' .. table.concat(str_a, ' ')
            end

            if _self.is_command() then
                return string.format('Command on %s: %s, %s',
                    Visca.category_names[_self.category],
                    Visca.command_names[_self.command] or string.format("Unknown (0x%0x)", _self.command),
                    args)
            elseif _self.is_inquiry() then
                return string.format('Inquiry on %s: %s, %s',
                    Visca.category_names[_self.category],
                    Visca.command_names[_self.command] or string.format("Unknown (0x%0x)", _self.command),
                    args)
            else
                return 'Unknown'
            end
        end

        return _self
    end

    local function message_payload_reply()
        local _self = {
            reply_type    = 0x00,
            socket_number = 0,
            error_type    = 0x00,
            arguments     = {}
        }

        function _self.from_payload(payload)
            _self.reply_type    = bit.band(payload[2], 0xF0)
            _self.socket_number = bit.band(payload[2], 0x0F)

            if _self.is_error() then
                _self.error_type = payload[3] or 0
            else
                for i = 3, #payload do
                    if not ((i == #payload) and (payload[i] == Visca.packet_consts.terminator)) then
                        table.insert(_self.arguments, payload[i])
                    end
                end
            end

            return _self
        end

        function _self.is_ack()
            return _self.reply_type == Visca.packet_consts.reply_ack
        end

        function _self.is_completion()
            return _self.reply_type == Visca.packet_consts.reply_completion
        end

        function _self.is_error()
            return _self.reply_type == Visca.packet_consts.reply_error
        end

        function _self.as_string()
            if _self.is_ack() then
                return 'Acknowledge'
            elseif _self.is_completion() then
                if #_self.arguments > 0 then
                    local str_a = {}
                    for b = 1, #_self.arguments do
                        table.insert(str_a, string.format('%02X', _self.arguments[b]))
                    end

                    return 'Completion, inquiry: ' .. table.concat(str_a, ' ')
                else
                    return 'Completion, command'
                end
            elseif _self.is_error() then
                return string.format('Error on socket %d: %s (%02x)',
                                     _self.socket_number,
                                     Visca.error_type_names[_self.error_type] or 'Unknown',
                                     _self.error_type)
            else
                return 'Unknown'
            end
        end

        return _self
    end

    function self.from_data(data)
        local message_length = #(data or '')
        if message_length > 1 then
            if (string.byte(data, 1) == 0x01 or
                string.byte(data, 1) == 0x02) and message_length >= 9 and message_length <= 24 then
                self.payload_type = string.byte(data, 1) * 256 + string.byte(data, 2)
                self.payload_size = string.byte(data, 3) * 256 + string.byte(data, 4)
                self.seq_nr       = string.byte(data, 5) * 2^24 +
                                    string.byte(data, 6) * 2^16 +
                                    string.byte(data, 7) * 2^8 +
                                    string.byte(data, 8)

                for b = 1, self.payload_size do
                    if 8+b <= message_length then
                        table.insert(self.payload, string.byte(data, 8 + b))
                    else
                        if self.payload_size > #self.payload then
                            self.payload_size = #self.payload
                        end
                        print(string.format("Ignoring byte %d, payload index beyond message length %d",
                                            8+b, message_length))
                    end
                end
            elseif message_length >= 1 and message_length <= 16 then
                self.payload_size = message_length
                for b = 1, message_length do
                    table.insert(self.payload, string.byte(data, b))
                end
            end

            if (bit.band(self.payload[1] or 0, 0xF0) == 0x80) then
                -- command or inquiry
                self.message.command = message_payload_command().from_payload(self.payload)
            elseif (bit.band(self.payload[1] or 0, 0xF0) == 0x90) then
                -- reply
                self.message.reply = message_payload_reply().from_payload(self.payload)
            end
        end

        return self
    end

    function self.to_data(mode)
        mode = mode or Visca.modes.generic
        local payload_size = (self.payload_size > 0) and self.payload_size or #self.payload
        local data = {}

        if mode == Visca.modes.generic then
            data = {
                self.msb(self.payload_type),
                self.lsb(self.payload_type),
                self.msb(payload_size),
                self.lsb(payload_size),
                bit.band(bit.rshift(self.seq_nr, 24), 0xFF),
                bit.band(bit.rshift(self.seq_nr, 16), 0xFF),
                bit.band(bit.rshift(self.seq_nr, 8), 0xFF),
                bit.band(self.seq_nr, 0xFF),
            }
        end

        for b = 1, payload_size do
            table.insert(data, self.payload[b])
        end

        local str_a = {}
        for _,v in ipairs(data) do
          table.insert(str_a, string.char(v))
        end

        return table.concat(str_a)
    end

    function self.as_string(mode)
        mode = mode or Visca.modes.generic
        local bin_str = self.to_data(mode)
        local bin_len = #(bin_str or "")

        local str_a = {}
        for b = 1, bin_len do
            table.insert(str_a, string.format('%02X', string.byte(bin_str, b)))
        end

        return table.concat(str_a, ' ')
    end

    function self.dump(name, prefix, mode)
        if name then
          print('\n' .. name .. ':')
        end
        prefix = prefix or '- '

        print(string.format('%sMessage:         %s',
                            prefix or '',
                            self.as_string(mode)))
        print(string.format("%sPayload type:    %s (0x%02X%02X)",
                            prefix or '',
                            Visca.payload_type_names[self.payload_type] or 'Unkown',
                            math.floor(self.payload_type/256), self.payload_type % 256))
        print(string.format('%sPayload length:  %d',
                            prefix or '',
                            (self.payload_size > 0) and self.payload_size or #self.payload))
        print(string.format('%sSequence number: %d',
                            prefix or '',
                            self.seq_nr))

        if self.message.command then
            print(string.format('%sPayload:         Command',
                                prefix or ''))
            print(string.format('%s                 %s',
                                prefix or '',
                                self.message.command.as_string()))
        elseif self.message.reply then
            print(string.format('%sPayload:         Reply',
                                prefix or ''))
            print(string.format('%s                 %s',
                                prefix or '',
                                self.message.reply.as_string()))
        else
            print(string.format('%sPayload:         %s',
                                prefix or '',
                                tostring(self.payload)))
            for k,v in pairs(self.payload) do
                print(string.format('%sPayload:         - byte %02X: 0x%02X',
                                    prefix or '',
                                    k,
                                    v))
            end

        end

        return self
    end

    return self
end

function Visca.connect(address, port)
    port = port or Visca.default_port
    if (port < 1) or (port > 65535) then
        port = Visca.default_port
    end
    local sock_addr, sock_err = socket.find_first_address(address, port)
    local error
    local connection = {
        sock        = nil,
        last_seq_nr = 0xFFFFFFFF,
        address     = sock_addr,
        mode        = Visca.modes.generic
    }

    if sock_addr then
        local sock = assert(socket.create("inet", "dgram", "udp"))
        local success, _ = sock:set_blocking(false)
        if success then
            connection.sock = sock
        end
    end

    if not connection.sock then
        error = string.format("Unable to connect to %s: %s", address, sock_err)
    end

    local function has_value(tbl, value)
        for _, v in pairs(tbl) do
            if v == value then
                return true
            end
        end

        return false
    end

    function connection.set_mode(mode)
        if has_value(Visca.modes, mode or Visca.modes.generic) then
            connection.mode = mode
            return true
        else
            return false
        end
    end

    function connection.close()
        local sock = connection.sock
        if sock ~= nil then
            sock:close()
            connection.sock = nil
        end
    end

    function connection.send(message)
        if connection.last_seq_nr < 0xFFFFFFFF then
            connection.last_seq_nr = connection.last_seq_nr + 1
        else
            connection.last_seq_nr = 0
        end
        message.seq_nr = connection.last_seq_nr

        if Visca.debug then
            print(string.format("Connection send %s", message.as_string(connection.mode)))
            message.dump(nil, nil, connection.mode)
        end

        local data_to_send = message.to_data(connection.mode)
        local sock = connection.sock
        if sock ~= nil then
            return sock:send_to(connection.address, data_to_send), data_to_send
        else
            return 0, data_to_send
        end
    end

    function connection.receive()
        local sock = connection.sock
        if sock ~= nil then
            local data, err, num = sock:receive_from(connection.address, 32)
            if data then
                local msg = Visca.Message()
                msg.from_data(data)
                if Visca.debug then
                    print(string.format("Received %s", msg.as_string(connection.mode)))
                end
                return msg
            else
                return nil, err, num
            end
        else
            return nil, "No connection", 0
        end
    end

    function connection.Cam_Focus_Mode(mode)
        if has_value(Visca.Focus_modes, mode) then
            local msg = Visca.Message()
            msg.payload_type = Visca.payload_types.visca_command
            msg.payload = {
                    Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                    Visca.packet_consts.command,
                    Visca.categories.focus,
                    bit.band(bit.rshift(mode, 8), 0xFF),
                    bit.band(mode, 0xFF),
                    Visca.packet_consts.terminator
                }

            return connection.send(msg)
        else
            if Visca.debug then
                print(string.format("Cam_Focus_Mode invalid mode (0x%04x)", mode or 0))
            end
            return 0
        end
    end

    function connection.Cam_Focus_Stop()
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.focus,
                Visca.commands.focus,
                Visca.command_arguments.focus_stop,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Focus_Far(speed)
        if speed then
            speed = math.min(math.max(speed or 0x02, Visca.limits.FOCUS_MIN_SPEED), Visca.limits.FOCUS_MAX_SPEED)
        end

        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.focus,
                Visca.commands.focus,
                speed and bit.bor(Visca.command_arguments.focus_far_var, bit.band(speed, 0x07))
                      or Visca.command_arguments.focus_far_std,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Focus_Near(speed)
        if speed then
            speed = math.min(math.max(speed or 0x02, Visca.limits.FOCUS_MIN_SPEED), Visca.limits.FOCUS_MAX_SPEED)
        end

        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.focus,
                Visca.commands.focus,
                speed and bit.bor(Visca.command_arguments.focus_near_var, bit.band(speed, 0x07))
                      or Visca.command_arguments.focus_near_std,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Power(on, await_ack, await_completion)
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera,
                Visca.commands.power,
                on and Visca.command_arguments.power_on or Visca.command_arguments.power_standby,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Preset_Recall(preset)
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera,
                Visca.commands.preset,
                Visca.command_arguments.preset_recall,
                bit.band(preset, 0x7F),  -- Preset Number(=0 to 127)
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_PanTilt(direction, pan_speed, tilt_speed)
        if has_value(Visca.PanTilt_directions, direction or Visca.PanTilt_directions.stop) then
            pan_speed = math.min(math.max(pan_speed or 1, Visca.limits.PAN_MIN_SPEED), Visca.limits.PAN_MAX_SPEED)
            tilt_speed = math.min(math.max(tilt_speed or 1, Visca.limits.TILT_MIN_SPEED), Visca.limits.TILT_MAX_SPEED)

            local msg = Visca.Message()
            msg.payload_type = Visca.payload_types.visca_command
            msg.payload = {
                    Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                    Visca.packet_consts.command,
                    Visca.categories.pan_tilter,
                    Visca.commands.pantilt_drive,
                    bit.band(pan_speed, 0x1F),  -- lowest 5 bits are only relevant
                    bit.band(tilt_speed, 0x1F), -- lowest 5 bits are only relevant
                    bit.band(bit.rshift(direction, 8), 0xFF),
                    bit.band(direction, 0xFF),
                    Visca.packet_consts.terminator
                }

            return connection.send(msg)
        else
            if Visca.debug then
                print(string.format("Cam_PanTilt invalid direction (%d)", direction))
            end
            return 0
        end
    end

    function connection.Cam_PanTilt_Absolute(speed, pan, tilt)
        speed = math.min(math.max(speed or 1, Visca.limits.PAN_MIN_SPEED), Visca.limits.PAN_MAX_SPEED)
        pan = math.min(math.max(pan or 1, Visca.limits.PAN_MIN_VALIE), Visca.limits.PAN_MAX_VALUE)
        tilt = math.min(math.max(tilt or 1, Visca.limits.TILT_MIN_VALUE), Visca.limits.TILT_MAX_VALUE)

        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.pan_tilter,
                Visca.commands.pantilt_absolute,
                speed,
                0x00,  -- According to Sony spec it's always zero. Does this set tilt speed?
                bit.band(bit.rshift(pan, 16), 0x0F),
                bit.band(bit.rshift(pan, 12), 0x0F),
                bit.band(bit.rshift(pan, 8), 0x0F),
                bit.band(bit.rshift(pan, 4), 0x0F),
                bit.band(pan, 0x0F),
                bit.band(bit.rshift(tilt, 12), 0x0F),
                bit.band(bit.rshift(tilt, 8), 0x0F),
                bit.band(bit.rshift(tilt, 4), 0x0F),
                bit.band(tilt, 0x0F),
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_PanTilt_Home()
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.pan_tilter,
                Visca.commands.pantilt_home,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_PanTilt_Reset()
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.pan_tilter,
                Visca.commands.pantilt_reset,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Pantilt_Position_Inquiry()
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_inquiry
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.inquiry,
                Visca.categories.pan_tilter,
                Visca.commands.pantilt_position,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_Stop()
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera,
                Visca.commands.zoom,
                Visca.Zoom_subcommand.stop,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_Tele(speed)
        if speed then
            speed = math.min(math.max(speed or 0x02, Visca.limits.ZOOM_MIN_SPEED), Visca.limits.ZOOM_MAX_SPEED)
        end

        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera,
                Visca.commands.zoom,
                speed and bit.bor(Visca.Zoom_subcommand.tele_variable, bit.band(speed, 0x07))
                      or Visca.Zoom_subcommand.tele_standard,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_Wide(speed)
        if speed then
            speed = math.min(math.max(speed or 0x02, Visca.limits.ZOOM_MIN_SPEED), Visca.limits.ZOOM_MAX_SPEED)
        end

        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera,
                Visca.commands.zoom,
                speed and bit.bor(Visca.Zoom_subcommand.wide_variable, bit.band(speed, 0x07))
                      or Visca.Zoom_subcommand.wide_standard,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_To(zoom)
        zoom = math.min(math.max(zoom or 0, Visca.limits.ZOOM_MIN_VALUE), Visca.limits.ZOOM_MAX_VALUE)

        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera,
                Visca.commands.zoom_direct,
                bit.band(bit.rshift(zoom, 12), 0x0F),
                bit.band(bit.rshift(zoom, 8), 0x0F),
                bit.band(bit.rshift(zoom, 4), 0x0F),
                bit.band(zoom, 0x0F),
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_Position_Inquiry()
        local msg = Visca.Message()
        msg.payload_type = Visca.payload_types.visca_inquiry
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.inquiry,
                Visca.categories.camera,
                Visca.commands.zoom_direct,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    if connection.sock then
        return connection
    else
        return nil, error
    end
end

return Visca
