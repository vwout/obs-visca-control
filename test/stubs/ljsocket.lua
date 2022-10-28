local stub_socket = {}

function stub_socket.set_blocking()
    return true
end

function stub_socket.send_to(self, _address, data)
    return #data
end

function stub_socket.bind(_address, _port)
    return true
end

local M = {}

function M.connect()
end

function M.find_first_address()
    return {
        get_ip = function() return "0.0.0.0" end,
        get_port = function() return 0 end,
    }, "find_first_address stub"
end

function M.create()
    return stub_socket
end

return M
