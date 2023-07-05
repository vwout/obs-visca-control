local bit = require("bit")
local socket = require("ljsocket")
local obs = obslua

--- Visca module
local Visca = {}

-- Constants
Visca.default_port = 52381
Visca.default_camera_nr = 1
Visca.debug = false

Visca.EnumMeta = {}
Visca.EnumMeta.__index = Visca.EnumMeta
function Visca.EnumMeta:has_value(value)
    for _, v in pairs(self) do
        if v == value then
            return true
        end
    end

    return false
end

--- @class ViscaModes Enumeration of supported Visca protocol modes
Visca.modes = setmetatable({
    generic = 0,
    ptzoptics = 1
}, Visca.EnumMeta)

-- Payload type
-- Stores the value (Byte 0 and Byte 1) of the following table on the payload division
Visca.payload_types = setmetatable({
    visca_command   = 0x0100,  -- VISCA command, Stores the VISCA command.
    visca_inquiry   = 0x0110,  -- VISCA inquiry, Stores the VISCA inquiry.
    visca_reply     = 0x0111,  -- VISCA reply, Stores the reply for the VISCA command and VISCA inquiry,
                               -- or VISCA device setting command.
    visca_setting   = 0x0120,  -- VISCA device setting command, Stores the VISCA device setting command.
    control_command = 0x0200,  -- Control command, Stores the control command.
    control_reply   = 0x0201   -- Control reply, Stores the reply for the control command.
}, Visca.EnumMeta)

Visca.payload_type_names = {
    [Visca.payload_types.visca_command]   = "VISCA Command",
    [Visca.payload_types.visca_inquiry]   = "VISCA Inquiry",
    [Visca.payload_types.visca_reply]     = "VISCA Reply",
    [Visca.payload_types.visca_setting]   = "VISCA Device Setting Command",
    [Visca.payload_types.control_command] = "Control Command",
    [Visca.payload_types.control_reply]   = "Control Reply"
}

Visca.packet_consts = setmetatable({
    req_addr_base    = 0x80,
    command          = 0x01,
    inquiry          = 0x09,
    reply_ack        = 0x40,
    reply_completion = 0x50,
    reply_error      = 0x60,
    reply            = 0x90,
    terminator       = 0xFF
}, Visca.EnumMeta)

Visca.error_type_names = {
    [0x01] = "Message length error",
    [0x02] = "Syntax error",
    [0x03] = "Command buffer full",
    [0x04] = "Command canceled",
    [0x05] = "No socket",              -- To be cancelled
    [0x41] = "Command not executable",
}

Visca.categories = setmetatable({
    interface    = 0x00,
    camera       = 0x04,
    color        = 0x04,
    exposure     = 0x04,
    focus        = 0x04,
    exposure_ext = 0x05,
    pan_tilter   = 0x06,
    camera_ext   = 0x07
}, Visca.EnumMeta)

Visca.category_names = {
    [Visca.categories.interface]    = "Interface",
    [Visca.categories.camera]       = "Camera/Color/Exposure/Focus/Zoom",
    [Visca.categories.color]        = "Camera/Color/Exposure/Focus/Zoom",
    [Visca.categories.exposure]     = "Camera/Color/Exposure/Focus/Zoom",
    [Visca.categories.focus]        = "Camera/Color/Exposure/Focus/Zoom",
    [Visca.categories.exposure_ext] = "Exposure",
    [Visca.categories.pan_tilter]   = "Pan/Tilt",
    [Visca.categories.camera_ext]   = "Exposure/Camera",
}

Visca.commands = setmetatable({
    power                   = 0x00,
    pantilt_drive           = 0x01,
    pantilt_absolute        = 0x02,
    pantilt_home            = 0x04,
    pantilt_reset           = 0x05,
    zoom                    = 0x07,
    focus                   = 0x08,
    color_gain              = 0x09,
    exposure_gain           = 0x0C,
    preset                  = 0x3F,
    zoom_direct             = 0x47,
    focus_direct            = 0x48,
    color_gain_direct       = 0x49,
    exposure_shutter_direct = 0x4A,
    exposure_iris_direct    = 0x4B,
    exposure_gain_direct    = 0x4B,
    brightness_direct       = 0xA1,
}, Visca.EnumMeta)

Visca.command_names = {
    [Visca.commands.power]                   = "Power",
    [Visca.commands.pantilt_drive]           = "Pan/Tilt (Direction)",
    [Visca.commands.pantilt_absolute]        = "Pan/Tilt (Absolute)",
    [Visca.commands.pantilt_home]            = "Pan/Tilt (Home)",
    [Visca.commands.pantilt_reset]           = "Pan/Tilt (Reset)",
    [Visca.commands.zoom]                    = "Zoom",
    [Visca.commands.focus]                   = "Focus",
    [Visca.commands.color_gain]              = "Color Gain/Saturation",
    [Visca.commands.exposure_gain]           = "Gain",
    [Visca.commands.preset]                  = "Preset",
    [Visca.commands.zoom_direct]             = "Zoom (Direct)",
    [Visca.commands.focus_direct]            = "Focus (Direct)",
    [Visca.commands.color_gain_direct]       = "Color Gain/Saturation (Direct)",
    [Visca.commands.exposure_iris_direct]    = "Iris Absolute",
    [Visca.commands.exposure_shutter_direct] = "Shutter Absolute",
    [Visca.commands.exposure_gain_direct]    = "Gain Absolute",
    [Visca.commands.brightness_direct]       = "Brightness (Direct)",
}

Visca.command_arguments = setmetatable({
    color_gain_reset = 0x00,
    color_gain_up    = 0x02,
    color_gain_down  = 0x03,
    preset_recall    = 0x02,
    power_on         = 0x02,
    power_standby    = 0x03,
    focus_stop       = 0x00,
    focus_far_std    = 0x02,
    focus_near_std   = 0x03,
    focus_far_var    = 0x20,
    focus_near_var   = 0x30,
}, Visca.EnumMeta)

Visca.inquiry_commands = setmetatable({
    software_version    = 0x02,
    pantilt_position    = 0x12,
    zoom_position       = 0x47,
    color_gain          = 0x49,
    brightness_position = 0xA1,
}, Visca.EnumMeta)

Visca.inquiry_command_names = {
    [Visca.inquiry_commands.software_version]    = "Software Version",
    [Visca.inquiry_commands.pantilt_position]    = "Pan/Tilt (Position)",
    [Visca.inquiry_commands.zoom_position]       = "Zoom (Position)",
    [Visca.inquiry_commands.color_gain]          = "Color Gain - Saturation (Level)",
    [Visca.inquiry_commands.brightness_position] = "Brightness (Position)",
}

local function ca_key(command, argument)
    return bit.lshift(command or 0, 8) + (argument or 0)
end

Visca.command_argument_names = {
    [ca_key(Visca.commands.color_gain, Visca.command_arguments.color_gain_reset)] = "Reset",
    [ca_key(Visca.commands.color_gain, Visca.command_arguments.color_gain_up)]    = "Up (increment)",
    [ca_key(Visca.commands.color_gain, Visca.command_arguments.color_gain_down)]  = "Down (decrement)",
    [ca_key(Visca.commands.preset,     Visca.command_arguments.preset_recall)]    = "Absolute Position (Preset)",
    [ca_key(Visca.commands.power,      Visca.command_arguments.power_on)]         = "On",
    [ca_key(Visca.commands.power,      Visca.command_arguments.power_standby)]    = "Standby",
    [ca_key(Visca.commands.focus,      Visca.command_arguments.focus_stop)]       = "Stop",
    [ca_key(Visca.commands.focus,      Visca.command_arguments.focus_far_std)]    = "Far (standard speed)",
    [ca_key(Visca.commands.focus,      Visca.command_arguments.focus_near_std)]   = "Near (standard speed)",
    [ca_key(Visca.commands.focus,      Visca.command_arguments.focus_far_var)]    = "Far (variable speed)",
    [ca_key(Visca.commands.focus,      Visca.command_arguments.focus_near_var)]   = "Near (variable speed)",
}

Visca.Focus_modes = setmetatable({
    auto             = 0x3802,
    manual           = 0x3803,
    toggle           = 0x3810,
    one_push_trigger = 0x1801,
    infinity         = 0x1802,
}, Visca.EnumMeta)

Visca.PanTilt_directions = setmetatable({
    upleft    = 0x0101,
    upright   = 0x0201,
    up        = 0x0301,
    downleft  = 0x0102,
    downright = 0x0202,
    down      = 0x0302,
    left      = 0x0103,
    right     = 0x0203,
    stop      = 0x0303,
}, Visca.EnumMeta)

Visca.Zoom_subcommand = setmetatable({
    stop = 0x00,
    tele_standard = 0x02,
    wide_standard = 0x03,
    tele_variable = 0x20,
    wide_variable = 0x30,
}, Visca.EnumMeta)

Visca.limits = {
    BRIGHTNESS_MIN       = 0x00,
    BRIGHTNESS_MAX       = 0xFF,
    COLOR_GAIN_MIN_LEVEL = 0x00,
    COLOR_GAIN_MAX_LEVEL = 0x0E,
    PAN_MIN_SPEED        = 0x01,
    PAN_MAX_SPEED        = 0x18,
    FOCUS_MIN_SPEED      = 0x00,
    FOCUS_MAX_SPEED      = 0x07,
    PAN_MIN_VALUE        = 0x00000,
    PAN_MAX_VALUE        = 0xFFFFF,
    TILT_MIN_VALUE       = 0x0000,
    TILT_MAX_VALUE       = 0xFFFF,
    TILT_MIN_SPEED       = 0x01,
    TILT_MAX_SPEED       = 0x18,
    ZOOM_MIN_SPEED       = 0x00,
    ZOOM_MAX_SPEED       = 0x07,
    ZOOM_MIN_VALUE       = 0x0000,
    ZOOM_MAX_VALUE       = 0x4000,
}

Visca.CameraVendor = {
    [0x0001] = "Sony/NewTek",
    [0x0003] = "Everet",
    [0x0052] = "JVC",
    [0x0220] = "GlowStream",
}

Visca.CameraModelMeta = {}
Visca.CameraModelMeta.__index = function(_, _) return {} end
Visca.CameraModel = {
    [0x0001] = {
        [0x0513] = "PTZ1 NDI",
        [0x051C] = "BRC-X400",
        [0x051D] = "BRC-X401",
        [0x0617] = "SRG-X400",
        [0x0618] = "SRG-X120",
        [0x061A] = "SRG-201M2",
        [0x061B] = "SRG-HD1M2",
    },
    [0x0003] = {
        [0x0002] = "EVZ405N",
        [0x013B] = "EVP212N",
    },
    [0x0052] = {
        [0x0000] = "Maybe KY-PZ200n",
    },
    [0x0220] = {
        [0x0511] = "GS300-20x-NDI",
    },
}
setmetatable(Visca.CameraModel, Visca.CameraModelMeta)

--- @class ViscaCompatibility Configuration table with camera compatibility options
Visca.compatibility = {
    fixed_sequence_number = nil, -- Set to a non-nil numeric value to keep the message sequence counter at a fixed value
    preset_nr_offset = nil,      -- Set to non-nil to to compensate for the preset numbering in the camera.
                                 -- When the first preset is 1, leave it nil (or set to 0).
                                 -- When the first preset is 0, set the offset to 1.
                                 -- The preset recalled at the camera is 'preset - <preset_nr_offset>'
}


--- @class PayloadCommand object
Visca.PayloadCommand = {}
Visca.PayloadCommand.__index = Visca.PayloadCommand

function Visca.PayloadCommand.new()
    local self = {
        command_inquiry = 0x00,
        category        = 0x00,
        command         = 0x00,
        arguments       = {}
    }
    setmetatable(self, Visca.PayloadCommand)
    return self
end

function Visca.PayloadCommand:from_payload(payload)
    self.command_inquiry = payload[2]
    self.category        = payload[3] or 0
    self.command         = payload[4] or 0

    for i = 5, #payload do
        if not ((i == #payload) and (payload[i] == Visca.packet_consts.terminator)) then
            table.insert(self.arguments, payload[i])
        end
    end

    return self
end

function Visca.PayloadCommand:is_command()
    return self.command_inquiry == Visca.packet_consts.command
end

function Visca.PayloadCommand:is_inquiry()
    return self.command_inquiry == Visca.packet_consts.inquiry
end

function Visca.PayloadCommand:is_reply()
    return self.command_inquiry == Visca.packet_consts.reply
end

function Visca.PayloadCommand:as_string()
    local args = '- (no arguments)'
    if #self.arguments > 0 then
        local descr = Visca.command_argument_names[ca_key(self.command, self.arguments[1])]

        local str_a = {}
        for i = descr and 2 or 1, #self.arguments do
            table.insert(str_a, string.format('%02X', self.arguments[i]))
        end

        args = (descr or 'arguments') .. ' ' .. table.concat(str_a, ' ')
    end

    if self:is_command() then
        return string.format('Command on %s: %s, %s',
            Visca.category_names[self.category],
            Visca.command_names[self.command] or string.format("Unknown (0x%0x)", self.command),
            args)
    elseif self:is_inquiry() then
        return string.format('Inquiry on %s: %s, %s',
            Visca.category_names[self.category],
            Visca.command_names[self.command] or string.format("Unknown (0x%0x)", self.command),
            args)
    else
        return 'Unknown'
    end
end

--- @class PayloadReply object
Visca.PayloadReply = {}
Visca.PayloadReply.__index = Visca.PayloadReply

function Visca.PayloadReply.new()
    local self = {
        reply_type    = 0x00,
        socket_number = 0,
        error_type    = 0x00,
        arguments     = {}
    }
    setmetatable(self, Visca.PayloadReply)
    return self
end

function Visca.PayloadReply:from_payload(payload)
    self.reply_type    = bit.band(payload[2], 0xF0)
    self.socket_number = bit.band(payload[2], 0x0F)

    if self:is_error() then
        self.error_type = payload[3] or 0
    else
        for i = 3, #payload do
            if not ((i == #payload) and (payload[i] == Visca.packet_consts.terminator)) then
                table.insert(self.arguments, payload[i])
            end
        end
    end

    return self
end

function Visca.PayloadReply:is_ack()
    return self.reply_type == Visca.packet_consts.reply_ack
end

function Visca.PayloadReply:is_completion()
    return self.reply_type == Visca.packet_consts.reply_completion
end

function Visca.PayloadReply:is_error()
    return self.reply_type == Visca.packet_consts.reply_error
end

function Visca.PayloadReply:get_inquiry_data_for(inquiry_payload)
    local _,_,category,inquiry_command = unpack(inquiry_payload)
    local data = {}

    if category == Visca.categories.interface then
        if inquiry_command == Visca.inquiry_commands.software_version then
            data = {
                vendor_id   = bit.lshift(self.arguments[1] or 0, 8) + (self.arguments[2] or 0),
                model_code  = bit.lshift(self.arguments[3] or 0, 8) + (self.arguments[4] or 0),
                rom_version = bit.lshift(self.arguments[5] or 0, 8) + (self.arguments[6] or 0),
            }
        end
    elseif category == Visca.categories.camera then
        if inquiry_command == Visca.inquiry_commands.color_gain then
            data = {
                color_level = bit.band(self.arguments[4] or 0, 0x0F)
            }
        elseif inquiry_command == Visca.inquiry_commands.brightness_position then
            data = {
                brightness = bit.lshift(bit.band(self.arguments[3] or 0, 0x0F), 4) +
                             bit.band(self.arguments[4] or 0, 0x0F),
            }
        elseif inquiry_command == Visca.inquiry_commands.zoom_position then
            data = {
                zoom = bit.lshift(bit.band(self.arguments[1] or 0, 0x0F), 12) +
                       bit.lshift(bit.band(self.arguments[2] or 0, 0x0F), 8) +
                       bit.lshift(bit.band(self.arguments[3] or 0, 0x0F), 4) +
                       bit.band(self.arguments[4] or 0, 0x0F),
            }
        end
    elseif category == Visca.categories.pan_tilter then
        if inquiry_command == Visca.inquiry_commands.pantilt_position then
            data = {
                pan  = bit.lshift(bit.band(self.arguments[1] or 0, 0x0F), 12) +
                       bit.lshift(bit.band(self.arguments[2] or 0, 0x0F), 8) +
                       bit.lshift(bit.band(self.arguments[3] or 0, 0x0F), 4) +
                       bit.band(self.arguments[4] or 0, 0x0F),
                tilt = bit.lshift(bit.band(self.arguments[5] or 0, 0x0F), 12) +
                       bit.lshift(bit.band(self.arguments[6] or 0, 0x0F), 8) +
                       bit.lshift(bit.band(self.arguments[7] or 0, 0x0F), 4) +
                       bit.band(self.arguments[8] or 0, 0x0F)
            }
        end
    end

    return data
end

function Visca.PayloadReply:as_string()
    if self:is_ack() then
        return 'Acknowledge'
    elseif self:is_completion() then
        if #self.arguments > 0 then
            local str_a = {}
            for b = 1, #self.arguments do
                table.insert(str_a, string.format('%02X', self.arguments[b]))
            end

            return 'Completion, inquiry: ' .. table.concat(str_a, ' ')
        else
            return 'Completion, command'
        end
    elseif self:is_error() then
        return string.format('Error on socket %d: %s (%02x)',
            self.socket_number,
            Visca.error_type_names[self.error_type] or 'Unknown',
            self.error_type)
    else
        return 'Unknown'
    end
end

--- @class Message Visca Message object
Visca.Message = {}
Visca.Message.__index = Visca.Message

--- Visca Message Constructor
---
--- A Visca message is binary data with a message header (8 bytes) and payload (1 to 16 bytes).
--- mode=generic uses this header, mode=PTZoptics skips this header
---
--- Byte:                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
--- Payload type (byte 0-1):   |
--- Payload length (byte 2-3):       |
--- Sequence number (byte 4-7):            |
--- Payload (byte 8 - max 23):                         |
---
--- The wire format is big-endian (LSB first)
---
--- @return Message
function Visca.Message.new()
    local msg = {
        payload_type = 0x0000,
        payload_size = 0x0000,
        seq_nr       = 0x00000000,
        payload      = {},
        message      = {},
    }
    setmetatable(msg, Visca.Message)
    return msg
end

function Visca.Message:from_data(data)
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
            self.message.command = Visca.PayloadCommand.new():from_payload(self.payload)
        elseif (bit.band(self.payload[1] or 0, 0xF0) == 0x90) then
            -- reply
            self.message.reply = Visca.PayloadReply.new():from_payload(self.payload)
        end
    end

    return self
end

function Visca.Message:to_data(mode)
    mode = mode or Visca.modes.generic
    local payload_size = (self.payload_size > 0) and self.payload_size or #self.payload
    local data = {}

    if mode == Visca.modes.generic then
        data = {
            bit.band(bit.rshift(self.payload_type, 8), 0xFF),
            bit.band(self.payload_type, 0xFF),
            bit.band(bit.rshift(payload_size, 8), 0xFF),
            bit.band(payload_size, 0xFF),
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

--- @param mode ViscaModes
function Visca.Message:as_string(mode)
    mode = mode or Visca.modes.generic
    local bin_str = self:to_data(mode)
    local bin_len = #(bin_str or "")

    local str_a = {}
    for b = 1, bin_len do
        table.insert(str_a, string.format('%02X', string.byte(bin_str, b)))
    end

    return table.concat(str_a, ' ')
end

function Visca.Message:dump(name, prefix, mode)
    if name then
      print('\n' .. name .. ':')
    end
    prefix = prefix or '- '

    print(string.format('%sMessage:         %s',
                        prefix or '',
                        self:as_string(mode)))
    print(string.format("%sPayload type:    %s (0x%02X%02X)",
                        prefix or '',
                        Visca.payload_type_names[self.payload_type] or 'Unknown',
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
                            self.message.command:as_string()))
    elseif self.message.reply then
        print(string.format('%sPayload:         Reply',
                            prefix or ''))
        print(string.format('%s                 %s',
                            prefix or '',
                            self.message.reply:as_string()))
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

--- @class ReplyServer Server for cameras sending out-of-socket replies
Visca.ReplyServer = {
    clients = {},
    whitelist = {},
    servers = {},
    replies = {},
}

function Visca.ReplyServer.add_listener_for(address, port)
    local cnt = (Visca.ReplyServer.clients[port] or 0)
    if cnt == 0 then
        local sock_address, err, num = socket.find_first_address("*", port,
            {family="inet", socket_type="dgram", protocol="udp"})
        if sock_address then
            local server
            server, err, num = socket.create("inet", "dgram", "udp")
            if server then
                local success
                success, err, num = server:set_blocking(false)
                if success then
                    success, err, num = server:bind(sock_address, port)
                    if success then
                        Visca.ReplyServer.servers[port] = server
                        cnt = cnt + 1

                        if Visca.debug then
                            print(string.format("Started new reply server at %s:%s",
                                sock_address:get_ip(), sock_address:get_port()))
                        end
                    else
                        print(string.format("Failed to bind server to %s:%s: %s (%d)",
                            sock_address:get_ip(), sock_address:get_port(), err or "Unknown", num or 0))
                    end
                else
                    print(string.format("Failed to set nonblocking server at %s:%s: %s (%d)",
                        sock_address:get_ip(), sock_address:get_port(), err or "Unknown", num or 0))
                end
            else
                print(string.format("Failed to start new reply server at %s:%s: %s (%d)",
                    sock_address:get_ip(), sock_address:get_port(), err or "Unknown", num or 0))
            end
        else
            print(string.format("Failed to determine server address for port %d: %s (%d)",
                port, err or "Unknown", num or 0))
        end
    end

    if Visca.ReplyServer.whitelist[address] == nil then
        Visca.ReplyServer.whitelist[address] = 1
    end
    Visca.ReplyServer.clients[port] = cnt
end

function Visca.ReplyServer.remove_listener_for(port)
    local cnt = (Visca.ReplyServer.clients[port] or 0) - 1

    if cnt <= 0 then
        local server = Visca.ReplyServer.servers[port]
        if server ~= nil then
            server:close()
            Visca.ReplyServer.servers[port] = nil
        end
        Visca.ReplyServer.clients[port] = nil
    else
        Visca.ReplyServer.clients[port] = cnt
    end
end

function Visca.ReplyServer.shutdown()
    for _,server in pairs(Visca.ReplyServer.servers) do
        server:close()
    end

    Visca.ReplyServer.servers = {}
    Visca.ReplyServer.whitelist = {}
    Visca.ReplyServer.clients = {}
    Visca.ReplyServer.replies = {}
end

function Visca.ReplyServer.receive()
    for _,server in pairs(Visca.ReplyServer.servers) do
        local data, reply_source = server:receive_from()
        if data ~= nil then
            local address = reply_source:get_ip()
            if Visca.ReplyServer.whitelist[address] ~= nil then
                table.insert(Visca.ReplyServer.replies, {address, data})
            end
        end
    end
end

function Visca.ReplyServer.get_data_for(address)
    for k,v in pairs(Visca.ReplyServer.replies) do
        if v ~= nil then
            local reply_source, data = unpack(v)
            if reply_source == address then
                Visca.ReplyServer.replies[k] = nil
                return data
            end
        end
    end
end

--- @class Transmission The Transmission object tracks responses received on a send message.
--- It stores the response by type (ack, error or completion) and tracks timeout.
Visca.Transmission = {}
Visca.Transmission.__index = Visca.Transmission

--- Visca Transaction Constructor
---
--- @param message Message The original sent message
--- @return Transmission
function Visca.Transmission.new(message)
    local transmission = {
      send                 = message,
      send_timestamp       = nil,
      ack                  = nil,  -- received ack message
      ack_timestamp        = nil,  -- received ack timestamp
      error                = nil,  -- received ack message
      error_timestamp      = nil,  -- received ack timestamp
      completion           = nil,  -- received completion message
      completion_timestamp = nil,  -- received completion timestamp
    }
    setmetatable(transmission, Visca.Transmission)

    return transmission
end

function Visca.Transmission:add_reply(reply)
    if reply:is_ack() then
        self.ack = reply
        self.ack_timestamp = obs.os_gettime_ns()
    elseif reply:is_completion() then
        self.completion = reply
        self.completion_timestamp = obs.os_gettime_ns()
    elseif reply:is_error() then
        self.error = reply
        self.error_timestamp = obs.os_gettime_ns()
    end
end

function Visca.Transmission:timed_out()
    -- One reply cycle should take maximum 4V. 1V is 42msec (worst case) for Sony.
    -- Including one 1V for sending, the timeout needed should only be 210000000ns.
    -- This typically not met by Visca over IP, so an increased timeout is used.
    local visca_timeout = 1000000000
    if not self.send_timestamp then
        return false
    elseif self.send_timestamp and (self.ack_timestamp or self.error_timestamp or self.completion_timestamp) then
        return false
    else
        return (obs.os_gettime_ns() - (self.send_timestamp or 0)) > visca_timeout
    end
end

function Visca.Transmission:is_inquiry()
    return self.send and (self.send.payload_type == Visca.payload_types.visca_inquiry)
end

function Visca.Transmission:inquiry_data()
    if self:is_inquiry() and self.completion then
        return self.completion:get_inquiry_data_for(self.send.payload)
    else
        return nil
    end
end

--- @class Connection Connection to a Visca camera
Visca.Connection = {}
Visca.Connection.__index = Visca.Connection

--- Visca Connection constructor
---
--- @param address string The IP address or DNS of the camera
--- @param port number    The Visca control port of the camera
--- @return Connection
function Visca.Connection.new(address, port)
    port = port or Visca.default_port
    if (port < 1) or (port > 65535) then
        port = Visca.default_port
    end
    local sock_addr, sock_err = socket.find_first_address(address, port)
    local connection = {
        sock               = nil,
        last_seq_nr        = 0xFFFFFFFF,
        address            = address,
        sock_address       = sock_addr,
        sock_err           = sock_err,
        mode               = Visca.modes.generic,
        transmission_queue = {},  -- List of Transmission objects
        callbacks          = {},  -- List of callbacks: [type][id] = function
        compatibility      = {}   -- List of compatibility settings (key/value)
    }
    setmetatable(connection, Visca.Connection)

    if sock_addr then
        local sock = assert(socket.create("inet", "dgram", "udp"))
        local success, _ = sock:set_blocking(false)
        if success then
            connection.sock = sock
            Visca.ReplyServer.add_listener_for(address, port)
        end
    end

    return connection
end

--- @param mode ViscaModes
function Visca.Connection:set_mode(mode)
    if Visca.modes:has_value(mode or Visca.modes.generic) then
        self.mode = mode
        return true
    else
        return false
    end
end

--- @param compatibility ViscaCompatibility
function Visca.Connection:set_compatibility(compatibility)
    compatibility = compatibility or {}

    for k,v in pairs(compatibility) do
        self.compatibility[k] = v
    end
end

function Visca.Connection:__register_callback(callback_type, id, callback)
    if type(self.callbacks[callback_type]) ~= 'table' then
        self.callbacks[callback_type] = {}
    end
    self.callbacks[callback_type][id] = callback
end

function Visca.Connection:__unregister_callback(callback_type, id)
    if self.callbacks[callback_type] ~= nil then
        self.callbacks[callback_type][id] = nil
    end
end

function Visca.Connection:__exec_callback(callback_type, t, ...)
    if self.callbacks[callback_type] ~= nil then
        for id,callback in pairs(self.callbacks[callback_type]) do
            if type(callback) == 'function' then
                local status,result_or_error = pcall(callback, t, unpack(arg or {}))
                if not status then
                    print(string.format("Callback %s for %s failed: %s", id, callback_type, result_or_error))
                end
            end
        end
    end
end

function Visca.Connection:register_on_ack_callback(id, callback)
    self:__register_callback('ack', id, callback)
end
function Visca.Connection:register_on_completion_callback(id, callback)
    self:__register_callback('completion', id, callback)
end
function Visca.Connection:register_on_error_callback(id, callback)
    self:__register_callback('error', id, callback)
end
function Visca.Connection:register_on_timeout_callback(id, callback)
    self:__register_callback('timeout', id, callback)
end

function Visca.Connection:unregister_on_ack_callback(id)
    self:__unregister_callback('ack', id)
end
function Visca.Connection:unregister_on_completion_callback(id)
    self:__unregister_callback('completion', id)
end
function Visca.Connection:unregister_on_error_callback(id)
    self:__unregister_callback('error', id)
end
function Visca.Connection:unregister_on_timeout_callback(id)
    self:__unregister_callback('timeout', id)
end

--- @param message Message
function Visca.Connection:__transmit(message)
    local data_to_send = message:to_data(self.mode)
    local sock = self.sock

    if Visca.debug then
        print(string.format("Connection transmit %s", message:as_string(self.mode)))
        message:dump(nil, nil, self.mode)
    end

    if sock ~= nil then
        return sock:send_to(self.sock_address, data_to_send), data_to_send
    else
        return 0, data_to_send
    end
end

function Visca.Connection:__transmissions_add_message(msg)
    local found = false
    local transmission

    for _,t in pairs(self.transmission_queue) do
        if self.mode == Visca.modes.generic then
            if t.send.seq_nr == msg.seq_nr then
                found = true
            end
        elseif self.mode == Visca.modes.ptzoptics then
            -- The response does not have a header, so we don't know the sequence number
            -- Let's just assume it belongs to the first message in the queue
            found = true
        end

        if found then
            t:add_reply(msg.message.reply)
            transmission = t
            break
        end
    end

    return transmission
end

function Visca.Connection:__transmissions_process()
    local transmit_size = 0
    local transmit_data

    for i,t in pairs(self.transmission_queue) do
        if t:timed_out() then
            self:__exec_callback('timeout', t)
            t = nil
        elseif t.error or t.completion then
            -- Message transaction completed, remove from queue
            t = nil
        end

        if not t then
            self.transmission_queue[i] = nil
        end
    end

    local first = true
    for _,t in pairs(self.transmission_queue) do
        -- Check if the first remaining message still needs transmission
        if t then
            -- When an ack has been received for the first message in the queue,
            -- but the command is waiting for completion, proceed to the next
            -- item in the queue for sending.
            -- Otherwise, stop queue handling and don't send anything (else)
            if not first then
                if not t.ack_timestamp then
                    break
                end
            end

            if not t.send_timestamp then
                transmit_size, transmit_data = self:__transmit(t.send)
                t.send_timestamp = obs.os_gettime_ns()
            end

            first = false
        end
    end

    return transmit_size, transmit_data
end

function Visca.Connection:close()
    local sock = self.sock
    if sock ~= nil then
        sock:close()
        self.sock = nil
    end
    if #self.transmission_queue > 0 then
        print(string.format("Warning: %d unfinished messages in queue", #self.transmission_queue))
    end
end

--- @param message Message
function Visca.Connection:send(message)
    if self.compatibility.fixed_sequence_number then
        message.seq_nr = self.compatibility.fixed_sequence_number or self.last_seq_nr
    else
        if self.last_seq_nr < 0xFFFFFFFF then
            self.last_seq_nr = self.last_seq_nr + 1
        else
            self.last_seq_nr = 0
        end

        message.seq_nr = self.last_seq_nr
    end

    table.insert(self.transmission_queue, Visca.Transmission.new(message))
    return self:__transmissions_process()
end

function Visca.Connection:receive()
    local result = {nil, "No connection", 0}

    local sock = self.sock
    if sock ~= nil then
        local data, err, num = sock:receive_from(self.sock_address, 32)
        if data == nil then
            Visca.ReplyServer.receive()
            data = Visca.ReplyServer.get_data_for(self.address)
        end

        if data then
            local msg = Visca.Message.new()
            msg:from_data(data)
            if Visca.debug then
                print(string.format("Received %s", msg:as_string(self.mode)))
            end

            if msg.message.reply then
                local transmission = self:__transmissions_add_message(msg)
                if transmission then
                    if msg.message.reply:is_ack() then
                        self:__exec_callback('ack', transmission)
                    elseif msg.message.reply:is_completion() then
                        self:__exec_callback('completion', transmission)
                    elseif msg.message.reply:is_error() then
                        self:__exec_callback('error', transmission)
                    end
                else
                    print(string.format("Warning: Unable to find send message for reply: %s",
                        msg:as_string(self.mode)))
                end
            end

            result = {msg}
        else
            result = {nil, err, num}
        end
    end

    -- Call protected - to continue whatever happens
    pcall(function() return self:__transmissions_process() end)

    return unpack(result)
end

function Visca.Connection:Send_Raw_Command(data)
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.terminator
    }

    if type(data) == "table" then
        for i,v in ipairs(data) do
            table.insert(msg.payload, i+1, v)
        end
    elseif type(data) == "string" then
        for i = 1, #data do
            table.insert(msg.payload, i+1, string.byte(data, i))
        end
    else
        table.insert(msg.payload, 2, data)
    end

    return self:send(msg)
end

function Visca.Connection:Cam_Color_Gain_Reset()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.color,
        Visca.commands.color_gain,
        Visca.command_arguments.color_gain_reset,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Color_Gain(level)
    level = math.min(math.max(level or 0, Visca.limits.COLOR_GAIN_MIN_LEVEL), Visca.limits.COLOR_GAIN_MAX_LEVEL)

    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.color,
        Visca.commands.color_gain_direct,
        0x00,
        0x00,
        0x00,
        bit.band(level, 0x0F),
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Color_Gain_Inquiry()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_inquiry
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.inquiry,
        Visca.categories.color,
        Visca.inquiry_commands.color_gain,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Brightness(position)
    position = math.min(math.max(position or 0, Visca.limits.BRIGHTNESS_MIN), Visca.limits.BRIGHTNESS_MAX)

    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.color,
        Visca.commands.brightness_direct,
        0x00,
        0x00,
        bit.band(bit.rshift(position, 4), 0x0F),
        bit.band(position, 0x0F),
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Brightness_Inquiry()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_inquiry
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.inquiry,
        Visca.categories.color,
        Visca.inquiry_commands.brightness_position,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Focus_Mode(mode)
    if Visca.Focus_modes:has_value(mode) then
        local msg = Visca.Message.new()
        msg.payload_type = Visca.payload_types.visca_command
        msg.payload = {
            Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
            Visca.packet_consts.command,
            Visca.categories.focus,
            bit.band(bit.rshift(mode, 8), 0xFF),
            bit.band(mode, 0xFF),
            Visca.packet_consts.terminator
        }

        return self:send(msg)
    else
        if Visca.debug then
            print(string.format("Cam_Focus_Mode invalid mode (0x%04x)", mode or 0))
        end
        return 0
    end
end

function Visca.Connection:Cam_Focus_Stop()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.focus,
        Visca.commands.focus,
        Visca.command_arguments.focus_stop,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Focus_Far(speed)
    if speed then
        speed = math.min(math.max(speed or 0x02, Visca.limits.FOCUS_MIN_SPEED), Visca.limits.FOCUS_MAX_SPEED)
    end

    local msg = Visca.Message.new()
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

    return self:send(msg)
end

function Visca.Connection:Cam_Focus_Near(speed)
    if speed then
        speed = math.min(math.max(speed or 0x02, Visca.limits.FOCUS_MIN_SPEED), Visca.limits.FOCUS_MAX_SPEED)
    end

    local msg = Visca.Message.new()
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

    return self:send(msg)
end

function Visca.Connection:Cam_Power(on)
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.camera,
        Visca.commands.power,
        on and Visca.command_arguments.power_on or Visca.command_arguments.power_standby,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Preset_Recall(preset)
    if self.compatibility.preset_nr_offset then
        preset = preset - self.compatibility.preset_nr_offset
    end
    preset = math.max(math.min(preset or 0, 127), 0)
    local msg = Visca.Message.new()
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

    return self:send(msg)
end

function Visca.Connection:Cam_PanTilt(direction, pan_speed, tilt_speed)
    if Visca.PanTilt_directions:has_value(direction or Visca.PanTilt_directions.stop) then
        pan_speed = math.min(math.max(pan_speed or 1, Visca.limits.PAN_MIN_SPEED), Visca.limits.PAN_MAX_SPEED)
        tilt_speed = math.min(math.max(tilt_speed or 1, Visca.limits.TILT_MIN_SPEED), Visca.limits.TILT_MAX_SPEED)

        local msg = Visca.Message.new()
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

        return self:send(msg)
    else
        if Visca.debug then
            print(string.format("Cam_PanTilt invalid direction (%d)", direction))
        end
        return 0
    end
end

function Visca.Connection:Cam_PanTilt_Absolute(speed, pan, tilt)
    speed = math.min(math.max(speed or 1, Visca.limits.PAN_MIN_SPEED), Visca.limits.PAN_MAX_SPEED)
    pan = math.min(math.max(pan or 1, Visca.limits.PAN_MIN_VALUE), Visca.limits.PAN_MAX_VALUE)
    tilt = math.min(math.max(tilt or 1, Visca.limits.TILT_MIN_VALUE), Visca.limits.TILT_MAX_VALUE)

    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.pan_tilter,
        Visca.commands.pantilt_absolute,
        speed, -- Pan speed
        speed, -- Tilt speed
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

    return self:send(msg)
end

function Visca.Connection:Cam_PanTilt_Home()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.pan_tilter,
        Visca.commands.pantilt_home,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_PanTilt_Reset()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.pan_tilter,
        Visca.commands.pantilt_reset,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Pantilt_Position_Inquiry()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_inquiry
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.inquiry,
        Visca.categories.pan_tilter,
        Visca.inquiry_commands.pantilt_position,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Zoom_Stop()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_command
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.command,
        Visca.categories.camera,
        Visca.commands.zoom,
        Visca.Zoom_subcommand.stop,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Zoom_Tele(speed)
    if speed then
        speed = math.min(math.max(speed or 0x02, Visca.limits.ZOOM_MIN_SPEED), Visca.limits.ZOOM_MAX_SPEED)
    end

    local msg = Visca.Message.new()
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

    return self:send(msg)
end

function Visca.Connection:Cam_Zoom_Wide(speed)
    if speed then
        speed = math.min(math.max(speed or 0x02, Visca.limits.ZOOM_MIN_SPEED), Visca.limits.ZOOM_MAX_SPEED)
    end

    local msg = Visca.Message.new()
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

    return self:send(msg)
end

function Visca.Connection:Cam_Zoom_To(zoom)
    zoom = math.min(math.max(zoom or 0, Visca.limits.ZOOM_MIN_VALUE), Visca.limits.ZOOM_MAX_VALUE)

    local msg = Visca.Message.new()
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

    return self:send(msg)
end

function Visca.Connection:Cam_Zoom_Position_Inquiry()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_inquiry
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.inquiry,
        Visca.categories.camera,
        Visca.inquiry_commands.zoom_position,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.Connection:Cam_Software_Version_Inquiry()
    local msg = Visca.Message.new()
    msg.payload_type = Visca.payload_types.visca_inquiry
    msg.payload = {
        Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
        Visca.packet_consts.inquiry,
        Visca.categories.interface,
        Visca.inquiry_commands.software_version,
        Visca.packet_consts.terminator
    }

    return self:send(msg)
end

function Visca.connect(address, port)
    local connection = Visca.Connection.new(address, port)
    if connection.sock then
        return connection
    else
        return nil, string.format("Unable to connect to %s: %s", address, connection.sock_err)
    end
end

return Visca
