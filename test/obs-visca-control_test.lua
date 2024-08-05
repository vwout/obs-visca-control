require("luacov")

-- Override search path to prefer stubs over others
package.path = "test/stubs/?.lua;test/helpers/?.lua;" .. package.path
-- Declare global that is available within OBS
obslua = require('obslua')

local lunit = require("lunit")
require("test.helpers.lunit_extensions")
local Visca = require("libvisca")

_G._UNITTEST = true
require("obs-visca-control")
_T._plugin_data.debug = false
_T._plugin_settings["debug_logging"] = 0

module("obs-visca-control_test", lunit.testcase, package.seeall)

function setup()
    _T._plugin_data.connections = {
        [1] = Visca.connect("localhost", 1234)
    }
end


function test_parse_preset_value()
    preset_name, preset_id = _T._parse_preset_value("0: Home")
    lunit.assert_equal("Home", preset_name)
    lunit.assert_equal(0, preset_id)
    preset_name, preset_id = _T._parse_preset_value("Pastor = 1")
    lunit.assert_equal("Pastor", preset_name)
    lunit.assert_equal(1, preset_id)
    preset_name, preset_id = _T._parse_preset_value("Invalid")
    lunit.assert_nil(preset_name)
    lunit.assert_nil(preset_id)
    preset_name, preset_id = _T._parse_preset_value("Stage: 2")
    lunit.assert_equal("Stage", preset_name)
    lunit.assert_equal(2, preset_id)
    preset_name, preset_id = _T._parse_preset_value("3 - Info")
    lunit.assert_equal("Info", preset_name)
    lunit.assert_equal(3, preset_id)
    preset_name, preset_id = _T._parse_preset_value("PresetNrTooHigh: 256")
    lunit.assert_nil(preset_name)
    lunit.assert_nil(preset_id)
end

function test_parse_custom_action_red_tuning()
    red_tuning_action1 = _T._parse_custom_action("0A 01 12 0F")
    lunit.assert_table_equal({0x0A, 0x01, 0x12, 0x0F}, red_tuning_action1)
    red_tuning_action2 = _T._parse_custom_action("81 0A 01 12 0F FF")
    lunit.assert_table_equal({0x0A, 0x01, 0x12, 0x0F}, red_tuning_action2)
end

function test_parse_custom_action_none()
    no_action1 = _T._parse_custom_action("")
    lunit.assert_nil(no_action1)
    no_action2 = _T._parse_custom_action(nil)
    lunit.assert_nil(no_action2)
end

function test_parse_custom_action_tally()
    tally_on_action1 = _T._parse_custom_action("017E010A0002")
    lunit.assert_table_equal({0x01, 0x7E, 0x01, 0x0A, 0x00, 0x02}, tally_on_action1)
    tally_on_action2 = _T._parse_custom_action("0x010x7E0x010x0A0x000x02")
    lunit.assert_table_equal({0x01, 0x7E, 0x01, 0x0A, 0x00, 0x02}, tally_on_action2)
end

function test_do_cam_action_start()
    local _q = _T._plugin_data.connections[1].transmission_queue

    local msg_idx = 1
    _T._do_cam_action_start(1, _T._camera_actions.PanTilt, {direction = Visca.PanTilt_directions.up})
    lunit.assert_equal(msg_idx, #_q)
    lunit.assert_not_nil(_q[msg_idx].send)
    lunit.assert_equal(Visca.payload_types.visca_command, _q[msg_idx].send.payload_type)
    lunit.assert_equal(msg_idx-1, _q[msg_idx].send.seq_nr)

    _T._plugin_settings["cam_1_hk_pt_speed"] = 7
    msg_idx = msg_idx + 1
    _T._do_cam_action_start(1, _T._camera_actions.PanTilt, {direction = Visca.PanTilt_directions.up})
    lunit.assert_equal(msg_idx, #_q)
    lunit.assert_equal(7, _q[msg_idx].send.payload[5])
    lunit.assert_equal(msg_idx-1, _q[msg_idx].send.seq_nr)

    msg_idx = msg_idx + 1
    _T._do_cam_action_start(1, _T._camera_actions.PanTilt, {direction = Visca.PanTilt_directions.up, speed = 12})
    lunit.assert_equal(msg_idx, #_q)
    lunit.assert_equal(12, _q[msg_idx].send.payload[5])

    _T._plugin_settings["cam_1_hk_pt_speed"] = nil

    msg_idx = msg_idx + 1
    _T._do_cam_action_start(1, _T._camera_actions.Zoom_In)
    lunit.assert_equal(msg_idx, #_q)
    lunit.assert_not_nil(_q[msg_idx].send)
    lunit.assert_equal(Visca.payload_types.visca_command, _q[msg_idx].send.payload_type)
    lunit.assert_equal(msg_idx-1, _q[msg_idx].send.seq_nr)
end

lunit.main(...)
