require("luacov")

-- Override search path to prefer stubs over others
package.path = "test/stubs/?.lua;test/helpers/?.lua;" .. package.path
-- Declare global that is available within OBS
obslua = require('obslua')

local lunit = require("lunit")
require("test.helpers.lunit_extensions")
local Visca = require("libvisca")

print(_VERSION)


local function run_command(description, f, a,b,c)
    local info = debug.getinfo(2, "nl")
    local func = info.name or "main"
    local line = info.currentline

    print("")
    print(string.format("=== Begin: %s (%s:%d) ===", description, func, line))

    local message_result, message_data = f(a,b,c)
    print(string.format("Result: %d", tostring(message_result or -1)))
    lunit.assert_true(message_result > 0)
    lunit.assert_not_nil(message_data)

    local msg = Visca.Message.new():from_data(message_data):dump(description)

    print(string.format("=== End: %s ===", description))
    print("")

    return msg, message_data
end

function clear_transmission_queue(connection)
    -- Hack to temporarily clear the transmission queue
    connection.transmission_queue = {}
end


module("libvisca_test", lunit.testcase, package.seeall)

--- @type: Visca.Connection
local connection

function setup()
    connection = Visca.connect('192.168.7.204')
    lunit.assert_true(connection:set_mode(Visca.modes.generic))
end

function teardown()
    --connection:close()
end

function test_set_preset_4()
    local set_preset_4 = Visca.Message.new():from_data("\x01\x00\x00\x07\x00\x00\x00\x01\x81\x01\x04\x3f\x02\x03\xff"):dump("set preset 4")
    lunit.assert_equal(Visca.payload_types.visca_command, set_preset_4.payload_type, "invalid payload")
    lunit.assert_equal(7, set_preset_4.payload_size, "invalid size")
    lunit.assert_equal(1, set_preset_4.seq_nr, "invalid seq")
    lunit.assert_not_nil(set_preset_4.message.command, "no cmd")
    lunit.assert_nil(set_preset_4.message.reply, "is rpl")
    lunit.assert_table_equal({0x81, 0x01, 0x04, 0x3f, 0x02, 0x03, 0xff}, set_preset_4.payload)

    lunit.assert_true(connection:set_mode(Visca.modes.generic))
    connection:send(set_preset_4)
end

function test_set_move_left()
    local msg2 = Visca.Message.new():from_data("\x01\x00\x00\x09\x00\x00\x00\x03\x81\x01\x06\x01\x01\x01\x03\x03\xff"):dump("set move left")
    lunit.assert_equal(Visca.payload_types.visca_command, msg2.payload_type)
    lunit.assert_equal(9, msg2.payload_size)
    lunit.assert_equal(3, msg2.seq_nr)
    lunit.assert_not_nil(msg2.message.command)
    lunit.assert_nil(msg2.message.reply)

    lunit.assert_true(connection:set_mode(Visca.modes.generic))
    connection:send(msg2)
end

function test_msg3_as_ptz()
    local msg3_as_ptz = Visca.Message.new():from_data("\x90\x42\xff"):dump("ptzoptics command ack (ptzoptics)", nil, Visca.modes.ptzoptics)
    lunit.assert_equal(3, msg3_as_ptz.payload_size)
    lunit.assert_nil(msg3_as_ptz.message.command)
    lunit.assert_not_nil(msg3_as_ptz.message.reply)
    -- TODO: add response parsing

    lunit.assert_false(connection:set_mode(42))
    lunit.assert_true(connection:set_mode(Visca.modes.ptzoptics))
    connection:send(msg3_as_ptz)
end

function test_ptzoptics_cmd_ack()
    local msg3 = Visca.Message.new():from_data("\x90\x42\xff"):dump("ptzoptics command ack")
    lunit.assert_equal(3, msg3.payload_size)
    -- TODO: add response parsing
end

function test_cam_power_on()
    lunit.assert_true(connection:set_mode(Visca.modes.generic))
    local len_err_num, data = connection:Cam_Power(true)
    lunit.assert_equal(14, len_err_num, "invalid length")
    local recv_msg = Visca.Message.new():from_data(data):dump("cam_power on")
    lunit.assert_not_nil(recv_msg.message.command)
    lunit.assert_table_equal({0x81, 0x01, 0x04, 0x00, 0x02, 0xFF}, recv_msg.payload)
end

function test_cam_power_off()
    lunit.assert_true(connection:set_mode(Visca.modes.generic))
    local len_err_num, data = connection:Cam_Power(false)
    lunit.assert_equal(14, len_err_num, "invalid length")
    local recv_msg = Visca.Message.new():from_data(data):dump("cam_power off")
    lunit.assert_not_nil(recv_msg.message.command)
    lunit.assert_table_equal({0x81, 0x01, 0x04, 0x00, 0x03, 0xFF}, recv_msg.payload)
end

function test_cam_reset_recall_2_generic()
    lunit.assert_true(connection:set_mode(Visca.modes.generic))
    connection:Cam_Preset_Recall(2)
end

function test_cam_reset_recall_8_ptzoptics()
    lunit.assert_true(connection:set_mode(Visca.modes.ptzoptics))
    local len_err_num, data = connection:Cam_Preset_Recall(8)
    lunit.assert_equal(7, len_err_num, "invalid length") -- Only data, no header
    local recv_msg = Visca.Message.new():from_data(data):dump("Cam_Preset_Recall 8 PTZOptics")
    lunit.assert_not_nil(recv_msg.message.command)
    lunit.assert_equal(8, recv_msg.message.command.arguments[2])
    lunit.assert_equal(7, recv_msg.payload_size, "invalid payload length")
end

function test_cam_reset_recall_6_jvc()
    connection:set_compatibility(nil)
    local _, data = connection:Cam_Preset_Recall(6)
    local recv_msg = Visca.Message.new():from_data(data):dump("Cam_Preset_Recall 6 normal")
    lunit.assert_not_nil(recv_msg.message.command)
    lunit.assert_equal(6, recv_msg.message.command.arguments[2])

    clear_transmission_queue(connection)

    connection:set_compatibility({ preset_nr_offset = 1 })
    _, data = connection:Cam_Preset_Recall(6)
    recv_msg = Visca.Message.new():from_data(data):dump("Cam_Preset_Recall 6 JVC")
    lunit.assert_not_nil(recv_msg.message.command)
    lunit.assert_equal(5, recv_msg.message.command.arguments[2])
end

function test_cam_color_gain()
    local msg_color_gain_reset = run_command("Cam_Color_Gain_Reset", function() return connection:Cam_Color_Gain_Reset() end)
    lunit.assert_equal(0x09, msg_color_gain_reset.message.command.command, "incorrect command")
    lunit.assert_equal(1, #msg_color_gain_reset.message.command.arguments, "invalid number of arguments")
    lunit.assert_equal(0x00, msg_color_gain_reset.message.command.arguments[1], "invalid argument")
end

function test_cam_color_gain_level()
    local msg_color_gain = run_command("Cam_Color_Gain", function(a) return connection:Cam_Color_Gain(a) end, 0x44)
    lunit.assert_equal(0x49, msg_color_gain.message.command.command, "incorrect command")
    lunit.assert_equal(4, #msg_color_gain.message.command.arguments, "invalid number of arguments")
    lunit.assert_equal(0x0E, msg_color_gain.message.command.arguments[4], "invalid argument") -- 0x44 is clipped to max value
end

function test_focus_manual()
    --lunit.assert_true(connection:set_mode(Visca.modes.generic))

    local msg_focus_mode_manual = run_command("Cam_Focus_Mode Manual", function(a) return connection:Cam_Focus_Mode(a) end, Visca.Focus_modes.manual)
    lunit.assert_equal(0x38, msg_focus_mode_manual.message.command.command, "incorrect command")
    lunit.assert_equal(1, #msg_focus_mode_manual.message.command.arguments, "invalid number of arguments")
    lunit.assert_equal(0x03, msg_focus_mode_manual.message.command.arguments[1], "invalid mode")
end

function test_focus_trigger()
    local msg_focus_mode_opt = run_command("Cam_Focus_Mode One Push Trigger", function(a) return connection:Cam_Focus_Mode(a) end, Visca.Focus_modes.one_push_trigger)
    lunit.assert_equal(0x18, msg_focus_mode_opt.message.command.command, "incorrect command")
    lunit.assert_equal(1, #msg_focus_mode_opt.message.command.arguments, "invalid number of arguments")
    lunit.assert_equal(0x01, msg_focus_mode_opt.message.command.arguments[1], "invalid mode")
end

function test_focus_stop()

    local msg_focus_stop = run_command("Cam_Focus_Mode Focus Stop", function() return connection:Cam_Focus_Stop() end)
    lunit.assert_equal(0x08, msg_focus_stop.message.command.command, "incorrect command")
    lunit.assert_equal(1, #msg_focus_stop.message.command.arguments, "invalid number of arguments")
    lunit.assert_equal(0x00, msg_focus_stop.message.command.arguments[1], "invalid mode")
end

function test_focus_far()
    local msg_focus_far = run_command("Cam_Focus_Mode Focus Far", function(a) return connection:Cam_Focus_Far(a) end, 12)  -- 12 is too high, max speed is 7
    lunit.assert_equal(0x08, msg_focus_far.message.command.command, "incorrect command")
    lunit.assert_equal(1, #msg_focus_far.message.command.arguments, "invalid number of arguments")
    lunit.assert_equal(0x27, msg_focus_far.message.command.arguments[1], "invalid mode")

    clear_transmission_queue(connection)
    connection:Cam_Focus_Stop()
end

function test_focus_near()
    local msg_focus_near = run_command("Cam_Focus_Mode Focus Near", function(a) return connection:Cam_Focus_Near(a) end, 3)
    lunit.assert_equal(0x08, msg_focus_near.message.command.command, "incorrect command")
    lunit.assert_equal(1, #msg_focus_near.message.command.arguments, "invalid number of arguments")
    lunit.assert_equal(0x33, msg_focus_near.message.command.arguments[1], "invalid mode")

    clear_transmission_queue(connection)
    connection:Cam_Focus_Stop()
end

function test_pantilt()
    lunit.assert_true(connection:set_mode(Visca.modes.generic))
    run_command("Cam_PanTilt Up", function(a,b,c) return connection:Cam_PanTilt(a,b,c) end, Visca.PanTilt_directions.up, 4, 22)

    clear_transmission_queue(connection)
    run_command("Cam_PanTilt Reset", function() return connection:Cam_PanTilt_Reset() end)

    clear_transmission_queue(connection)
    local t_size, t_data = connection:Cam_PanTilt_Absolute(0, 64591, 65412)
    lunit.assert_equal(23, t_size)
    lunit.assert_equal(Visca.limits.PAN_MIN_SPEED, string.byte(t_data, 13))
    lunit.assert_equal(Visca.limits.PAN_MIN_SPEED, string.byte(t_data, 14))
end

function test_zoom()
    lunit.assert_true(connection:set_mode(Visca.modes.generic))
    run_command("Cam_Zoom_Wide", function(a) return connection:Cam_Zoom_Wide(a) end, 5)

    clear_transmission_queue(connection)
    run_command("Cam_Zoom_Stop", function() return connection:Cam_Zoom_Stop() end)

    clear_transmission_queue(connection)
    run_command("Cam_Zoom_Tele", function(a) return connection:Cam_Zoom_Tele(a) end, 5)

    clear_transmission_queue(connection)
    connection:Cam_Zoom_Stop()

    clear_transmission_queue(connection)
    run_command("Cam_Zoom_To", function(a) return connection:Cam_Zoom_To(a) end, 0x1234)
end

function test_reply_parsing_cmd()
    local msg_cmd = Visca.Message.new():from_data("\x01\x00\x00\x07\x00\x00\x00\x03\x81\x01\x04\x3f\x02\x02\xff"):dump("msg_cmd")
    lunit.assert_equal(Visca.payload_types.visca_command, msg_cmd.payload_type)
    lunit.assert_not_nil(msg_cmd.message.command)
    lunit.assert_nil(msg_cmd.message.reply)
end

function test_reply_parsing_ack()
    local msg_ack = Visca.Message.new():from_data("\x01\x11\x00\x03\x00\x00\x00\x03\x90\x41\xff"):dump("msg_ack")
    lunit.assert_equal(Visca.payload_types.visca_reply, msg_ack.payload_type)
    lunit.assert_nil(msg_ack.message.command)
    lunit.assert_not_nil(msg_ack.message.reply)
    lunit.assert_true(msg_ack.message.reply:is_ack())
end

function test_reply_parsing_completed()
    local msg_completed = Visca.Message.new():from_data("\x01\x11\x00\x03\x00\x00\x00\x03\x90\x51\xff"):dump("msg_completed")
    lunit.assert_equal(Visca.payload_types.visca_reply, msg_completed.payload_type)
    lunit.assert_nil(msg_completed.message.command)
    lunit.assert_not_nil(msg_completed.message.reply)
    lunit.assert_true(msg_completed.message.reply:is_completion())
end

function test_reply_parsing_error()
    local msg_error = Visca.Message.new():from_data("\x01\x11\x00\x09\x00\x00\x00\x02\x90\x60\x41\xff"):dump("msg_error")
    lunit.assert_equal(Visca.payload_types.visca_reply, msg_error.payload_type)
    lunit.assert_nil(msg_error.message.command)
    lunit.assert_equal(4, msg_error.payload_size)
    lunit.assert_equal(2, msg_error.seq_nr)
    lunit.assert_not_nil(msg_error.message.reply)
    lunit.assert_true(msg_error.message.reply:is_error())
    lunit.assert_equal(0x41, msg_error.message.reply.error_type)
end

function test_reply_parsing_inquiry_replies()
    local msg_inq1 = Visca.Message.new():from_data("\x01\x11\x00\x0b\x00\x00\x00\x06\x90\x50\x00\x03\x04\x02\x0f\x0f\x05\x0b\xFF"):dump("msg_inq1")
    lunit.assert_equal(11, msg_inq1.payload_size)
    lunit.assert_equal(6, msg_inq1.seq_nr)
    lunit.assert_not_nil(msg_inq1.message.reply)
    lunit.assert_true(msg_inq1.message.reply:is_completion())
    lunit.assert_table_equal({0x00, 0x03, 0x04, 0x02, 0x0f, 0x0f, 0x05, 0x0b}, msg_inq1.message.reply.arguments)

    local msg_inq2 = Visca.Message.new():from_data("\x01\x11\x00\x07\x00\x00\xd8\x4F\x90\x50\x00\x00\x00\x00\xFF"):dump("msg_inq2")
    lunit.assert_equal(7, msg_inq2.payload_size)
    lunit.assert_equal(55375, msg_inq2.seq_nr)
    lunit.assert_not_nil(msg_inq2.message.reply)
    lunit.assert_true(msg_inq2.message.reply:is_completion())
    lunit.assert_table_equal({0x00, 0x00, 0x00, 0x00}, msg_inq2.message.reply.arguments)
end

function test_reply_parsing_inquiry_software_version()
    local msg_inq_sw_10 = Visca.Message.new():from_data("\x01\x11\x00\x0a\x00\x00\x00\x01\x90\x50\x00\x03\x00\x02\x28\x01\x0d\xff"):dump("msg_inq_sw_10")
    lunit.assert_equal(10, msg_inq_sw_10.payload_size)
    lunit.assert_equal(1, msg_inq_sw_10.seq_nr)
    lunit.assert_not_nil(msg_inq_sw_10.message.reply)
    lunit.assert_true(msg_inq_sw_10.message.reply:is_completion())

    local msg_inq_sw_10_data = msg_inq_sw_10.message.reply:get_inquiry_data_for({0,0,Visca.categories.interface,Visca.inquiry_commands.software_version})
    lunit.assert_not_nil(msg_inq_sw_10_data)
    lunit.assert_equal(0x0003, msg_inq_sw_10_data.vendor_id)
    lunit.assert_equal(0x0002, msg_inq_sw_10_data.model_code)
    lunit.assert_equal(0x2801, msg_inq_sw_10_data.rom_version)

    local msg_inq_sw_13 = Visca.Message.new():from_data("\x01\x11\x00\x0d\x00\x00\x00\x01\x90\x50\x00\x03\x01\x3b\x08\x70\x05\x2b\x05\x6b\xff"):dump("msg_inq_sw_13")
    lunit.assert_equal(13, msg_inq_sw_13.payload_size)
    lunit.assert_equal(1, msg_inq_sw_13.seq_nr)
    lunit.assert_not_nil(msg_inq_sw_13.message.reply)
    lunit.assert_true(msg_inq_sw_13.message.reply:is_completion())

    local msg_inq_sw_13_data = msg_inq_sw_13.message.reply:get_inquiry_data_for({0,0,Visca.categories.interface,Visca.inquiry_commands.software_version})
    lunit.assert_not_nil(msg_inq_sw_13_data)
    lunit.assert_equal(0x0003, msg_inq_sw_13_data.vendor_id)
    lunit.assert_equal(0x013B, msg_inq_sw_13_data.model_code)
    lunit.assert_equal(0x0870, msg_inq_sw_13_data.rom_version)
end

function test_reply_parsing_inquiry_color_level()
    local msg_inq_color_level = Visca.Message.new():from_data("\x90\x50\x00\x00\x00\x0A\xFF"):dump("msg_inq_color_level")
    lunit.assert_not_nil(msg_inq_color_level.message.reply)
    local msg_inq_color_level_data = msg_inq_color_level.message.reply:get_inquiry_data_for({0,0,Visca.categories.color,Visca.inquiry_commands.color_gain})
    lunit.assert_not_nil(msg_inq_color_level_data)
    lunit.assert_equal(10, msg_inq_color_level_data.color_level)
end

function test_reply_parsing_inquiry_brightnes()
    local msg_inq_brightness = Visca.Message.new():from_data("\x90\x50\x00\x00\x06\x09\xFF"):dump("msg_inq_brightness")
    lunit.assert_not_nil(msg_inq_brightness.message.reply)
    local msg_inq_brightness_data = msg_inq_brightness.message.reply:get_inquiry_data_for({0,0,Visca.categories.color,Visca.inquiry_commands.brightness_position})
    lunit.assert_not_nil(msg_inq_brightness_data)
    lunit.assert_equal(0x69, msg_inq_brightness_data.brightness)
end

function test_inquiry()
    lunit.assert_true(connection:set_mode(Visca.modes.generic))

    local msg_pt_bytes, msg_pt_data = connection:Cam_Pantilt_Position_Inquiry()
    lunit.assert_equal(8 + 5, msg_pt_bytes)
    local msg_inq_pt = Visca.Message.new():from_data(msg_pt_data):dump("msg_inq_pt")
    lunit.assert_equal(5, msg_inq_pt.payload_size)
    lunit.assert_equal(Visca.inquiry_commands.pantilt_position, msg_inq_pt.payload[4])

    clear_transmission_queue(connection)
    local msg_z_bytes, msg_z_data = connection:Cam_Zoom_Position_Inquiry()
    lunit.assert_equal(8 + 5, msg_z_bytes)
    local msg_inq_z = Visca.Message.new():from_data(msg_z_data):dump("msg_inq_z")
    lunit.assert_equal(5, msg_inq_z.payload_size)
    lunit.assert_equal(Visca.inquiry_commands.zoom_position, msg_inq_z.payload[4])

    clear_transmission_queue(connection)
    local msg_gain_bytes, msg_gain_data = connection:Cam_Color_Gain_Inquiry()
    lunit.assert_equal(8 + 5, msg_gain_bytes)
    local msg_inq_gain = Visca.Message.new():from_data(msg_gain_data):dump("msg_inq_gain")
    lunit.assert_equal(5, msg_inq_gain.payload_size)
    lunit.assert_equal(Visca.inquiry_commands.color_gain, msg_inq_gain.payload[4])

    clear_transmission_queue(connection)
    local msg_brightness_bytes, msg_brightness_data = connection:Cam_Brightness_Inquiry()
    lunit.assert_equal(8 + 5, msg_brightness_bytes)
    local msg_inq_brightness = Visca.Message.new():from_data(msg_brightness_data):dump("msg_inq_brightness")
    lunit.assert_equal(5, msg_inq_brightness.payload_size)
    lunit.assert_equal(Visca.inquiry_commands.brightness_position, msg_inq_brightness.payload[4])
end

function test_send_raw_command()
    lunit.assert_true(connection:set_mode(Visca.modes.ptzoptics))
    local msg_tally_bytes, msg_tally_data = connection:Send_Raw_Command({0x01, 0x7E, 0x01, 0x0A, 0x00, 0x02})
    lunit.assert_equal(8, msg_tally_bytes)
    msg_tally = Visca.Message.new():from_data(msg_tally_data)
    lunit.assert_table_equal({0x81, 0x01, 0x7E, 0x01, 0x0A, 0x00, 0x02, 0xFF}, msg_tally.payload)
end

lunit.main(...)
