# obs-visca-control
A plugin for [OBS](https://obsproject.com/) to control Visca-over-IP based cameras.

This plugin adds a source to a scene in OBS. With this source, a camera can be controlled.
Its main purpose is to automatically switch a camera to a certain preset when the scene is activated.
This activation can be as soon as the scene is active in preview, in program, or both.

Besides recalling a pre-made preset, this plugin supports a few more control operations:
- Switch camera On
- Switch camera Off
- Preset Recall

This plugin requires the camera to support Visca over IP.
It follows the specification as designed by Sony.
This plugin has been tested with Everet cameras.

## Installation
The plugin is a script plugin and utilizes the Lua scripting capabilities of OBS.
To use the plugin, add the file `obs-visca-control.lua` to OBS under *Script* in the *Tools* menu.
The other `.lua` files in this repository are also required, but should not be added as scripts in OBS.

## Configuration
Before the plugin can be used in a scene, it requires configuration in the `Script` dialog.
![Plugin configuration](images/docs/plugin_settings.png)

Start by enumerating the number of cameras cameras that you want to control.
For each camera a set of configuration properties will be shown:
- Name: A friendly name for easy recognition of the camera
- Address: The IP address at which the camera is available. The plugin assumes that Visca is operated on port `52381`.
- The list of presets that you want to configure for the camera

Switch between cameras using the drop-down.
Reload the plugin to update the names of the cameras in the camera drop-down list.

The preset list contains one preset per line and contains the name for the preset and the number of the preset stored in the camera.
The preset follows a specific syntax to link a preset number to a name. The following forms are supported:
- `<name>` `<separator>` `<preset number>`
- `<preset number>` `<separator>` `<name>`

The separator can be `:`, `=` or `-`.
Valid examples are `0: Home`, `5 = Pastor` or `Stage - 6`

## Usage
To control a camera, add a `Visca Camera Control` source to a scene.
![Source configuration](images/docs/scene_settings.png)

In the source settings, select the camera, action and optionally the preset that the camera should switch to.
The camera action is executed when either the scene in which the source is used becomes active in preview, in program, or both, depending on the selected entry in the selection.

# Credits
This plugin uses [luajitsocket](https://github.com/CapsAdmin/luajitsocket/), a library that implements socket support for LuaJIT, since the Lua socket library is not available in OBS.