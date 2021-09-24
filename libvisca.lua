bit = require("bit")
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
    command = 0x0100,  -- VISCA command, Stores the VISCA command.
    inquiry = 0x0110,  -- VISCA inquiry, Stores the VISCA inquiry.
    reply   = 0x0111,  -- VISCA reply, Stores the reply for the VISCA command and VISCA inquiry, or VISCA device setting command.
    setting = 0x0120,  -- VISCA device setting command, Stores the VISCA device setting command.
    control = 0x0200,  -- Control command, Stores the control command.
    reply   = 0x0201   -- Control reply, Stores the reply for the control command.
}

Visca.packet_consts = {
    req_addr_base = 0x80,
    command       = 0x01,
    inquiry       = 0x09,
    terminator    = 0xFF
}

Visca.categories = {
    interface  = 0x00,
    camera1    = 0x04,
    pan_tilter = 0x06,
    camera2    = 0x07
}

Visca.command_sets = {
    power      = 0x00,
    preset     = 0x3F,
}

Visca.commands = {
    preset_recall = 0x02,
    pantilt_drive = 0x01,
    pantilt_home  = 0x04,
    pantilt_reset = 0x05,
    zoom          = 0x07,
    zoom_to       = 0x47,
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
    PAN_MIN_SPEED  = 0x01,
    PAN_MAX_SPEED  = 0x18,
    TILT_MIN_SPEED = 0x00,
    TILT_MAX_SPEED = 0x07,
    ZOOM_MIN_VALUE = 0x0000,
    ZOOM_MAX_VALUE = 0x4000,
}

-- A Visca message is binary data with a message header (8 bytes) and payload (1 to 16 bytes).
--
-- Byte:                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
-- Payload (byte 0-1):        |
-- Payload length (byte 2-3):       |
-- Sequence number (byte 4-7):            |
-- Payload (byte 8 - max 23):                         |
--
-- The wire format is big-endian (LSB first)
function Visca.Message()
    local self = {
        command      = 0x00,
        payload_type = 0x0000,
        payload_size = 0x0000,
        seq_nr       = 0x00000000,
        payload      = {}
    }

    function self.lsb(v)
      return bit.band(v, 0x00FF)
    end

    function self.msb(v)
      return bit.rshift(v, 8)
    end

    function self.from_data(data)
        local message_length = #(data or "")
        if message_length > 1 then
            if (string.byte(data, 1) == 0x01 or
                string.byte(data, 1) == 0x02) and message_length >= 9 and message_length <= 24 then
                self.command      = string.byte(data, 1) * 256 + string.byte(data, 2)
                self.payload_size = string.byte(data, 3) * 256 + string.byte(data, 4)
                self.seq_nr       = string.byte(data, 5) * 2^24 +
                                    string.byte(data, 6) * 2*16 +
                                    string.byte(data, 7) * 2*8 +
                                    string.byte(data, 8)

                for b = 1, self.payload_size do
                    table.insert(self.payload, string.byte(data, 8 + b))
                end
            elseif message_length >= 1 and message_length <= 16 then
                for b = 1, message_length do
                    table.insert(self.payload, string.byte(data, b))
                end
            end
        end

        return self
    end
    
    function self.to_data(mode)
        mode = mode or Visca.modes.generic
        self.payload_size = #self.payload

        local data = {}

        if mode == Visca.modes.generic then
            data = {
                self.msb(self.command),
                self.lsb(self.command),
                self.msb(self.payload_size),
                self.lsb(self.payload_size),
                bit.band(bit.rshift(self.seq_nr, 24), 0xFF),
                bit.band(bit.rshift(self.seq_nr, 16), 0xFF),
                bit.band(bit.rshift(self.seq_nr, 8), 0xFF),
                bit.band(self.seq_nr, 0xFF),
            }
        end

        for b = 1, self.payload_size do
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
            table.insert(str_a, string.format(' %02X', string.byte(bin_str, b)))
        end

        return table.concat(str_a)
    end

    return self
end

function Visca.connect(address, port)
    port = port or Visca.default_port
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
    else
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
            sock = nil
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
        end

        local sock = connection.sock
        if sock ~= nil then
            return sock:send_to(connection.address, message.to_data(connection.mode))
        else
            return 0
        end
    end
    
    function connection.await_ack_for(message)
    end
    
    function connection.await_completion_for(message)
    end

    function connection.Cam_Power(on, await_ack, await_completion)
        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1,  0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera1,
                Visca.command_sets.power,
                on and 0x02 or 0x03,  -- On = 0x02, Off = 0x03
                Visca.packet_consts.terminator
            }

        connection.send(msg)
    end
    
    function connection.Cam_Preset_Recall(preset)
        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera1,
                Visca.command_sets.preset,
                Visca.commands.preset_recall,
                bit.band(preset, 0x7F),  -- Preset Number(=0 to 127)
                Visca.packet_consts.terminator
            }
        
        connection.send(msg)
    end
    
    function connection.Cam_PanTilt(direction, pan_speed, tilt_speed)
        if has_value(Visca.PanTilt_directions, direction or Visca.PanTilt_directions.stop) then
            pan_speed = math.min(math.max(pan_speed or 1, Visca.limits.PAN_MIN_SPEED), Visca.limits.PAN_MAX_SPEED)
            tilt_speed = math.min(math.max(tilt_speed or 1, Visca.limits.TILT_MIN_SPEED), Visca.limits.TILT_MAX_SPEED)

            local msg = Visca.Message()
            msg.command = Visca.payload_types.command
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

    function connection.Cam_PanTilt_Home()
        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
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
        msg.command = Visca.payload_types.command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.pan_tilter,
                Visca.commands.pantilt_reset,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_Stop()
        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera1,
                Visca.commands.zoom,
                Visca.Zoom_subcommand.stop,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_Tele(speed)
        if speed then
            speed = math.min(math.max(speed or 0x02, Visca.limits.TILT_MIN_SPEED), Visca.limits.TILT_MAX_SPEED)
        end

        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera1,
                Visca.commands.zoom,
                speed and bit.bor(Visca.Zoom_subcommand.tele_variable, bit.band(speed, 0x07)) or Visca.Zoom_subcommand.tele_standard,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_Wide(speed)
        if speed then
            speed = math.min(math.max(speed or 0x02, Visca.limits.TILT_MIN_SPEED), Visca.limits.TILT_MAX_SPEED)
        end

        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera1,
                Visca.commands.zoom,
                speed and bit.bor(Visca.Zoom_subcommand.wide_variable, bit.band(speed, 0x07)) or Visca.Zoom_subcommand.wide_standard,
                Visca.packet_consts.terminator
            }

        return connection.send(msg)
    end

    function connection.Cam_Zoom_To(zoom)
        zoom = math.min(math.max(zoom or 0, Visca.limits.ZOOM_MIN_VALUE), Visca.limits.ZOOM_MAX_VALUE)
    
        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                Visca.packet_consts.req_addr_base + bit.band(Visca.default_camera_nr or 1, 0x0F),
                Visca.packet_consts.command,
                Visca.categories.camera1,
                Visca.commands.zoom_to,
                bit.band(bit.rshift(zoom, 12), 0x0F),
                bit.band(bit.rshift(zoom, 8), 0x0F),
                bit.band(bit.rshift(zoom, 4), 0x0F),
                bit.band(zoom, 0x0F),
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
