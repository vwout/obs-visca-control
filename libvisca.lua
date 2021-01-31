bit = require("bit")
local socket = require("ljsocket")

local Visca = {}

Visca.default_port = 52381

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
        if message_length >= 9 and message_length <= 24 then
            self.command      = string.byte(data, 1) * 256 + string.byte(data, 2)
            self.payload_size = string.byte(data, 3) * 256 + string.byte(data, 4)
            self.seq_nr       = string.byte(data, 5) * 2^24 +
                                string.byte(data, 6) * 2*16 +
                                string.byte(data, 7) * 2*8 +
                                string.byte(data, 8)
            for b = 1, self.payload_size do
                self.payload[b] = string.byte(data, 8 + b)
            end
        end
        
        return self
    end
    
    function self.to_data()
        self.payload_size = #self.payload
        
        local data = {
            self.msb(self.command),
            self.lsb(self.command),
            self.msb(self.payload_size),
            self.lsb(self.payload_size),
            bit.band(bit.rshift(self.seq_nr, 24), 0xFF),
            bit.band(bit.rshift(self.seq_nr, 16), 0xFF),
            bit.band(bit.rshift(self.seq_nr, 8), 0xFF),
            bit.band(self.seq_nr, 0xFF),
        }

        for b = 1, self.payload_size do
            data[8+b] = self.payload[b]
        end
        
        local str = ""
        for _,v in ipairs(data) do
          str = str .. string.char(v)
        end

        return str
    end

    return self
end

function Visca.connect(address, port)
    port = port or Visca.default_port
    local connection = {
        sock        = nil,
        last_seq_nr = 0,
        address     = socket.find_first_address(address, port)
    }

    local sock = assert(socket.create("inet", "dgram", "udp"))
    local success, _ = sock:set_blocking(false)
    if success then
        connection.sock = sock
    end

    function connection.close()
        local sock = connection.sock
        if sock ~= nil then
            sock:close()
            sock = nil
        end
    end

    function connection.send(message)
        connection.last_seq_nr = connection.last_seq_nr + 1
        message.seq_nr = connection.last_seq_nr

        local sock = connection.sock
        if sock ~= nil then
            return sock:send_to(connection.address, message.to_data())
        else
            return 0
        end
    end
    
    function connection.await_ack_for(message)
    end
    
    function connection.await_completion_for(message)
    end

    function connection.Cam_Power(on, await_ack, await_completion, camera_nr)
        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                0x80 + bit.band(camera_nr or 1,  0x0F),
                0x01,
                0x04,
                0x00,
                on and 0x02 or 0x03,  -- On = 0x02, Off = 0x03
                0xFF
            }

        connection.send(msg)
    end
    
    function connection.Cam_Preset_Recall(preset, camera_nr)
        local msg = Visca.Message()
        msg.command = Visca.payload_types.command
        msg.payload = {
                0x80 + bit.band(camera_nr or 1, 0x0F),
                0x01,
                0x04,
                0x3F,
                0x02,
                bit.band(preset, 0x7F),  -- Preset Number(=0 to 127)
                0xFF
            }
        
        connection.send(msg)
    end
    
    return connection
end

return Visca
