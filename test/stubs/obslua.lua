local socket = require("socket")

-- Definition of globals to reproduce the Lua scripting environment in OBS - bfxdev 2020

-- Use this file to support development in Lua for OBS. It is designed to work in Visual Studio Code with
-- sumneko's Lua Language Server extension, see https://marketplace.visualstudio.com/items?itemName=sumneko.lua
-- With this extension (currently v0.21.2), it is necessary to adapt some settings:
--  - Increase the "Preload File Size" ("Lua.workspace.preloadFileSize") to a size larger than the
--    actual size of this file (e.g. increase to 10000). Otherwise the extension will just ignore the file.
--  - Select "LuaJIT" as "Runtime Version" ("Lua.runtime.version") for support of specific functions and modules
--  - Add the file path (or containing folder path) in the "Workspace Library" ("Lua.workspace.library"). This
--    setting is not even necessary if this file is in the same folder as the source file, or if the file is open
--    in Visual Studio Code.
-- Code documentation follows the syntax of EmmyLua-style annotations, see https://emmylua.github.io
-- Consequently the file should be usable in other environments such as Visual Studio or IntelliJ IDE.

--- Returns Kb of dynamic memory in use.
--- This function is deprecated in Lua 5.1. Use collectgarbage ("count") instead.
--- @param param string
--- @return number
function gcinfo(param) end

--- Unsupported and undocumented function in the Lua base library.
--- From Lua code, the setmetatable function may only be used on objects of table type.
--- The newproxy function circumvents that limitation by creating a zero-size userdata and setting
--- either a new, empty metatable on it or using the metatable of another newproxy instance. We are
--- then free to modify the metatable from Lua. This is the only way to create a proxy object from
--- Lua which honors certain metamethods, such as __len.
--- @param param bool
function newproxy(param) end

--- OBS function that returns the path of the folder of the current script
--- @return string
function script_path() end

--- SWIG function - Not documented
function swig_equals() end

--- SWIG function that returns as a string the type of object pointed to by the argument (assuming it was a SWIG wrapped object)
function swig_type(obj) end

--- Main obslua module
obslua = {}

-- Constants
obslua.ARCH_BITS = 32
obslua.BUILD_CAPTIONS = 1
obslua.CALL_PARAM_IN = 1
obslua.CALL_PARAM_OUT = 2
obslua.CALL_PARAM_TYPE_BOOL = 3
obslua.CALL_PARAM_TYPE_FLOAT = 2
obslua.CALL_PARAM_TYPE_INT = 1
obslua.CALL_PARAM_TYPE_PTR = 4
obslua.CALL_PARAM_TYPE_STRING = 5
obslua.CALL_PARAM_TYPE_VOID = 0
obslua.COMPILE_LUA = 1
obslua.COMPILE_PYTHON = 1
obslua.FALSE = 0
obslua.FILE_LINE = "D:/obs2/libobs\\util\\base.h (36): "
obslua.GS_A8 = 1
obslua.GS_ADDRESS_BORDER = 3
obslua.GS_ADDRESS_CLAMP = 0
obslua.GS_ADDRESS_MIRROR = 2
obslua.GS_ADDRESS_MIRRORONCE = 4
obslua.GS_ADDRESS_WRAP = 1
obslua.GS_ALWAYS = 7
obslua.GS_BACK = 0
obslua.GS_BGRA = 5
obslua.GS_BGRX = 4
obslua.GS_BLEND_DSTALPHA = 8
obslua.GS_BLEND_DSTCOLOR = 6
obslua.GS_BLEND_INVDSTALPHA = 9
obslua.GS_BLEND_INVDSTCOLOR = 7
obslua.GS_BLEND_INVSRCALPHA = 5
obslua.GS_BLEND_INVSRCCOLOR = 3
obslua.GS_BLEND_ONE = 1
obslua.GS_BLEND_SRCALPHA = 4
obslua.GS_BLEND_SRCALPHASAT = 10
obslua.GS_BLEND_SRCCOLOR = 2
obslua.GS_BLEND_ZERO = 0
obslua.GS_BUILD_MIPMAPS = 1
obslua.GS_CLEAR_COLOR = 1
obslua.GS_CLEAR_DEPTH = 2
obslua.GS_CLEAR_STENCIL = 4
obslua.GS_DECR = 4
obslua.GS_DEVICE_DIRECT3D_11 = 2
obslua.GS_DEVICE_OPENGL = 1
obslua.GS_DUP_BUFFER = 16
obslua.GS_DXT1 = 15
obslua.GS_DXT3 = 16
obslua.GS_DXT5 = 17
obslua.GS_DYNAMIC = 2
obslua.GS_EQUAL = 3
obslua.GS_ERROR_FAIL = -1
obslua.GS_ERROR_MODULE_NOT_FOUND = -2
obslua.GS_ERROR_NOT_SUPPORTED = -3
obslua.GS_FILTER_ANISOTROPIC = 2
obslua.GS_FILTER_LINEAR = 1
obslua.GS_FILTER_MIN_LINEAR_MAG_MIP_POINT = 6
obslua.GS_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 7
obslua.GS_FILTER_MIN_MAG_LINEAR_MIP_POINT = 8
obslua.GS_FILTER_MIN_MAG_POINT_MIP_LINEAR = 3
obslua.GS_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT = 4
obslua.GS_FILTER_MIN_POINT_MAG_MIP_LINEAR = 5
obslua.GS_FILTER_POINT = 0
obslua.GS_FLIP_U = 1
obslua.GS_FLIP_V = 2
obslua.GS_FRONT = 1
obslua.GS_GEQUAL = 4
obslua.GS_GL_DUMMYTEX = 8
obslua.GS_GREATER = 5
obslua.GS_INCR = 3
obslua.GS_INVERT = 5
obslua.GS_KEEP = 0
obslua.GS_LEQUAL = 2
obslua.GS_LESS = 1
obslua.GS_LINES = 1
obslua.GS_LINESTRIP = 2
obslua.GS_MAX_TEXTURES = 8
obslua.GS_NEGATIVE_X = 1
obslua.GS_NEGATIVE_Y = 3
obslua.GS_NEGATIVE_Z = 5
obslua.GS_NEITHER = 2
obslua.GS_NEVER = 0
obslua.GS_NOTEQUAL = 6
obslua.GS_POINTS = 0
obslua.GS_POSITIVE_X = 0
obslua.GS_POSITIVE_Y = 2
obslua.GS_POSITIVE_Z = 4
obslua.GS_R10G10B10A2 = 6
obslua.GS_R16 = 8
obslua.GS_R16F = 13
obslua.GS_R32F = 14
obslua.GS_R8 = 2
obslua.GS_R8G8 = 18
obslua.GS_RENDER_TARGET = 4
obslua.GS_REPLACE = 2
obslua.GS_RG16F = 11
obslua.GS_RG32F = 12
obslua.GS_RGBA = 3
obslua.GS_RGBA16 = 7
obslua.GS_RGBA16F = 9
obslua.GS_RGBA32F = 10
obslua.GS_SHADER_PARAM_BOOL = 1
obslua.GS_SHADER_PARAM_FLOAT = 2
obslua.GS_SHADER_PARAM_INT = 3
obslua.GS_SHADER_PARAM_INT2 = 8
obslua.GS_SHADER_PARAM_INT3 = 9
obslua.GS_SHADER_PARAM_INT4 = 10
obslua.GS_SHADER_PARAM_MATRIX4X4 = 11
obslua.GS_SHADER_PARAM_STRING = 4
obslua.GS_SHADER_PARAM_TEXTURE = 12
obslua.GS_SHADER_PARAM_UNKNOWN = 0
obslua.GS_SHADER_PARAM_VEC2 = 5
obslua.GS_SHADER_PARAM_VEC3 = 6
obslua.GS_SHADER_PARAM_VEC4 = 7
obslua.GS_SHARED_KM_TEX = 64
obslua.GS_SHARED_TEX = 32
obslua.GS_STENCIL_BACK = 2
obslua.GS_STENCIL_BOTH = 3
obslua.GS_STENCIL_FRONT = 1
obslua.GS_SUCCESS = 0
obslua.GS_TEXTURE_2D = 0
obslua.GS_TEXTURE_3D = 1
obslua.GS_TEXTURE_CUBE = 2
obslua.GS_TRIS = 3
obslua.GS_TRISTRIP = 4
obslua.GS_UNKNOWN = 0
obslua.GS_UNSIGNED_LONG = 1
obslua.GS_UNSIGNED_SHORT = 0
obslua.GS_USE_DEBUG_MARKERS = 0
obslua.GS_Z16 = 1
obslua.GS_Z24_S8 = 2
obslua.GS_Z32F = 3
obslua.GS_Z32F_S8X24 = 4
obslua.GS_ZERO = 1
obslua.GS_ZS_NONE = 0
obslua.INTERACT_ALT_KEY = 8
obslua.INTERACT_CAPS_KEY = 1
obslua.INTERACT_COMMAND_KEY = 128
obslua.INTERACT_CONTROL_KEY = 4
obslua.INTERACT_IS_KEY_PAD = 512
obslua.INTERACT_IS_LEFT = 1024
obslua.INTERACT_IS_RIGHT = 2048
obslua.INTERACT_MOUSE_LEFT = 16
obslua.INTERACT_MOUSE_MIDDLE = 32
obslua.INTERACT_MOUSE_RIGHT = 64
obslua.INTERACT_NONE = 0
obslua.INTERACT_NUMLOCK_KEY = 256
obslua.INTERACT_SHIFT_KEY = 2
obslua.INT_CUR_LINE = 35
obslua.LOG_DEBUG = 400
obslua.LOG_ERROR = 100
obslua.LOG_INFO = 300
obslua.LOG_WARNING = 200
obslua.MKDIR_ERROR = -1
obslua.MKDIR_EXISTS = 1
obslua.MKDIR_SUCCESS = 0
obslua.MOUSE_LEFT = 0
obslua.MOUSE_MIDDLE = 1
obslua.MOUSE_RIGHT = 2
obslua.OBS_ALLOW_DIRECT_RENDERING = 1
obslua.OBS_BALANCE_TYPE_LINEAR = 2
obslua.OBS_BALANCE_TYPE_SINE_LAW = 0
obslua.OBS_BALANCE_TYPE_SQUARE_LAW = 1
obslua.OBS_BOUNDS_MAX_ONLY = 6
obslua.OBS_BOUNDS_NONE = 0
obslua.OBS_BOUNDS_SCALE_INNER = 2
obslua.OBS_BOUNDS_SCALE_OUTER = 3
obslua.OBS_BOUNDS_SCALE_TO_HEIGHT = 5
obslua.OBS_BOUNDS_SCALE_TO_WIDTH = 4
obslua.OBS_BOUNDS_STRETCH = 1
obslua.OBS_COMBO_FORMAT_FLOAT = 2
obslua.OBS_COMBO_FORMAT_INT = 1
obslua.OBS_COMBO_FORMAT_INVALID = 0
obslua.OBS_COMBO_FORMAT_STRING = 3
obslua.OBS_COMBO_INVALID = 0
obslua.OBS_COMBO_TYPE_EDITABLE = 1
obslua.OBS_COMBO_TYPE_INVALID = 0
obslua.OBS_COMBO_TYPE_LIST = 2
obslua.OBS_DATA_ARRAY = 5
obslua.OBS_DATA_BOOLEAN = 3
obslua.OBS_DATA_NULL = 0
obslua.OBS_DATA_NUMBER = 2
obslua.OBS_DATA_NUM_DOUBLE = 2
obslua.OBS_DATA_NUM_INT = 1
obslua.OBS_DATA_NUM_INVALID = 0
obslua.OBS_DATA_OBJECT = 4
obslua.OBS_DATA_STRING = 1
obslua.OBS_DEINTERLACE_FIELD_ORDER_BOTTOM = 1
obslua.OBS_DEINTERLACE_FIELD_ORDER_TOP = 0
obslua.OBS_DEINTERLACE_MODE_BLEND = 3
obslua.OBS_DEINTERLACE_MODE_BLEND_2X = 4
obslua.OBS_DEINTERLACE_MODE_DISABLE = 0
obslua.OBS_DEINTERLACE_MODE_DISCARD = 1
obslua.OBS_DEINTERLACE_MODE_LINEAR = 5
obslua.OBS_DEINTERLACE_MODE_LINEAR_2X = 6
obslua.OBS_DEINTERLACE_MODE_RETRO = 2
obslua.OBS_DEINTERLACE_MODE_YADIF = 7
obslua.OBS_DEINTERLACE_MODE_YADIF_2X = 8
obslua.OBS_EDITABLE_LIST_TYPE_FILES = 1
obslua.OBS_EDITABLE_LIST_TYPE_FILES_AND_URLS = 2
obslua.OBS_EDITABLE_LIST_TYPE_STRINGS = 0
obslua.OBS_EFFECT_AREA = 9
obslua.OBS_EFFECT_BICUBIC = 4
obslua.OBS_EFFECT_BILINEAR_LOWRES = 6
obslua.OBS_EFFECT_DEFAULT = 0
obslua.OBS_EFFECT_DEFAULT_RECT = 1
obslua.OBS_EFFECT_LANCZOS = 5
obslua.OBS_EFFECT_OPAQUE = 2
obslua.OBS_EFFECT_PREMULTIPLIED_ALPHA = 7
obslua.OBS_EFFECT_REPEAT = 8
obslua.OBS_EFFECT_SOLID = 3
obslua.OBS_FONT_BOLD = 1
obslua.OBS_FONT_ITALIC = 2
obslua.OBS_FONT_STRIKEOUT = 8
obslua.OBS_FONT_UNDERLINE = 4
obslua.OBS_FRONTEND_EVENT_EXIT = 17
obslua.OBS_FRONTEND_EVENT_FINISHED_LOADING = 26
obslua.OBS_FRONTEND_EVENT_PREVIEW_SCENE_CHANGED = 24
obslua.OBS_FRONTEND_EVENT_PROFILE_CHANGED = 15
obslua.OBS_FRONTEND_EVENT_PROFILE_CHANGING = 35
obslua.OBS_FRONTEND_EVENT_PROFILE_LIST_CHANGED = 16
obslua.OBS_FRONTEND_EVENT_PROFILE_RENAMED = 37
obslua.OBS_FRONTEND_EVENT_RECORDING_PAUSED = 27
obslua.OBS_FRONTEND_EVENT_RECORDING_STARTED = 5
obslua.OBS_FRONTEND_EVENT_RECORDING_STARTING = 4
obslua.OBS_FRONTEND_EVENT_RECORDING_STOPPED = 7
obslua.OBS_FRONTEND_EVENT_RECORDING_STOPPING = 6
obslua.OBS_FRONTEND_EVENT_RECORDING_UNPAUSED = 28
obslua.OBS_FRONTEND_EVENT_REPLAY_BUFFER_SAVED = 30
obslua.OBS_FRONTEND_EVENT_REPLAY_BUFFER_STARTED = 19
obslua.OBS_FRONTEND_EVENT_REPLAY_BUFFER_STARTING = 18
obslua.OBS_FRONTEND_EVENT_REPLAY_BUFFER_STOPPED = 21
obslua.OBS_FRONTEND_EVENT_REPLAY_BUFFER_STOPPING = 20
obslua.OBS_FRONTEND_EVENT_SCENE_CHANGED = 8
obslua.OBS_FRONTEND_EVENT_SCENE_COLLECTION_CHANGED = 13
obslua.OBS_FRONTEND_EVENT_SCENE_COLLECTION_CHANGING = 34
obslua.OBS_FRONTEND_EVENT_SCENE_COLLECTION_CLEANUP = 25
obslua.OBS_FRONTEND_EVENT_SCENE_COLLECTION_LIST_CHANGED = 14
obslua.OBS_FRONTEND_EVENT_SCENE_COLLECTION_RENAMED = 38
obslua.OBS_FRONTEND_EVENT_SCENE_LIST_CHANGED = 9
obslua.OBS_FRONTEND_EVENT_SCREENSHOT_TAKEN = 40
obslua.OBS_FRONTEND_EVENT_SCRIPTING_SHUTDOWN = 36
obslua.OBS_FRONTEND_EVENT_STREAMING_STARTED = 1
obslua.OBS_FRONTEND_EVENT_STREAMING_STARTING = 0
obslua.OBS_FRONTEND_EVENT_STREAMING_STOPPED = 3
obslua.OBS_FRONTEND_EVENT_STREAMING_STOPPING = 2
obslua.OBS_FRONTEND_EVENT_STUDIO_MODE_DISABLED = 23
obslua.OBS_FRONTEND_EVENT_STUDIO_MODE_ENABLED = 22
obslua.OBS_FRONTEND_EVENT_TBAR_VALUE_CHANGED = 33
obslua.OBS_FRONTEND_EVENT_THEME_CHANGED = 39
obslua.OBS_FRONTEND_EVENT_TRANSITION_CHANGED = 10
obslua.OBS_FRONTEND_EVENT_TRANSITION_DURATION_CHANGED = 29
obslua.OBS_FRONTEND_EVENT_TRANSITION_LIST_CHANGED = 12
obslua.OBS_FRONTEND_EVENT_TRANSITION_STOPPED = 11
obslua.OBS_FRONTEND_EVENT_VIRTUALCAM_STARTED = 31
obslua.OBS_FRONTEND_EVENT_VIRTUALCAM_STOPPED = 32
obslua.OBS_GROUP_CHECKABLE = 2
obslua.OBS_GROUP_NORMAL = 1
obslua.OBS_HOTKEY_REGISTERER_ENCODER = 3
obslua.OBS_HOTKEY_REGISTERER_FRONTEND = 0
obslua.OBS_HOTKEY_REGISTERER_OUTPUT = 2
obslua.OBS_HOTKEY_REGISTERER_SERVICE = 4
obslua.OBS_HOTKEY_REGISTERER_SOURCE = 1
obslua.OBS_ICON_TYPE_AUDIO_INPUT = 4
obslua.OBS_ICON_TYPE_AUDIO_OUTPUT = 5
obslua.OBS_ICON_TYPE_BROWSER = 12
obslua.OBS_ICON_TYPE_CAMERA = 9
obslua.OBS_ICON_TYPE_COLOR = 2
obslua.OBS_ICON_TYPE_CUSTOM = 13
obslua.OBS_ICON_TYPE_DESKTOP_CAPTURE = 6
obslua.OBS_ICON_TYPE_GAME_CAPTURE = 8
obslua.OBS_ICON_TYPE_IMAGE = 1
obslua.OBS_ICON_TYPE_MEDIA = 11
obslua.OBS_ICON_TYPE_SLIDESHOW = 3
obslua.OBS_ICON_TYPE_TEXT = 10
obslua.OBS_ICON_TYPE_UNKNOWN = 0
obslua.OBS_ICON_TYPE_WINDOW_CAPTURE = 7
obslua.OBS_KEY_LAST_VALUE = 636
obslua.OBS_MEDIA_STATE_BUFFERING = 3
obslua.OBS_MEDIA_STATE_ENDED = 6
obslua.OBS_MEDIA_STATE_ERROR = 7
obslua.OBS_MEDIA_STATE_NONE = 0
obslua.OBS_MEDIA_STATE_OPENING = 2
obslua.OBS_MEDIA_STATE_PAUSED = 4
obslua.OBS_MEDIA_STATE_PLAYING = 1
obslua.OBS_MEDIA_STATE_STOPPED = 5
obslua.OBS_MONITORING_TYPE_MONITOR_AND_OUTPUT = 2
obslua.OBS_MONITORING_TYPE_MONITOR_ONLY = 1
obslua.OBS_MONITORING_TYPE_NONE = 0
obslua.OBS_NO_DIRECT_RENDERING = 0
obslua.OBS_NUMBER_SCROLLER = 0
obslua.OBS_NUMBER_SLIDER = 1
obslua.OBS_OBJ_TYPE_ENCODER = 3
obslua.OBS_OBJ_TYPE_INVALID = 0
obslua.OBS_OBJ_TYPE_OUTPUT = 2
obslua.OBS_OBJ_TYPE_SERVICE = 4
obslua.OBS_OBJ_TYPE_SOURCE = 1
obslua.OBS_ORDER_MOVE_BOTTOM = 3
obslua.OBS_ORDER_MOVE_DOWN = 1
obslua.OBS_ORDER_MOVE_TOP = 2
obslua.OBS_ORDER_MOVE_UP = 0
obslua.OBS_OUTPUT_DELAY_PRESERVE = 1
obslua.OBS_PATH_DIRECTORY = 2
obslua.OBS_PATH_FILE = 0
obslua.OBS_PATH_FILE_SAVE = 1
obslua.OBS_PROPERTIES_DEFER_UPDATE = 1
obslua.OBS_PROPERTY_BOOL = 1
obslua.OBS_PROPERTY_BUTTON = 8
obslua.OBS_PROPERTY_COLOR = 7
obslua.OBS_PROPERTY_EDITABLE_LIST = 10
obslua.OBS_PROPERTY_FLOAT = 3
obslua.OBS_PROPERTY_FONT = 9
obslua.OBS_PROPERTY_FRAME_RATE = 11
obslua.OBS_PROPERTY_GROUP = 12
obslua.OBS_PROPERTY_INT = 2
obslua.OBS_PROPERTY_INVALID = 0
obslua.OBS_PROPERTY_LIST = 6
obslua.OBS_PROPERTY_PATH = 5
obslua.OBS_PROPERTY_TEXT = 4
obslua.OBS_SCALE_AREA = 5
obslua.OBS_SCALE_BICUBIC = 2
obslua.OBS_SCALE_BILINEAR = 3
obslua.OBS_SCALE_DISABLE = 0
obslua.OBS_SCALE_LANCZOS = 4
obslua.OBS_SCALE_POINT = 1
obslua.OBS_SCENE_DUP_COPY = 1
obslua.OBS_SCENE_DUP_PRIVATE_COPY = 3
obslua.OBS_SCENE_DUP_PRIVATE_REFS = 2
obslua.OBS_SCENE_DUP_REFS = 0
obslua.OBS_SOURCE_ASYNC = 4
obslua.OBS_SOURCE_ASYNC_VIDEO = 5
obslua.OBS_SOURCE_AUDIO = 2
obslua.OBS_SOURCE_CAP_DISABLED = 1024
obslua.OBS_SOURCE_CAP_OBSOLETE = 1024
obslua.OBS_SOURCE_COMPOSITE = 64
obslua.OBS_SOURCE_CONTROLLABLE_MEDIA = 8192
obslua.OBS_SOURCE_CUSTOM_DRAW = 8
obslua.OBS_SOURCE_DEPRECATED = 256
obslua.OBS_SOURCE_DO_NOT_DUPLICATE = 128
obslua.OBS_SOURCE_DO_NOT_SELF_MONITOR = 512
obslua.OBS_SOURCE_FLAG_FORCE_MONO = 2
obslua.OBS_SOURCE_FLAG_UNUSED_1 = 1
obslua.OBS_SOURCE_INTERACTION = 32
obslua.OBS_SOURCE_MONITOR_BY_DEFAULT = 2048
obslua.OBS_SOURCE_SUBMIX = 4096
obslua.OBS_SOURCE_TYPE_FILTER = 1
obslua.OBS_SOURCE_TYPE_INPUT = 0
obslua.OBS_SOURCE_TYPE_SCENE = 3
obslua.OBS_SOURCE_TYPE_TRANSITION = 2
obslua.OBS_SOURCE_VIDEO = 1
obslua.OBS_TASK_GRAPHICS = 1
obslua.OBS_TASK_UI = 0
obslua.OBS_TEXT_DEFAULT = 0
obslua.OBS_TEXT_MULTILINE = 2
obslua.OBS_TEXT_INFO = 3
obslua.OBS_TEXT_PASSWORD = 1
obslua.OBS_TRANSITION_MODE_AUTO = 0
obslua.OBS_TRANSITION_MODE_MANUAL = 1
obslua.OBS_TRANSITION_SCALE_ASPECT = 1
obslua.OBS_TRANSITION_SCALE_MAX_ONLY = 0
obslua.OBS_TRANSITION_SCALE_STRETCH = 2
obslua.OBS_TRANSITION_SOURCE_A = 0
obslua.OBS_TRANSITION_SOURCE_B = 1
obslua.OFF = 0
obslua.ON = 1
obslua.PYTHON_LIB = "python36"
obslua.SCRIPT_DIR = "../../data/obs-scripting/64bit"
obslua.S__LINE__ = "33"
obslua.TRUE = 1
obslua.UI_ENABLED = 1
obslua.XINPUT_MOUSE_LEN = 33

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.base_get_alignment() end

--- Sets/gets the current log handler.
---
--- C definition: `void base_get_log_handler(log_handler_t *handler, void **param)`
--- @param handler p_f_int_p_q_const__char_va_list_p_void__void
--- @param param p_void
function obslua.base_get_log_handler(handler, param) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 base_allocator
function obslua.base_set_allocator(param1) end

--- Sets the current crash handler.
---
--- C definition: `void base_set_crash_handler(void (*handler)(const char *, va_list, void *), void *param)`
--- @param handler f_p_q_const__char_va_list_p_void__void
--- @param param ref_void*
function obslua.base_set_crash_handler(handler, param) end

--- Sets/gets the current log handler.
---
--- C definition: `void base_set_log_handler(log_handler_t handler, void *param)`
--- @param handler f_int_p_q_const__char_va_list_p_void__void
--- @param param ref_void*
function obslua.base_set_log_handler(handler, param) end

--- Frees memory allocated with :c:func:`bmalloc()` or :c:func:`bfree()`.
---
--- C definition: `void bfree(void *ptr)`
--- @param ptr ref_void*
function obslua.bfree(ptr) end

--- Logging function.
---
--- C definition: `void blog(int log_level, const char *format, ...)`
--- @param log_level int
--- @param format char*
function obslua.blog(log_level, format) end

--- Allocates memory and increases the memory leak counter.
---
--- C definition: `void *bmalloc(size_t size)`
--- @param size number
--- @return void
function obslua.bmalloc(size) end

--- Duplicates memory.
---
--- C definition: `void *bmemdup(const void *ptr, size_t size)`
--- @param ptr ref_void*
--- @param size number
--- @return void
function obslua.bmemdup(ptr, size) end

--- Returns current number of active allocations.
---
--- C definition: `long bnum_allocs(void)`
--- @return number
function obslua.bnum_allocs() end

--- Reallocates memory.  Use only with memory that's been allocated by
--- :c:func:`bmalloc()`.
---
--- C definition: `void *brealloc(void *ptr, size_t size)`
--- @param ptr ref_void*
--- @param size number
--- @return void
function obslua.brealloc(ptr, size) end

--- Duplicates a string.
--- C definition: `char *bstrdup(const char *str)`
--- @param str string
--- @return string
function obslua.bstrdup(str) end

--- Duplicates a string of *n* bytes and automatically zero-terminates
--- it.
---
--- C definition: `char *bstrdup_n(const char *str, size_t n)`
--- @param str string
--- @param n number
--- @return string
function obslua.bstrdup_n(str, n) end

--- Duplicates a string.
--- C definition: `wchar_t *bwstrdup(const wchar_t *str)`
--- @param str wchar_t
--- @return wchar_t
function obslua.bwstrdup(str) end

--- Duplicates a string of *n* bytes and automatically zero-terminates
--- it.
---
--- C definition: `wchar_t *bwstrdup_n(const wchar_t *str, size_t n)`
--- @param str wchar_t
--- @param n number
--- @return wchar_t
function obslua.bwstrdup_n(str, n) end

--- Inline function that allocates zeroed memory.
---
--- C definition: `void *bzalloc(size_t size)`
--- @param size number
--- @return void
function obslua.bzalloc(size) end

--- Gets a boolean parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :return:     Boolean value
---
--- C definition: `bool calldata_bool(const calldata_t *data, const char *name)`
--- @param data calldata
--- @param name string
--- @return boolean
function obslua.calldata_bool(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
function obslua.calldata_clear(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.calldata_create() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
function obslua.calldata_destroy(param1) end

--- Gets a floating point parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :return:     Floating point value
---
--- C definition: `double calldata_float(const calldata_t *data, const char *name)`
--- @param data calldata
--- @param name string
--- @return number
function obslua.calldata_float(data, name) end

--- Frees a calldata structure.
---
--- :param data: Calldata structure
---
--- C definition: `void calldata_free(calldata_t *data)`
--- @param data calldata
function obslua.calldata_free(data) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 string
--- @param param3 bool
function obslua.calldata_get_bool(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 string
--- @param param3 ref_void*
--- @param param4 number
function obslua.calldata_get_data(param1, param2, param3, param4) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 string
--- @param param3 double
function obslua.calldata_get_float(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 string
--- @param param3 long_long
function obslua.calldata_get_int(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 string
--- @param param3 ref_void*
function obslua.calldata_get_ptr(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 string
--- @param param3 p_char
function obslua.calldata_get_string(param1, param2, param3) end

--- Initializes a calldata structure (zeroes it).
---
--- :param data: Calldata structure
---
--- C definition: `void calldata_init(calldata_t *data)`
--- @param data calldata
function obslua.calldata_init(data) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 unsigned_char
--- @param param3 number
function obslua.calldata_init_fixed(param1, param2, param3) end

--- Gets an integer parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :return:     Integer value
---
--- C definition: `long long calldata_int(const calldata_t *data, const char *name)`
--- @param data calldata
--- @param name string
--- @return number
function obslua.calldata_int(data, name) end

--- Gets a pointer parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :return:     Pointer value
---
--- C definition: `void *calldata_ptr(const calldata_t *data, const char *name)`
--- @param data calldata
--- @param name string
--- @return void
function obslua.calldata_ptr(data, name) end

--- Casts a pointer parameter of a calldata_t object to an
--- obs_sceneitem_t object.
---
--- :param calldata: A calldata_t object.
--- :param name:     Name of the parameter.
--- :return:         A borrowed reference to an obs_sceneitem_t object.
--- C definition: Not available
--- @param calldata unknown
--- @param name unknown
--- @return unknown
function obslua.calldata_sceneitem(calldata, name) end

--- Sets a boolean parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :param val:  Boolean value
---
--- C definition: `void calldata_set_bool(calldata_t *data, const char *name, bool val)`
--- @param data calldata
--- @param name string
--- @param val boolean
function obslua.calldata_set_bool(data, name, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 calldata
--- @param param2 string
--- @param param3 ref_void*
--- @param param4 number
function obslua.calldata_set_data(param1, param2, param3, param4) end

--- Sets a floating point parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :param val:  Floating point value
---
--- C definition: `void calldata_set_float(calldata_t *data, const char *name, double val)`
--- @param data calldata
--- @param name string
--- @param val number
function obslua.calldata_set_float(data, name, val) end

--- Sets an integer parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :param val:  Integer value
---
--- C definition: `void calldata_set_int(calldata_t *data, const char *name, long long val)`
--- @param data calldata
--- @param name string
--- @param val number
function obslua.calldata_set_int(data, name, val) end

--- Sets a pointer parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :param val:  Pointer value
---
--- C definition: `void calldata_set_ptr(calldata_t *data, const char *name, void *ptr)`
--- @param data calldata
--- @param name string
--- @param ptr ref_void*
function obslua.calldata_set_ptr(data, name, ptr) end

--- Sets a string parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :param val:  String
---
--- C definition: `void calldata_set_string(calldata_t *data, const char *name, const char *str)`
--- @param data calldata
--- @param name string
--- @param str string
function obslua.calldata_set_string(data, name, str) end

--- Casts a pointer parameter of a calldata_t object to an obs_source_t
--- object.
---
--- :param calldata: A calldata_t object.
--- :param name:     Name of the parameter.
--- :return:         A borrowed reference to an obs_source_t object.
---
--- C definition: Not available
--- @param calldata unknown
--- @param name unknown
--- @return unknown
function obslua.calldata_source(calldata, name) end

--- Gets a string parameter.
---
--- :param data: Calldata structure
--- :param name: Parameter name
--- :return:     String value
---
--- C definition: `const char *calldata_string(const calldata_t *data, const char *name)`
--- @param data calldata
--- @param name string
--- @return string
function obslua.calldata_string(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_begin_frame() end

--- Begins/ends a scene (this is automatically called by libobs, there's
--- no need to call this manually).
---
--- C definition: `void gs_begin_scene(void)`
function obslua.gs_begin_scene() end

--- Sets the blend function
---
--- :param src:  Blend type for the source
--- :param dest: Blend type for the destination
---
--- C definition: `void gs_blend_function(enum gs_blend_type src, enum gs_blend_type dest)`
--- @param src number
--- @param dest number
function obslua.gs_blend_function(src, dest) end

--- Sets the blend function for RGB and alpha separately
---
--- :param src_c:  Blend type for the source RGB
--- :param dest_c: Blend type for the destination RGB
--- :param src_a:  Blend type for the source alpha
--- :param dest_a: Blend type for the destination alpha
---
--- C definition: `void gs_blend_function_separate(enum gs_blend_type src_c, enum gs_blend_type dest_c, enum gs_blend_type src_a, enum gs_blend_type dest_a)`
--- @param src_c number
--- @param dest_c number
--- @param src_a number
--- @param dest_a number
function obslua.gs_blend_function_separate(src_c, dest_c, src_a, dest_a) end

--- Pops/restores the last blend state
---
--- C definition: `void gs_blend_state_pop(void)`
function obslua.gs_blend_state_pop() end

--- Pushes/stores the current blend state
---
--- C definition: `void gs_blend_state_push(void)`
function obslua.gs_blend_state_push() end

--- Clears color/depth/stencil buffers.
---
--- :param clear_flags: Flags to clear with.  Can be one of the following
---                     values:
---
---                     - GS_CLEAR_COLOR   - Clears color buffer
---                     - GS_CLEAR_DEPTH   - Clears depth buffer
---                     - GS_CLEAR_STENCIL - Clears stencil buffer
---
--- :param color:       Color value to clear the color buffer with
--- :param depth:       Depth value to clear the depth buffer with
--- :param stencil:     Stencil value to clear the stencil buffer with
---
--- C definition: `void gs_clear(uint32_t clear_flags, const struct vec4 *color, float depth, uint8_t stencil)`
--- @param clear_flags number
--- @param color vec4
--- @param depth number
--- @param stencil number
function obslua.gs_clear(clear_flags, color, depth, stencil) end

--- C definition: `void gs_color(uint32_t color)`
--- @param color number
function obslua.gs_color(color) end

--- C definition: `void gs_color4v(const struct vec4 *v)`
--- @param v vec4
function obslua.gs_color4v(v) end

--- Copies a texture
---
--- :param dst: Destination texture
--- :param src: Source texture
---
--- C definition: `void gs_copy_texture(gs_texture_t *dst, gs_texture_t *src)`
--- @param dst gs_texture
--- @param src gs_texture
function obslua.gs_copy_texture(dst, src) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
--- @param param2 number
--- @param param3 number
--- @param param4 gs_texture
--- @param param5 number
--- @param param6 number
--- @param param7 number
--- @param param8 number
function obslua.gs_copy_texture_region(param1, param2, param3, param4, param5, param6, param7, param8) end

--- Creates a graphics context
---
--- :param graphics: Pointer to receive the graphics context
--- :param module:   Module name
--- :param adapter:  Adapter index
--- :return:         Can return one of the following values:
---
---                  - GS_SUCCESS
---                  - GS_ERROR_FAIL
---                  - GS_ERROR_MODULE_NOT_FOUND
---                  - GS_ERROR_NOT_SUPPORTED
---
--- C definition: `int gs_create(graphics_t **graphics, const char *module, uint32_t adapter)`
--- @param graphics p_graphics_subsystem
--- @param module string
--- @param adapter number
--- @return number
function obslua.gs_create(graphics, module, adapter) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 gs_color_format
--- @param param3 unsigned_int
--- @param param4 unsigned_int
function obslua.gs_create_texture_file_data(param1, param2, param3, param4) end

--- Creates a cubemap texture.
---
--- :param size:         Width/height/depth value
--- :param color_format: Color format
--- :param levels:       Number of texture levels
--- :param data:         Pointer to array of texture data pointers
--- :param flags:        Can be 0 or a bitwise-OR combination of one or
---                      more of the following value:
---
---                      - GS_BUILD_MIPMAPS - Automatically builds
---                        mipmaps (Note: not fully tested)
---                      - GS_DYNAMIC - Dynamic
---                      - GS_RENDER_TARGET - Render target
---
--- :return:             A new cube texture object
---
--- C definition: `gs_texture_t *gs_cubetexture_create(uint32_t size, enum gs_color_format color_format, uint32_t levels, const uint8_t **data, uint32_t flags)`
--- @param size number
--- @param color_format number
--- @param levels number
--- @param data p_unsigned_char
--- @param flags number
--- @return gs_texture
function obslua.gs_cubetexture_create(size, color_format, levels, data, flags) end

--- Destroys a cube texture.
---
--- :param cubetex: Cube texture object
---
--- C definition: `void     gs_cubetexture_destroy(gs_texture_t *cubetex)`
--- @param cubetex gs_texture
function obslua.gs_cubetexture_destroy(cubetex) end

--- Gets the color format of a cube texture.
---
--- :param cubetex: Cube texture object
--- :return:        The color format of the cube texture
---
--- C definition: `enum gs_color_format gs_cubetexture_get_color_format(const gs_texture_t *cubetex)`
--- @param cubetex gs_texture
--- @return number
function obslua.gs_cubetexture_get_color_format(cubetex) end

--- Get the width/height/depth value of a cube texture.
---
--- :param cubetex: Cube texture object
--- :return:        The width/height/depth value of the cube texture
---
--- C definition: `uint32_t gs_cubetexture_get_size(const gs_texture_t *cubetex)`
--- @param cubetex gs_texture
--- @return number
function obslua.gs_cubetexture_get_size(cubetex) end

--- Sets an image of a cube texture side.
---
--- :param cubetex:  Cube texture object
--- :param side:     Side
--- :param data:     Texture data to set
--- :param linesize: Line size (pitch) of the texture data
--- :param invert:   *true* to invert texture data, *false* otherwise
---
--- C definition: `void gs_cubetexture_set_image(gs_texture_t *cubetex, uint32_t side, const void *data, uint32_t linesize, bool invert)`
--- @param cubetex gs_texture
--- @param side number
--- @param data ref_void*
--- @param linesize number
--- @param invert boolean
function obslua.gs_cubetexture_set_image(cubetex, side, data, linesize, invert) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 float
--- @param param2 string
function obslua.gs_debug_marker_begin(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 float
--- @param param2 string
function obslua.gs_debug_marker_begin_format(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_debug_marker_end() end

--- Sets the depth function
---
--- :param test: Sets the depth test type
---
--- C definition: `void gs_depth_function(enum gs_depth_test test)`
--- @param test number
function obslua.gs_depth_function(test) end

--- Destroys a graphics context
---
--- :param graphics: Graphics context
---
--- C definition: `void gs_destroy(graphics_t *graphics)`
--- @param graphics graphics_subsystem
function obslua.gs_destroy(graphics) end

--- Draws a primitive or set of primitives.
---
--- :param draw_mode:  The primitive draw mode to use
--- :param start_vert: Starting vertex index
--- :param num_verts:  Number of vertices
---
--- C definition: `void gs_draw(enum gs_draw_mode draw_mode, uint32_t start_vert, uint32_t num_verts)`
--- @param draw_mode number
--- @param start_vert number
--- @param num_verts number
function obslua.gs_draw(draw_mode, start_vert, num_verts) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
--- @param param2 quat
--- @param param3 number
--- @param param4 number
--- @param param5 number
--- @param param6 number
--- @param param7 number
function obslua.gs_draw_cube_backdrop(param1, param2, param3, param4, param5, param6, param7) end

--- Draws a 2D sprite.  Sets the "image" parameter of the current effect
--- to the texture and renders a quad.
---
--- If width or height is 0, the width or height of the texture will be
--- used.  The flip value specifies whether the texture should be flipped
--- on the U or V axis with GS_FLIP_U and GS_FLIP_V.
---
--- :param tex:    Texture to draw
--- :param flip:   Can be 0 or a bitwise-OR combination of one of the
---                following values:
---
---                - GS_FLIP_U - Flips the texture horizontally
---                - GS_FLIP_V - Flips the texture vertically
---
--- :param width:  Width
--- :param height: Height
---
--- C definition: `void gs_draw_sprite(gs_texture_t *tex, uint32_t flip, uint32_t width, uint32_t height)`
--- @param tex gs_texture
--- @param flip number
--- @param width number
--- @param height number
function obslua.gs_draw_sprite(tex, flip, width, height) end

--- Draws a subregion of a 2D sprite.  Sets the "image" parameter of the
--- current effect to the texture and renders a quad.
---
--- :param tex:    Texture to draw
--- :param flip:   Can be 0 or a bitwise-OR combination of one of the
---                following values:
---
---                - GS_FLIP_U - Flips the texture horizontally
---                - GS_FLIP_V - Flips the texture vertically
---
--- :param x:      X value within subregion
--- :param y:      Y value within subregion
--- :param cx:     CX value of subregion
--- :param cy:     CY value of subregion
---
--- C definition: `void gs_draw_sprite_subregion(gs_texture_t *tex, uint32_t flip, uint32_t x, uint32_t y, uint32_t cx, uint32_t cy)`
--- @param tex gs_texture
--- @param flip number
--- @param x number
--- @param y number
--- @param cx number
--- @param cy number
function obslua.gs_draw_sprite_subregion(tex, flip, x, y, cx, cy) end

--- Creates an effect from a string.
---
--- :param effect_String: Effect string
--- :param error_string:  Receives a pointer to the error string, which
---                       must be freed with :c:func:`bfree()`.  If
---                       *NULL*, this parameter is ignored.
--- :return:              The effect object, or *NULL* on error
---
--- C definition: `gs_effect_t *gs_effect_create(const char *effect_string, const char *filename, char **error_string)`
--- @param effect_string string
--- @param filename string
--- @param error_string p_char
--- @return gs_effect
function obslua.gs_effect_create(effect_string, filename, error_string) end

--- Creates an effect from file.
---
--- :param file:         Path to the effect file
--- :param error_string: Receives a pointer to the error string, which
---                      must be freed with :c:func:`bfree()`.  If
---                      *NULL*, this parameter is ignored.
--- :return:             The effect object, or *NULL* on error
---
--- C definition: `gs_effect_t *gs_effect_create_from_file(const char *file, char **error_string)`
--- @param file string
--- @param error_string p_char
--- @return gs_effect
function obslua.gs_effect_create_from_file(file, error_string) end

--- Destroys the effect
---
--- :param effect: Effect object
---
--- C definition: `void gs_effect_destroy(gs_effect_t *effect)`
--- @param effect gs_effect
function obslua.gs_effect_destroy(effect) end

--- Gets the current active technique of the effect.
---
--- :param effect: Effect object
--- :return:       Technique object, or *NULL* if none currently active
---
--- C definition: `gs_technique_t *gs_effect_get_current_technique(const gs_effect_t *effect)`
--- @param effect gs_effect
--- @return gs_effect_technique
function obslua.gs_effect_get_current_technique(effect) end

--- Returns a copy of the param's default value.
---
--- :param param:   Effect parameter
--- :return:        A pointer to the copied byte value of the param's default value. Freed with :c:func:`bfree()`.
---
--- C definition: `void gs_effect_get_default_val(gs_eparam_t *param)`
--- @param param gs_effect_param
function obslua.gs_effect_get_default_val(param) end

--- Returns the size in bytes of the param's default value.
---
--- :param param:   Effect parameter
--- :return:        The size in bytes of the param's default value.
--- C definition: `size_t gs_effect_get_default_val_size(gs_eparam_t *param)`
--- @param param gs_effect_param
--- @return number
function obslua.gs_effect_get_default_val_size(param) end

--- Gets the number of parameters associated with the effect.
---
--- :param effect: Effect object
--- :return:       Number of parameters the effect has
---
--- C definition: `size_t gs_effect_get_num_params(const gs_effect_t *effect)`
--- @param effect gs_effect
--- @return number
function obslua.gs_effect_get_num_params(effect) end

--- Gets a parameter of an effect by its index.
---
--- :param effect: Effect object
--- :param param:  Parameter index
--- :return:       The effect parameter object, or *NULL* if index
---                invalid
---
--- C definition: `gs_eparam_t *gs_effect_get_param_by_idx(const gs_effect_t *effect, size_t param)`
--- @param effect gs_effect
--- @param param number
--- @return gs_effect_param
function obslua.gs_effect_get_param_by_idx(effect, param) end

--- Gets parameter of an effect by its name.
---
--- :param effect: Effect object
--- :param name:   Name of the parameter
--- :return:       The effect parameter object, or *NULL* if not found
---
--- C definition: `gs_eparam_t *gs_effect_get_param_by_name(const gs_effect_t *effect, const char *name)`
--- @param effect gs_effect
--- @param name string
--- @return gs_effect_param
function obslua.gs_effect_get_param_by_name(effect, name) end

--- Gets a technique of the effect.
---
--- :param effect: Effect object
--- :param name:   Name of the technique
--- :return:       Technique object, or *NULL* if not found
---
--- C definition: `gs_technique_t *gs_effect_get_technique(const gs_effect_t *effect, const char *name)`
--- @param effect gs_effect
--- @param name string
--- @return gs_effect_technique
function obslua.gs_effect_get_technique(effect, name) end

--- Returns a copy of the param's current value.
---
--- :param param:   Effect parameter
--- :return:        A pointer to the copied byte value of the param's current value. Freed with :c:func:`bfree()`.
---
--- C definition: `void *gs_effect_get_val(gs_eparam_t *param)`
--- @param param gs_effect_param
--- @return void
function obslua.gs_effect_get_val(param) end

--- Returns the size in bytes of the param's current value.
---
--- :param param:   Effect parameter
--- :return:        The size in bytes of the param's current value.
---
--- C definition: `size_t gs_effect_get_val_size(gs_eparam_t *param)`
--- @param param gs_effect_param
--- @return number
function obslua.gs_effect_get_val_size(param) end

--- Gets the view/projection matrix parameter ("viewproj") of the effect.
---
--- :param effect: Effect object
--- :return:       The view/projection matrix parameter of the effect
---
--- C definition: `gs_eparam_t *gs_effect_get_viewproj_matrix(const gs_effect_t *effect)`
--- @param effect gs_effect
--- @return gs_effect_param
function obslua.gs_effect_get_viewproj_matrix(effect) end

--- Gets the world matrix parameter ("world") of the effect.
---
--- :param effect: Effect object
--- :return:       The world matrix parameter of the effect
---
--- C definition: `gs_eparam_t *gs_effect_get_world_matrix(const gs_effect_t *effect)`
--- @param effect gs_effect
--- @return gs_effect_param
function obslua.gs_effect_get_world_matrix(effect) end

--- Helper function that automatically begins techniques/passes.
---
--- :param effect: Effect object
--- :param name:   Name of the technique to execute
--- :return:       *true* to draw, *false* when complete
---
--- Here is an example of how this function is typically used:
---
--- .. code:: cpp
---
--- for (gs_effect_loop(effect, "my_technique")) {
---         /* perform drawing here */
---         [...]
--- }
---
--- C definition: `bool gs_effect_loop(gs_effect_t *effect, const char *name)`
--- @param effect gs_effect
--- @param name string
--- @return boolean
function obslua.gs_effect_loop(effect, name) end

--- Sets a boolean parameter.
---
--- :param param: Effect parameter
--- :param val:   Boolean value
---
--- C definition: `void gs_effect_set_bool(gs_eparam_t *param, bool val)`
--- @param param gs_effect_param
--- @param val boolean
function obslua.gs_effect_set_bool(param, val) end

--- Convenience function for setting a color value via an integer value.
---
--- :param param: Effect parameter
--- :param argb:  Integer color value (i.e. hex value would be
---               0xAARRGGBB)
---
--- C definition: `void gs_effect_set_color(gs_eparam_t *param, uint32_t argb)`
--- @param param gs_effect_param
--- @param argb number
function obslua.gs_effect_set_color(param, argb) end

--- Sets the parameter to its default value
---
--- :param: Effect parameter
---
--- C definition: `void gs_effect_set_default(gs_eparam_t *param)`
--- @param param gs_effect_param
function obslua.gs_effect_set_default(param) end

--- Sets a floating point parameter.
---
--- :param param: Effect parameter
--- :param val:   Floating point value
---
--- C definition: `void gs_effect_set_float(gs_eparam_t *param, float val)`
--- @param param gs_effect_param
--- @param val number
function obslua.gs_effect_set_float(param, val) end

--- Sets a integer parameter.
---
--- :param param: Effect parameter
--- :param val:   Integer value
---
--- C definition: `void gs_effect_set_int(gs_eparam_t *param, int val)`
--- @param param gs_effect_param
--- @param val number
function obslua.gs_effect_set_int(param, val) end

--- Sets a matrix parameter.
---
--- :param param: Effect parameter
--- :param val:   Matrix
---
--- C definition: `void gs_effect_set_matrix4(gs_eparam_t *param, const struct matrix4 *val)`
--- @param param gs_effect_param
--- @param val matrix4
function obslua.gs_effect_set_matrix4(param, val) end

--- Manually changes the sampler for an effect parameter the next time
--- it's used.
---
--- :param param:   Effect parameter
--- :param sampler: Sampler state object
---
--- C definition: `void gs_effect_set_next_sampler(gs_eparam_t *param, gs_samplerstate_t *sampler)`
--- @param param gs_effect_param
--- @param sampler gs_sampler_state
function obslua.gs_effect_set_next_sampler(param, sampler) end

--- Sets a texture parameter.
---
--- :param param: Effect parameter
--- :param val:   Texture
---
--- C definition: `void gs_effect_set_texture(gs_eparam_t *param, gs_texture_t *val)`
--- @param param gs_effect_param
--- @param val gs_texture
function obslua.gs_effect_set_texture(param, val) end

--- Sets a parameter with data manually.
---
--- :param param: Effect parameter
--- :param val:   Pointer to data
--- :param size:  Size of data
---
--- C definition: `void gs_effect_set_val(gs_eparam_t *param, const void *val, size_t size)`
--- @param param gs_effect_param
--- @param val ref_void*
--- @param size number
function obslua.gs_effect_set_val(param, val, size) end

--- Sets a 2-component vector parameter.
---
--- :param param: Effect parameter
--- :param val:   Vector
---
--- C definition: `void gs_effect_set_vec2(gs_eparam_t *param, const struct vec2 *val)`
--- @param param gs_effect_param
--- @param val vec2
function obslua.gs_effect_set_vec2(param, val) end

--- Sets a 3-component vector parameter.
---
--- :param param: Effect parameter
--- :param val:   Vector
---
--- C definition: `void gs_effect_set_vec3(gs_eparam_t *param, const struct vec3 *val)`
--- @param param gs_effect_param
--- @param val vec3
function obslua.gs_effect_set_vec3(param, val) end

--- Sets a 4-component vector parameter.
---
--- :param param: Effect parameter
--- :param val:   Vector
---
--- C definition: `void gs_effect_set_vec4(gs_eparam_t *param, const struct vec4 *val)`
--- @param param gs_effect_param
--- @param val vec4
function obslua.gs_effect_set_vec4(param, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_effect
function obslua.gs_effect_update_params(param1) end

--- Enables/disables blending
---
--- :param enable: *true* to enable, *false* to disable
---
--- C definition: `void gs_enable_blending(bool enable)`
--- @param enable boolean
function obslua.gs_enable_blending(enable) end

--- Enables/disables specific color channels
---
--- :param red:   *true* to enable red channel, *false* to disable
--- :param green: *true* to enable green channel, *false* to disable
--- :param blue:  *true* to enable blue channel, *false* to disable
--- :param alpha: *true* to enable alpha channel, *false* to disable
---
--- C definition: `void gs_enable_color(bool red, bool green, bool blue, bool alpha)`
--- @param red boolean
--- @param green boolean
--- @param blue boolean
--- @param alpha boolean
function obslua.gs_enable_color(red, green, blue, alpha) end

--- Enables/disables depth testing
---
--- :param enable: *true* to enable, *false* to disable
---
--- C definition: `void gs_enable_depth_test(bool enable)`
--- @param enable boolean
function obslua.gs_enable_depth_test(enable) end

--- Enables/disables stencil testing
---
--- :param enable: *true* to enable, *false* to disable
---
--- C definition: `void gs_enable_stencil_test(bool enable)`
--- @param enable boolean
function obslua.gs_enable_stencil_test(enable) end

--- Enables/disables stencil writing
---
--- :param enable: *true* to enable, *false* to disable
---
--- C definition: `void gs_enable_stencil_write(bool enable)`
--- @param enable boolean
function obslua.gs_enable_stencil_write(enable) end

--- Begins/ends a scene (this is automatically called by libobs, there's
--- no need to call this manually).
---
--- C definition: `void gs_end_scene(void)`
function obslua.gs_end_scene() end

--- Enters and locks the graphics context
---
--- :param graphics: Graphics context
---
--- C definition: `void gs_enter_context(graphics_t *graphics)`
--- @param graphics graphics_subsystem
function obslua.gs_enter_context(graphics) end

--- Enumerates adapters (this really only applies on windows).
---
--- :param callback: Enumeration callback
--- :param param:    Private data passed to the callback
---
--- C definition: `void gs_enum_adapters(bool (*callback)(void *param, const char *name, uint32_t id), void *param)`
--- @param callback f_p_void_p_q_const__char_unsigned_int__bool
--- @param param ref_void*
function obslua.gs_enum_adapters(callback, param) end

--- Flushes GPU calls
---
--- C definition: `void gs_flush(void)`
function obslua.gs_flush() end

--- Sets the projection matrix to a frustum matrix
---
--- C definition: `void gs_frustum(float left, float right, float top, float bottom, float znear, float zfar)`
--- @param left number
--- @param right number
--- @param top number
--- @param bottom number
--- @param znear number
--- @param zfar number
function obslua.gs_frustum(left, right, top, bottom, znear, zfar) end

--- :return: The currently locked graphics context for this thread
---
--- C definition: `graphics_t *gs_get_context(void)`
--- @return graphics_subsystem
function obslua.gs_get_context() end

--- :return: The current cull mode
---
--- C definition: `enum gs_cull_mode gs_get_cull_mode(void)`
--- @return number
function obslua.gs_get_cull_mode() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_get_device_name() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_get_device_obj() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_get_device_type() end

--- :return: The currently active effect, or *NULL* if none active
---
--- C definition: `gs_effect_t *gs_get_effect(void)`
--- @return gs_effect
function obslua.gs_get_effect() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
function obslua.gs_get_format_bpp(param1) end

--- Gets the height of the currently active swap chain
---
--- C definition: `uint32_t gs_get_height(void)`
--- @return number
function obslua.gs_get_height() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_get_input() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_get_pixel_shader() end

--- :return: The currently active render target
---
--- C definition: `gs_texture_t  *gs_get_render_target(void)`
--- @return gs_texture
function obslua.gs_get_render_target() end

--- Gets the size of the currently active swap chain
---
--- :param cx: Pointer to receive width
--- :param cy: Pointer to receive height
---
--- C definition: `void gs_get_size(uint32_t *cx, uint32_t *cy)`
--- @param cx unsigned_int
--- @param cy unsigned_int
function obslua.gs_get_size(cx, cy) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_get_texture_type(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 number
--- @param param3 number
function obslua.gs_get_total_levels(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_get_vertex_shader() end

--- Gets the current viewport
---
--- :param rect: Pointer to receive viewport rectangle
---
--- C definition: `void gs_get_viewport(struct gs_rect *rect)`
--- @param rect gs_rect
function obslua.gs_get_viewport(rect) end

--- Gets the width of the currently active swap chain
---
--- C definition: `uint32_t gs_get_width(void)`
--- @return number
function obslua.gs_get_width() end

--- :return: The currently active Z-stencil target
---
--- C definition: `gs_zstencil_t *gs_get_zstencil_target(void)`
--- @return gs_zstencil_buffer
function obslua.gs_get_zstencil_target() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_image_file2
function obslua.gs_image_file2_free(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_image_file2
--- @param param2 string
function obslua.gs_image_file2_init(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_image_file2
function obslua.gs_image_file2_init_texture(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_image_file2
--- @param param2 number
function obslua.gs_image_file2_tick(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_image_file2
function obslua.gs_image_file2_update_texture(param1) end

--- Frees an image file helper
---
--- :param image: Image file helper
---
--- C definition: `void gs_image_file_free(gs_image_file_t *image)`
--- @param image gs_image_file
function obslua.gs_image_file_free(image) end

--- Loads an initializes an image file helper.  Does not initialize the
--- texture; call :c:func:`gs_image_file_init_texture()` to initialize
--- the texture.
---
--- :param image: Image file helper to initialize
--- :param file:  Path to the image file to load
---
--- C definition: `void gs_image_file_init(gs_image_file_t *image, const char *file)`
--- @param image gs_image_file
--- @param file string
function obslua.gs_image_file_init(image, file) end

--- Initializes the texture of an image file helper.  This is separate
--- from :c:func:`gs_image_file_init()` because it allows deferring the
--- graphics initialization if needed.
---
--- :param image: Image file helper
---
--- C definition: `void gs_image_file_init_texture(gs_image_file_t *image)`
--- @param image gs_image_file
function obslua.gs_image_file_init_texture(image) end

--- Performs a tick operation on the image file helper (used primarily
--- for animated file).  Does not update the texture until
--- :c:func:`gs_image_file_update_texture()` is called.
---
--- :param image:           Image file helper
--- :param elapsed_time_ns: Elapsed time in nanoseconds
---
--- C definition: `bool gs_image_file_tick(gs_image_file_t *image, uint64_t elapsed_time_ns)`
--- @param image gs_image_file
--- @param elapsed_time_ns number
--- @return boolean
function obslua.gs_image_file_tick(image, elapsed_time_ns) end

--- Updates the texture (used primarily for animated files)
---
--- :param image: Image file helper
--- C definition: `void gs_image_file_update_texture(gs_image_file_t *image)`
--- @param image gs_image_file
function obslua.gs_image_file_update_texture(image) end

--- Creates an index buffer.
---
--- :param type:    Index buffer type
--- :param indices: Index buffer data.  This buffer must be allocated
---                 with :c:func:`bmalloc()`, :c:func:`bzalloc()`, or
---                 :c:func:`bralloc()`, and ownership of this buffer is
---                 passed to the index buffer object.
--- :param num:     Number of indices in the buffer
---
--- :param flags:   Creation flags.  Can be 0 or a bitwise-OR combination
---                 of any of the following values:
---
---                 - GS_DYNAMIC - Can be dynamically updated in real time.
---                 - GS_DUP_BUFFER - Do not pass buffer ownership
---
--- :return:        A new index buffer object, or *NULL* if failed
---
--- C definition: `gs_indexbuffer_t *gs_indexbuffer_create(enum gs_index_type type, void *indices, size_t num, uint32_t flags)`
--- @param type number
--- @param indices ref_void*
--- @param num number
--- @param flags number
--- @return gs_index_buffer
function obslua.gs_indexbuffer_create(type, indices, num, flags) end

--- Destroys an index buffer object.
---
--- :param indexbuffer: Index buffer object
---
--- C definition: `void     gs_indexbuffer_destroy(gs_indexbuffer_t *indexbuffer)`
--- @param indexbuffer gs_index_buffer
function obslua.gs_indexbuffer_destroy(indexbuffer) end

--- Flushes a index buffer to its interval index data object.  To modify
--- its internal index data, call :c:func:`gs_indexbuffer_get_data()`.
---
--- Can only be used with dynamic index buffer objects.
---
--- :param indexbuffer: Index buffer object
---
--- C definition: `void     gs_indexbuffer_flush(gs_indexbuffer_t *indexbuffer)`
--- @param indexbuffer gs_index_buffer
function obslua.gs_indexbuffer_flush(indexbuffer) end

--- Flushes a index buffer to the specified index buffer data.
---
--- Can only be used with dynamic index buffer objects.
---
--- :param indexbuffer: Index buffer object
--- :param data:        Index buffer data to flush
---
--- C definition: `void     gs_indexbuffer_flush_direct(gs_indexbuffer_t *indexbuffer, const void *data)`
--- @param indexbuffer gs_index_buffer
--- @param data ref_void*
function obslua.gs_indexbuffer_flush_direct(indexbuffer, data) end

--- Gets the index buffer data associated with a index buffer object.
--- This data can be changed and index buffer can be updated with
--- :c:func:`gs_indexbuffer_flush()`.
---
--- Can only be used with dynamic index buffer objects.
---
--- :param vertbuffer: Index buffer object
--- :return:           Index buffer data pointer
---
--- C definition: `void     *gs_indexbuffer_get_data(const gs_indexbuffer_t *indexbuffer)`
--- @param indexbuffer gs_index_buffer
--- @return void
function obslua.gs_indexbuffer_get_data(indexbuffer) end

--- Gets the number of indices associated with this index buffer.
---
--- :param indexbuffer: Index buffer object
--- :return:            Number of indices the vertex buffer object has
---
--- C definition: `size_t   gs_indexbuffer_get_num_indices(const gs_indexbuffer_t *indexbuffer)`
--- @param indexbuffer gs_index_buffer
--- @return number
function obslua.gs_indexbuffer_get_num_indices(indexbuffer) end

--- Gets the type of index buffer.
---
--- :param indexbuffer: Index buffer object
--- :return:            Index buffer type
---
--- C definition: `enum gs_index_type gs_indexbuffer_get_type(const gs_indexbuffer_t *indexbuffer)`
--- @param indexbuffer gs_index_buffer
--- @return number
function obslua.gs_indexbuffer_get_type(indexbuffer) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
function obslua.gs_is_compressed_format(param1) end

--- Leaves and unlocks the graphics context
---
--- :param graphics: Graphics context
---
--- C definition: `void gs_leave_context(void)`
function obslua.gs_leave_context() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 boolean
--- @param param2 number
function obslua.gs_load_default_samplerstate(param1, param2) end

--- Loads a index buffer
---
--- :param indexbuffer: Index buffer to load, or NULL to unload
---
--- C definition: `void gs_load_indexbuffer(gs_indexbuffer_t *indexbuffer)`
--- @param indexbuffer gs_index_buffer
function obslua.gs_load_indexbuffer(indexbuffer) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_shader
function obslua.gs_load_pixelshader(param1) end

--- Loads a sampler state (this is usually not called manually)
---
--- :param samplerstate: Sampler state to load, or NULL to unload
--- :param unit:         Texture unit to load sampler state for
---
--- C definition: `void gs_load_samplerstate(gs_samplerstate_t *samplerstate, int unit)`
--- @param samplerstate gs_sampler_state
--- @param unit number
function obslua.gs_load_samplerstate(samplerstate, unit) end

--- Loads a swapchain
---
--- :param swapchain: Swap chain to load, or NULL to unload
---
--- C definition: `void gs_load_swapchain(gs_swapchain_t *swapchain)`
--- @param swapchain gs_swap_chain
function obslua.gs_load_swapchain(swapchain) end

--- Loads a texture (this is usually not called manually)
---
--- :param tex:  Texture to load, or NULL to unload
--- :param unit: Texture unit to load texture for
---
--- C definition: `void gs_load_texture(gs_texture_t *tex, int unit)`
--- @param tex gs_texture
--- @param unit number
function obslua.gs_load_texture(tex, unit) end

--- Loads a vertex buffer
---
--- :param vertbuffer: Vertex buffer to load, or NULL to unload
---
--- C definition: `void gs_load_vertexbuffer(gs_vertbuffer_t *vertbuffer)`
--- @param vertbuffer gs_vertex_buffer
function obslua.gs_load_vertexbuffer(vertbuffer) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_shader
function obslua.gs_load_vertexshader(param1) end

--- Gets the current matrix
---
--- :param dst: Destination matrix
---
--- C definition: `void gs_matrix_get(struct matrix4 *dst)`
--- @param dst matrix4
function obslua.gs_matrix_get(dst) end

--- Sets the current matrix to an identity matrix.
---
--- C definition: `void gs_matrix_identity(void)`
function obslua.gs_matrix_identity() end

--- Multiplies the current matrix
---
--- :param matrix: Matrix to multiply the current stack matrix with
---
--- C definition: `void gs_matrix_mul(const struct matrix4 *matrix)`
--- @param matrix matrix4
function obslua.gs_matrix_mul(matrix) end

--- Pops the current matrix from the matrix stack.
---
--- C definition: `void gs_matrix_pop(void)`
function obslua.gs_matrix_pop() end

--- Pushes the matrix stack and duplicates the current matrix.
---
--- C definition: `void gs_matrix_push(void)`
function obslua.gs_matrix_push() end

--- Multiplies the current matrix with an axis angle
---
--- :param rot: Axis angle to multiple the current matrix stack with
---
--- C definition: `void gs_matrix_rotaa(const struct axisang *rot)`
--- @param rot axisang
function obslua.gs_matrix_rotaa(rot) end

--- Multiplies the current matrix with an axis angle
---
--- :param rot: Axis angle to multiple the current matrix stack with
---
--- C definition: `void gs_matrix_rotaa4f(float x, float y, float z, float angle)`
--- @param x number
--- @param y number
--- @param z number
--- @param angle number
function obslua.gs_matrix_rotaa4f(x, y, z, angle) end

--- Multiplies the current matrix with a quaternion
---
--- :param rot: Quaternion to multiple the current matrix stack with
---
--- C definition: `void gs_matrix_rotquat(const struct quat *rot)`
--- @param rot quat
function obslua.gs_matrix_rotquat(rot) end

--- Scales the current matrix
---
--- :param scale: Scale value to scale the current matrix stack with
---
--- C definition: `void gs_matrix_scale(const struct vec3 *scale)`
--- @param scale vec3
function obslua.gs_matrix_scale(scale) end

--- Scales the current matrix
---
--- :param scale: Scale value to scale the current matrix stack with
---
--- C definition: `void gs_matrix_scale3f(float x, float y, float z)`
--- @param x number
--- @param y number
--- @param z number
function obslua.gs_matrix_scale3f(x, y, z) end

--- Sets the current matrix.
---
--- :param matrix: The matrix to set
---
--- C definition: `void gs_matrix_set(const struct matrix4 *matrix)`
--- @param matrix matrix4
function obslua.gs_matrix_set(matrix) end

--- Translates the current matrix
---
--- :param pos: Vector to translate the current matrix stack with
---
--- C definition: `void gs_matrix_translate(const struct vec3 *pos)`
--- @param pos vec3
function obslua.gs_matrix_translate(pos) end

--- Translates the current matrix
---
--- :param pos: Vector to translate the current matrix stack with
---
--- C definition: `void gs_matrix_translate3f(float x, float y, float z)`
--- @param x number
--- @param y number
--- @param z number
function obslua.gs_matrix_translate3f(x, y, z) end

--- Transposes the current matrix.
---
--- C definition: `void gs_matrix_transpose(void)`
function obslua.gs_matrix_transpose() end

--- C definition: `void gs_normal3f(float x, float y, float z)`
--- @param x number
--- @param y number
--- @param z number
function obslua.gs_normal3f(x, y, z) end

--- C definition: `void gs_normal3v(const struct vec3 *v)`
--- @param v vec3
function obslua.gs_normal3v(v) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_nv12_available() end

--- Sets the projection matrix to an orthographic matrix
---
--- C definition: `void gs_ortho(float left, float right, float top, float bottom, float znear, float zfar)`
--- @param left number
--- @param right number
--- @param top number
--- @param bottom number
--- @param znear number
--- @param zfar number
function obslua.gs_ortho(left, right, top, bottom, znear, zfar) end

--- Gets an annotation of a param by its index.
---
--- :param param:  Param object
--- :param param:  Annotation index
--- :return:       The effect parameter object (annotation), or *NULL* if index
---                invalid
---
--- C definition: `gs_eparam_t *gs_param_get_annotation_by_idx(const gs_eparam_t *param, size_t annotation)`
--- @param param gs_effect_param
--- @param annotation number
--- @return gs_effect_param
function obslua.gs_param_get_annotation_by_idx(param, annotation) end

--- Gets parameter of an effect by its name.
---
--- :param param:  Param object
--- :param name:   Name of the annotation
--- :return:       The effect parameter object (annotation), or *NULL* if not found
---
--- C definition: `gs_eparam_t *gs_param_get_annotation_by_name(const gs_eparam_t *pardam, const char *annotation)`
--- @param pardam gs_effect_param
--- @param annotation string
--- @return gs_effect_param
function obslua.gs_param_get_annotation_by_name(pardam, annotation) end

--- Gets the number of annotations associated with the parameter.
---
--- :param param:  Param object
--- :return:       Number of annotations the param has
---
--- C definition: `size_t gs_param_get_num_annotations(const gs_eparam_t *param)`
--- @param param gs_effect_param
--- @return number
function obslua.gs_param_get_num_annotations(param) end

--- Sets the projection matrix to a perspective mode
---
--- :param fovy:   Field of view (in degrees)
--- :param aspect: Aspect ratio
--- :param znear:  Near plane
--- :param zfar:   Far plane
---
--- C definition: `void gs_perspective(float fovy, float aspect, float znear, float zfar)`
--- @param fovy number
--- @param aspect number
--- @param znear number
--- @param zfar number
function obslua.gs_perspective(fovy, aspect, znear, zfar) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 string
--- @param param3 p_char
function obslua.gs_pixelshader_create(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 p_char
function obslua.gs_pixelshader_create_from_file(param1, param2) end

--- Displays what was rendered on to the current render target
---
--- C definition: `void gs_present(void)`
function obslua.gs_present() end

--- Pops/restores the last projection matrix pushed
---
--- C definition: `void gs_projection_pop(void)`
function obslua.gs_projection_pop() end

--- Pushes/stores the current projection matrix
---
--- C definition: `void gs_projection_push(void)`
function obslua.gs_projection_push() end

--- C definition: `gs_vertbuffer_t *gs_render_save(void)`
--- @return gs_vertex_buffer
function obslua.gs_render_save() end

--- C definition: `void gs_render_start(bool b_new)`
--- @param b_new boolean
function obslua.gs_render_start(b_new) end

--- C definition: `void gs_render_stop(enum gs_draw_mode mode)`
--- @param mode number
function obslua.gs_render_stop(mode) end

--- Sets the blend state to the default value: source alpha and invert
--- source alpha.
---
--- C definition: `void gs_reset_blend_state(void)`
function obslua.gs_reset_blend_state() end

---  Sets the viewport to current swap chain size
---
--- C definition: `void gs_reset_viewport(void)`
function obslua.gs_reset_viewport() end

--- Resizes the currently active swap chain
---
--- :param cx: New width
--- :param cy: New height
---
--- C definition: `void gs_resize(uint32_t cx, uint32_t cy)`
--- @param cx number
--- @param cy number
function obslua.gs_resize(cx, cy) end

--- Creates a sampler state object.
---
--- :param info: Sampler state information
--- :return:     New sampler state object
---
--- C definition: `gs_samplerstate_t *gs_samplerstate_create(const struct gs_sampler_info *info)`
--- @param info gs_sampler_info
--- @return gs_sampler_state
function obslua.gs_samplerstate_create(info) end

--- Destroys a sampler state object.
---
--- :param samplerstate: Sampler state object
---
--- C definition: `void     gs_samplerstate_destroy(gs_samplerstate_t *samplerstate)`
--- @param samplerstate gs_sampler_state
function obslua.gs_samplerstate_destroy(samplerstate) end

---  Sets the projection matrix to a default screen-sized orthographic
---  mode
---
--- C definition: `void gs_set_2d_mode(void)`
function obslua.gs_set_2d_mode() end

---  Sets the projection matrix to a default screen-sized perspective
---  mode
---
---  :param fovy:  Field of view (in degrees)
---  :param znear: Near plane
---  :param zfar:  Far plane
---
--- C definition: `void gs_set_3d_mode(double fovy, double znear, double zfar)`
--- @param fovy number
--- @param znear number
--- @param zfar number
function obslua.gs_set_3d_mode(fovy, znear, zfar) end

--- Sets a cubemap side as the active render target
---
--- :param cubetex:  Cubemap
--- :param side:     Cubemap side
--- :param zstencil: Z-stencil buffer, or *NULL* if none
---
--- C definition: `void gs_set_cube_render_target(gs_texture_t *cubetex, int side, gs_zstencil_t *zstencil)`
--- @param cubetex gs_texture
--- @param side number
--- @param zstencil gs_zstencil_buffer
function obslua.gs_set_cube_render_target(cubetex, side, zstencil) end

--- Sets the current cull mode.
---
--- :param mode: Cull mode
---
--- C definition: `void gs_set_cull_mode(enum gs_cull_mode mode)`
--- @param mode number
function obslua.gs_set_cull_mode(mode) end

--- Sets the active render target
---
--- :param tex:      Texture to set as the active render target
--- :param zstencil: Z-stencil to use as the active render target
---
--- C definition: `void gs_set_render_target(gs_texture_t *tex, gs_zstencil_t *zstencil)`
--- @param tex gs_texture
--- @param zstencil gs_zstencil_buffer
function obslua.gs_set_render_target(tex, zstencil) end

--- Sets or clears the current scissor rectangle
---
--- :rect: Scissor rectangle, or *NULL* to clear
---
--- C definition: `void gs_set_scissor_rect(const struct gs_rect *rect)`
--- @param rect gs_rect
function obslua.gs_set_scissor_rect(rect) end

--- Sets the current viewport
---
--- :param x:      X position relative to upper left
--- :param y:      Y position relative to upper left
--- :param width:  Width of the viewport
--- :param height: Height of the viewport
---
--- C definition: `void gs_set_viewport(int x, int y, int width, int height)`
--- @param x number
--- @param y number
--- @param width number
--- @param height number
function obslua.gs_set_viewport(x, y, width, height) end

--- Copies a texture to a staging surface and copies it to RAM.  Ideally
--- best to give this a frame to process to prevent stalling.
---
--- :param dst: Staging surface
--- :param src: Texture to stage
---
--- C definition: `void gs_stage_texture(gs_stagesurf_t *dst, gs_texture_t *src)`
--- @param dst gs_stage_surface
--- @param src gs_texture
function obslua.gs_stage_texture(dst, src) end

--- Creates a staging surface.
---
--- :param width:        Width
--- :param height:       Height
--- :param color_format: Color format
--- :return:             The staging surface object
---
--- C definition: `gs_stagesurf_t *gs_stagesurface_create(uint32_t width, uint32_t height, enum gs_color_format color_format)`
--- @param width number
--- @param height number
--- @param color_format number
--- @return gs_stage_surface
function obslua.gs_stagesurface_create(width, height, color_format) end

--- Destroys a staging surface.
---
--- :param stagesurf: Staging surface object
---
--- C definition: `void     gs_stagesurface_destroy(gs_stagesurf_t *stagesurf)`
--- @param stagesurf gs_stage_surface
function obslua.gs_stagesurface_destroy(stagesurf) end

--- Gets the color format of a staging surface object.
---
--- :param stagesurf: Staging surface object
--- :return:          Color format of the staging surface
---
--- C definition: `enum gs_color_format gs_stagesurface_get_color_format(const gs_stagesurf_t *stagesurf)`
--- @param stagesurf gs_stage_surface
--- @return number
function obslua.gs_stagesurface_get_color_format(stagesurf) end

--- Gets the width/height of a staging surface object.
---
--- :param stagesurf: Staging surface object
--- :return:          Width/height of the staging surface
---
--- C definition: `uint32_t gs_stagesurface_get_height(const gs_stagesurf_t *stagesurf)`
--- @param stagesurf gs_stage_surface
--- @return number
function obslua.gs_stagesurface_get_height(stagesurf) end

--- Gets the width/height of a staging surface object.
---
--- :param stagesurf: Staging surface object
--- :return:          Width/height of the staging surface
---
--- C definition: `uint32_t gs_stagesurface_get_width(const gs_stagesurf_t *stagesurf)`
--- @param stagesurf gs_stage_surface
--- @return number
function obslua.gs_stagesurface_get_width(stagesurf) end

--- Maps the staging surface texture (for reading).  Call
--- :c:func:`gs_stagesurface_unmap()` to unmap when complete.
---
--- :param stagesurf: Staging surface object
--- :param data:      Pointer to receive texture data pointer
--- :param linesize:  Pointer to receive line size (pitch) of the texture
---                   data
--- :return:          *true* if map successful, *false* otherwise
---
--- C definition: `bool     gs_stagesurface_map(gs_stagesurf_t *stagesurf, uint8_t **data, uint32_t *linesize)`
--- @param stagesurf gs_stage_surface
--- @param data p_unsigned_char
--- @param linesize unsigned_int
--- @return boolean
function obslua.gs_stagesurface_map(stagesurf, data, linesize) end

--- Unmaps a staging surface.
---
--- :param stagesurf: Staging surface object
---
--- C definition: `void     gs_stagesurface_unmap(gs_stagesurf_t *stagesurf)`
--- @param stagesurf gs_stage_surface
function obslua.gs_stagesurface_unmap(stagesurf) end

--- Sets the stencil function
---
--- :param side: Stencil side
--- :param test: Depth test
---
--- C definition: `void gs_stencil_function(enum gs_stencil_side side, enum gs_depth_test test)`
--- @param side number
--- @param test number
function obslua.gs_stencil_function(side, test) end

--- Sets the stencil operation
---
--- :param side:  Stencil side
--- :param fail:  Operation to perform on stencil test failure
--- :param zfail: Operation to perform on depth test failure
--- :param zpass: Operation to perform on depth test success
---
--- C definition: `void gs_stencil_op(enum gs_stencil_side side, enum gs_stencil_op_type fail, enum gs_stencil_op_type zfail, enum gs_stencil_op_type zpass)`
--- @param side number
--- @param fail number
--- @param zfail number
--- @param zpass number
function obslua.gs_stencil_op(side, fail, zfail, zpass) end

--- Creates a swap chain (display view on a native widget)
---
--- :param data: Swap chain initialization data
--- :return:     New swap chain object, or *NULL* if failed
---
--- C definition: `gs_swapchain_t *gs_swapchain_create(const struct gs_init_data *data)`
--- @param data gs_init_data
--- @return gs_swap_chain
function obslua.gs_swapchain_create(data) end

--- Destroys a swap chain
---
--- C definition: `void     gs_swapchain_destroy(gs_swapchain_t *swapchain)`
--- @param swapchain gs_swap_chain
function obslua.gs_swapchain_destroy(swapchain) end

--- Begins a technique.
---
--- :param technique: Technique object
--- :return:          Number of passes this technique uses
---
--- C definition: `size_t gs_technique_begin(gs_technique_t *technique)`
--- @param technique gs_effect_technique
--- @return number
function obslua.gs_technique_begin(technique) end

--- Begins a pass.  Automatically loads the vertex/pixel shaders
--- associated with this pass.  Draw after calling this function.
---
--- :param technique: Technique object
--- :param pass:      Pass index
--- :return:          *true* if the pass is valid, *false* otherwise
---
--- C definition: `bool gs_technique_begin_pass(gs_technique_t *technique, size_t pass)`
--- @param technique gs_effect_technique
--- @param pass number
--- @return boolean
function obslua.gs_technique_begin_pass(technique, pass) end

--- Begins a pass by its name if the pass has a name.  Automatically
--- loads the vertex/pixel shaders associated with this pass.  Draw after
--- calling this function.
---
--- :param technique: Technique object
--- :param name:      Name of the pass
--- :return:          *true* if the pass is valid, *false* otherwise
---
--- C definition: `bool gs_technique_begin_pass_by_name(gs_technique_t *technique, const char *name)`
--- @param technique gs_effect_technique
--- @param name string
--- @return boolean
function obslua.gs_technique_begin_pass_by_name(technique, name) end

--- Ends a technique.  Make sure all active passes have been ended before
--- calling.
---
--- :param technique: Technique object
---
--- C definition: `void gs_technique_end(gs_technique_t *technique)`
--- @param technique gs_effect_technique
function obslua.gs_technique_end(technique) end

--- Ends a pass.
---
--- :param technique: Technique object
---
--- C definition: `void gs_technique_end_pass(gs_technique_t *technique)`
--- @param technique gs_effect_technique
function obslua.gs_technique_end_pass(technique) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_effect_technique
--- @param param2 number
function obslua.gs_technique_get_pass_by_idx(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_effect_technique
--- @param param2 string
function obslua.gs_technique_get_pass_by_name(param1, param2) end

--- C definition: `void gs_texcoord(float x, float y, int unit)`
--- @param x number
--- @param y number
--- @param unit number
function obslua.gs_texcoord(x, y, unit) end

--- C definition: `void gs_texcoord2v(const struct vec2 *v, int unit)`
--- @param v vec2
--- @param unit number
function obslua.gs_texcoord2v(v, unit) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture_render
--- @param param2 number
--- @param param3 number
function obslua.gs_texrender_begin(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 number
function obslua.gs_texrender_create(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture_render
function obslua.gs_texrender_destroy(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture_render
function obslua.gs_texrender_end(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture_render
function obslua.gs_texrender_get_texture(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture_render
function obslua.gs_texrender_reset(param1) end

--- Creates a texture.
---
--- :param width:        Width
--- :param height:       Height
--- :param color_format: Color format
--- :param levels:       Number of total texture levels.  Set to 1 if no
---                      mip-mapping
--- :param data:         Pointer to array of texture data pointers
--- :param flags:        Can be 0 or a bitwise-OR combination of one or
---                      more of the following value:
---
---                      - GS_BUILD_MIPMAPS - Automatically builds
---                        mipmaps (Note: not fully tested)
---                      - GS_DYNAMIC - Dynamic
---                      - GS_RENDER_TARGET - Render target
---
--- :return:             A new texture object
---
--- C definition: `gs_texture_t *gs_texture_create(uint32_t width, uint32_t height, enum gs_color_format color_format, uint32_t levels, const uint8_t **data, uint32_t flags)`
--- @param width number
--- @param height number
--- @param color_format number
--- @param levels number
--- @param data p_unsigned_char
--- @param flags number
--- @return gs_texture
function obslua.gs_texture_create(width, height, color_format, levels, data, flags) end

--- Creates a texture from a file.  Note that this isn't recommended for
--- animated gifs -- instead use the :ref:`image_file_helper`.
---
--- :param file: Image file to open
---
--- C definition: `gs_texture_t *gs_texture_create_from_file(const char *file)`
--- @param file string
--- @return gs_texture
function obslua.gs_texture_create_from_file(file) end

--- Destroys a texture
---
--- :param tex: Texture object
---
--- C definition: `void     gs_texture_destroy(gs_texture_t *tex)`
--- @param tex gs_texture
function obslua.gs_texture_destroy(tex) end

--- Gets the texture's color format
---
--- :param tex: Texture object
--- :return:    The texture's color format
---
--- C definition: `enum gs_color_format gs_texture_get_color_format(const gs_texture_t *tex)`
--- @param tex gs_texture
--- @return number
function obslua.gs_texture_get_color_format(tex) end

--- Gets the texture's height
---
--- :param tex: Texture object
--- :return:    The texture's height
---
--- C definition: `uint32_t gs_texture_get_height(const gs_texture_t *tex)`
--- @param tex gs_texture
--- @return number
function obslua.gs_texture_get_height(tex) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_texture_get_obj(param1) end

--- Gets the texture's width
---
--- :param tex: Texture object
--- :return:    The texture's width
---
--- C definition: `uint32_t gs_texture_get_width(const gs_texture_t *tex)`
--- @param tex gs_texture
--- @return number
function obslua.gs_texture_get_width(tex) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_texture_is_rect(param1) end

--- Maps a texture.
---
--- :param tex:      Texture object
--- :param ptr:      Pointer to receive the pointer to the texture data
---                  to write to
--- :param linesize: Pointer to receive the line size (pitch) of the
---                  texture
---
--- C definition: `bool     gs_texture_map(gs_texture_t *tex, uint8_t **ptr, uint32_t *linesize)`
--- @param tex gs_texture
--- @param ptr p_unsigned_char
--- @param linesize unsigned_int
--- @return boolean
function obslua.gs_texture_map(tex, ptr, linesize) end

--- Sets the image of a dynamic texture
---
--- :param tex:      Texture object
--- :param data:     Data to set as the image
--- :param linesize: Line size (pitch) of the data
--- :param invert:   *true* to invert vertically, *false* otherwise
---
--- C definition: `void gs_texture_set_image(gs_texture_t *tex, const uint8_t *data, uint32_t linesize, bool invert)`
--- @param tex gs_texture
--- @param data unsigned_char
--- @param linesize number
--- @param invert boolean
function obslua.gs_texture_set_image(tex, data, linesize, invert) end

--- Unmaps a texture.
---
--- :param tex: Texture object
---
--- C definition: `void     gs_texture_unmap(gs_texture_t *tex)`
--- @param tex gs_texture
function obslua.gs_texture_unmap(tex) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer
function obslua.gs_timer_begin(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_timer_create() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer
function obslua.gs_timer_destroy(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer
function obslua.gs_timer_end(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer
--- @param param2 unsigned_long_long
function obslua.gs_timer_get_data(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer_range
function obslua.gs_timer_range_begin(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_timer_range_create() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer_range
function obslua.gs_timer_range_destroy(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer_range
function obslua.gs_timer_range_end(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_timer_range
--- @param param2 bool
--- @param param3 unsigned_long_long
function obslua.gs_timer_range_get_data(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.gs_vbdata_create() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_vb_data
function obslua.gs_vbdata_destroy(param1) end

--- C definition: `void gs_vertex2f(float x, float y)`
--- @param x number
--- @param y number
function obslua.gs_vertex2f(x, y) end

--- C definition: `void gs_vertex2v(const struct vec2 *v)`
--- @param v vec2
function obslua.gs_vertex2v(v) end

--- C definition: `void gs_vertex3f(float x, float y, float z)`
--- @param x number
--- @param y number
--- @param z number
function obslua.gs_vertex3f(x, y, z) end

--- C definition: `void gs_vertex3v(const struct vec3 *v)`
--- @param v vec3
function obslua.gs_vertex3v(v) end

--- Creates a vertex buffer.
---
--- :param data:  Vertex buffer data to create vertex buffer with.  The
---               structure should be created with gs_vbdata_create(),
---               and then buffers in this structure should be allocated
---               with :c:func:`bmalloc()`, :c:func:`bzalloc()`, or
---               :c:func:`brealloc()`.  The ownership of the gs_vb_data
---               pointer is then passed to the function, and they should
---               not be destroyed by the caller once passed
---
--- :param flags: Creation flags.  Can be 0 or a bitwise-OR combination
---               of any of the following values:
---
---               - GS_DYNAMIC - Can be dynamically updated in real time.
---               - GS_DUP_BUFFER - Do not pass buffer ownership of the
---                 structure or the buffer pointers within the
---                 structure.
---
--- :return:      A new vertex buffer object, or *NULL* if failed
---
--- C definition: `gs_vertbuffer_t *gs_vertexbuffer_create(struct gs_vb_data *data, uint32_t flags)`
--- @param data gs_vb_data
--- @param flags number
--- @return gs_vertex_buffer
function obslua.gs_vertexbuffer_create(data, flags) end

--- Destroys a vertex buffer object.
---
--- :param vertbuffer: Vertex buffer object
---
--- C definition: `void     gs_vertexbuffer_destroy(gs_vertbuffer_t *vertbuffer)`
--- @param vertbuffer gs_vertex_buffer
function obslua.gs_vertexbuffer_destroy(vertbuffer) end

--- Flushes a vertex buffer to its interval vertex data object.  To
--- modify its internal vertex data, call
--- :c:func:`gs_vertexbuffer_get_data()`.
---
--- Can only be used with dynamic vertex buffer objects.
---
--- :param vertbuffer: Vertex buffer object
---
--- C definition: `void     gs_vertexbuffer_flush(gs_vertbuffer_t *vertbuffer)`
--- @param vertbuffer gs_vertex_buffer
function obslua.gs_vertexbuffer_flush(vertbuffer) end

--- Directly flushes a vertex buffer to the specified vertex buffer data.
--- .
---
--- Can only be used with dynamic vertex buffer objects.
---
--- :param vertbuffer: Vertex buffer object
--- :param data:       Vertex buffer data to flush.  Components that
---                    don't need to be flushed can be left *NULL*
---
--- C definition: `void     gs_vertexbuffer_flush_direct(gs_vertbuffer_t *vertbuffer, const struct gs_vb_data *data)`
--- @param vertbuffer gs_vertex_buffer
--- @param data gs_vb_data
function obslua.gs_vertexbuffer_flush_direct(vertbuffer, data) end

--- Gets the vertex buffer data associated with a vertex buffer object.
--- This data can be changed and vertex buffer can be updated with
--- :c:func:`gs_vertexbuffer_flush()`.
---
--- Can only be used with dynamic vertex buffer objects.
---
--- :param vertbuffer: Vertex buffer object
--- :return:           Vertex buffer data structure
---
--- C definition: `struct gs_vb_data *gs_vertexbuffer_get_data(const gs_vertbuffer_t *vertbuffer)`
--- @param vertbuffer gs_vertex_buffer
--- @return gs_vb_data
function obslua.gs_vertexbuffer_get_data(vertbuffer) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 string
--- @param param3 p_char
function obslua.gs_vertexshader_create(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 p_char
function obslua.gs_vertexshader_create_from_file(param1, param2) end

--- Pops/recalls the last pushed viewport
---
--- C definition: `void gs_viewport_pop(void)`
function obslua.gs_viewport_pop() end

--- Pushes/stores the current viewport
---
--- C definition: `void gs_viewport_push(void)`
function obslua.gs_viewport_push() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 number
--- @param param3 number
--- @param param4 number
--- @param param5 number
--- @param param6 p_unsigned_char
--- @param param7 number
function obslua.gs_voltexture_create(param1, param2, param3, param4, param5, param6, param7) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_voltexture_destroy(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_voltexture_get_color_format(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_voltexture_get_depth(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_voltexture_get_height(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 gs_texture
function obslua.gs_voltexture_get_width(param1) end

--- Creates a Z-stencil surface object.
---
--- :param width:  Width
--- :param height: Height
--- :param format: Format
--- :return:       New Z-stencil surface object, or *NULL* if failed
---
--- C definition: `gs_zstencil_t *gs_zstencil_create(uint32_t width, uint32_t height, enum gs_zstencil_format format)`
--- @param width number
--- @param height number
--- @param format number
--- @return gs_zstencil_buffer
function obslua.gs_zstencil_create(width, height, format) end

--- Destroys a Z-stencil buffer.
---
--- :param zstencil: Z-stencil surface object
---
--- C definition: `void     gs_zstencil_destroy(gs_zstencil_t *zstencil)`
--- @param zstencil gs_zstencil_buffer
function obslua.gs_zstencil_destroy(zstencil) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
function obslua.matrix3_copy(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 axisang
function obslua.matrix3_from_axisang(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix4
function obslua.matrix3_from_matrix4(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 quat
function obslua.matrix3_from_quat(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
function obslua.matrix3_identity(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
function obslua.matrix3_inv(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 plane
function obslua.matrix3_mirror(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 vec3
function obslua.matrix3_mirrorv(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 matrix3
function obslua.matrix3_mul(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 quat
function obslua.matrix3_rotate(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 axisang
function obslua.matrix3_rotate_aa(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 number
--- @param param4 number
--- @param param5 number
--- @param param6 number
function obslua.matrix3_rotate_aa4f(param1, param2, param3, param4, param5, param6) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 vec3
function obslua.matrix3_scale(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 number
--- @param param4 number
--- @param param5 number
function obslua.matrix3_scale3f(param1, param2, param3, param4, param5) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 vec3
function obslua.matrix3_translate(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
--- @param param3 number
--- @param param4 number
--- @param param5 number
function obslua.matrix3_translate3f(param1, param2, param3, param4, param5) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix3
--- @param param2 matrix3
function obslua.matrix3_transpose(param1, param2) end

--- Copies a matrix
---
--- :param dst: Destination matrix
--- :param m:   Matrix to copy
---
--- C definition: `void matrix4_copy(struct matrix4 *dst, const struct matrix4 *m)`
--- @param dst matrix4
--- @param m matrix4
function obslua.matrix4_copy(dst, m) end

--- Gets the determinant value of a matrix
---
--- :param m: Matrix
--- :return:  Determinant
---
--- C definition: `float matrix4_determinant(const struct matrix4 *m)`
--- @param m matrix4
--- @return number
function obslua.matrix4_determinant(m) end

--- Converts an axis angle to a matrix
---
--- :param dst: Destination matrix
--- :param aa:  Axis angle to convert
---
--- C definition: `void matrix4_from_axisang(struct matrix4 *dst, const struct axisang *aa)`
--- @param dst matrix4
--- @param aa axisang
function obslua.matrix4_from_axisang(dst, aa) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix4
--- @param param2 matrix3
function obslua.matrix4_from_matrix3(param1, param2) end

--- Converts a quaternion to a matrix
---
--- :param dst: Destination matrix
--- :param q:   Quaternion to convert
---
--- C definition: `void matrix4_from_quat(struct matrix4 *dst, const struct quat *q)`
--- @param dst matrix4
--- @param q quat
function obslua.matrix4_from_quat(dst, q) end

--- Sets an identity matrix
---
--- :param dst: Destination matrix
---
--- C definition: `void matrix4_identity(struct matrix4 *dst)`
--- @param dst matrix4
function obslua.matrix4_identity(dst) end

--- Inverts a matrix
---
--- :param dst: Destination matrix
--- :param m:   Matrix to invert
---
--- C definition: `bool matrix4_inv(struct matrix4 *dst, const struct matrix4 *m)`
--- @param dst matrix4
--- @param m matrix4
--- @return boolean
function obslua.matrix4_inv(dst, m) end

--- Multiples two matrices
---
--- :param dst: Destination matrix
--- :param m1:  Matrix 1
--- :param m2:  Matrix 2
---
--- C definition: `void matrix4_mul(struct matrix4 *dst, const struct matrix4 *m1, const struct matrix4 *m2)`
--- @param dst matrix4
--- @param m1 matrix4
--- @param m2 matrix4
function obslua.matrix4_mul(dst, m1, m2) end

--- Rotates a matrix by a quaternion
---
--- :param dst: Destination matrix
--- :param m:   Matrix to rotate
--- :param q:   Rotation quaternion
---
--- C definition: `void matrix4_rotate(struct matrix4 *dst, const struct matrix4 *m, const struct quat *q)`
--- @param dst matrix4
--- @param m matrix4
--- @param q quat
function obslua.matrix4_rotate(dst, m, q) end

--- Rotates a matrix by an axis angle
---
--- :param dst: Destination matrix
--- :param m:   Matrix to rotate
--- :param aa:  Rotation anxis angle
---
--- C definition: `void matrix4_rotate_aa(struct matrix4 *dst, const struct matrix4 *m, const struct axisang *aa)`
--- @param dst matrix4
--- @param m matrix4
--- @param aa axisang
function obslua.matrix4_rotate_aa(dst, m, aa) end

--- Rotates a matrix by an axis angle
---
--- :param dst: Destination matrix
--- :param m:   Matrix to rotate
--- :param aa:  Rotation anxis angle
---
--- C definition: `void matrix4_rotate_aa4f(struct matrix4 *dst, const struct matrix4 *m, float x, float y, float z, float rot)`
--- @param dst matrix4
--- @param m matrix4
--- @param x number
--- @param y number
--- @param z number
--- @param rot number
function obslua.matrix4_rotate_aa4f(dst, m, x, y, z, rot) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix4
--- @param param2 axisang
--- @param param3 matrix4
function obslua.matrix4_rotate_aa_i(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix4
--- @param param2 quat
--- @param param3 matrix4
function obslua.matrix4_rotate_i(param1, param2, param3) end

--- Scales each matrix component by the components of a 3-component vector
---
--- :param dst: Destination matrix
--- :param m:   Matrix to scale
--- :param v:   Scale vector
---
--- C definition: `void matrix4_scale(struct matrix4 *dst, const struct matrix4 *m, const struct vec3 *v)`
--- @param dst matrix4
--- @param m matrix4
--- @param v vec3
function obslua.matrix4_scale(dst, m, v) end

--- Scales each matrix component by the components of a 3-component vector
---
--- :param dst: Destination matrix
--- :param m:   Matrix to scale
--- :param v:   Scale vector
---
--- C definition: `void matrix4_scale3f(struct matrix4 *dst, const struct matrix4 *m, float x, float y, float z)`
--- @param dst matrix4
--- @param m matrix4
--- @param x number
--- @param y number
--- @param z number
function obslua.matrix4_scale3f(dst, m, x, y, z) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix4
--- @param param2 vec3
--- @param param3 matrix4
function obslua.matrix4_scale_i(param1, param2, param3) end

--- Translates the matrix by a 3-component vector
---
--- :param dst: Destination matrix
--- :param m:   Matrix to translate
--- :param v:   Translation vector
---
--- C definition: `void matrix4_translate3f(struct matrix4 *dst, const struct matrix4 *m, float x, float y, float z)`
--- @param dst matrix4
--- @param m matrix4
--- @param x number
--- @param y number
--- @param z number
function obslua.matrix4_translate3f(dst, m, x, y, z) end

--- Translates the matrix by a 3-component vector
---
--- :param dst: Destination matrix
--- :param m:   Matrix to translate
--- :param v:   Translation vector
---
--- C definition: `void matrix4_translate3v(struct matrix4 *dst, const struct matrix4 *m, const struct vec3 *v)`
--- @param dst matrix4
--- @param m matrix4
--- @param v vec3
function obslua.matrix4_translate3v(dst, m, v) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix4
--- @param param2 vec3
--- @param param3 matrix4
function obslua.matrix4_translate3v_i(param1, param2, param3) end

--- Translates the matrix by a 4-component vector
---
--- :param dst: Destination matrix
--- :param m:   Matrix to translate
--- :param v:   Translation vector
---
--- C definition: `void matrix4_translate4v(struct matrix4 *dst, const struct matrix4 *m, const struct vec4 *v)`
--- @param dst matrix4
--- @param m matrix4
--- @param v vec4
function obslua.matrix4_translate4v(dst, m, v) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 matrix4
--- @param param2 vec4
--- @param param3 matrix4
function obslua.matrix4_translate4v_i(param1, param2, param3) end

--- Transposes a matrix
---
--- :param dst: Destination matrix
--- :param m:   Matrix to transpose
--- C definition: `void matrix4_transpose(struct matrix4 *dst, const struct matrix4 *m)`
--- @param dst matrix4
--- @param m matrix4
function obslua.matrix4_transpose(dst, m) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_add_data_path(param1) end

--- **Lua only:** Adds a primary output render callback.  This callback
--- has no parameters.
---
--- :param callback: Render callback.  Use
---                  :py:func:`obs_remove_main_render_callback()` or
---                  :py:func:`remove_current_callback()` to remove the
---                  callback.
---
--- C definition: Not available
--- @param callback unknown
--- @return unknown
function obslua.obs_add_main_render_callback(callback) end

--- Adds a module search path to be used with obs_find_modules.  If the search
--- path strings contain %module%, that text will be replaced with the module
--- name when used.
---
--- :param  bin:  Specifies the module's binary directory search path
--- :param  data: Specifies the module's data directory search path
---
--- C definition: `void obs_add_module_path(const char *bin, const char *data)`
--- @param bin string
--- @param data string
function obslua.obs_add_module_path(bin, data) end

--- Adds/removes a raw video callback.  Allows the ability to obtain raw
--- video frames without necessarily using an output.
---
--- :param conversion: Specifies conversion requirements.  Can be NULL.
--- :param callback:   The callback that receives raw video frames.
--- :param param:      The private data associated with the callback.
---
--- Primary signal/procedure handlers
--- C definition: `void obs_add_raw_video_callback(const struct video_scale_info *conversion, void (*callback)(void *param, struct video_data *frame), void *param)`
--- @param conversion video_scale_info
--- @param callback f_p_void_p_struct_video_data__void
--- @param param ref_void*
function obslua.obs_add_raw_video_callback(conversion, callback, param) end

--- obs_add_tick_callback not found in OBS documentation nor C wrapper
obslua.obs_add_tick_callback = function() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
function obslua.obs_apply_private_data(param1) end

--- Creates an audio encoder with the specified settings.
---
--- The "encoder" context is used for encoding video/audio data.  Use
--- :c:func:`obs_encoder_release()` to release it.
---
--- :param   id:             The encoder type string identifier
--- :param   name:           The desired name of the encoder.  If this is
---                          not unique, it will be made to be unique
--- :param   settings:       The settings for the encoder, or *NULL* if
---                          none
--- :param   mixer_idx:      The audio mixer index this audio encoder
---                          will capture audio from
--- :param   hotkey_data:    Saved hotkey data for the encoder, or *NULL*
---                          if none
--- :return:                 A reference to the newly created encoder, or
---                          *NULL* if failed
---
--- C definition: `obs_encoder_t *obs_audio_encoder_create(const char *id, const char *name, obs_data_t *settings, size_t mixer_idx, obs_data_t *hotkey_data)`
--- @param id string
--- @param name string
--- @param settings obs_data
--- @param mixer_idx number
--- @param hotkey_data obs_data
--- @return obs_encoder
function obslua.obs_audio_encoder_create(id, name, settings, mixer_idx, hotkey_data) end

--- Adds/releases a reference to a data object.
---
--- C definition: `void obs_data_addref(obs_data_t *data)`
--- @param data obs_data
function obslua.obs_data_addref(data) end

--- Merges the data of *apply_data* in to *target*.
---
--- C definition: `void obs_data_apply(obs_data_t *target, obs_data_t *apply_data)`
--- @param target obs_data
--- @param apply_data obs_data
function obslua.obs_data_apply(target, apply_data) end

--- C definition: `void obs_data_array_addref(obs_data_array_t *array)`
--- @param array obs_data_array
function obslua.obs_data_array_addref(array) end

--- C definition: `size_t obs_data_array_count(obs_data_array_t *array)`
--- @param array obs_data_array
--- @return number
function obslua.obs_data_array_count(array) end

--- :return: A new reference to a data array object.
---
--- C definition: `obs_data_array_t *obs_data_array_create()`
--- @return obs_data_array
function obslua.obs_data_array_create() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_array
--- @param param2 number
function obslua.obs_data_array_erase(param1, param2) end

--- C definition: `void obs_data_array_insert(obs_data_array_t *array, size_t idx, obs_data_t *obj)`
--- @param array obs_data_array
--- @param idx number
--- @param obj obs_data
function obslua.obs_data_array_insert(array, idx, obj) end

--- :return: An incremented reference to the data object associated with
---          this array entry.
---
--- C definition: `obs_data_t *obs_data_array_item(obs_data_array_t *array, size_t idx)`
--- @param array obs_data_array
--- @param idx number
--- @return obs_data
function obslua.obs_data_array_item(array, idx) end

--- C definition: `size_t obs_data_array_push_back(obs_data_array_t *array, obs_data_t *obj)`
--- @param array obs_data_array
--- @param obj obs_data
--- @return number
function obslua.obs_data_array_push_back(array, obj) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_array
--- @param param2 obs_data_array
function obslua.obs_data_array_push_back_array(param1, param2) end

--- C definition: `void obs_data_array_release(obs_data_array_t *array)`
--- @param array obs_data_array
function obslua.obs_data_array_release(array) end

--- Clears all user data in the data object.
---
--- C definition: `void obs_data_clear(obs_data_t *data)`
--- @param data obs_data
function obslua.obs_data_clear(data) end

--- :return: A new reference to a data object.
---
--- C definition: `obs_data_t *obs_data_create()`
--- @return obs_data
function obslua.obs_data_create() end

--- Creates a data object from a Json string.
---
--- :param json_string: Json string
--- :return:            A new reference to a data object
---
--- C definition: `obs_data_t *obs_data_create_from_json(const char *json_string)`
--- @param json_string string
--- @return obs_data
function obslua.obs_data_create_from_json(json_string) end

--- Creates a data object from a Json file.
---
--- :param json_file: Json file path
--- :return:          A new reference to a data object
---
--- C definition: `obs_data_t *obs_data_create_from_json_file(const char *json_file)`
--- @param json_file string
--- @return obs_data
function obslua.obs_data_create_from_json_file(json_file) end

--- Creates a data object from a Json file, with a backup file in case
--- the original is corrupted or fails to load.
---
--- :param json_file:  Json file path
--- :param backup_ext: Backup file extension
--- :return:           A new reference to a data object
---
--- C definition: `obs_data_t *obs_data_create_from_json_file_safe(const char *json_file, const char *backup_ext)`
--- @param json_file string
--- @param backup_ext string
--- @return obs_data
function obslua.obs_data_create_from_json_file_safe(json_file, backup_ext) end

--- Erases the user data for item *name* within the data object.
---
--- C definition: `void obs_data_erase(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
function obslua.obs_data_erase(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
function obslua.obs_data_first(param1) end

--- :return: An incremented reference to a data array object.
---
--- C definition: `obs_data_array_t *obs_data_get_array(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return obs_data_array
function obslua.obs_data_get_array(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_get_autoselect_array(param1, param2) end

--- C definition: `bool obs_data_get_autoselect_bool(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return boolean
function obslua.obs_data_get_autoselect_bool(data, name) end

--- C definition: `double obs_data_get_autoselect_double(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return number
function obslua.obs_data_get_autoselect_double(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 media_frames_per_second
--- @param param4 p_char
function obslua.obs_data_get_autoselect_frames_per_second(param1, param2, param3, param4) end

--- C definition: `long long obs_data_get_autoselect_int(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return number
function obslua.obs_data_get_autoselect_int(data, name) end

--- :return: An incremented reference to a data object.
---
--- C definition: `obs_data_t *obs_data_get_autoselect_obj(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return obs_data
function obslua.obs_data_get_autoselect_obj(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 quat
function obslua.obs_data_get_autoselect_quat(param1, param2, param3) end

--- C definition: `const char *obs_data_get_autoselect_string(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return string
function obslua.obs_data_get_autoselect_string(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec2
function obslua.obs_data_get_autoselect_vec2(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec3
function obslua.obs_data_get_autoselect_vec3(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec4
function obslua.obs_data_get_autoselect_vec4(param1, param2, param3) end

--- C definition: `bool obs_data_get_bool(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return boolean
function obslua.obs_data_get_bool(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_get_default_array(param1, param2) end

--- C definition: `bool obs_data_get_default_bool(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return boolean
function obslua.obs_data_get_default_bool(data, name) end

--- C definition: `double obs_data_get_default_double(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return number
function obslua.obs_data_get_default_double(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 media_frames_per_second
--- @param param4 p_char
function obslua.obs_data_get_default_frames_per_second(param1, param2, param3, param4) end

--- C definition: `long long obs_data_get_default_int(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return number
function obslua.obs_data_get_default_int(data, name) end

--- :return: An incremented reference to a data object.
---
--- C definition: `obs_data_t *obs_data_get_default_obj(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return obs_data
function obslua.obs_data_get_default_obj(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 quat
function obslua.obs_data_get_default_quat(param1, param2, param3) end

--- C definition: `const char *obs_data_get_default_string(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return string
function obslua.obs_data_get_default_string(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec2
function obslua.obs_data_get_default_vec2(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec3
function obslua.obs_data_get_default_vec3(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec4
function obslua.obs_data_get_default_vec4(param1, param2, param3) end

--- C definition: `double obs_data_get_double(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return number
function obslua.obs_data_get_double(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 media_frames_per_second
--- @param param4 p_char
function obslua.obs_data_get_frames_per_second(param1, param2, param3, param4) end

--- C definition: `long long obs_data_get_int(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return number
function obslua.obs_data_get_int(data, name)
    return tonumber(data[name])
end

--- :return: Json string for this object
---
--- C definition: `const char *obs_data_get_json(obs_data_t *data)`
--- @param data obs_data
--- @return string
function obslua.obs_data_get_json(data) end

--- :return: An incremented reference to a data object.
---
--- C definition: `obs_data_t *obs_data_get_obj(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return obs_data
function obslua.obs_data_get_obj(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 quat
function obslua.obs_data_get_quat(param1, param2, param3) end

--- C definition: `const char *obs_data_get_string(obs_data_t *data, const char *name)`
--- @param data obs_data
--- @param name string
--- @return string
function obslua.obs_data_get_string(data, name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec2
function obslua.obs_data_get_vec2(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec3
function obslua.obs_data_get_vec3(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec4
function obslua.obs_data_get_vec4(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_has_autoselect_value(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_has_default_value(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_has_user_value(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_item_byname(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_array(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_autoselect_array(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_autoselect_bool(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_autoselect_double(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
--- @param param2 media_frames_per_second
--- @param param3 p_char
function obslua.obs_data_item_get_autoselect_frames_per_second(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_autoselect_int(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_autoselect_obj(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_autoselect_string(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_bool(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_default_array(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_default_bool(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_default_double(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
--- @param param2 media_frames_per_second
--- @param param3 p_char
function obslua.obs_data_item_get_default_frames_per_second(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_default_int(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_default_obj(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_default_string(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_double(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
--- @param param2 media_frames_per_second
--- @param param3 p_char
function obslua.obs_data_item_get_frames_per_second(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_int(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_name(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_obj(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_get_string(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_gettype(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_has_autoselect_value(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_has_default_value(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_has_user_value(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
function obslua.obs_data_item_next(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_numtype(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
function obslua.obs_data_item_release(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
function obslua.obs_data_item_remove(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 obs_data_array
function obslua.obs_data_item_set_array(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 obs_data_array
function obslua.obs_data_item_set_autoselect_array(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 boolean
function obslua.obs_data_item_set_autoselect_bool(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 number
function obslua.obs_data_item_set_autoselect_double(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 media_frames_per_second
--- @param param3 string
function obslua.obs_data_item_set_autoselect_frames_per_second(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 number
function obslua.obs_data_item_set_autoselect_int(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 obs_data
function obslua.obs_data_item_set_autoselect_obj(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 string
function obslua.obs_data_item_set_autoselect_string(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 boolean
function obslua.obs_data_item_set_bool(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 obs_data_array
function obslua.obs_data_item_set_default_array(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 boolean
function obslua.obs_data_item_set_default_bool(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 number
function obslua.obs_data_item_set_default_double(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 media_frames_per_second
--- @param param3 string
function obslua.obs_data_item_set_default_frames_per_second(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 number
function obslua.obs_data_item_set_default_int(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 obs_data
function obslua.obs_data_item_set_default_obj(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 string
function obslua.obs_data_item_set_default_string(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 number
function obslua.obs_data_item_set_double(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 media_frames_per_second
--- @param param3 string
function obslua.obs_data_item_set_frames_per_second(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 number
function obslua.obs_data_item_set_int(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 obs_data
function obslua.obs_data_item_set_obj(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 p_obs_data_item
--- @param param2 string
function obslua.obs_data_item_set_string(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_unset_autoselect_value(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_unset_default_value(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data_item
function obslua.obs_data_item_unset_user_value(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
function obslua.obs_data_newref(param1) end

--- Adds/releases a reference to a data object.
---
--- C definition: `void obs_data_release(obs_data_t *data)`
--- @param data obs_data
function obslua.obs_data_release(data) end

--- Saves the data to a file as Json text.
---
--- :param file: The file to save to
--- :return:     *true* if successful, *false* otherwise
---
--- C definition: `bool obs_data_save_json(obs_data_t *data, const char *file)`
--- @param data obs_data
--- @param file string
--- @return boolean
function obslua.obs_data_save_json(data, file) end

--- Saves the data to a file as Json text, and if overwriting an old
--- file, backs up that old file to help prevent potential file
--- corruption.
---
--- :param file:       The file to save to
--- :param backup_ext: The backup extension to use for the overwritten
---                    file if it exists
--- :return:           *true* if successful, *false* otherwise
---
--- C definition: `bool obs_data_save_json_safe(obs_data_t *data, const char *file, const char *temp_ext, const char *backup_ext)`
--- @param data obs_data
--- @param file string
--- @param temp_ext string
--- @param backup_ext string
--- @return boolean
function obslua.obs_data_save_json_safe(data, file, temp_ext, backup_ext) end

--- C definition: `void obs_data_set_array(obs_data_t *data, const char *name, obs_data_array_t *array)`
--- @param data obs_data
--- @param name string
--- @param array obs_data_array
function obslua.obs_data_set_array(data, name, array) end

--- C definition: `void obs_data_set_autoselect_bool(obs_data_t *data, const char *name, bool val)`
--- @param data obs_data
--- @param name string
--- @param val boolean
function obslua.obs_data_set_autoselect_bool(data, name, val) end

--- C definition: `void obs_data_set_autoselect_double(obs_data_t *data, const char *name, double val)`
--- @param data obs_data
--- @param name string
--- @param val number
function obslua.obs_data_set_autoselect_double(data, name, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 media_frames_per_second
--- @param param4 string
function obslua.obs_data_set_autoselect_frames_per_second(param1, param2, param3, param4) end

--- C definition: `void obs_data_set_autoselect_int(obs_data_t *data, const char *name, long long val)`
--- @param data obs_data
--- @param name string
--- @param val number
function obslua.obs_data_set_autoselect_int(data, name, val) end

--- :return: An incremented reference to a data object.
---
--- C definition: `void obs_data_set_autoselect_obj(obs_data_t *data, const char *name, obs_data_t *obj)`
--- @param data obs_data
--- @param name string
--- @param obj obs_data
function obslua.obs_data_set_autoselect_obj(data, name, obj) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 quat
function obslua.obs_data_set_autoselect_quat(param1, param2, param3) end

--- C definition: `void obs_data_set_autoselect_string(obs_data_t *data, const char *name, const char *val)`
--- @param data obs_data
--- @param name string
--- @param val string
function obslua.obs_data_set_autoselect_string(data, name, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec2
function obslua.obs_data_set_autoselect_vec2(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec3
function obslua.obs_data_set_autoselect_vec3(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec4
function obslua.obs_data_set_autoselect_vec4(param1, param2, param3) end

--- C definition: `void obs_data_set_bool(obs_data_t *data, const char *name, bool val)`
--- @param data obs_data
--- @param name string
--- @param val boolean
function obslua.obs_data_set_bool(data, name, val) end

--- C definition: `void obs_data_set_default_bool(obs_data_t *data, const char *name, bool val)`
--- @param data obs_data
--- @param name string
--- @param val boolean
function obslua.obs_data_set_default_bool(data, name, val) end

--- C definition: `void obs_data_set_default_double(obs_data_t *data, const char *name, double val)`
--- @param data obs_data
--- @param name string
--- @param val number
function obslua.obs_data_set_default_double(data, name, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 media_frames_per_second
--- @param param4 string
function obslua.obs_data_set_default_frames_per_second(param1, param2, param3, param4) end

--- C definition: `void obs_data_set_default_int(obs_data_t *data, const char *name, long long val)`
--- @param data obs_data
--- @param name string
--- @param val number
function obslua.obs_data_set_default_int(data, name, val) end

--- :return: An incremented reference to a data object.
---
--- C definition: `void obs_data_set_default_obj(obs_data_t *data, const char *name, obs_data_t *obj)`
--- @param data obs_data
--- @param name string
--- @param obj obs_data
function obslua.obs_data_set_default_obj(data, name, obj) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 quat
function obslua.obs_data_set_default_quat(param1, param2, param3) end

--- C definition: `void obs_data_set_default_string(obs_data_t *data, const char *name, const char *val)`
--- @param data obs_data
--- @param name string
--- @param val string
function obslua.obs_data_set_default_string(data, name, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec2
function obslua.obs_data_set_default_vec2(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec3
function obslua.obs_data_set_default_vec3(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec4
function obslua.obs_data_set_default_vec4(param1, param2, param3) end

--- C definition: `void obs_data_set_double(obs_data_t *data, const char *name, double val)`
--- @param data obs_data
--- @param name string
--- @param val number
function obslua.obs_data_set_double(data, name, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 media_frames_per_second
--- @param param4 string
function obslua.obs_data_set_frames_per_second(param1, param2, param3, param4) end

--- C definition: `void obs_data_set_int(obs_data_t *data, const char *name, long long val)`
--- @param data obs_data
--- @param name string
--- @param val number
function obslua.obs_data_set_int(data, name, val) end

--- C definition: `void obs_data_set_obj(obs_data_t *data, const char *name, obs_data_t *obj)`
--- @param data obs_data
--- @param name string
--- @param obj obs_data
function obslua.obs_data_set_obj(data, name, obj) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 quat
function obslua.obs_data_set_quat(param1, param2, param3) end

--- C definition: `void obs_data_set_string(obs_data_t *data, const char *name, const char *val)`
--- @param data obs_data
--- @param name string
--- @param val string
function obslua.obs_data_set_string(data, name, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec2
function obslua.obs_data_set_vec2(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec3
function obslua.obs_data_set_vec3(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
--- @param param3 vec4
function obslua.obs_data_set_vec4(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_unset_autoselect_value(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_unset_default_value(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
--- @param param2 string
function obslua.obs_data_unset_user_value(param1, param2) end

--- Adds a draw callback for a display context, which will be called
--- whenever the display is rendered.
---
--- :param  display: The display context
--- :param  draw:    The draw callback which is called each time a frame
---                  updates
--- :param  param:   The user data to be associated with this draw callback
---
--- C definition: `void obs_display_add_draw_callback(obs_display_t *display, void (*draw)(void *param, uint32_t cx, uint32_t cy), void *param)`
--- @param display obs_display
--- @param draw f_p_void_unsigned_int_unsigned_int__void
--- @param param ref_void*
function obslua.obs_display_add_draw_callback(display, draw, param) end

--- Adds a new window display linked to the main render pipeline.  This creates
--- a new swap chain which updates every frame.
---
--- *(Important note: do not use more than one display widget within the
--- hierarchy of the same base window; this will cause presentation
--- stalls on Macs.)*
---
--- :param  graphics_data: The swap chain initialization data
--- :return:               The new display context, or NULL if failed
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- enum gs_color_format {
---         [...]
---         GS_RGBA,
---         GS_BGRX,
---         GS_BGRA,
---         GS_RGBA16F,
---         GS_RGBA32F,
---         [...]
--- };
---
--- enum gs_zstencil_format {
---         GS_ZS_NONE,
---         GS_Z16,
---         GS_Z24_S8,
---         GS_Z32F,
---         GS_Z32F_S8X24
--- };
---
--- struct gs_window {
--- #if defined(_WIN32)
---         void                    *hwnd;
--- #elif defined(__APPLE__)
---         __unsafe_unretained id  view;
--- #elif defined(__linux__) || defined(__FreeBSD__)
---         uint32_t                id;
---         void                    *display;
--- #endif
--- };
---
--- struct gs_init_data {
---         struct gs_window        window;
---         uint32_t                cx, cy;
---         uint32_t                num_backbuffers;
---         enum gs_color_format    format;
---         enum gs_zstencil_format zsformat;
---         uint32_t                adapter;
--- };
---
--- C definition: `obs_display_t *obs_display_create(const struct gs_init_data *graphics_data)`
--- @param graphics_data gs_init_data
--- @param param2 number
--- @return obs_display
function obslua.obs_display_create(graphics_data, param2) end

--- Destroys a display context.
---
--- C definition: `void obs_display_destroy(obs_display_t *display)`
--- @param display obs_display
function obslua.obs_display_destroy(display) end

--- :return: *true* if the display is enabled, *false* otherwise
---
--- C definition: `bool obs_display_enabled(obs_display_t *display)`
--- @param display obs_display
--- @return boolean
function obslua.obs_display_enabled(display) end

--- Removes a draw callback for a display context.
---
--- C definition: `void obs_display_remove_draw_callback(obs_display_t *display, void (*draw)(void *param, uint32_t cx, uint32_t cy), void *param)`
--- @param display obs_display
--- @param draw f_p_void_unsigned_int_unsigned_int__void
--- @param param ref_void*
function obslua.obs_display_remove_draw_callback(display, draw, param) end

--- Changes the size of a display context.
---
--- C definition: `void obs_display_resize(obs_display_t *display, uint32_t cx, uint32_t cy)`
--- @param display obs_display
--- @param cx number
--- @param cy number
function obslua.obs_display_resize(display, cx, cy) end

--- Sets the background (clear) color for the display context.
--- C definition: `void obs_display_set_background_color(obs_display_t *display, uint32_t color)`
--- @param display obs_display
--- @param color number
function obslua.obs_display_set_background_color(display, color) end

--- Enables/disables a display context.
---
--- C definition: `void obs_display_set_enabled(obs_display_t *display, bool enable)`
--- @param display obs_display
--- @param enable boolean
function obslua.obs_display_set_enabled(display, enable) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_display
--- @param param2 unsigned_int
--- @param param3 unsigned_int
function obslua.obs_display_size(param1, param2, param3) end

--- :return: *true* if the encoder is active, *false* otherwise
---
--- C definition: `bool obs_encoder_active(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return boolean
function obslua.obs_encoder_active(encoder) end

--- Adds/releases a reference to an encoder.  When the last reference is
--- released, the encoder is destroyed.
---
--- C definition: `void obs_encoder_addref(obs_encoder_t *encoder)`
--- @param encoder obs_encoder
function obslua.obs_encoder_addref(encoder) end

--- :return: The video/audio handler associated with this encoder, or
---          *NULL* if none or not a matching encoder type
---
--- C definition: `audio_t *obs_encoder_audio(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return audio_t
function obslua.obs_encoder_audio(encoder) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
--- @param param2 string
function obslua.obs_encoder_create_rerouted(param1, param2) end

--- :return: An incremented reference to the encoder's default settings
---
--- C definition: `obs_data_t *obs_encoder_defaults(const char *id)`
--- @param id string
--- @return obs_data
function obslua.obs_encoder_defaults(id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
function obslua.obs_encoder_get_caps(param1) end

--- :return: The codec identifier of the encoder
---
--- C definition: `const char *obs_encoder_get_codec(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return string
function obslua.obs_encoder_get_codec(encoder) end

--- :return: An incremented reference to the encoder's default settings
---
--- C definition: `obs_data_t *obs_encoder_get_defaults(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return obs_data
function obslua.obs_encoder_get_defaults(encoder) end

--- Calls the :c:member:`obs_encoder_info.get_name` callback to get the
--- translated display name of an encoder type.
---
--- :param    id:            The encoder type string identifier
--- :return:                 The translated display name of an encoder type
---
--- C definition: `const char *obs_encoder_get_display_name(const char *id)`
--- @param id string
--- @return string
function obslua.obs_encoder_get_display_name(id) end

--- Gets extra data (headers) associated with this encoder.
---
--- :return: *true* if successful, *false* if no extra data associated
---          with this encoder
---
--- C definition: `bool obs_encoder_get_extra_data(const obs_encoder_t *encoder, uint8_t **extra_data, size_t *size)`
--- @param encoder obs_encoder
--- @param extra_data p_unsigned_char
--- @param size size_t
--- @return boolean
function obslua.obs_encoder_get_extra_data(encoder, extra_data, size) end

--- :return: The width/height of a video encoder's encoded image
---
--- C definition: `uint32_t obs_encoder_get_height(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return number
function obslua.obs_encoder_get_height(encoder) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
function obslua.obs_encoder_get_id(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
function obslua.obs_encoder_get_last_error(param1) end

--- :return: The name of the encoder
---
--- C definition: `const char *obs_encoder_get_name(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return string
function obslua.obs_encoder_get_name(encoder) end

--- Sets the preferred video format for a video encoder.  If the encoder can use
--- the format specified, it will force a conversion to that format if the
--- obs output format does not match the preferred format.
---
--- If the format is set to VIDEO_FORMAT_NONE, will revert to the default
--- functionality of converting only when absolutely necessary.
---
--- C definition: `enum video_format obs_encoder_get_preferred_video_format(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return number
function obslua.obs_encoder_get_preferred_video_format(encoder) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
function obslua.obs_encoder_get_ref(param1) end

--- :return: The sample rate of an audio encoder's audio data
---
--- C definition: `uint32_t obs_encoder_get_sample_rate(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return number
function obslua.obs_encoder_get_sample_rate(encoder) end

--- :return: An incremented reference to the encoder's settings
---
--- C definition: `obs_data_t *obs_encoder_get_settings(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return obs_data
function obslua.obs_encoder_get_settings(encoder) end

--- :return: The encoder type: OBS_ENCODER_VIDEO or OBS_ENCODER_AUDIO
---
--- C definition: `enum obs_encoder_type obs_encoder_get_type(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return number
function obslua.obs_encoder_get_type(encoder) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
function obslua.obs_encoder_get_type_data(param1) end

--- These functions are used to get a weak reference from a strong encoder
--- reference, or a strong encoder reference from a weak reference.  If
--- the encoder is destroyed, *obs_weak_encoder_get_encoder* will return
--- *NULL*.
---
--- C definition: `obs_weak_encoder_t *obs_encoder_get_weak_encoder(obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return obs_weak_encoder
function obslua.obs_encoder_get_weak_encoder(encoder) end

--- :return: The width/height of a video encoder's encoded image
---
--- C definition: `uint32_t obs_encoder_get_width(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return number
function obslua.obs_encoder_get_width(encoder) end

--- Adds or releases a reference to an encoder packet.
---
--- .. ---------------------------------------------------------------------------
---
--- .. _libobs/obs-encoder.h: https://github.com/jp9000/obs-studio/blob/master/libobs/obs-encoder.h
--- C definition: `void obs_encoder_packet_ref(struct encoder_packet *dst, struct encoder_packet *src)`
--- @param dst encoder_packet
--- @param src encoder_packet
function obslua.obs_encoder_packet_ref(dst, src) end

--- Adds or releases a reference to an encoder packet.
---
--- .. ---------------------------------------------------------------------------
---
--- .. _libobs/obs-encoder.h: https://github.com/jp9000/obs-studio/blob/master/libobs/obs-encoder.h
--- C definition: `void obs_encoder_packet_release(struct encoder_packet *packet)`
--- @param packet encoder_packet
function obslua.obs_encoder_packet_release(packet) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
function obslua.obs_encoder_paused(param1) end

--- Use these functions to get the properties of an encoder or encoder
--- type.  Properties are optionally used (if desired) to automatically
--- generate user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing encoder.  Free
---          with :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_encoder_properties(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return obs_properties
function obslua.obs_encoder_properties(encoder) end

--- Adds/releases a reference to an encoder.  When the last reference is
--- released, the encoder is destroyed.
---
--- C definition: `void obs_encoder_release(obs_encoder_t *encoder)`
--- @param encoder obs_encoder
function obslua.obs_encoder_release(encoder) end

--- :return: *true* if pre-encode (CPU) scaling enabled, *false*
---          otherwise.
---
--- C definition: `bool obs_encoder_scaling_enabled(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return boolean
function obslua.obs_encoder_scaling_enabled(encoder) end

--- Sets the video/audio handler to use with this video/audio encoder.
--- This is used to capture the raw video/audio data.
---
--- C definition: `void obs_encoder_set_audio(obs_encoder_t *encoder, audio_t *audio)`
--- @param encoder obs_encoder
--- @param audio audio_t
function obslua.obs_encoder_set_audio(encoder, audio) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
--- @param param2 string
function obslua.obs_encoder_set_last_error(param1, param2) end

--- Sets the name of an encoder.  If the encoder is not private and the
--- name is not unique, it will automatically be given a unique name.
---
--- C definition: `void obs_encoder_set_name(obs_encoder_t *encoder, const char *name)`
--- @param encoder obs_encoder
--- @param name string
function obslua.obs_encoder_set_name(encoder, name) end

--- Sets the preferred video format for a video encoder.  If the encoder can use
--- the format specified, it will force a conversion to that format if the
--- obs output format does not match the preferred format.
---
--- If the format is set to VIDEO_FORMAT_NONE, will revert to the default
--- functionality of converting only when absolutely necessary.
---
--- C definition: `void obs_encoder_set_preferred_video_format(obs_encoder_t *encoder, enum video_format format)`
--- @param encoder obs_encoder
--- @param format number
function obslua.obs_encoder_set_preferred_video_format(encoder, format) end

--- Sets the scaled resolution for a video encoder.  Set width and height to 0
--- to disable scaling.  If the encoder is active, this function will trigger
--- a warning, and do nothing.
---
--- C definition: `void obs_encoder_set_scaled_size(obs_encoder_t *encoder, uint32_t width, uint32_t height)`
--- @param encoder obs_encoder
--- @param width number
--- @param height number
function obslua.obs_encoder_set_scaled_size(encoder, width, height) end

--- Sets the video/audio handler to use with this video/audio encoder.
--- This is used to capture the raw video/audio data.
---
--- C definition: `void obs_encoder_set_video(obs_encoder_t *encoder, video_t *video)`
--- @param encoder obs_encoder
--- @param video video_t
function obslua.obs_encoder_set_video(encoder, video) end

--- Updates the settings for this encoder context.
---
--- C definition: `void obs_encoder_update(obs_encoder_t *encoder, obs_data_t *settings)`
--- @param encoder obs_encoder
--- @param settings obs_data
function obslua.obs_encoder_update(encoder, settings) end

--- :return: The video/audio handler associated with this encoder, or
---          *NULL* if none or not a matching encoder type
---
--- C definition: `video_t *obs_encoder_video(const obs_encoder_t *encoder)`
--- @param encoder obs_encoder
--- @return video_t
function obslua.obs_encoder_video(encoder) end

--- Helper function for entering the OBS graphics context.
---
--- C definition: `void obs_enter_graphics(void)`
function obslua.obs_enter_graphics() end

--- Enumerates audio devices which can be used for audio monitoring.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef bool (*obs_enum_audio_device_cb)(void *data, const char *name, const char *id);
---
--- C definition: `void obs_enum_audio_monitoring_devices(obs_enum_audio_device_cb cb, void *data)`
--- @param cb f_p_void_p_q_const__char_p_q_const__char__bool
--- @param data ref_void*
function obslua.obs_enum_audio_monitoring_devices(cb, data) end

--- Enumerates all available encoder types.
---
--- C definition: `bool obs_enum_encoder_types(size_t idx, const char **id)`
--- @param idx number
--- @param id p_char
--- @return boolean
function obslua.obs_enum_encoder_types(idx, id) end

--- Enumerates encoders.
---
--- C definition: `void obs_enum_encoders(bool (*enum_proc)(void*, obs_encoder_t*), void *param)`
--- @param enum_proc f_p_void_p_struct_obs_encoder__bool
--- @param param ref_void*
function obslua.obs_enum_encoders(enum_proc, param) end

--- Enumerates all available filter source types.
---
--- Filters are sources that are used to modify the video/audio output of
--- other sources.
---
--- C definition: `bool obs_enum_filter_types(size_t idx, const char **id)`
--- @param idx number
--- @param id p_char
--- @return boolean
function obslua.obs_enum_filter_types(idx, id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 f_p_void_size_t_p_struct_obs_hotkey_binding__bool
--- @param param2 ref_void*
function obslua.obs_enum_hotkey_bindings(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 f_p_void_size_t_p_struct_obs_hotkey__bool
--- @param param2 ref_void*
function obslua.obs_enum_hotkeys(param1, param2) end

--- Enumerates all available inputs source types.
---
--- Inputs are general source inputs (such as capture sources, device sources,
--- etc).
---
--- C definition: `bool obs_enum_input_types(size_t idx, const char **id)`
--- @param idx number
--- @param id p_char
--- @return boolean
function obslua.obs_enum_input_types(idx, id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 p_char
--- @param param3 p_char
function obslua.obs_enum_input_types2(param1, param2, param3) end

--- Enumerates all loaded modules.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_enum_module_callback_t)(void *param, obs_module_t *module);
---
--- C definition: `void obs_enum_modules(obs_enum_module_callback_t callback, void *param)`
--- @param callback f_p_void_p_struct_obs_module__void
--- @param param ref_void*
function obslua.obs_enum_modules(callback, param) end

--- Enumerates all available output types.
---
--- C definition: `bool obs_enum_output_types(size_t idx, const char **id)`
--- @param idx number
--- @param id p_char
--- @return boolean
function obslua.obs_enum_output_types(idx, id) end

--- Enumerates outputs.
---
--- C definition: `void obs_enum_outputs(bool (*enum_proc)(void*, obs_output_t*), void *param)`
--- @param enum_proc f_p_void_p_struct_obs_output__bool
--- @param param ref_void*
function obslua.obs_enum_outputs(enum_proc, param) end

--- Enumerates all scenes.
---
--- Callback function returns true to continue enumeration, or false to end
--- enumeration.
---
--- Use :c:func:`obs_source_get_ref()` or
--- :c:func:`obs_source_get_weak_source()` if you want to retain a
--- reference after obs_enum_scenes finishes.
---
--- C definition: `void obs_enum_scenes(bool (*enum_proc)(void*, obs_source_t*), void *param)`
--- @param enum_proc f_p_void_p_struct_obs_source__bool
--- @param param ref_void*
function obslua.obs_enum_scenes(enum_proc, param) end

--- Enumerates all available service types.
---
--- C definition: `bool obs_enum_service_types(size_t idx, const char **id)`
--- @param idx number
--- @param id p_char
--- @return boolean
function obslua.obs_enum_service_types(idx, id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 f_p_void_p_struct_obs_service__bool
--- @param param2 ref_void*
function obslua.obs_enum_services(param1, param2) end

--- Enumerates all source types (inputs, filters, transitions, etc).
---
--- C definition: `bool obs_enum_source_types(size_t idx, const char **id)`
--- @param idx number
--- @param id p_char
--- @return boolean
function obslua.obs_enum_source_types(idx, id) end

--- Enumerates all sources.
---
--- :return: An array of reference-incremented sources.  Release with
---          :py:func:`source_list_release()`.
---
--- C definition: Not available
--- @return unknown
function obslua.obs_enum_sources() end

--- Enumerates all available transition source types.
---
--- Transitions are sources used to transition between two or more other
--- sources.
---
--- C definition: `bool obs_enum_transition_types(size_t idx, const char **id)`
--- @param idx number
--- @param id p_char
--- @return boolean
function obslua.obs_enum_transition_types(idx, id) end

--- If the source is a filter, returns the parent source of the filter.
--- The parent source is the source being filtered.
---
--- Only guaranteed to be valid inside of the video_render, filter_audio,
--- filter_video, and filter_remove callbacks.
---
--- C definition: `obs_source_t *obs_filter_get_parent(const obs_source_t *filter)`
--- @param filter obs_source
--- @return obs_source
function obslua.obs_filter_get_parent(filter) end

--- If the source is a filter, returns the target source of the filter.
--- The target source is the next source in the filter chain.
---
--- Only guaranteed to be valid inside of the video_render, filter_audio,
--- filter_video, and filter_remove callbacks.
---
--- C definition: `obs_source_t *obs_filter_get_target(const obs_source_t *filter)`
--- @param filter obs_source
--- @return obs_source
function obslua.obs_filter_get_target(filter) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_find_data_file(param1) end

--- Returns the location of a plugin module data file.
---
--- Note:   Modules should use obs_module_file function defined in obs-module.h
---         as a more elegant means of getting their files without having to
---         specify the module parameter.
---
--- :param  module: The module associated with the file to locate
--- :param  file:   The file to locate
--- :return:        Path string, or NULL if not found.  Use bfree to free string
---
--- C definition: `char *obs_find_module_file(obs_module_t *module, const char *file)`
--- @param module obs_module
--- @param file string
--- @return string
function obslua.obs_find_module_file(module, file) end

--- Adds a callback that will be called when a frontend event occurs.
--- See :c:type:`obs_frontend_event` on what sort of events can be
--- triggered.
---
--- :param callback:     Callback to use when a frontend event occurs.
--- :param private_data: Private data associated with the callback.
---
--- C definition: `void obs_frontend_add_event_callback(obs_frontend_event_cb callback, void *private_data)`
--- @param callback obs_frontend_event_cb
--- @param private_data void*
function obslua.obs_frontend_add_event_callback(callback, private_data) end

--- Adds a callback that will be called when the current scene collection
--- is being saved/loaded.
---
--- :param callback:     Callback to use when saving/loading a scene
---                      collection.
--- :param private_data: Private data associated with the callback.
---
--- C definition: `void obs_frontend_add_save_callback(obs_frontend_save_cb callback, void *private_data)`
--- @param callback obs_frontend_save_cb
--- @param private_data void*
function obslua.obs_frontend_add_save_callback(callback, private_data) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_frontend_defer_save_begin() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_frontend_defer_save_end() end

--- :return: A new reference to the current preview scene if studio mode
---          is active, or the current scene if studio mode is not
---          active.
---
--- C definition: `obs_source_t *obs_frontend_get_current_preview_scene(void)`
--- @return obs_source
function obslua.obs_frontend_get_current_preview_scene() end

--- :return: A new pointer to the current profile name.  Free with
---          :c:func:`bfree()`.
---
--- C definition: `char *obs_frontend_get_current_profile(void)`
--- @return char*
function obslua.obs_frontend_get_current_profile() end

--- :return: A new reference to the currently active scene.
---
--- C definition: `obs_source_t *obs_frontend_get_current_scene(void)`
--- @return obs_source
function obslua.obs_frontend_get_current_scene() end

--- :return: A new pointer to the current scene collection name.  Free
---          with :c:func:`bfree()`.
---
--- C definition: `char *obs_frontend_get_current_scene_collection(void)`
--- @return char*
function obslua.obs_frontend_get_current_scene_collection() end

--- :return: A new reference to the currently active transition.
---
--- C definition: `obs_source_t *obs_frontend_get_current_transition(void)`
--- @return obs_source_t*
function obslua.obs_frontend_get_current_transition() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_frontend_get_global_config() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_frontend_get_profile_config() end

--- :return: The list of profile names, ending with NULL.  The list is
---          stored within one contiguous segment of memory, so freeing
---          the returned pointer with :c:func:`bfree()` will free the
---          entire list.
---
--- C definition: `char **obs_frontend_get_profiles(void)`
--- @return char**
function obslua.obs_frontend_get_profiles() end

--- :return: A new reference to the current srecording output.
---
--- C definition: `obs_output_t *obs_frontend_get_recording_output(void)`
--- @return obs_output
function obslua.obs_frontend_get_recording_output() end

--- :return: A new reference to the current replay buffer output.
---
--- C definition: `obs_output_t *obs_frontend_get_replay_buffer_output(void)`
--- @return obs_output
function obslua.obs_frontend_get_replay_buffer_output() end

--- :return: The list of profile names, ending with NULL.  The list is
---          stored within one contiguous segment of memory, so freeing
---          the returned pointer with :c:func:`bfree()` will free the
---          entire list.
---
--- C definition: `char **obs_frontend_get_scene_collections(void)`
--- @return char**
function obslua.obs_frontend_get_scene_collections() end

--- :return: The scene name list, ending with NULL.  The list is stored
---          within one contiguous segment of memory, so freeing the
---          returned pointer with :c:func:`bfree()` will free the entire
---          list.
---
--- C definition: `char **obs_frontend_get_scene_names(void)`
--- @return char**
function obslua.obs_frontend_get_scene_names() end

--- :param sources: Pointer to a :c:type:`obs_frontend_source_list`
---                 structure to receive the list of
---                 reference-incremented scenes.  Release with
---                 :c:func:`obs_frontend_source_list_free`.
---
--- C definition: `void obs_frontend_get_scenes(struct obs_frontend_source_list *sources)`
--- @param sources obs_frontend_source_list*
function obslua.obs_frontend_get_scenes(sources) end

--- :return: A new reference to the current streaming output.
---
--- C definition: `obs_output_t *obs_frontend_get_streaming_output(void)`
--- @return obs_output
function obslua.obs_frontend_get_streaming_output() end

--- :return: A new reference to the current streaming service object.
---
--- C definition: `obs_service_t *obs_frontend_get_streaming_service(void)`
--- @return obs_service
function obslua.obs_frontend_get_streaming_service() end

--- :param sources: Pointer to a :c:type:`obs_frontend_source_list`
---                 structure to receive the list of
---                 reference-incremented transitions.  Release with
---                 :c:func:`obs_frontend_source_list_free`.
---
--- C definition: `void obs_frontend_get_transitions(struct obs_frontend_source_list *sources)`
--- @param sources obs_frontend_source_list*
function obslua.obs_frontend_get_transitions(sources) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 number
--- @param param3 string
--- @param param4 string
function obslua.obs_frontend_open_projector(param1, param2, param3, param4) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_frontend_preview_enabled() end

--- :return: *true* if studio mode is active, *false* otherwise.
---
--- C definition: `bool obs_frontend_preview_program_mode_active(void)`
--- @return boolean
function obslua.obs_frontend_preview_program_mode_active() end

--- Triggers a preview-to-program transition if studio mode is active.
---
--- C definition: `void obs_frontend_preview_program_trigger_transition(void)`
function obslua.obs_frontend_preview_program_trigger_transition() end

--- :return: *true* if recording active, *false* otherwise.
---
--- C definition: `bool obs_frontend_recording_active(void)`
--- @return boolean
function obslua.obs_frontend_recording_active() end

--- :pause: *true* to pause recording, *false* to unpause.
---
--- C definition: `void obs_frontend_recording_pause(bool pause)`
--- @param pause boolean
function obslua.obs_frontend_recording_pause(pause) end

--- :return: *true* if recording paused, *false* otherwise.
---
--- C definition: `bool obs_frontend_recording_paused(void)`
--- @return boolean
function obslua.obs_frontend_recording_paused() end

--- Starts recording.
---
--- C definition: `void obs_frontend_recording_start(void)`
function obslua.obs_frontend_recording_start() end

--- Stops recording.
---
--- C definition: `void obs_frontend_recording_stop(void)`
function obslua.obs_frontend_recording_stop() end

--- Removes an event callback.
---
--- :param callback:     Callback to remove.
--- :param private_data: Private data associated with the callback.
---
--- C definition: `void obs_frontend_remove_event_callback(obs_frontend_event_cb callback, void *private_data)`
--- @param callback obs_frontend_event_cb
--- @param private_data void*
function obslua.obs_frontend_remove_event_callback(callback, private_data) end

--- Removes a save/load callback.
---
--- :param callback:     Callback to remove.
--- :param private_data: Private data associated with the callback.
---
--- C definition: `void obs_frontend_remove_save_callback(obs_frontend_save_cb callback, void *private_data)`
--- @param callback obs_frontend_save_cb
--- @param private_data void*
function obslua.obs_frontend_remove_save_callback(callback, private_data) end

--- :return: *true* if replay buffer active, *false* otherwise.
---
--- C definition: `bool obs_frontend_replay_buffer_active(void)`
--- @return boolean
function obslua.obs_frontend_replay_buffer_active() end

--- Saves a replay if the replay buffer is active.
---
--- C definition: `void obs_frontend_replay_buffer_save(void)`
function obslua.obs_frontend_replay_buffer_save() end

--- Starts replay buffer.
---
--- C definition: `void obs_frontend_replay_buffer_start(void)`
function obslua.obs_frontend_replay_buffer_start() end

--- Stops replay buffer.
---
--- C definition: `void obs_frontend_replay_buffer_stop(void)`
function obslua.obs_frontend_replay_buffer_stop() end

--- Saves the current scene collection.
---
--- C definition: `void obs_frontend_save(void)`
function obslua.obs_frontend_save() end

--- Saves the current streaming service data.
---
--- C definition: `void obs_frontend_save_streaming_service(void)`
function obslua.obs_frontend_save_streaming_service() end

--- Sets the current preview scene in studio mode, or the currently
--- active scene if not in studio mode.
---
--- :param scene: The scene to set as the current preview.
---
--- C definition: `void obs_frontend_set_current_preview_scene(obs_source_t *scene)`
--- @param scene obs_source
function obslua.obs_frontend_set_current_preview_scene(scene) end

--- :param profile: Name of the profile to activate.
---
--- C definition: `void obs_frontend_set_current_profile(const char *profile)`
--- @param profile char*
function obslua.obs_frontend_set_current_profile(profile) end

--- :param scene: The scene to set as the current scene.
---
--- C definition: `void obs_frontend_set_current_scene(obs_source_t *scene)`
--- @param scene obs_source_t*
function obslua.obs_frontend_set_current_scene(scene) end

--- :param profile: Name of the scene collection to activate.
---
--- C definition: `void obs_frontend_set_current_scene_collection(const char *collection)`
--- @param collection char*
function obslua.obs_frontend_set_current_scene_collection(collection) end

--- :param transition: The transition to set as the current transition.
---
--- C definition: `void obs_frontend_set_current_transition(obs_source_t *transition)`
--- @param transition obs_source_t*
function obslua.obs_frontend_set_current_transition(transition) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 boolean
function obslua.obs_frontend_set_preview_enabled(param1) end

--- Activates/deactivates studio mode.
---
--- :param enable: *true* to activate studio mode, *false* to deactivate
---                studio mode.
---
--- C definition: `void obs_frontend_set_preview_program_mode(bool enable)`
--- @param enable boolean
function obslua.obs_frontend_set_preview_program_mode(enable) end

--- Sets the current streaming service to stream with.
---
--- :param service: The streaming service to set.
---
--- C definition: `void obs_frontend_set_streaming_service(obs_service_t *service)`
--- @param service obs_service
function obslua.obs_frontend_set_streaming_service(service) end

--- :return: *true* if streaming active, *false* otherwise.
---
--- C definition: `bool obs_frontend_streaming_active(void)`
--- @return boolean
function obslua.obs_frontend_streaming_active() end

--- Starts streaming.
---
--- C definition: `void obs_frontend_streaming_start(void)`
function obslua.obs_frontend_streaming_start() end

--- Stops streaming.
---
--- C definition: `void obs_frontend_streaming_stop(void)`
function obslua.obs_frontend_streaming_stop() end

--- Takes a screenshot of the main OBS output.
---
--- C definition: `void *obs_frontend_take_screenshot(void)`
--- @return void*
function obslua.obs_frontend_take_screenshot() end

--- Takes a screenshot of the specified source.
---
--- :param source: The source to take screenshot of.
--- C definition: `void *obs_frontend_take_source_screenshot(obs_source_t *source)`
--- @param source obs_source
--- @return void*
function obslua.obs_frontend_take_source_screenshot(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_active_fps() end

--- :return: The main audio output handler for this OBS context
---
--- C definition: `audio_t *obs_get_audio(void)`
--- @return audio_t
function obslua.obs_get_audio() end

--- Gets the current audio settings.
---
--- :return: *false* if no audio
---
--- C definition: `bool obs_get_audio_info(struct obs_audio_info *oai)`
--- @param oai obs_audio_info
--- @return boolean
function obslua.obs_get_audio_info(oai) end

--- Gets the current audio device for audio monitoring.
---
--- C definition: `void obs_get_audio_monitoring_device(const char **name, const char **id)`
--- @param name p_char
--- @param id p_char
function obslua.obs_get_audio_monitoring_device(name, id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_average_frame_time_ns() end

--- Returns a commoinly used base effect.
---
--- :param effect: | Can be one of the following values:
---                | OBS_EFFECT_DEFAULT             - RGB/YUV
---                | OBS_EFFECT_DEFAULT_RECT        - RGB/YUV (using texture_rect)
---                | OBS_EFFECT_OPAQUE              - RGB/YUV (alpha set to 1.0)
---                | OBS_EFFECT_SOLID               - RGB/YUV (solid color only)
---                | OBS_EFFECT_BICUBIC             - Bicubic downscale
---                | OBS_EFFECT_LANCZOS             - Lanczos downscale
---                | OBS_EFFECT_BILINEAR_LOWRES     - Bilinear low resolution downscale
---                | OBS_EFFECT_PREMULTIPLIED_ALPHA - Premultiplied alpha
---
--- C definition: `gs_effect_t *obs_get_base_effect(enum obs_base_effect effect)`
--- @param effect number
--- @return gs_effect
function obslua.obs_get_base_effect(effect) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_cmdline_args() end

--- Gets an encoder by its name.
---
--- Increments the encoder reference counter, use
--- :c:func:`obs_encoder_release()` to release it when complete.
---
--- C definition: `obs_encoder_t *obs_get_encoder_by_name(const char *name)`
--- @param name string
--- @return obs_encoder
function obslua.obs_get_encoder_by_name(name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_get_encoder_caps(param1) end

--- :return: The codec identifier of the encoder
---
--- C definition: `const char *obs_get_encoder_codec(const char *id)`
--- @param id string
--- @return string
function obslua.obs_get_encoder_codec(id) end

--- Use these functions to get the properties of an encoder or encoder
--- type.  Properties are optionally used (if desired) to automatically
--- generate user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing encoder.  Free
---          with :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_get_encoder_properties(const char *id)`
--- @param id string
--- @return obs_properties
function obslua.obs_get_encoder_properties(id) end

--- :return: The encoder type: OBS_ENCODER_VIDEO or OBS_ENCODER_AUDIO
---
--- C definition: `enum obs_encoder_type obs_get_encoder_type(const char *id)`
--- @param id string
--- @return number
function obslua.obs_get_encoder_type(id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_frame_interval_ns() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_lagged_frames() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_get_latest_input_type_id(param1) end

--- :return: The current locale
---
--- C definition: `const char *obs_get_locale(void)`
--- @return string
function obslua.obs_get_locale() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_main_texture() end

--- :return: The master user volume
---
--- C definition: `float obs_get_master_volume(void)`
--- @return number
function obslua.obs_get_master_volume() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_get_module(param1) end

--- :return: The module author(s)
---
--- C definition: `void obs_get_module_author(obs_module_t *module)`
--- @param module obs_module
function obslua.obs_get_module_author(module) end

--- :return: The module binary path
---
--- C definition: `const char *obs_get_module_binary_path(obs_module_t *module)`
--- @param module obs_module
--- @return string
function obslua.obs_get_module_binary_path(module) end

--- :return: The module data path
---
--- C definition: `const char *obs_get_module_data_path(obs_module_t *module)`
--- @param module obs_module
--- @return string
function obslua.obs_get_module_data_path(module) end

--- :return: The module description
---
--- C definition: `const char *obs_get_module_description(obs_module_t *module)`
--- @param module obs_module
--- @return string
function obslua.obs_get_module_description(module) end

--- :return: The module file name
---
--- C definition: `const char *obs_get_module_file_name(obs_module_t *module)`
--- @param module obs_module
--- @return string
function obslua.obs_get_module_file_name(module) end

--- :return: The module full name (or *NULL* if none)
---
--- C definition: `const char *obs_get_module_name(obs_module_t *module)`
--- @param module obs_module
--- @return string
function obslua.obs_get_module_name(module) end

--- Gets an output by its name.
---
--- Increments the output reference counter, use
--- :c:func:`obs_output_release()` to release it when complete.
---
--- C definition: `obs_output_t *obs_get_output_by_name(const char *name)`
--- @param name string
--- @return obs_output
function obslua.obs_get_output_by_name(name) end

--- :return: The output capability flags
---
--- C definition: `uint32_t obs_get_output_flags(const char *id)`
--- @param id string
--- @return number
function obslua.obs_get_output_flags(id) end

--- Use these functions to get the properties of an output or output
--- type.  Properties are optionally used (if desired) to automatically
--- generate user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing output.  Free
---          with :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_get_output_properties(const char *id)`
--- @param id string
--- @return obs_properties
function obslua.obs_get_output_properties(id) end

--- Gets the primary output source for a channel and increments the reference
--- counter for that source.  Use :c:func:`obs_source_release()` to release.
---
--- C definition: `obs_source_t *obs_get_output_source(uint32_t channel)`
--- @param channel number
--- @return obs_source
function obslua.obs_get_output_source(channel) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_private_data() end

--- :return: The primary obs procedure handler
---
--- .. _core_signal_handler_reference:
---
--- Core OBS Signals
--- C definition: `proc_handler_t *obs_get_proc_handler(void)`
--- @return proc_handler
function obslua.obs_get_proc_handler() end

--- :return: The profiler name store (see util/profiler.h) used by OBS,
---          which is either a name store passed to obs_startup, an
---          internal name store, or NULL in case obs_initialized()
---          returns false.
---
--- C definition: `profiler_name_store_t *obs_get_profiler_name_store(void)`
--- @return profiler_name_store_t
function obslua.obs_get_profiler_name_store() end

--- Gets an service by its name.
---
--- Increments the service reference counter, use
--- :c:func:`obs_service_release()` to release it when complete.
---
--- C definition: `obs_service_t *obs_get_service_by_name(const char *name)`
--- @param name string
--- @return obs_service
function obslua.obs_get_service_by_name(name) end

--- Use these functions to get the properties of a service or service
--- type.  Properties are optionally used (if desired) to automatically
--- generate user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing service.  Free
---          with :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_get_service_properties(const char *id)`
--- @param id string
--- @return obs_properties
function obslua.obs_get_service_properties(id) end

--- :return: The primary obs signal handler
---
--- See :ref:`core_signal_handler_reference` for more information on
--- core signals.
---
--- C definition: `signal_handler_t *obs_get_signal_handler(void)`
--- @return signal_handler
function obslua.obs_get_signal_handler() end

--- Gets a source by its name.
---
--- Increments the source reference counter, use
--- :c:func:`obs_source_release()` to release it when complete.
---
--- C definition: `obs_source_t *obs_get_source_by_name(const char *name)`
--- @param name string
--- @return obs_source
function obslua.obs_get_source_by_name(name) end

--- Calls :c:member:`obs_source_info.get_defaults` to get the defaults
--- settings of the source type.
---
--- :return: The default settings for a source type
---
--- C definition: `obs_data_t *obs_get_source_defaults(const char *id)`
--- @param id string
--- @return obs_data
function obslua.obs_get_source_defaults(id) end

--- :return: Capability flags of a source
---
--- Author's Note: "Output flags" is poor wording in retrospect; this
--- should have been named "Capability flags", and the OBS_SOURCE_*
--- macros should really be OBS_SOURCE_CAP_* macros instead.
---
--- See :c:member:`obs_source_info.output_flags` for more information.
---
--- C definition: `uint32_t obs_get_source_output_flags(const char *id)`
--- @param id string
--- @return number
function obslua.obs_get_source_output_flags(id) end

--- Use these functions to get the properties of a source or source type.
--- Properties are optionally used (if desired) to automatically generate
--- user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing source.  Free with
---          :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_get_source_properties(const char *id)`
--- @param id string
--- @return obs_properties
function obslua.obs_get_source_properties(id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_total_frames() end

--- :return: The current core version
---
--- C definition: `uint32_t obs_get_version(void)`
--- @return number
function obslua.obs_get_version() end

--- :return: The current core version string
---
--- C definition: `const char *obs_get_version_string(void)`
--- @return string
function obslua.obs_get_version_string() end

--- :return: The main video output handler for this OBS context
---
--- C definition: `video_t *obs_get_video(void)`
--- @return video_t
function obslua.obs_get_video() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_get_video_frame_time() end

--- Gets the current video settings.
---
--- :return: *false* if no video
---
--- C definition: `bool obs_get_video_info(struct obs_video_info *ovi)`
--- @param ovi obs_video_info
--- @return boolean
function obslua.obs_get_video_info(ovi) end

--- :return: The group context, or *NULL* if not a group.  Does not
---          increase the reference
---
--- C definition: `obs_scene_t *obs_group_from_source(const obs_source_t *source)`
--- @param source obs_source
--- @return obs_scene
function obslua.obs_group_from_source(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey_binding
function obslua.obs_hotkey_binding_get_hotkey(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey_binding
function obslua.obs_hotkey_binding_get_hotkey_id(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey_binding
function obslua.obs_hotkey_binding_get_key_combination(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 boolean
function obslua.obs_hotkey_enable_background_press(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 boolean
function obslua.obs_hotkey_enable_callback_rerouting(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 boolean
function obslua.obs_hotkey_enable_strict_modifiers(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey
function obslua.obs_hotkey_get_description(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey
function obslua.obs_hotkey_get_id(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey
function obslua.obs_hotkey_get_name(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey
function obslua.obs_hotkey_get_pair_partner_id(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey
function obslua.obs_hotkey_get_registerer(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_hotkey
function obslua.obs_hotkey_get_registerer_type(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_key_combination
--- @param param2 boolean
function obslua.obs_hotkey_inject_event(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 obs_data_array
function obslua.obs_hotkey_load(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 obs_key_combination
--- @param param3 number
function obslua.obs_hotkey_load_bindings(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 obs_data_array
--- @param param3 obs_data_array
function obslua.obs_hotkey_pair_load(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 p_obs_data_array
--- @param param3 p_obs_data_array
function obslua.obs_hotkey_pair_save(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 string
--- @param param3 string
function obslua.obs_hotkey_pair_set_descriptions(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 string
--- @param param3 string
function obslua.obs_hotkey_pair_set_names(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
function obslua.obs_hotkey_pair_unregister(param1) end

--- Adds a frontend hotkey.  The callback takes one parameter: a boolean
--- 'pressed' parameter.
---
--- :param name:        Unique name identifier string of the hotkey.
--- :param description: Hotkey description shown to the user.
--- :param callback:    Callback for the hotkey.  Use
---                     :py:func:`obs_hotkey_unregister()` or
---                     :py:func:`remove_current_callback()` to remove
---                     the callback.
---
--- C definition: Not available
--- @param name unknown
--- @param description unknown
--- @param callback unknown
--- @return unknown
function obslua.obs_hotkey_register_frontend(name, description, callback) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
function obslua.obs_hotkey_save(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 f_p_void_size_t_bool__void
--- @param param2 ref_void*
function obslua.obs_hotkey_set_callback_routing_func(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 string
function obslua.obs_hotkey_set_description(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 string
function obslua.obs_hotkey_set_name(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 boolean
function obslua.obs_hotkey_trigger_routed_callback(param1, param2) end

--- Unregisters the hotkey associated with the specified callback.
---
--- :param callback: Callback of the hotkey to unregister.
---
--- C definition: Not available
--- @param callback number
--- @return unknown
function obslua.obs_hotkey_unregister(callback) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 f_p_void__void
--- @param param2 ref_void*
function obslua.obs_hotkey_update_atomic(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
--- @param param2 obs_data
function obslua.obs_hotkeys_load_encoder(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_output
--- @param param2 obs_data
function obslua.obs_hotkeys_load_output(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_service
--- @param param2 obs_data
function obslua.obs_hotkeys_load_service(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_data
function obslua.obs_hotkeys_load_source(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_encoder
function obslua.obs_hotkeys_save_encoder(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_output
function obslua.obs_hotkeys_save_output(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_service
function obslua.obs_hotkeys_save_service(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_hotkeys_save_source(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 string
--- @param param3 string
--- @param param4 string
function obslua.obs_hotkeys_set_audio_hotkeys_translations(param1, param2, param3, param4) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 string
function obslua.obs_hotkeys_set_sceneitem_hotkeys_translations(param1, param2) end

--- Initializes the module, which calls its obs_module_load export.
---
--- :return: *true* if the module was loaded successfully
---
--- C definition: `bool obs_init_module(obs_module_t *module)`
--- @param module obs_module
--- @return boolean
function obslua.obs_init_module(module) end

--- :return: true if the main OBS context has been initialized
---
--- C definition: `bool obs_initialized(void)`
--- @return boolean
function obslua.obs_initialized() end

--- :return: *true* if the the source has custom properties, *false*
---          otherwise
---
--- C definition: `bool obs_is_source_configurable(const char *id)`
--- @param id string
--- @return boolean
function obslua.obs_is_source_configurable(id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_key_combination
function obslua.obs_key_combination_is_empty(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_key_combination
--- @param param2 dstr
function obslua.obs_key_combination_to_str(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_key_from_name(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
function obslua.obs_key_from_virtual_key(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
function obslua.obs_key_to_name(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 dstr
function obslua.obs_key_to_str(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
function obslua.obs_key_to_virtual_key(param1) end

--- Helper function for leaving the OBS graphics context.
---
--- C definition: `void obs_leave_graphics(void)`
function obslua.obs_leave_graphics() end

--- Automatically loads all modules from module paths (convenience function).
---
--- C definition: `void obs_load_all_modules(void)`
function obslua.obs_load_all_modules() end

--- :return: A source created from saved data
---
--- C definition: `obs_source_t *obs_load_source(obs_data_t *data)`
--- @param data obs_data
--- @return obs_source
function obslua.obs_load_source(data) end

--- Helper function to load active sources from a data array.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_load_source_cb)(void *private_data, obs_source_t *source);
---
--- C definition: `void obs_load_sources(obs_data_array_t *array, obs_load_source_cb cb, void *private_data)`
--- @param array obs_data_array
--- @param cb f_p_void_p_struct_obs_source__void
--- @param private_data ref_void*
function obslua.obs_load_sources(array, cb, private_data) end

--- Logs loaded modules.
---
--- C definition: `void obs_log_loaded_modules(void)`
function obslua.obs_log_loaded_modules() end

--- Returns the path of a plugin module config file (whether it exists or not).
---
--- Note:   Modules should use obs_module_config_path function defined in
---         obs-module.h as a more elegant means of getting their files without
---         having to specify the module parameter.
---
--- :param  module: The module associated with the path
--- :param  file:   The file to get a path to
--- :return:        Path string, or NULL if not found.  Use bfree to free string
--- C definition: `char *obs_module_get_config_path(obs_module_t *module, const char *file)`
--- @param module obs_module
--- @param file string
--- @return string
function obslua.obs_module_get_config_path(module, file) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_module
--- @param param2 string
--- @param param3 p_char
function obslua.obs_module_get_locale_string(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_module
--- @param param2 string
function obslua.obs_module_get_locale_text(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_module
--- @param param2 string
--- @param param3 string
function obslua.obs_module_load_locale(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_nv12_tex_active() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 ref_void*
function obslua.obs_obj_get_data(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 ref_void*
function obslua.obs_obj_get_id(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 ref_void*
function obslua.obs_obj_get_type(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 ref_void*
function obslua.obs_obj_invalid(param1) end

--- Opens a plugin module directly from a specific path.
---
--- If the module already exists then the function will return successful, and
--- the module parameter will be given the pointer to the existing
--- module.
---
--- This does not initialize the module, it only loads the module image.  To
--- initialize the module, call :c:func:`obs_init_module()`.
---
--- :param  module:    The pointer to the created module
--- :param  path:      Specifies the path to the module library file.  If the
---                    extension is not specified, it will use the extension
---                    appropriate to the operating system
--- :param  data_path: Specifies the path to the directory where the module's
---                    data files are stored (or *NULL* if none)
--- :returns:          | MODULE_SUCCESS          - Successful
---                    | MODULE_ERROR            - A generic error occurred
---                    | MODULE_FILE_NOT_FOUND   - The module was not found
---                    | MODULE_MISSING_EXPORTS  - Required exports are missing
---                    | MODULE_INCOMPATIBLE_VER - Incompatible version
---
--- C definition: `int obs_open_module(obs_module_t **module, const char *path, const char *data_path)`
--- @param module p_obs_module
--- @param path string
--- @param data_path string
--- @return number
function obslua.obs_open_module(module, path, data_path) end

--- :return: *true* if the output is currently active, *false* otherwise
---
--- C definition: `bool obs_output_active(const obs_output_t *output)`
--- @param output obs_output
--- @return boolean
function obslua.obs_output_active(output) end

--- Adds/releases a reference to an output.  When the last reference is
--- released, the output is destroyed.
---
--- C definition: `void obs_output_addref(obs_output_t *output)`
--- @param output obs_output
function obslua.obs_output_addref(output) end

--- Gets the current video/audio handlers for the output.
---
--- C definition: `audio_t *obs_output_audio(const obs_output_t *output)`
--- @param output obs_output
--- @return audio_t
function obslua.obs_output_audio(output) end

--- Begins data capture from raw media or encoders.  This is typically
--- when the output actually activates (starts) internally.  Video/audio
--- data will start being sent to the callbacks of the output.
---
--- :param flags: Set to 0 to initialize both audio/video, otherwise a
---               bitwise OR combination of OBS_OUTPUT_VIDEO and/or
---               OBS_OUTPUT_AUDIO
--- :return:      *true* if successful, *false* otherwise.  Typically the
---               return value does not need to be checked if
---               :c:func:`obs_output_can_begin_data_capture()` was
---               called
---
--- C definition: `bool obs_output_begin_data_capture(obs_output_t *output, uint32_t flags)`
--- @param output obs_output
--- @param flags number
--- @return boolean
function obslua.obs_output_begin_data_capture(output, flags) end

--- Determines whether video/audio capture (encoded or raw) is able to
--- start.  Call this before initializing any output data to ensure that
--- the output can start.
---
--- :param flags: Set to 0 to initialize both audio/video, otherwise a
---               bitwise OR combination of OBS_OUTPUT_VIDEO and/or
---               OBS_OUTPUT_AUDIO
--- :return:      *true* if data capture can begin
---
--- C definition: `bool obs_output_can_begin_data_capture(const obs_output_t *output, uint32_t flags)`
--- @param output obs_output
--- @param flags number
--- @return boolean
function obslua.obs_output_can_begin_data_capture(output, flags) end

--- :return: *true* if the output can be paused, *false* otherwise
---
--- C definition: `bool obs_output_can_pause(const obs_output_t *output)`
--- @param output obs_output
--- @return boolean
function obslua.obs_output_can_pause(output) end

--- Creates an output with the specified settings.
---
--- The "output" context is used for anything related to outputting the
--- final video/audio mix (E.g. streaming or recording).  Use
--- obs_output_release to release it.
---
--- :param   id:             The output type string identifier
--- :param   name:           The desired name of the output.  If this is
---                          not unique, it will be made to be unique
--- :param   settings:       The settings for the output, or *NULL* if
---                          none
--- :param   hotkey_data:    Saved hotkey data for the output, or *NULL*
---                          if none
--- :return:                 A reference to the newly created output, or
---                          *NULL* if failed
---
--- C definition: `obs_output_t *obs_output_create(const char *id, const char *name, obs_data_t *settings, obs_data_t *hotkey_data)`
--- @param id string
--- @param name string
--- @param settings obs_data
--- @param hotkey_data obs_data
--- @return obs_output
function obslua.obs_output_create(id, name, settings, hotkey_data) end

--- :return: An incremented reference to the output's default settings
---
--- C definition: `obs_data_t *obs_output_defaults(const char *id)`
--- @param id string
--- @return obs_data
function obslua.obs_output_defaults(id) end

--- Ends data capture of an output.  This is typically when the output
--- actually intentionally deactivates (stops).  Video/audio data will
--- stop being sent to the callbacks of the output.  The output will
--- trigger the "stop" signal with the OBS_OUTPUT_SUCCESS code to
--- indicate that the output has stopped successfully.  See
--- :ref:`output_signal_handler_reference` for more information on output
--- signals.
---
--- C definition: `void obs_output_end_data_capture(obs_output_t *output)`
--- @param output obs_output
function obslua.obs_output_end_data_capture(output) end

--- Attempts to get the output to stop immediately without waiting for
--- data to send.
---
--- C definition: `void obs_output_force_stop(obs_output_t *output)`
--- @param output obs_output
function obslua.obs_output_force_stop(output) end

--- If delay is active, gets the currently active delay value, in
--- seconds.  The active delay can increase if the
--- OBS_OUTPUT_DELAY_PRESERVE flag was set when setting a delay.
---
--- C definition: `uint32_t obs_output_get_active_delay(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_active_delay(output) end

--- Gets the video/audio encoders for an encoded output.
---
--- :param idx:     The audio encoder index if the output supports
---                 multiple audio streams at once
--- :return:        The video/audio encoder.  The reference is not
---                 incremented
---
--- C definition: `obs_encoder_t *obs_output_get_audio_encoder(const obs_output_t *output, size_t idx)`
--- @param output obs_output
--- @param idx number
--- @return obs_encoder
function obslua.obs_output_get_audio_encoder(output, idx) end

--- :return: The congestion value.  This value is used to visualize the
---          current congestion of a network output.  For example, if
---          there is no congestion, the value will be 0.0f, if it's
---          fully congested, the value will be 1.0f
---
--- C definition: `float obs_output_get_congestion(obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_congestion(output) end

--- :return: How long the output took to connect to a server, in
---          milliseconds
---
--- C definition: `int obs_output_get_connect_time_ms(obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_connect_time_ms(output) end

--- Gets the currently set delay value, in seconds.
---
--- C definition: `uint32_t obs_output_get_delay(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_delay(output) end

--- Calls the :c:member:`obs_output_info.get_name` callback to get the
--- translated display name of an output type.
---
--- :param    id:            The output type string identifier
--- :return:                 The translated display name of an output type
---
--- C definition: `const char *obs_output_get_display_name(const char *id)`
--- @param id string
--- @return string
function obslua.obs_output_get_display_name(id) end

--- :return: The output capability flags
---
--- C definition: `uint32_t obs_output_get_flags(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_flags(output) end

--- :return: Number of frames that were dropped due to network congestion
---
--- C definition: `int obs_output_get_frames_dropped(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_frames_dropped(output) end

--- :return: The width/height of the output
---
--- C definition: `uint32_t obs_output_get_height(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_height(output) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_output
function obslua.obs_output_get_id(param1) end

--- Sets/gets the translated error message that is presented to a user in
--- case of disconnection, inability to connect, etc.
---
--- C definition: `const char *obs_output_get_last_error(obs_output_t *output)`
--- @param output obs_output
--- @return string
function obslua.obs_output_get_last_error(output) end

--- Sets/gets the current audio mixer for non-encoded outputs.  For
--- multi-track outputs, this would be the equivalent of setting the mask
--- only for the specified mixer index.
---
--- C definition: `size_t obs_output_get_mixer(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_mixer(output) end

--- Sets/gets the current audio mixers (via mask) for non-encoded
--- multi-track outputs.  If used with single-track outputs, the
--- single-track output will use either the first set mixer track in the
--- bitmask, or the first track if none is set in the bitmask.
---
--- C definition: `size_t obs_output_get_mixers(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_mixers(output) end

--- :return: The name of the output
---
--- C definition: `const char *obs_output_get_name(const obs_output_t *output)`
--- @param output obs_output
--- @return string
function obslua.obs_output_get_name(output) end

--- Returns the current pause offset of the output.  Used with raw
--- outputs to calculate system timestamps when using calculated
--- timestamps (see FFmpeg output for an example).
---
--- .. ---------------------------------------------------------------------------
---
--- .. _libobs/obs-output.h: https://github.com/jp9000/obs-studio/blob/master/libobs/obs-output.h
--- C definition: `uint64_t obs_output_get_pause_offset(obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_pause_offset(output) end

--- :return: The procedure handler of the output
---
--- C definition: `proc_handler_t *obs_output_get_proc_handler(const obs_output_t *output)`
--- @param output obs_output
--- @return proc_handler
function obslua.obs_output_get_proc_handler(output) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_output
function obslua.obs_output_get_ref(param1) end

--- Sets/gets the service for outputs that require services (such as RTMP
--- outputs).  *obs_output_get_service* does not return an incremented
--- reference.
---
--- C definition: `obs_service_t *obs_output_get_service(const obs_output_t *output)`
--- @param output obs_output
--- @return obs_service
function obslua.obs_output_get_service(output) end

--- :return: An incremented reference to the output's settings
---
--- C definition: `obs_data_t *obs_output_get_settings(const obs_output_t *output)`
--- @param output obs_output
--- @return obs_data
function obslua.obs_output_get_settings(output) end

--- :return: The signal handler of the output
---
--- C definition: `signal_handler_t *obs_output_get_signal_handler(const obs_output_t *output)`
--- @param output obs_output
--- @return signal_handler
function obslua.obs_output_get_signal_handler(output) end

--- :return: Supported video/audio codecs of an encoded output, separated
---          by semicolen
---
--- C definition: `const char *obs_output_get_supported_audio_codecs(const obs_output_t *output)`
--- @param output obs_output
--- @return string
function obslua.obs_output_get_supported_audio_codecs(output) end

--- :return: Supported video/audio codecs of an encoded output, separated
---          by semicolen
---
--- C definition: `const char *obs_output_get_supported_video_codecs(const obs_output_t *output)`
--- @param output obs_output
--- @return string
function obslua.obs_output_get_supported_video_codecs(output) end

--- :return: Total bytes sent/processed
---
--- C definition: `uint64_t obs_output_get_total_bytes(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_total_bytes(output) end

--- :return: Total frames sent/processed
---
--- C definition: `int obs_output_get_total_frames(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_total_frames(output) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_output
function obslua.obs_output_get_type_data(param1) end

--- Gets the video/audio encoders for an encoded output.
---
--- :param idx:     The audio encoder index if the output supports
---                 multiple audio streams at once
--- :return:        The video/audio encoder.  The reference is not
---                 incremented
---
--- C definition: `obs_encoder_t *obs_output_get_video_encoder(const obs_output_t *output)`
--- @param output obs_output
--- @return obs_encoder
function obslua.obs_output_get_video_encoder(output) end

--- These functions are used to get a weak reference from a strong output
--- reference, or a strong output reference from a weak reference.  If
--- the output is destroyed, *obs_weak_output_get_output* will return
--- *NULL*.
---
--- C definition: `obs_weak_output_t *obs_output_get_weak_output(obs_output_t *output)`
--- @param output obs_output
--- @return obs_weak_output
function obslua.obs_output_get_weak_output(output) end

--- :return: The width/height of the output
---
--- C definition: `uint32_t obs_output_get_width(const obs_output_t *output)`
--- @param output obs_output
--- @return number
function obslua.obs_output_get_width(output) end

--- Initializes any encoders/services associated with the output.  This
--- must be called for encoded outputs before calling
--- :c:func:`obs_output_begin_data_capture()`.
---
--- :param flags: Set to 0 to initialize both audio/video, otherwise a
---               bitwise OR combination of OBS_OUTPUT_VIDEO and/or
---               OBS_OUTPUT_AUDIO
--- :return:      *true* if successful, *false* otherwise
---
--- C definition: `bool obs_output_initialize_encoders(obs_output_t *output, uint32_t flags)`
--- @param output obs_output
--- @param flags number
--- @return boolean
function obslua.obs_output_initialize_encoders(output, flags) end

--- obs_output_output_caption_text1 not found in OBS documentation nor C wrapper
obslua.obs_output_output_caption_text1 = function() end

--- obs_output_output_caption_text2 not found in OBS documentation nor C wrapper
obslua.obs_output_output_caption_text2 = function() end

--- Pause an output (if supported by the output).
---
--- :return: *true* if the output was paused successfully, *false*
---          otherwise
---
--- C definition: `bool obs_output_pause(obs_output_t *output, bool pause)`
--- @param output obs_output
--- @param pause boolean
--- @return boolean
function obslua.obs_output_pause(output, pause) end

--- :return: *true* if the output is paused, *false* otherwise
---
--- C definition: `bool obs_output_paused(const obs_output_t *output)`
--- @param output obs_output
--- @return boolean
function obslua.obs_output_paused(output) end

--- Use these functions to get the properties of an output or output
--- type.  Properties are optionally used (if desired) to automatically
--- generate user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing output.  Free
---          with :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_output_properties(const obs_output_t *output)`
--- @param output obs_output
--- @return obs_properties
function obslua.obs_output_properties(output) end

--- :return: *true* if the output is currently reconnecting to a server,
---          *false* otherwise
---
--- C definition: `bool obs_output_reconnecting(const obs_output_t *output)`
--- @param output obs_output
--- @return boolean
function obslua.obs_output_reconnecting(output) end

--- Adds/releases a reference to an output.  When the last reference is
--- released, the output is destroyed.
---
--- C definition: `void obs_output_release(obs_output_t *output)`
--- @param output obs_output
function obslua.obs_output_release(output) end

--- Optionally sets the audio conversion information.  Only used by raw
--- outputs.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- enum audio_format {
---         AUDIO_FORMAT_UNKNOWN,
---
---         AUDIO_FORMAT_U8BIT,
---         AUDIO_FORMAT_16BIT,
---         AUDIO_FORMAT_32BIT,
---         AUDIO_FORMAT_FLOAT,
---
---         AUDIO_FORMAT_U8BIT_PLANAR,
---         AUDIO_FORMAT_16BIT_PLANAR,
---         AUDIO_FORMAT_32BIT_PLANAR,
---         AUDIO_FORMAT_FLOAT_PLANAR,
--- };
---
--- enum speaker_layout {
---         SPEAKERS_UNKNOWN,
---         SPEAKERS_MONO,
---         SPEAKERS_STEREO,
---         SPEAKERS_2POINT1,
---         SPEAKERS_QUAD,
---         SPEAKERS_4POINT1,
---         SPEAKERS_5POINT1,
---         SPEAKERS_5POINT1_SURROUND,
---         SPEAKERS_7POINT1,
---         SPEAKERS_7POINT1_SURROUND,
---         SPEAKERS_SURROUND,
--- };
---
--- struct audio_convert_info {
---         uint32_t            samples_per_sec;
---         enum audio_format   format;
---         enum speaker_layout speakers;
--- };
---
--- C definition: `void obs_output_set_audio_conversion(obs_output_t *output, const struct audio_convert_info *conversion)`
--- @param output obs_output
--- @param conversion audio_convert_info
function obslua.obs_output_set_audio_conversion(output, conversion) end

--- Sets the video/audio encoders for an encoded output.
---
--- :param encoder: The video/audio encoder
--- :param idx:     The audio encoder index if the output supports
---                 multiple audio streams at once
---
--- C definition: `void obs_output_set_audio_encoder(obs_output_t *output, obs_encoder_t *encoder, size_t idx)`
--- @param output obs_output
--- @param encoder obs_encoder
--- @param idx number
function obslua.obs_output_set_audio_encoder(output, encoder, idx) end

--- Sets the current output delay, in seconds (if the output supports delay)
---
--- If delay is currently active, it will set the delay value, but will not
--- affect the current delay, it will only affect the next time the output is
--- activated.
---
--- :param delay_sec: Amount to delay the output, in seconds
--- :param flags:      | Can be 0 or a combination of one of the following values:
---                    | OBS_OUTPUT_DELAY_PRESERVE - On reconnection, start where it left of on reconnection.  Note however that this option will consume extra memory to continually increase delay while waiting to reconnect
---
--- C definition: `void obs_output_set_delay(obs_output_t *output, uint32_t delay_sec, uint32_t flags)`
--- @param output obs_output
--- @param delay_sec number
--- @param flags number
function obslua.obs_output_set_delay(output, delay_sec, flags) end

--- Sets/gets the translated error message that is presented to a user in
--- case of disconnection, inability to connect, etc.
---
--- C definition: `void obs_output_set_last_error(obs_output_t *output, const char *message)`
--- @param output obs_output
--- @param message string
function obslua.obs_output_set_last_error(output, message) end

--- Sets the current video/audio handlers for the output (typically
--- :c:func:`obs_get_video()` and :c:func:`obs_get_audio()`).  Only used
--- with raw outputs so they can catch the raw video/audio frames.
---
--- C definition: `void obs_output_set_media(obs_output_t *output, video_t *video, audio_t *audio)`
--- @param output obs_output
--- @param video video_t
--- @param audio audio_t
function obslua.obs_output_set_media(output, video, audio) end

--- Sets/gets the current audio mixer for non-encoded outputs.  For
--- multi-track outputs, this would be the equivalent of setting the mask
--- only for the specified mixer index.
---
--- C definition: `void obs_output_set_mixer(obs_output_t *output, size_t mixer_idx)`
--- @param output obs_output
--- @param mixer_idx number
function obslua.obs_output_set_mixer(output, mixer_idx) end

--- Sets/gets the current audio mixers (via mask) for non-encoded
--- multi-track outputs.  If used with single-track outputs, the
--- single-track output will use either the first set mixer track in the
--- bitmask, or the first track if none is set in the bitmask.
---
--- C definition: `void obs_output_set_mixers(obs_output_t *output, size_t mixers)`
--- @param output obs_output
--- @param mixers number
function obslua.obs_output_set_mixers(output, mixers) end

--- Sets the preferred scaled resolution for this output.  Set width and height
--- to 0 to disable scaling.
---
--- If this output uses an encoder, it will call obs_encoder_set_scaled_size on
--- the encoder before the stream is started.  If the encoder is already active,
--- then this function will trigger a warning and do nothing.
---
--- C definition: `void obs_output_set_preferred_size(obs_output_t *output, uint32_t width, uint32_t height)`
--- @param output obs_output
--- @param width number
--- @param height number
function obslua.obs_output_set_preferred_size(output, width, height) end

--- Sets the auto-reconnect settings for outputs that support it.  The
--- retry time will double on each retry to prevent overloading services.
---
--- :param retry_count: Maximum retry count.  Set to 0 to disable
---                     reconnecting
--- :param retry_sec:   Starting retry wait duration, in seconds
---
--- C definition: `void obs_output_set_reconnect_settings(obs_output_t *output, int retry_count, int retry_sec)`
--- @param output obs_output
--- @param retry_count number
--- @param retry_sec number
function obslua.obs_output_set_reconnect_settings(output, retry_count, retry_sec) end

--- Sets/gets the service for outputs that require services (such as RTMP
--- outputs).  *obs_output_get_service* does not return an incremented
--- reference.
---
--- C definition: `void obs_output_set_service(obs_output_t *output, obs_service_t *service)`
--- @param output obs_output
--- @param service obs_service
function obslua.obs_output_set_service(output, service) end

--- Optionally sets the video conversion information.  Only used by raw
--- outputs.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- enum video_format {
---         VIDEO_FORMAT_NONE,
---
---         /* planar 420 format */
---         VIDEO_FORMAT_I420, /* three-plane */
---         VIDEO_FORMAT_NV12, /* two-plane, luma and packed chroma */
---
---         /* packed 422 formats */
---         VIDEO_FORMAT_YVYU,
---         VIDEO_FORMAT_YUY2, /* YUYV */
---         VIDEO_FORMAT_UYVY,
---
---         /* packed uncompressed formats */
---         VIDEO_FORMAT_RGBA,
---         VIDEO_FORMAT_BGRA,
---         VIDEO_FORMAT_BGRX,
---         VIDEO_FORMAT_Y800, /* grayscale */
---
---         /* planar 4:4:4 */
---         VIDEO_FORMAT_I444,
--- };
---
--- enum video_colorspace {
---         VIDEO_CS_DEFAULT,
---         VIDEO_CS_601,
---         VIDEO_CS_709,
---         VIDEO_CS_SRGB,
--- };
---
--- enum video_range_type {
---         VIDEO_RANGE_DEFAULT,
---         VIDEO_RANGE_PARTIAL,
---         VIDEO_RANGE_FULL
--- };
---
--- struct video_scale_info {
---         enum video_format     format;
---         uint32_t              width;
---         uint32_t              height;
---         enum video_range_type range;
---         enum video_colorspace colorspace;
--- };
---
--- C definition: `void obs_output_set_video_conversion(obs_output_t *output, const struct video_scale_info *conversion)`
--- @param output obs_output
--- @param conversion video_scale_info
function obslua.obs_output_set_video_conversion(output, conversion) end

--- Sets the video/audio encoders for an encoded output.
---
--- :param encoder: The video/audio encoder
--- :param idx:     The audio encoder index if the output supports
---                 multiple audio streams at once
---
--- C definition: `void obs_output_set_video_encoder(obs_output_t *output, obs_encoder_t *encoder)`
--- @param output obs_output
--- @param encoder obs_encoder
function obslua.obs_output_set_video_encoder(output, encoder) end

--- Ends data capture of an output with an output code, indicating that
--- the output stopped unexpectedly.  This is typically used if for
--- example the server was disconnected for some reason, or if there was
--- an error saving to file.  The output will trigger the "stop" signal
--- with the the desired code to indicate that the output has stopped
--- successfully.  See :ref:`output_signal_handler_reference` for more
--- information on output signals.
---
--- :c:func:`obs_output_set_last_error()` may be used in conjunction with
--- these error codes to optionally relay more detailed error information
--- to the user
---
--- :param code: | Can be one of the following values:
---              | OBS_OUTPUT_SUCCESS        - Successfully stopped
---              | OBS_OUTPUT_BAD_PATH       - The specified path was invalid
---              | OBS_OUTPUT_CONNECT_FAILED - Failed to connect to a server
---              | OBS_OUTPUT_INVALID_STREAM - Invalid stream path
---              | OBS_OUTPUT_ERROR          - Generic error
---              | OBS_OUTPUT_DISCONNECTED   - Unexpectedly disconnected
---              | OBS_OUTPUT_UNSUPPORTED    - The settings, video/audio format, or codecs are unsupported by this output
---              | OBS_OUTPUT_NO_SPACE       - Ran out of disk space
---
--- C definition: `void obs_output_signal_stop(obs_output_t *output, int code)`
--- @param output obs_output
--- @param code number
function obslua.obs_output_signal_stop(output, code) end

--- Starts the output.
---
--- :return: *true* if output successfully started, *false* otherwise.  If
---          the output failed to start,
---          :c:func:`obs_output_get_last_error()` may contain a specific
---          error string related to the reason
---
--- C definition: `bool obs_output_start(obs_output_t *output)`
--- @param output obs_output
--- @return boolean
function obslua.obs_output_start(output) end

--- Requests the output to stop.  The output will wait until all data is
--- sent up until the time the call was made, then when the output has
--- successfully stopped, it will send the "stop" signal.  See
--- :ref:`output_signal_handler_reference` for more information on output
--- signals.
---
--- C definition: `void obs_output_stop(obs_output_t *output)`
--- @param output obs_output
function obslua.obs_output_stop(output) end

--- Updates the settings for this output context.
---
--- C definition: `void obs_output_update(obs_output_t *output, obs_data_t *settings)`
--- @param output obs_output
--- @param settings obs_data
function obslua.obs_output_update(output, settings) end

--- Notifies modules that all modules have been loaded.
---
--- C definition: `void obs_post_load_modules(void)`
function obslua.obs_post_load_modules() end

--- Adds a boolean property.
---
--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_bool(obs_properties_t *props, const char *name, const char *description)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @return obs_property
function obslua.obs_properties_add_bool(props, name, description) end

--- Adds a button property to an obs_properties_t object.  The callback
--- takes two parameters:  the first parameter is the obs_properties_t
--- object, and the second parameter is the obs_property_t for the
--- button.
---
--- :param properties:   An obs_properties_t object.
--- :param setting_name: A setting identifier string.
--- :param text:         Button text.
--- :param callback:     Button callback.  This callback is automatically
---                      cleaned up.
---
--- C definition: Not available
--- @param properties unknown
--- @param setting_name unknown
--- @param text unknown
--- @param callback unknown
--- @return unknown
function obslua.obs_properties_add_button(properties, setting_name, text, callback) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_properties
--- @param param2 string
--- @param param3 string
--- @param param4 f_p_struct_obs_properties_p_struct_obs_property_p_void__bool
--- @param param5 ref_void*
function obslua.obs_properties_add_button2(param1, param2, param3, param4, param5) end

--- Adds a color property.
---
--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_color(obs_properties_t *props, const char *name, const char *description)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @return obs_property
function obslua.obs_properties_add_color(props, name, description) end

--- Adds a list in which the user can add/insert/remove items.
---
--- :param    name:         Setting identifier string
--- :param    description:  Localized name shown to user
--- :param    type:         Can be one of the following values:
---
---                         - **OBS_EDITABLE_LIST_TYPE_STRINGS** - An
---                           editable list of strings.
---                         - **OBS_EDITABLE_LIST_TYPE_FILES** - An
---                           editable list of files.
---                         - **OBS_EDITABLE_LIST_TYPE_FILES_AND_URLS** -
---                           An editable list of files and URLs.
---
--- :param    filter:       File filter to use if a file list
--- :param    default_path: Default path if a file list
--- :return:                The property
---
--- C definition: `obs_property_t *obs_properties_add_editable_list(obs_properties_t *props, const char *name, const char *description, enum obs_editable_list_type type, const char *filter, const char *default_path)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param type number
--- @param filter string
--- @param default_path string
--- @return obs_property
function obslua.obs_properties_add_editable_list(props, name, description, type, filter, default_path) end

--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :param    min:         Minimum value
--- :param    max:         Maximum value
--- :param    step:        Step value
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_float(obs_properties_t *props, const char *name, const char *description, double min, double max, double step)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param min number
--- @param max number
--- @param step number
--- @return obs_property
function obslua.obs_properties_add_float(props, name, description, min, max, step) end

--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :param    min:         Minimum value
--- :param    max:         Maximum value
--- :param    step:        Step value
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_float_slider(obs_properties_t *props, const char *name, const char *description, double min, double max, double step)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param min number
--- @param max number
--- @param step number
--- @return obs_property
function obslua.obs_properties_add_float_slider(props, name, description, min, max, step) end

--- Adds a font property.
---
--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_font(obs_properties_t *props, const char *name, const char *description)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @return obs_property
function obslua.obs_properties_add_font(props, name, description) end

--- Adds a frame rate property.
---
--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :return:               The property
---
--- Important Related Functions:
---
--- - :c:func:`obs_property_frame_rate_option_add`
--- - :c:func:`obs_property_frame_rate_fps_range_add`
--- - :c:func:`obs_property_frame_rate_option_insert`
--- - :c:func:`obs_property_frame_rate_fps_range_insert`
---
--- C definition: `obs_property_t *obs_properties_add_frame_rate(obs_properties_t *props, const char *name, const char *description)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @return obs_property
function obslua.obs_properties_add_frame_rate(props, name, description) end

--- Adds a property group.
---
--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :param    type:        Can be one of the following values:
---
---                        - **OBS_GROUP_NORMAL** - A normal group with just a name and content.
---                        - **OBS_GROUP_CHECKABLE** - A checkable group with a checkbox, name and content.
---
--- :param    group:       Group to add
---
--- :return:               The property
---
--- Important Related Functions:
---
--- - :c:func:`obs_property_group_type`
--- - :c:func:`obs_property_group_content`
--- - :c:func:`obs_properties_get_parent`
---
--- C definition: `obs_property_t *obs_properties_add_group(obs_properties_t *props, const char *name, const char *description, enum obs_group_type type, obs_properties_t *group)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param type number
--- @param group obs_properties
--- @return obs_property
function obslua.obs_properties_add_group(props, name, description, type, group) end

--- Adds an integer property.
---
--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :param    min:         Minimum value
--- :param    max:         Maximum value
--- :param    step:        Step value
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_int(obs_properties_t *props, const char *name, const char *description, int min, int max, int step)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param min number
--- @param max number
--- @param step number
--- @return obs_property
function obslua.obs_properties_add_int(props, name, description, min, max, step) end

--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :param    min:         Minimum value
--- :param    max:         Maximum value
--- :param    step:        Step value
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_int_slider(obs_properties_t *props, const char *name, const char *description, int min, int max, int step)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param min number
--- @param max number
--- @param step number
--- @return obs_property
function obslua.obs_properties_add_int_slider(props, name, description, min, max, step) end

--- Adds an integer/string/floating point item list.  This would be
--- implemented as a combo box in user interface.
---
--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :param    type:        Can be one of the following values:
---
---                        - **OBS_COMBO_TYPE_EDITABLE** - Can be edited.
---                          Only used with string lists.
---                        - **OBS_COMBO_TYPE_LIST** - Not editable.
---
--- :param    format:      Can be one of the following values:
---
---                        - **OBS_COMBO_FORMAT_INT** - Integer list
---                        - **OBS_COMBO_FORMAT_FLOAT** - Floating point
---                          list
---                        - **OBS_COMBO_FORMAT_STRING** - String list
---
--- :return:               The property
---
--- Important Related Functions:
---
--- - :c:func:`obs_property_list_add_string`
--- - :c:func:`obs_property_list_add_int`
--- - :c:func:`obs_property_list_add_float`
--- - :c:func:`obs_property_list_insert_string`
--- - :c:func:`obs_property_list_insert_int`
--- - :c:func:`obs_property_list_insert_float`
--- - :c:func:`obs_property_list_item_remove`
--- - :c:func:`obs_property_list_clear`
---
--- C definition: `obs_property_t *obs_properties_add_list(obs_properties_t *props, const char *name, const char *description, enum obs_combo_type type, enum obs_combo_format format)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param type number
--- @param format number
--- @return obs_property
function obslua.obs_properties_add_list(props, name, description, type, format) end

--- Adds a 'path' property.  Can be a directory or a file.
---
--- If target is a file path, the filters should be this format, separated by
--- double semi-colens, and extensions separated by space::
---
---   "Example types 1 and 2 (*.ex1 *.ex2);;Example type 3 (*.ex3)"
---
--- :param    name:         Setting identifier string
--- :param    description:  Localized name shown to user
--- :param    type:         Can be one of the following values:
---
---                         - **OBS_PATH_FILE** - File (for reading)
---                         - **OBS_PATH_FILE_SAVE** - File (for writing)
---                         - **OBS_PATH_DIRECTORY** - Directory
---
--- :param    filter:       If type is a file path, then describes the file filter
---                         that the user can browse.  Items are separated via
---                         double semi-colens.  If multiple file types in a
---                         filter, separate with space.
--- :param    default_path: The default path to start in, or *NULL*
--- :return:                The property
---
--- C definition: `obs_property_t *obs_properties_add_path(obs_properties_t *props, const char *name, const char *description, enum obs_path_type type, const char *filter, const char *default_path)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param type number
--- @param filter string
--- @param default_path string
--- @return obs_property
function obslua.obs_properties_add_path(props, name, description, type, filter, default_path) end

--- :param    name:        Setting identifier string
--- :param    description: Localized name shown to user
--- :param    type:        Can be one of the following values:
---
---                        - **OBS_TEXT_DEFAULT** - Single line of text
---                        - **OBS_TEXT_PASSWORD** - Single line of text (passworded)
---                        - **OBS_TEXT_MULTILINE** - Multi-line text
---
--- :return:               The property
---
--- C definition: `obs_property_t *obs_properties_add_text(obs_properties_t *props, const char *name, const char *description, enum obs_text_type type)`
--- @param props obs_properties
--- @param name string
--- @param description string
--- @param type number
--- @return obs_property
function obslua.obs_properties_add_text(props, name, description, type) end

--- Applies settings to the properties by calling all the necessary
--- modification callbacks
---
--- C definition: `void obs_properties_apply_settings(obs_properties_t *props, obs_data_t *settings)`
--- @param props obs_properties
--- @param settings obs_data
function obslua.obs_properties_apply_settings(props, settings) end

--- :return: A new properties object.
---
--- C definition: `obs_properties_t *obs_properties_create(void)`
--- @return obs_properties
function obslua.obs_properties_create() end

--- Creates a new properties object with specific private data *param*
--- associated with the object, and is automatically freed with the
--- object when the properties are destroyed via the *destroy* function.
---
--- :return: A new properties object.
---
--- C definition: `obs_properties_t *obs_properties_create_param(void *param, void (*destroy)(void *param))`
--- @param param ref_void*
--- @param destroy f_p_void__void
--- @return obs_properties
function obslua.obs_properties_create_param(param, destroy) end

--- C definition: `void obs_properties_destroy(obs_properties_t *props)`
--- @param props obs_properties
function obslua.obs_properties_destroy(props) end

--- :return: The first property in the properties object.
---
--- C definition: `obs_property_t *obs_properties_first(obs_properties_t *props)`
--- @param props obs_properties
--- @return obs_property
function obslua.obs_properties_first(props) end

--- :param property: The name of the property to get
--- :return:         A specific property or *NULL* if not found
---
--- C definition: `obs_property_t *obs_properties_get(obs_properties_t *props, const char *property)`
--- @param props obs_properties
--- @param property string
--- @return obs_property
function obslua.obs_properties_get(props, property) end

--- :param flags: 0 or a bitwise OR combination of one of the following
---               values:
---
---               - OBS_PROPERTIES_DEFER_UPDATE - A hint that tells the
---                 front-end to defers updating the settings until the
---                 user has finished editing all properties rather than
---                 immediately updating any settings
---
--- C definition: `uint32_t obs_properties_get_flags(obs_properties_t *props)`
--- @param props obs_properties
--- @return number
function obslua.obs_properties_get_flags(props) end

--- Sets custom data associated with this properties object.  If private
--- data is already associated with the object, that private data will be
--- destroyed before assigning new private data to it.
---
--- C definition: `void *obs_properties_get_param(obs_properties_t *props)`
--- @param props obs_properties
--- @return void
function obslua.obs_properties_get_param(props) end

--- C definition: `obs_properties_t *obs_properties_get_parent(obs_properties_t *props)`
--- @param props obs_properties
--- @return obs_properties
function obslua.obs_properties_get_parent(props) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_properties
--- @param param2 string
function obslua.obs_properties_remove_by_name(param1, param2) end

--- :param flags: 0 or a bitwise OR combination of one of the following
---               values:
---
---               - OBS_PROPERTIES_DEFER_UPDATE - A hint that tells the
---                 front-end to defers updating the settings until the
---                 user has finished editing all properties rather than
---                 immediately updating any settings
---
--- C definition: `void obs_properties_set_flags(obs_properties_t *props, uint32_t flags)`
--- @param props obs_properties
--- @param flags number
function obslua.obs_properties_set_flags(props, flags) end

--- Sets custom data associated with this properties object.  If private
--- data is already associated with the object, that private data will be
--- destroyed before assigning new private data to it.
---
--- C definition: `void obs_properties_set_param(obs_properties_t *props, void *param, void (*destroy)(void *param))`
--- @param props obs_properties
--- @param param ref_void*
--- @param destroy f_p_void__void
function obslua.obs_properties_set_param(props, param, destroy) end

--- C definition: `bool obs_property_button_clicked(obs_property_t *p, void *obj)`
--- @param p obs_property
--- @param obj ref_void*
--- @return boolean
function obslua.obs_property_button_clicked(p, obj) end

--- :return: The actual localized display name of the property
---
--- *(Author's note: This one should have been the "name")*
---
--- C definition: `const char *           obs_property_description(obs_property_t *p)`
--- @param p obs_property
--- @return string
function obslua.obs_property_description(p) end

--- C definition: `const char *obs_property_editable_list_default_path(obs_property_t *p)`
--- @param p obs_property
--- @return string
function obslua.obs_property_editable_list_default_path(p) end

--- C definition: `const char *obs_property_editable_list_filter(obs_property_t *p)`
--- @param p obs_property
--- @return string
function obslua.obs_property_editable_list_filter(p) end

--- C definition: `enum obs_editable_list_type obs_property_editable_list_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_editable_list_type(p) end

--- C definition: `bool                   obs_property_enabled(obs_property_t *p)`
--- @param p obs_property
--- @return boolean
function obslua.obs_property_enabled(p) end

--- C definition: `double                 obs_property_float_max(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_float_max(p) end

--- C definition: `double                 obs_property_float_min(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_float_min(p) end

--- C definition: `void obs_property_float_set_limits(obs_property_t *p, double min, double max, double step)`
--- @param p obs_property
--- @param min number
--- @param max number
--- @param step number
function obslua.obs_property_float_set_limits(p, min, max, step) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_property
--- @param param2 string
function obslua.obs_property_float_set_suffix(param1, param2) end

--- C definition: `double                 obs_property_float_step(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_float_step(p) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_property
function obslua.obs_property_float_suffix(param1) end

--- C definition: `enum obs_number_type   obs_property_float_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_float_type(p) end

--- C definition: `void obs_property_frame_rate_clear(obs_property_t *p)`
--- @param p obs_property
function obslua.obs_property_frame_rate_clear(p) end

--- C definition: `size_t obs_property_frame_rate_fps_range_add(obs_property_t *p, struct media_frames_per_second min, struct media_frames_per_second max)`
--- @param p obs_property
--- @param min media_frames_per_second
--- @param max media_frames_per_second
--- @return number
function obslua.obs_property_frame_rate_fps_range_add(p, min, max) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_property
--- @param param2 number
--- @param param3 media_frames_per_second
--- @param param4 media_frames_per_second
function obslua.obs_property_frame_rate_fps_range_insert(param1, param2, param3, param4) end

--- C definition: `struct media_frames_per_second obs_property_frame_rate_fps_range_max( obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return media_frames_per_second
function obslua.obs_property_frame_rate_fps_range_max(p, idx) end

--- C definition: `struct media_frames_per_second obs_property_frame_rate_fps_range_min( obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return media_frames_per_second
function obslua.obs_property_frame_rate_fps_range_min(p, idx) end

--- C definition: `void obs_property_frame_rate_fps_ranges_clear(obs_property_t *p)`
--- @param p obs_property
function obslua.obs_property_frame_rate_fps_ranges_clear(p) end

--- C definition: `size_t      obs_property_frame_rate_fps_ranges_count(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_frame_rate_fps_ranges_count(p) end

--- C definition: `size_t obs_property_frame_rate_option_add(obs_property_t *p, const char *name, const char *description)`
--- @param p obs_property
--- @param name string
--- @param description string
--- @return number
function obslua.obs_property_frame_rate_option_add(p, name, description) end

--- C definition: `const char *obs_property_frame_rate_option_description( obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return string
function obslua.obs_property_frame_rate_option_description(p, idx) end

--- C definition: `void obs_property_frame_rate_option_insert(obs_property_t *p, size_t idx, const char *name, const char *description)`
--- @param p obs_property
--- @param idx number
--- @param name string
--- @param description string
function obslua.obs_property_frame_rate_option_insert(p, idx, name, description) end

--- C definition: `const char *obs_property_frame_rate_option_name(obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return string
function obslua.obs_property_frame_rate_option_name(p, idx) end

--- C definition: `void obs_property_frame_rate_options_clear(obs_property_t *p)`
--- @param p obs_property
function obslua.obs_property_frame_rate_options_clear(p) end

--- C definition: `size_t      obs_property_frame_rate_options_count(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_frame_rate_options_count(p) end

--- :return: One of the following values:
---
---          - OBS_PROPERTY_INVALID
---          - OBS_PROPERTY_BOOL
---          - OBS_PROPERTY_INT
---          - OBS_PROPERTY_FLOAT
---          - OBS_PROPERTY_TEXT
---          - OBS_PROPERTY_PATH
---          - OBS_PROPERTY_LIST
---          - OBS_PROPERTY_COLOR
---          - OBS_PROPERTY_BUTTON
---          - OBS_PROPERTY_FONT
---          - OBS_PROPERTY_EDITABLE_LIST
---          - OBS_PROPERTY_FRAME_RATE
---          - OBS_PROPERTY_GROUP
---
--- C definition: `enum obs_property_type obs_property_get_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_get_type(p) end

--- C definition: `obs_properties_t *obs_property_group_content(obs_property_t *p)`
--- @param p obs_property
--- @return obs_properties
function obslua.obs_property_group_content(p) end

---   :return: One of the following values:
---
---          - OBS_COMBO_INVALID
---          - OBS_GROUP_NORMAL
---          - OBS_GROUP_CHECKABLE
---
--- C definition: `enum obs_group_type obs_property_group_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_group_type(p) end

--- C definition: `int                    obs_property_int_max(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_int_max(p) end

--- C definition: `int                    obs_property_int_min(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_int_min(p) end

--- C definition: `void obs_property_int_set_limits(obs_property_t *p, int min, int max, int step)`
--- @param p obs_property
--- @param min number
--- @param max number
--- @param step number
function obslua.obs_property_int_set_limits(p, min, max, step) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_property
--- @param param2 string
function obslua.obs_property_int_set_suffix(param1, param2) end

--- C definition: `int                    obs_property_int_step(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_int_step(p) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_property
function obslua.obs_property_int_suffix(param1) end

--- C definition: `enum obs_number_type   obs_property_int_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_int_type(p) end

--- Adds a floating point to a floating point list.
---
--- C definition: `size_t obs_property_list_add_float(obs_property_t *p, const char *name, double val)`
--- @param p obs_property
--- @param name string
--- @param val number
--- @return number
function obslua.obs_property_list_add_float(p, name, val) end

--- Adds an integer to a integer list.
---
--- C definition: `size_t obs_property_list_add_int(obs_property_t *p, const char *name, long long val)`
--- @param p obs_property
--- @param name string
--- @param val number
--- @return number
function obslua.obs_property_list_add_int(p, name, val) end

--- Adds a string to a string list.
---
--- C definition: `size_t obs_property_list_add_string(obs_property_t *p, const char *name, const char *val)`
--- @param p obs_property
--- @param name string
--- @param val string
--- @return number
function obslua.obs_property_list_add_string(p, name, val) end

--- C definition: `void obs_property_list_clear(obs_property_t *p)`
--- @param p obs_property
function obslua.obs_property_list_clear(p) end

--- C definition: `enum obs_combo_format  obs_property_list_format(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_list_format(p) end

--- Inserts a floating point in to a floating point list.
---
--- C definition: `void obs_property_list_insert_float(obs_property_t *p, size_t idx, const char *name, double val)`
--- @param p obs_property
--- @param idx number
--- @param name string
--- @param val number
function obslua.obs_property_list_insert_float(p, idx, name, val) end

--- Inserts an integer in to an integer list.
---
--- C definition: `void obs_property_list_insert_int(obs_property_t *p, size_t idx, const char *name, long long val)`
--- @param p obs_property
--- @param idx number
--- @param name string
--- @param val number
function obslua.obs_property_list_insert_int(p, idx, name, val) end

--- Inserts a string in to a string list.
---
--- C definition: `void obs_property_list_insert_string(obs_property_t *p, size_t idx, const char *name, const char *val)`
--- @param p obs_property
--- @param idx number
--- @param name string
--- @param val string
function obslua.obs_property_list_insert_string(p, idx, name, val) end

--- C definition: `size_t      obs_property_list_item_count(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_list_item_count(p) end

--- C definition: `void obs_property_list_item_disable(obs_property_t *p, size_t idx, bool disabled)`
--- @param p obs_property
--- @param idx number
--- @param disabled boolean
function obslua.obs_property_list_item_disable(p, idx, disabled) end

--- C definition: `bool obs_property_list_item_disabled(obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return boolean
function obslua.obs_property_list_item_disabled(p, idx) end

--- C definition: `double      obs_property_list_item_float(obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return number
function obslua.obs_property_list_item_float(p, idx) end

--- C definition: `long long   obs_property_list_item_int(obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return number
function obslua.obs_property_list_item_int(p, idx) end

--- C definition: `const char *obs_property_list_item_name(obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return string
function obslua.obs_property_list_item_name(p, idx) end

--- C definition: `void obs_property_list_item_remove(obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
function obslua.obs_property_list_item_remove(p, idx) end

--- C definition: `const char *obs_property_list_item_string(obs_property_t *p, size_t idx)`
--- @param p obs_property
--- @param idx number
--- @return string
function obslua.obs_property_list_item_string(p, idx) end

--- C definition: `enum obs_combo_type    obs_property_list_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_list_type(p) end

--- :return: A detailed description of what the setting is used for.
---          Usually used with things like tooltips.
---
--- C definition: `const char *           obs_property_long_description(obs_property_t *p)`
--- @param p obs_property
--- @return string
function obslua.obs_property_long_description(p) end

--- C definition: `bool obs_property_modified(obs_property_t *p, obs_data_t *settings)`
--- @param p obs_property
--- @param settings obs_data
--- @return boolean
function obslua.obs_property_modified(p, settings) end

--- :return: The setting identifier string of the property
---
--- *(Author's Note: "name" was a bad name to use here.  Should have been
--- "setting")*
---
--- C definition: `const char *           obs_property_name(obs_property_t *p)`
--- @param p obs_property
--- @return string
function obslua.obs_property_name(p) end

--- :param p: Pointer to the pointer of the next property
--- :return: *true* if successful, *false* if no more properties
---
--- C definition: `bool                   obs_property_next(obs_property_t **p)`
--- @param p p_obs_property
--- @return boolean
function obslua.obs_property_next(p) end

--- C definition: `const char *           obs_property_path_default_path(obs_property_t *p)`
--- @param p obs_property
--- @return string
function obslua.obs_property_path_default_path(p) end

--- C definition: `const char *           obs_property_path_filter(obs_property_t *p)`
--- @param p obs_property
--- @return string
function obslua.obs_property_path_filter(p) end

--- C definition: `enum obs_path_type     obs_property_path_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_path_type(p) end

--- Sets the displayed localized name of the property, shown to the user.
---
--- C definition: `void obs_property_set_description(obs_property_t *p, const char *description)`
--- @param p obs_property
--- @param description string
function obslua.obs_property_set_description(p, description) end

--- C definition: `void obs_property_set_enabled(obs_property_t *p, bool enabled)`
--- @param p obs_property
--- @param enabled boolean
function obslua.obs_property_set_enabled(p, enabled) end

--- Sets the localized long description of the property, usually shown to
--- a user via tooltip.
---
--- C definition: `void obs_property_set_long_description(obs_property_t *p, const char *long_description)`
--- @param p obs_property
--- @param long_description string
function obslua.obs_property_set_long_description(p, long_description) end

--- Allows the ability to change the properties depending on what
--- settings are used by the user.
---
--- Relevant data types used with these functions:
---
--- .. code:: cpp
---
--- typedef bool (*obs_property_modified_t)(obs_properties_t *props,
---                 obs_property_t *property, obs_data_t *settings);
--- typedef bool (*obs_property_modified2_t)(void *priv,
---                 obs_properties_t *props, obs_property_t *property,
---                 obs_data_t *settings);
---
--- C definition: `void obs_property_set_modified_callback(obs_property_t *p, obs_property_modified_t modified)`
--- @param p obs_property_t*
--- @param modified obs_property_modified_t
function obslua.obs_property_set_modified_callback(p, modified) end

--- Allows the ability to change the properties depending on what
--- settings are used by the user.
---
--- Relevant data types used with these functions:
---
--- .. code:: cpp
---
--- typedef bool (*obs_property_modified_t)(obs_properties_t *props,
---                 obs_property_t *property, obs_data_t *settings);
--- typedef bool (*obs_property_modified2_t)(void *priv,
---                 obs_properties_t *props, obs_property_t *property,
---                 obs_data_t *settings);
---
--- C definition: `void obs_property_set_modified_callback2(obs_property_t *p, obs_property_modified2_t modified2, void *priv)`
--- @param p obs_property
--- @param modified2 f_p_void_p_struct_obs_properties_p_struct_obs_property_p_struct_obs_data__bool
--- @param priv ref_void*
function obslua.obs_property_set_modified_callback2(p, modified2, priv) end

--- C definition: `void obs_property_set_visible(obs_property_t *p, bool visible)`
--- @param p obs_property
--- @param visible boolean
function obslua.obs_property_set_visible(p, visible) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_property
function obslua.obs_property_text_monospace(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_property
--- @param param2 boolean
function obslua.obs_property_text_set_monospace(param1, param2) end

--- C definition: `enum obs_text_type     obs_property_text_type(obs_property_t *p)`
--- @param p obs_property
--- @return number
function obslua.obs_property_text_type(p) end

--- C definition: `bool                   obs_property_visible(obs_property_t *p)`
--- @param p obs_property
--- @return boolean
function obslua.obs_property_visible(p) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 f_p_void__void
--- @param param3 ref_void*
--- @param param4 boolean
function obslua.obs_queue_task(param1, param2, param3, param4) end

--- Registers a source type.  Typically used in
--- :c:func:`obs_module_load()` or in the program's initialization phase.
---
--- C definition: `void obs_register_source(struct obs_source_info *info)`
--- @param info obs_source_info*
function obslua.obs_register_source(info) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_remove_data_path(param1) end

--- **Lua only:** Removes a primary output render callback.
---
--- :param callback: Render callback.
---
--- C definition: Not available
--- @param callback unknown
--- @return unknown
function obslua.obs_remove_main_render_callback(callback) end

--- Adds/removes a raw video callback.  Allows the ability to obtain raw
--- video frames without necessarily using an output.
---
--- :param conversion: Specifies conversion requirements.  Can be NULL.
--- :param callback:   The callback that receives raw video frames.
--- :param param:      The private data associated with the callback.
---
--- Primary signal/procedure handlers
--- C definition: `void obs_remove_raw_video_callback(void (*callback)(void *param, struct video_data *frame), void *param)`
--- @param callback f_p_void_p_struct_video_data__void
--- @param param ref_void*
function obslua.obs_remove_raw_video_callback(callback, param) end

--- obs_remove_tick_callback not found in OBS documentation nor C wrapper
obslua.obs_remove_tick_callback = function() end

--- Renders the main output texture.  Useful for rendering a preview pane
--- of the main output.
---
--- C definition: `void obs_render_main_texture(void)`
function obslua.obs_render_main_texture() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_render_main_texture_src_color_only() end

--- Sets base audio output format/channels/samples/etc.
---
--- Note: Cannot reset base audio if an output is currently active.
---
--- :return: *true* if successful, *false* otherwise
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- struct obs_audio_info {
---         uint32_t            samples_per_sec;
---         enum speaker_layout speakers;
--- };
---
--- C definition: `bool obs_reset_audio(const struct obs_audio_info *oai)`
--- @param oai obs_audio_info
--- @return boolean
function obslua.obs_reset_audio(oai) end

--- Sets base video output base resolution/fps/format.
---
--- Note: This data cannot be changed if an output is currently active.
---
--- Note: The graphics module cannot be changed without fully destroying
--- the OBS context.
---
--- :param   ovi: Pointer to an obs_video_info structure containing the
---               specification of the graphics subsystem,
--- :return:      | OBS_VIDEO_SUCCESS          - Success
---               | OBS_VIDEO_NOT_SUPPORTED    - The adapter lacks capabilities
---               | OBS_VIDEO_INVALID_PARAM    - A parameter is invalid
---               | OBS_VIDEO_CURRENTLY_ACTIVE - Video is currently active
---               | OBS_VIDEO_MODULE_NOT_FOUND - The graphics module is not found
---               | OBS_VIDEO_FAIL             - Generic failure
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- struct obs_video_info {
---         /**
---          * Graphics module to use (usually "libobs-opengl" or "libobs-d3d11")
---          */
---         const char          *graphics_module;
---
---         uint32_t            fps_num;       /**< Output FPS numerator */
---         uint32_t            fps_den;       /**< Output FPS denominator */
---
---         uint32_t            base_width;    /**< Base compositing width */
---         uint32_t            base_height;   /**< Base compositing height */
---
---         uint32_t            output_width;  /**< Output width */
---         uint32_t            output_height; /**< Output height */
---         enum video_format   output_format; /**< Output format */
---
---         /** Video adapter index to use (NOTE: avoid for optimus laptops) */
---         uint32_t            adapter;
---
---         /** Use shaders to convert to different color formats */
---         bool                gpu_conversion;
---
---         enum video_colorspace colorspace;  /**< YUV type (if YUV) */
---         enum video_range_type range;       /**< YUV range (if YUV) */
---
---         enum obs_scale_type scale_type;    /**< How to scale if scaling */
--- };
---
--- C definition: `int obs_reset_video(struct obs_video_info *ovi)`
--- @param ovi obs_video_info
--- @return number
function obslua.obs_reset_video(ovi) end

--- :return: A new reference to a source's saved data
---
--- C definition: `obs_data_t *obs_save_source(obs_source_t *source)`
--- @param source obs_source
--- @return obs_data
function obslua.obs_save_source(source) end

--- :return: A data array with the saved data of all active sources
---
--- C definition: `obs_data_array_t *obs_save_sources(void)`
--- @return obs_data_array
function obslua.obs_save_sources() end

--- :return: A data array with the saved data of all active sources,
---          filtered by the *cb* function
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef bool (*obs_save_source_filter_cb)(void *data, obs_source_t *source);
---
--- C definition: `obs_data_array_t *obs_save_sources_filtered(obs_save_source_filter_cb cb, void *data)`
--- @param cb f_p_void_p_struct_obs_source__bool
--- @param data ref_void*
--- @return obs_data_array
function obslua.obs_save_sources_filtered(cb, data) end

--- :return: A new scene item for a source within a scene.  Does not
---          increment the reference
---
--- C definition: `obs_sceneitem_t *obs_scene_add(obs_scene_t *scene, obs_source_t *source)`
--- @param scene obs_scene
--- @param source obs_source
--- @return obs_scene_item
function obslua.obs_scene_add(scene, source) end

--- Adds a group with the specified name.  Does not signal the scene with
--- the *refresh* signal.
---
--- :param scene: Scene to add the group to
--- :param name:  Name of the group
--- :return:      The new group's scene item
---
--- C definition: `obs_sceneitem_t *obs_scene_add_group(obs_scene_t *scene, const char *name)`
--- @param scene obs_scene
--- @param name string
--- @return obs_scene_item
function obslua.obs_scene_add_group(scene, name) end

--- Adds a group with the specified name.
---
--- :param scene:  Scene to add the group to
--- :param name:   Name of the group
--- :param signal: If *true*, signals the scene with the *refresh*
---                signal
--- :return:       The new group's scene item
---
--- C definition: `obs_sceneitem_t *obs_scene_add_group2(obs_scene_t *scene, const char *name, bool signal)`
--- @param scene obs_scene
--- @param name string
--- @param signal boolean
--- @return obs_scene_item
function obslua.obs_scene_add_group2(scene, name, signal) end

--- Adds/releases a reference to a scene.
---
--- C definition: `void obs_scene_addref(obs_scene_t *scene)`
--- @param scene obs_scene
function obslua.obs_scene_addref(scene) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_scene
--- @param param2 f_p_void_p_struct_obs_scene__void
--- @param param3 ref_void*
function obslua.obs_scene_atomic_update(param1, param2, param3) end

--- :param name: Name of the scene source.  If it's not unique, it will
---              be made unique
--- :return:     A reference to a scene
---
--- C definition: `obs_scene_t *obs_scene_create(const char *name)`
--- @param name string
--- @return obs_scene
function obslua.obs_scene_create(name) end

--- :param name: Name of the scene source.  Does not have to be unique,
---              or can be *NULL*
--- :return:     A reference to a private scene
---
--- C definition: `obs_scene_t *obs_scene_create_private(const char *name)`
--- @param name string
--- @return obs_scene
function obslua.obs_scene_create_private(name) end

--- Duplicates a scene.  When a scene is duplicated, its sources can be
--- just referenced, or fully duplicated.
---
--- :param name: Name of the new scene source
---
--- :param type:  | Type of duplication:
---               | OBS_SCENE_DUP_REFS         - Duplicates the scene, but scene items are only duplicated with references
---               | OBS_SCENE_DUP_COPY         - Duplicates the scene, and scene items are also fully duplicated when possible
---               | OBS_SCENE_DUP_PRIVATE_REFS - Duplicates with references, but the scene is a private source
---               | OBS_SCENE_DUP_PRIVATE_COPY - Fully duplicates scene items when possible, but the scene and duplicates sources are private sources
---
--- :return:     A reference to a new scene
---
--- C definition: `obs_scene_t *obs_scene_duplicate(obs_scene_t *scene, const char *name, enum obs_scene_duplicate_type type)`
--- @param scene obs_scene
--- @param name string
--- @param type number
--- @return obs_scene
function obslua.obs_scene_duplicate(scene, name, type) end

--- Enumerates scene items within a scene.
---
--- :param scene: obs_scene_t object to enumerate items from.
--- :return:      List of scene items.  Release with
---               :py:func:`sceneitem_list_release()`.
---
--- C definition: Not available
--- @param scene obs_scene
--- @param param2 f_p_struct_obs_scene_p_struct_obs_scene_item_p_void__bool
--- @param param3 ref_void*
--- @return unknown
function obslua.obs_scene_enum_items(scene, param2, param3) end

--- :param id: The unique numeric identifier of the scene item
--- :return:   The scene item if found, otherwise *NULL* if not found
---
--- C definition: `obs_sceneitem_t *obs_scene_find_sceneitem_by_id(obs_scene_t *scene, int64_t id)`
--- @param scene obs_scene
--- @param id number
--- @return obs_scene_item
function obslua.obs_scene_find_sceneitem_by_id(scene, id) end

--- :param name: The name of the source to find
--- :return:     The scene item if found, otherwise *NULL* if not found
---
--- C definition: `obs_sceneitem_t *obs_scene_find_source(obs_scene_t *scene, const char *name)`
--- @param scene obs_scene
--- @param name string
--- @return obs_scene_item
function obslua.obs_scene_find_source(scene, name) end

--- Same as obs_scene_find_source, but also searches groups within the
--- scene.
---
--- :param name: The name of the source to find
--- :return:     The scene item if found, otherwise *NULL* if not found
---
--- C definition: `obs_sceneitem_t *obs_scene_find_source_recursive(obs_scene_t *scene, const char *name)`
--- @param scene obs_scene
--- @param name string
--- @return obs_scene_item
function obslua.obs_scene_find_source_recursive(scene, name) end

--- :return: The scene context, or *NULL* if not a scene.  Does not
---          increase the reference
---
--- C definition: `obs_scene_t *obs_scene_from_source(const obs_source_t *source)`
--- @param source obs_source
--- @return obs_scene
function obslua.obs_scene_from_source(source) end

--- Finds a group within a scene by its name.
---
--- :param scene: Scene to find the group within
--- :param name:  The name of the group to find
--- :return:      The group scene item, or *NULL* if not found
---
--- C definition: `obs_sceneitem_t *obs_scene_get_group(obs_scene_t *scene, const char *name)`
--- @param scene obs_scene
--- @param name string
--- @return obs_scene_item
function obslua.obs_scene_get_group(scene, name) end

--- :return: The scene's source.  Does not increment the reference
---
--- C definition: `obs_source_t *obs_scene_get_source(const obs_scene_t *scene)`
--- @param scene obs_scene
--- @return obs_source
function obslua.obs_scene_get_source(scene) end

--- Creates a group out of the specified scene items.  The group will be
--- inserted at the top scene item.  Does not signal the scene with the
--- *refresh* signal.
---
--- :param scene: Scene to add the group to
--- :param name:  Name of the group
--- :param items: Array of scene items to put in a group
--- :param count: Number of scene items in the array
--- :return:      The new group's scene item
---
--- C definition: `obs_sceneitem_t *obs_scene_insert_group(obs_scene_t *scene, const char *name, obs_sceneitem_t **items, size_t count)`
--- @param scene obs_scene
--- @param name string
--- @param items p_obs_scene_item
--- @param count number
--- @return obs_scene_item
function obslua.obs_scene_insert_group(scene, name, items, count) end

--- Creates a group out of the specified scene items.  The group will be
--- inserted at the top scene item.  Does not signal a refresh.
---
--- :param scene: Scene to add the group to
--- :param name:  Name of the group
--- :param items: Array of scene items to put in a group
--- :param count: Number of scene items in the array
--- :param signal: If *true*, signals the scene with the *refresh*
---                signal
--- :return:      The new group's scene item
---
--- C definition: `obs_sceneitem_t *obs_scene_insert_group2(obs_scene_t *scene, const char *name, obs_sceneitem_t **items, size_t count, bool signal)`
--- @param scene obs_scene
--- @param name string
--- @param items p_obs_scene_item
--- @param count number
--- @param signal boolean
--- @return obs_scene_item
function obslua.obs_scene_insert_group2(scene, name, items, count, signal) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_scene
function obslua.obs_scene_is_group(param1) end

--- Adds/releases a reference to a scene.
---
--- C definition: `void obs_scene_release(obs_scene_t *scene)`
--- @param scene obs_scene
function obslua.obs_scene_release(scene) end

--- Reorders items within a scene.
---
--- C definition: `bool obs_scene_reorder_items(obs_scene_t *scene, obs_sceneitem_t * const *item_order, size_t item_order_size)`
--- @param scene obs_scene
--- @param item_order p_obs_scene_item
--- @param item_order_size number
--- @return boolean
function obslua.obs_scene_reorder_items(scene, item_order, item_order_size) end

--- Reorders items within a scene with groups and group sub-items.
---
--- C definition: `bool obs_scene_reorder_items2(obs_scene_t *scene, struct obs_sceneitem_order_info *item_order, size_t item_order_size)`
--- @param scene obs_scene
--- @param item_order obs_sceneitem_order_info
--- @param item_order_size number
--- @return boolean
function obslua.obs_scene_reorder_items2(scene, item_order, item_order_size) end

--- Adds/releases a reference to a scene item.
---
--- C definition: `void obs_sceneitem_addref(obs_sceneitem_t *item)`
--- @param item obs_scene_item
function obslua.obs_sceneitem_addref(item) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_scene_item
function obslua.obs_sceneitem_defer_group_resize_begin(param1) end

--- Allows the ability to call any one of the transform functions on
--- scene items within a group without updating the internal matrices of
--- the group until obs_sceneitem_defer_group_resize_end has been called.
---
--- This is necessary if the user is resizing items while they are within
--- a group, as the group's transform will automatically update its
--- transform every frame otherwise.
--- C definition: `void obs_sceneitem_defer_group_resize_end(obs_sceneitem_t *item)`
--- @param item obs_scene_item
function obslua.obs_sceneitem_defer_group_resize_end(item) end

--- Allows the ability to call any one of the transform functions without
--- updating the internal matrices until obs_sceneitem_defer_update_end
--- has been called.
---
--- C definition: `void obs_sceneitem_defer_update_begin(obs_sceneitem_t *item)`
--- @param item obs_scene_item
function obslua.obs_sceneitem_defer_update_begin(item) end

--- Allows the ability to call any one of the transform functions without
--- updating the internal matrices until obs_sceneitem_defer_update_end
--- has been called.
---
--- C definition: `void obs_sceneitem_defer_update_end(obs_sceneitem_t *item)`
--- @param item obs_scene_item
function obslua.obs_sceneitem_defer_update_end(item) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_scene_item
function obslua.obs_sceneitem_force_update_transform(param1) end

--- Sets/gets the alignment of the scene item relative to its position.
---
--- :param alignment: | Can be any bitwise OR combination of:
---                   | OBS_ALIGN_CENTER
---                   | OBS_ALIGN_LEFT
---                   | OBS_ALIGN_RIGHT
---                   | OBS_ALIGN_TOP
---                   | OBS_ALIGN_BOTTOM
---
--- C definition: `uint32_t obs_sceneitem_get_alignment(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return number
function obslua.obs_sceneitem_get_alignment(item) end

--- Sets/gets the bounding box width/height of the scene item.
---
--- C definition: `void obs_sceneitem_get_bounds(const obs_sceneitem_t *item, struct vec2 *bounds)`
--- @param item obs_scene_item
--- @param bounds vec2
function obslua.obs_sceneitem_get_bounds(item, bounds) end

--- Sets/gets the alignment of the source within the bounding box.
---
--- :param alignment: | Can be any bitwise OR combination of:
---                   | OBS_ALIGN_CENTER
---                   | OBS_ALIGN_LEFT
---                   | OBS_ALIGN_RIGHT
---                   | OBS_ALIGN_TOP
---                   | OBS_ALIGN_BOTTOM
---
--- C definition: `uint32_t obs_sceneitem_get_bounds_alignment(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return number
function obslua.obs_sceneitem_get_bounds_alignment(item) end

--- Sets/gets the bounding box type of a scene item.  Bounding boxes are
--- used to stretch/position the source relative to a specific bounding
--- box of a specific size.
---
--- :param type: | Can be one of the following values:
---              | OBS_BOUNDS_NONE            - No bounding box
---              | OBS_BOUNDS_STRETCH         - Stretch to the bounding box without preserving aspect ratio
---              | OBS_BOUNDS_SCALE_INNER     - Scales with aspect ratio to inner bounding box rectangle
---              | OBS_BOUNDS_SCALE_OUTER     - Scales with aspect ratio to outer bounding box rectangle
---              | OBS_BOUNDS_SCALE_TO_WIDTH  - Scales with aspect ratio to the bounding box width
---              | OBS_BOUNDS_SCALE_TO_HEIGHT - Scales with aspect ratio to the bounding box height
---              | OBS_BOUNDS_MAX_ONLY        - Scales with aspect ratio, but only to the size of the source maximum
---
--- C definition: `enum obs_bounds_type obs_sceneitem_get_bounds_type(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return number
function obslua.obs_sceneitem_get_bounds_type(item) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_scene_item
--- @param param2 vec2
function obslua.obs_sceneitem_get_box_scale(param1, param2) end

--- Gets the transform matrix of the scene item used for the bounding box
--- or edges of the scene item.
---
--- C definition: `void obs_sceneitem_get_box_transform(const obs_sceneitem_t *item, struct matrix4 *transform)`
--- @param item obs_scene_item
--- @param transform matrix4
function obslua.obs_sceneitem_get_box_transform(item, transform) end

--- Sets/gets the cropping of the scene item.
---
--- C definition: `void obs_sceneitem_get_crop(const obs_sceneitem_t *item, struct obs_sceneitem_crop *crop)`
--- @param item obs_scene_item
--- @param crop obs_sceneitem_crop
function obslua.obs_sceneitem_get_crop(item, crop) end

--- Gets the transform matrix of the scene item used for drawing the
--- source.
---
--- C definition: `void obs_sceneitem_get_draw_transform(const obs_sceneitem_t *item, struct matrix4 *transform)`
--- @param item obs_scene_item
--- @param transform matrix4
function obslua.obs_sceneitem_get_draw_transform(item, transform) end

--- Returns the parent group of a scene item.
---
--- :param item: Scene item to get the group of
--- :return:     The parent group of the scene item, or *NULL* if not in
---              a group
---
--- C definition: `obs_sceneitem_t *obs_sceneitem_get_group(obs_sceneitem_t *item)`
--- @param item obs_scene
--- @param param2 obs_scene_item
--- @return obs_scene_item
function obslua.obs_sceneitem_get_group(item, param2) end

--- :return: The unique numeric identifier of the scene item.
---
--- C definition: `int64_t obs_sceneitem_get_id(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return number
function obslua.obs_sceneitem_get_id(item) end

--- Sets/gets the transform information of the scene item.
---
--- C definition: `void obs_sceneitem_get_info(const obs_sceneitem_t *item, struct obs_transform_info *info)`
--- @param item obs_scene_item
--- @param info obs_transform_info
function obslua.obs_sceneitem_get_info(item, info) end

--- Sets/gets the position of a scene item.
---
--- C definition: `void obs_sceneitem_get_pos(const obs_sceneitem_t *item, struct vec2 *pos)`
--- @param item obs_scene_item
--- @param pos vec2
function obslua.obs_sceneitem_get_pos(item, pos) end

--- :return: An incremented reference to the private settings of the
---          scene item.  Allows the front-end to set custom information
---          which is saved with the scene item
---
--- C definition: `obs_data_t *obs_sceneitem_get_private_settings(obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return obs_data
function obslua.obs_sceneitem_get_private_settings(item) end

--- Sets/gets the rotation of a scene item.
---
--- C definition: `float obs_sceneitem_get_rot(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return number
function obslua.obs_sceneitem_get_rot(item) end

--- Sets/gets the scaling of the scene item.
---
--- C definition: `void obs_sceneitem_get_scale(const obs_sceneitem_t *item, struct vec2 *scale)`
--- @param item obs_scene_item
--- @param scale vec2
function obslua.obs_sceneitem_get_scale(item, scale) end

--- Sets/gets the scale filter used for the scene item.
---
--- :param filter: | Can be one of the following values:
---                | OBS_SCALE_DISABLE
---                | OBS_SCALE_POINT
---                | OBS_SCALE_BICUBIC
---                | OBS_SCALE_BILINEAR
---                | OBS_SCALE_LANCZOS
---
--- C definition: `enum obs_scale_type obs_sceneitem_get_scale_filter( obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return number
function obslua.obs_sceneitem_get_scale_filter(item) end

--- :return: The scene associated with the scene item.  Does not
---          increment the reference
---
--- C definition: `obs_scene_t *obs_sceneitem_get_scene(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return obs_scene
function obslua.obs_sceneitem_get_scene(item) end

--- :return: The source associated with the scene item.  Does not
---          increment the reference
---
--- C definition: `obs_source_t *obs_sceneitem_get_source(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return obs_source
function obslua.obs_sceneitem_get_source(item) end

--- Adds a scene item to a group.
---
--- C definition: `void obs_sceneitem_group_add_item(obs_sceneitem_t *group, obs_sceneitem_t *item)`
--- @param group obs_scene_item
--- @param item obs_scene_item
function obslua.obs_sceneitem_group_add_item(group, item) end

--- Enumerates scene items within a group.
---
--- C definition: `void obs_sceneitem_group_enum_items(obs_sceneitem_t *group, bool (*callback)(obs_scene_t*, obs_sceneitem_t*, void*), void *param)`
--- @param group obs_scene_item
--- @param callback f_p_struct_obs_scene_p_struct_obs_scene_item_p_void__bool
--- @param param ref_void*
function obslua.obs_sceneitem_group_enum_items(group, callback, param) end

--- :param group: Group scene item
--- :return:      Scene of the group, or *NULL* if not a group
---
--- C definition: `obs_scene_t *obs_sceneitem_group_get_scene(const obs_sceneitem_t *group)`
--- @param group obs_scene_item
--- @return obs_scene
function obslua.obs_sceneitem_group_get_scene(group) end

--- Removes a scene item from a group.  The item will be placed before
--- the group in the main scene.
---
--- C definition: `void obs_sceneitem_group_remove_item(obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @param param2 obs_scene_item
function obslua.obs_sceneitem_group_remove_item(item, param2) end

--- Ungroups the specified group.  Scene items within the group will be
--- placed where the group was.  Does not signal the scene with the
--- *refresh* signal.
---
--- C definition: `void obs_sceneitem_group_ungroup(obs_sceneitem_t *group)`
--- @param group obs_scene_item
function obslua.obs_sceneitem_group_ungroup(group) end

--- Ungroups the specified group.  Scene items within the group will be
--- placed where the group was.
---
--- :param group: Group scene item
--- :param signal: If *true*, signals the scene with the *refresh*
---                signal
---
--- C definition: `void obs_sceneitem_group_ungroup2(obs_sceneitem_t *group, bool signal)`
--- @param group obs_scene_item
--- @param signal boolean
function obslua.obs_sceneitem_group_ungroup2(group, signal) end

--- :param item: Scene item
--- :return:     *true* if scene item is a group, *false* otherwise
---
--- C definition: `bool obs_sceneitem_is_group(obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return boolean
function obslua.obs_sceneitem_is_group(item) end

--- Sets/gets the locked/unlocked state of the scene item.
---
--- C definition: `bool obs_sceneitem_locked(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return boolean
function obslua.obs_sceneitem_locked(item) end

--- Adds/releases a reference to a scene item.
---
--- C definition: `void obs_sceneitem_release(obs_sceneitem_t *item)`
--- @param item obs_scene_item
function obslua.obs_sceneitem_release(item) end

--- Removes the scene item from the scene.
---
--- C definition: `void obs_sceneitem_remove(obs_sceneitem_t *item)`
--- @param item obs_scene_item
function obslua.obs_sceneitem_remove(item) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_scene_item
--- @param param2 boolean
function obslua.obs_sceneitem_select(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_scene_item
function obslua.obs_sceneitem_selected(param1) end

--- Sets/gets the alignment of the scene item relative to its position.
---
--- :param alignment: | Can be any bitwise OR combination of:
---                   | OBS_ALIGN_CENTER
---                   | OBS_ALIGN_LEFT
---                   | OBS_ALIGN_RIGHT
---                   | OBS_ALIGN_TOP
---                   | OBS_ALIGN_BOTTOM
---
--- C definition: `void obs_sceneitem_set_alignment(obs_sceneitem_t *item, uint32_t alignment)`
--- @param item obs_scene_item
--- @param alignment number
function obslua.obs_sceneitem_set_alignment(item, alignment) end

--- Sets/gets the bounding box width/height of the scene item.
---
--- C definition: `void obs_sceneitem_set_bounds(obs_sceneitem_t *item, const struct vec2 *bounds)`
--- @param item obs_scene_item
--- @param bounds vec2
function obslua.obs_sceneitem_set_bounds(item, bounds) end

--- Sets/gets the alignment of the source within the bounding box.
---
--- :param alignment: | Can be any bitwise OR combination of:
---                   | OBS_ALIGN_CENTER
---                   | OBS_ALIGN_LEFT
---                   | OBS_ALIGN_RIGHT
---                   | OBS_ALIGN_TOP
---                   | OBS_ALIGN_BOTTOM
---
--- C definition: `void obs_sceneitem_set_bounds_alignment(obs_sceneitem_t *item, uint32_t alignment)`
--- @param item obs_scene_item
--- @param alignment number
function obslua.obs_sceneitem_set_bounds_alignment(item, alignment) end

--- Sets/gets the bounding box type of a scene item.  Bounding boxes are
--- used to stretch/position the source relative to a specific bounding
--- box of a specific size.
---
--- :param type: | Can be one of the following values:
---              | OBS_BOUNDS_NONE            - No bounding box
---              | OBS_BOUNDS_STRETCH         - Stretch to the bounding box without preserving aspect ratio
---              | OBS_BOUNDS_SCALE_INNER     - Scales with aspect ratio to inner bounding box rectangle
---              | OBS_BOUNDS_SCALE_OUTER     - Scales with aspect ratio to outer bounding box rectangle
---              | OBS_BOUNDS_SCALE_TO_WIDTH  - Scales with aspect ratio to the bounding box width
---              | OBS_BOUNDS_SCALE_TO_HEIGHT - Scales with aspect ratio to the bounding box height
---              | OBS_BOUNDS_MAX_ONLY        - Scales with aspect ratio, but only to the size of the source maximum
---
--- C definition: `void obs_sceneitem_set_bounds_type(obs_sceneitem_t *item, enum obs_bounds_type type)`
--- @param item obs_scene_item
--- @param type number
function obslua.obs_sceneitem_set_bounds_type(item, type) end

--- Sets/gets the cropping of the scene item.
---
--- C definition: `void obs_sceneitem_set_crop(obs_sceneitem_t *item, const struct obs_sceneitem_crop *crop)`
--- @param item obs_scene_item
--- @param crop obs_sceneitem_crop
function obslua.obs_sceneitem_set_crop(item, crop) end

--- Sets/gets the transform information of the scene item.
---
--- C definition: `void obs_sceneitem_set_info(obs_sceneitem_t *item, const struct obs_transform_info *info)`
--- @param item obs_scene_item
--- @param info obs_transform_info
function obslua.obs_sceneitem_set_info(item, info) end

--- Sets/gets the locked/unlocked state of the scene item.
---
--- C definition: `bool obs_sceneitem_set_locked(obs_sceneitem_t *item, bool locked)`
--- @param item obs_scene_item
--- @param locked boolean
--- @return boolean
function obslua.obs_sceneitem_set_locked(item, locked) end

--- Changes the scene item's order relative to the other scene items
--- within the scene.
---
--- :param movement: | Can be one of the following:
---                  | OBS_ORDER_MOVE_UP
---                  | OBS_ORDER_MOVE_DOWN
---                  | OBS_ORDER_MOVE_TOP
---                  | OBS_ORDER_MOVE_BOTTOM
---
--- C definition: `void obs_sceneitem_set_order(obs_sceneitem_t *item, enum obs_order_movement movement)`
--- @param item obs_scene_item
--- @param movement number
function obslua.obs_sceneitem_set_order(item, movement) end

--- Changes the scene item's order index.
---
--- C definition: `void obs_sceneitem_set_order_position(obs_sceneitem_t *item, int position)`
--- @param item obs_scene_item
--- @param position number
function obslua.obs_sceneitem_set_order_position(item, position) end

--- Sets/gets the position of a scene item.
---
--- C definition: `void obs_sceneitem_set_pos(obs_sceneitem_t *item, const struct vec2 *pos)`
--- @param item obs_scene_item
--- @param pos vec2
function obslua.obs_sceneitem_set_pos(item, pos) end

--- Sets/gets the rotation of a scene item.
---
--- C definition: `void obs_sceneitem_set_rot(obs_sceneitem_t *item, float rot_deg)`
--- @param item obs_scene_item
--- @param rot_deg number
function obslua.obs_sceneitem_set_rot(item, rot_deg) end

--- Sets/gets the scaling of the scene item.
---
--- C definition: `void obs_sceneitem_set_scale(obs_sceneitem_t *item, const struct vec2 *scale)`
--- @param item obs_scene_item
--- @param scale vec2
function obslua.obs_sceneitem_set_scale(item, scale) end

--- Sets/gets the scale filter used for the scene item.
---
--- :param filter: | Can be one of the following values:
---                | OBS_SCALE_DISABLE
---                | OBS_SCALE_POINT
---                | OBS_SCALE_BICUBIC
---                | OBS_SCALE_BILINEAR
---                | OBS_SCALE_LANCZOS
---
--- C definition: `void obs_sceneitem_set_scale_filter(obs_sceneitem_t *item, enum obs_scale_type filter)`
--- @param item obs_scene_item
--- @param filter number
function obslua.obs_sceneitem_set_scale_filter(item, filter) end

--- Sets/gets the visibility state of the scene item.
---
--- C definition: `bool obs_sceneitem_set_visible(obs_sceneitem_t *item, bool visible)`
--- @param item obs_scene_item
--- @param visible boolean
--- @return boolean
function obslua.obs_sceneitem_set_visible(item, visible) end

--- Sets/gets the visibility state of the scene item.
---
--- C definition: `bool obs_sceneitem_visible(const obs_sceneitem_t *item)`
--- @param item obs_scene_item
--- @return boolean
function obslua.obs_sceneitem_visible(item) end

--- Adds/releases a reference to a service.  When the last reference is
--- released, the service is destroyed.
---
--- C definition: `void obs_service_addref(obs_service_t *service)`
--- @param service obs_service
function obslua.obs_service_addref(service) end

--- Applies service-specific video encoder settings.
---
--- :param  video_encoder_settings: Video encoder settings.  Can be *NULL*
--- :param  audio_encoder_settings: Audio encoder settings.  Can be *NULL*
---
--- .. ---------------------------------------------------------------------------
---
--- .. _libobs/obs-service.h: https://github.com/jp9000/obs-studio/blob/master/libobs/obs-service.h
--- C definition: `void obs_service_apply_encoder_settings(obs_service_t *service, obs_data_t *video_encoder_settings, obs_data_t *audio_encoder_settings)`
--- @param service obs_service
--- @param video_encoder_settings obs_data
--- @param audio_encoder_settings obs_data
function obslua.obs_service_apply_encoder_settings(service, video_encoder_settings, audio_encoder_settings) end

--- Creates a service with the specified settings.
---
--- The "service" context is used for encoding video/audio data.  Use
--- obs_service_release to release it.
---
--- :param   id:             The service type string identifier
--- :param   name:           The desired name of the service.  If this is
---                          not unique, it will be made to be unique
--- :param   settings:       The settings for the service, or *NULL* if
---                          none
--- :param   hotkey_data:    Saved hotkey data for the service, or *NULL*
---                          if none
--- :return:                 A reference to the newly created service, or
---                          *NULL* if failed
---
--- C definition: `obs_service_t *obs_service_create(const char *id, const char *name, obs_data_t *settings, obs_data_t *hotkey_data)`
--- @param id string
--- @param name string
--- @param settings obs_data
--- @param hotkey_data obs_data
--- @return obs_service
function obslua.obs_service_create(id, name, settings, hotkey_data) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 string
--- @param param3 obs_data
function obslua.obs_service_create_private(param1, param2, param3) end

--- :return: An incremented reference to the service's default settings
---
--- C definition: `obs_data_t *obs_service_defaults(const char *id)`
--- @param id string
--- @return obs_data
function obslua.obs_service_defaults(id) end

--- Calls the :c:member:`obs_service_info.get_name` callback to get the
--- translated display name of a service type.
---
--- :param    id:            The service type string identifier
--- :return:                 The translated display name of a service type
---
--- C definition: `const char *obs_service_get_display_name(const char *id)`
--- @param id string
--- @return string
function obslua.obs_service_get_display_name(id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_service
function obslua.obs_service_get_id(param1) end

---   :return: Stream key (if any) currently used for this service
---
--- C definition: `const char *obs_service_get_key(const obs_service_t *service)`
--- @param service obs_service
--- @return string
function obslua.obs_service_get_key(service) end

--- :return: The name of the service
---
--- C definition: `const char *obs_service_get_name(const obs_service_t *service)`
--- @param service obs_service
--- @return string
function obslua.obs_service_get_name(service) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_service
function obslua.obs_service_get_output_type(param1) end

--- :return: Password (if any) currently used for this service
---
--- C definition: `const char *obs_service_get_password(const obs_service_t *service)`
--- @param service obs_service
--- @return string
function obslua.obs_service_get_password(service) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_service
function obslua.obs_service_get_ref(param1) end

--- :return: An incremented reference to the service's settings
---
--- C definition: `obs_data_t *obs_service_get_settings(const obs_service_t *service)`
--- @param service obs_service
--- @return obs_data
function obslua.obs_service_get_settings(service) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_service
function obslua.obs_service_get_type(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_service
function obslua.obs_service_get_type_data(param1) end

---   :return: The URL currently used for this service
---
--- C definition: `const char *obs_service_get_url(const obs_service_t *service)`
--- @param service obs_service
--- @return string
function obslua.obs_service_get_url(service) end

--- :return: User name (if any) currently used for this service
---
--- C definition: `const char *obs_service_get_username(const obs_service_t *service)`
--- @param service obs_service
--- @return string
function obslua.obs_service_get_username(service) end

--- These functions are used to get a weak reference from a strong service
--- reference, or a strong service reference from a weak reference.  If
--- the service is destroyed, *obs_weak_service_get_service* will return
--- *NULL*.
---
--- C definition: `obs_weak_service_t *obs_service_get_weak_service(obs_service_t *service)`
--- @param service obs_service
--- @return obs_weak_service
function obslua.obs_service_get_weak_service(service) end

--- Use these functions to get the properties of a service or service
--- type.  Properties are optionally used (if desired) to automatically
--- generate user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing service.  Free
---          with :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_service_properties(const obs_service_t *service)`
--- @param service obs_service
--- @return obs_properties
function obslua.obs_service_properties(service) end

--- Adds/releases a reference to a service.  When the last reference is
--- released, the service is destroyed.
---
--- C definition: `void obs_service_release(obs_service_t *service)`
--- @param service obs_service
function obslua.obs_service_release(service) end

--- Updates the settings for this service context.
---
--- C definition: `void obs_service_update(obs_service_t *service, obs_data_t *settings)`
--- @param service obs_service
--- @param settings obs_data
function obslua.obs_service_update(service, settings) end

--- Sets the current audio device for audio monitoring.
---
--- C definition: `bool obs_set_audio_monitoring_device(const char *name, const char *id)`
--- @param name string
--- @param id string
--- @return boolean
function obslua.obs_set_audio_monitoring_device(name, id) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 p_char
function obslua.obs_set_cmdline_args(param1, param2) end

--- Sets a new locale to use for modules.  This will call
--- obs_module_set_locale for each module with the new locale.
---
--- :param  locale: The locale to use for modules
---
--- C definition: `void obs_set_locale(const char *locale)`
--- @param locale string
function obslua.obs_set_locale(locale) end

--- Sets the master user volume.
---
--- C definition: `void obs_set_master_volume(float volume)`
--- @param volume number
function obslua.obs_set_master_volume(volume) end

--- Sets the primary output source for a channel.
---
--- C definition: `void obs_set_output_source(uint32_t channel, obs_source_t *source)`
--- @param channel number
--- @param source obs_source
function obslua.obs_set_output_source(channel, source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_data
function obslua.obs_set_private_data(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 f_p_f_p_void__void_p_void_bool__void
function obslua.obs_set_ui_task_handler(param1) end

--- Releases all data associated with OBS and terminates the OBS context.
---
--- C definition: `void obs_shutdown(void)`
function obslua.obs_shutdown() end

--- :return: *true* if active, *false* if not.  A source is only
---          considered active if it's being shown on the final mix
---
--- C definition: `bool obs_source_active(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_active(source) end

--- Adds an active child source.  Must be called by parent sources on child
--- sources when the child is added and active.  This ensures that the source is
--- properly activated if the parent is active.
---
--- :return: *true* if source can be added, *false* if it causes recursion
---
--- C definition: `bool obs_source_add_active_child(obs_source_t *parent, obs_source_t *child)`
--- @param parent obs_source
--- @param child obs_source
--- @return boolean
function obslua.obs_source_add_active_child(parent, child) end

--- Adds/removes an audio capture callback for a source.  This allows the
--- ability to get the raw audio data of a source as it comes in.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_source_audio_capture_t)(void *param, obs_source_t *source,
---                 const struct audio_data *audio_data, bool muted);
---
--- C definition: `void obs_source_add_audio_capture_callback(obs_source_t *source, obs_source_audio_capture_t callback, void *param)`
--- @param source obs_source
--- @param callback f_p_void_p_struct_obs_source_p_q_const__struct_audio_data_bool__void
--- @param param ref_void*
function obslua.obs_source_add_audio_capture_callback(source, callback, param) end

--- Adds/releases a reference to a source.  When the last reference is
--- released, the source is destroyed.
---
--- C definition: `void obs_source_addref(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_addref(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_async_decoupled(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_async_unbuffered(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_audio_active(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_audio_pending(param1) end

--- :return: *true* if the the source has custom properties, *false*
---          otherwise
---
--- C definition: `bool obs_source_configurable(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_configurable(source) end

--- Copies filters from the source to the destination.  If filters by the
--- same name already exist in the destination source, the newer filters
--- will be given unique names.
---
--- C definition: `void obs_source_copy_filters(obs_source_t *dst, obs_source_t *src)`
--- @param dst obs_source
--- @param src obs_source
function obslua.obs_source_copy_filters(dst, src) end

--- Creates a source of the specified type with the specified settings.
---
--- The "source" context is used for anything related to presenting
--- or modifying video/audio.  Use obs_source_release to release it.
---
--- :param   id:             The source type string identifier
--- :param   name:           The desired name of the source.  If this is
---                          not unique, it will be made to be unique
--- :param   settings:       The settings for the source, or *NULL* if
---                          none
--- :param   hotkey_data:    Saved hotkey data for the source, or *NULL*
---                          if none
--- :return:                 A reference to the newly created source, or
---                          *NULL* if failed
---
--- C definition: `obs_source_t *obs_source_create(const char *id, const char *name, obs_data_t *settings, obs_data_t *hotkey_data)`
--- @param id string
--- @param name string
--- @param settings obs_data
--- @param hotkey_data obs_data
--- @return obs_source
function obslua.obs_source_create(id, name, settings, hotkey_data) end

--- Creates a 'private' source which is not enumerated by
--- :c:func:`obs_enum_sources()`, and is not saved by
--- :c:func:`obs_save_sources()`.
---
--- Author's Note: The existence of this function is a result of design
--- flaw: the front-end should control saving/loading of sources, and
--- functions like :c:func:`obs_enum_sources()` and
--- :c:func:`obs_save_sources()` should not exist in the back-end.
---
--- :param   id:             The source type string identifier
--- :param   name:           The desired name of the source.  For private
---                          sources, this does not have to be unique,
---                          and can additionally be *NULL* if desired
--- :param   settings:       The settings for the source, or *NULL* if
---                          none
--- :return:                 A reference to the newly created source, or
---                          *NULL* if failed
---
--- C definition: `obs_source_t *obs_source_create_private(const char *id, const char *name, obs_data_t *settings)`
--- @param id string
--- @param name string
--- @param settings obs_data
--- @return obs_source
function obslua.obs_source_create_private(id, name, settings) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_dec_active(param1) end

--- Increments/decrements a source's "showing" state.  Typically used
--- when drawing a source on a display manually.
---
--- C definition: `void obs_source_dec_showing(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_dec_showing(source) end

--- Can be used by filters to directly render a non-async parent source
--- without any filter processing.
---
--- C definition: `void obs_source_default_render(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_default_render(source) end

--- Helper function to draw sprites for a source (synchronous video).
---
--- :param  image:  The sprite texture to draw.  Assigns to the 'image' variable
---                 of the current effect.
--- :param  x:      X position of the sprite.
--- :param  y:      Y position of the sprite.
--- :param  cx:     Width of the sprite.  If 0, uses the texture width.
--- :param  cy:     Height of the sprite.  If 0, uses the texture height.
--- :param  flip:   Specifies whether to flip the image vertically.
---
--- C definition: `void obs_source_draw(gs_texture_t *image, int x, int y, uint32_t cx, uint32_t cy, bool flip)`
--- @param image gs_texture
--- @param x number
--- @param y number
--- @param cx number
--- @param cy number
--- @param flip boolean
function obslua.obs_source_draw(image, x, y, cx, cy, flip) end

--- Helper function to set the color matrix information when drawing the
--- source.
---
--- :param  color_matrix:    The color matrix.  Assigns to the 'color_matrix'
---                          effect variable.
--- :param  color_range_min: The minimum color range.  Assigns to the
---                          'color_range_min' effect variable.  If NULL,
---                          {0.0f, 0.0f, 0.0f} is used.
--- :param  color_range_max: The maximum color range.  Assigns to the
---                          'color_range_max' effect variable.  If NULL,
---                          {1.0f, 1.0f, 1.0f} is used.
---
--- C definition: `void obs_source_draw_set_color_matrix(const struct matrix4 *color_matrix, const struct vec3 *color_range_min, const struct vec3 *color_range_max)`
--- @param color_matrix matrix4
--- @param color_range_min vec3
--- @param color_range_max vec3
function obslua.obs_source_draw_set_color_matrix(color_matrix, color_range_min, color_range_max) end

--- Duplicates a source.  If the source has the
--- OBS_SOURCE_DO_NOT_DUPLICATE output flag set, this only returns a
--- new reference to the same source.
---
--- :param source:         The source to duplicate
--- :param desired_name:   The desired name of the new source.  If this is
---                        not a private source and the name is not unique,
---                        it will be made to be unique
--- :param create_private: If *true*, the new source will be a private
---                        source if fully duplicated
--- :return:               A new source reference
---
--- C definition: `obs_source_t *obs_source_duplicate(obs_source_t *source, const char *desired_name, bool create_private)`
--- @param source obs_source
--- @param desired_name string
--- @param create_private boolean
--- @return obs_source
function obslua.obs_source_duplicate(source, desired_name, create_private) end

--- Sets/gets whether push-to-mute is enabled.
---
--- C definition: `void obs_source_enable_push_to_mute(obs_source_t *source, bool enabled)`
--- @param source obs_source
--- @param enabled boolean
function obslua.obs_source_enable_push_to_mute(source, enabled) end

--- Sets/gets whether push-to-talk is enabled.
---
--- C definition: `void obs_source_enable_push_to_talk(obs_source_t *source, bool enabled)`
--- @param source obs_source
--- @param enabled boolean
function obslua.obs_source_enable_push_to_talk(source, enabled) end

--- Enables/disables a source, or returns the enabled state.
---
--- C definition: `bool obs_source_enabled(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_enabled(source) end

--- Enumerates active child sources or source tree used by this source.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_source_enum_proc_t)(obs_source_t *parent,
---                 obs_source_t *child, void *param);
---
--- C definition: `void obs_source_enum_active_sources(obs_source_t *source, obs_source_enum_proc_t enum_callback, void *param)`
--- @param source obs_source
--- @param enum_callback f_p_struct_obs_source_p_struct_obs_source_p_void__void
--- @param param ref_void*
function obslua.obs_source_enum_active_sources(source, enum_callback, param) end

--- Enumerates active child sources or source tree used by this source.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_source_enum_proc_t)(obs_source_t *parent,
---                 obs_source_t *child, void *param);
---
--- C definition: `void obs_source_enum_active_tree(obs_source_t *source, obs_source_enum_proc_t enum_callback, void *param)`
--- @param source obs_source
--- @param enum_callback f_p_struct_obs_source_p_struct_obs_source_p_void__void
--- @param param ref_void*
function obslua.obs_source_enum_active_tree(source, enum_callback, param) end

--- Enumerates active filters on a source.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_source_enum_proc_t)(obs_source_t *parent,
---                 obs_source_t *child, void *param);
---
--- C definition: `void obs_source_enum_filters(obs_source_t *source, obs_source_enum_proc_t callback, void *param)`
--- @param source obs_source_t*
--- @param callback obs_source_enum_proc_t
--- @param param void*
function obslua.obs_source_enum_filters(source, callback, param) end

--- Adds/removes a filter to/from a source.
---
--- C definition: `void obs_source_filter_add(obs_source_t *source, obs_source_t *filter)`
--- @param source obs_source
--- @param filter obs_source
function obslua.obs_source_filter_add(source, filter) end

--- Adds/removes a filter to/from a source.
---
--- C definition: `void obs_source_filter_remove(obs_source_t *source, obs_source_t *filter)`
--- @param source obs_source
--- @param filter obs_source
function obslua.obs_source_filter_remove(source, filter) end

--- Modifies the order of a specific filter.
---
--- :param movement: | Can be one of the following:
---                  | OBS_ORDER_MOVE_UP
---                  | OBS_ORDER_MOVE_DOWN
---                  | OBS_ORDER_MOVE_TOP
---                  | OBS_ORDER_MOVE_BOTTOM
---
--- C definition: `void obs_source_filter_set_order(obs_source_t *source, obs_source_t *filter, enum obs_order_movement movement)`
--- @param source obs_source
--- @param filter obs_source
--- @param movement number
function obslua.obs_source_filter_set_order(source, filter, movement) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source_frame
--- @param param2 obs_source_frame
function obslua.obs_source_frame_copy(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 number
--- @param param2 number
--- @param param3 number
function obslua.obs_source_frame_create(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source_frame
function obslua.obs_source_frame_destroy(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source_frame
function obslua.obs_source_frame_free(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source_frame
--- @param param2 number
--- @param param3 number
--- @param param4 number
function obslua.obs_source_frame_init(param1, param2, param3, param4) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_source_audio_mix
function obslua.obs_source_get_audio_mix(param1, param2) end

--- Sets/gets the audio mixer channels that a source outputs to
--- (depending on what bits are set).  Audio mixers allow filtering
--- specific using multiple audio encoders to mix different sources
--- together depending on what mixer channel they're set to.
---
--- For example, to output to mixer 1 and 3, you would perform a bitwise
--- OR on bits 0 and 2:  (1<<0) | (1<<2), or 0x5.
---
--- C definition: `uint32_t obs_source_get_audio_mixers(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_audio_mixers(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_audio_timestamp(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_balance_value(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_base_height(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_base_width(param1) end

--- Sets/gets the deinterlace field order.
---
--- :param order: | OBS_DEINTERLACE_FIELD_ORDER_TOP - Start from top
---               | OBS_DEINTERLACE_FIELD_ORDER_BOTTOM - Start from bottom
---
--- C definition: `enum obs_deinterlace_field_order obs_source_get_deinterlace_field_order(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_deinterlace_field_order(source) end

--- Sets/gets the deinterlace mode.
---
--- :param mode:   | OBS_DEINTERLACE_MODE_DISABLE    - Disables deinterlacing
---                | OBS_DEINTERLACE_MODE_DISCARD    - Discard
---                | OBS_DEINTERLACE_MODE_RETRO      - Retro
---                | OBS_DEINTERLACE_MODE_BLEND      - Blend
---                | OBS_DEINTERLACE_MODE_BLEND_2X   - Blend 2x
---                | OBS_DEINTERLACE_MODE_LINEAR     - Linear
---                | OBS_DEINTERLACE_MODE_LINEAR_2X  - Linear 2x
---                | OBS_DEINTERLACE_MODE_YADIF      - Yadif
---                | OBS_DEINTERLACE_MODE_YADIF_2X   - Yadif 2x
---
--- C definition: `enum obs_deinterlace_mode obs_source_get_deinterlace_mode(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_deinterlace_mode(source) end

--- Calls the :c:member:`obs_source_info.get_name` callback to get the
--- translated display name of a source type.
---
--- :param    id:            The source type string identifier
--- :return:                 The translated display name of a source type
---
--- C definition: `const char *obs_source_get_display_name(const char *id)`
--- @param id string
--- @return string
function obslua.obs_source_get_display_name(id) end

--- :return: The desired filter, or *NULL* if not found.  The reference
---          of the filter is incremented
---
--- C definition: `obs_source_t *obs_source_get_filter_by_name(obs_source_t *source, const char *name)`
--- @param source obs_source
--- @param name string
--- @return obs_source
function obslua.obs_source_get_filter_by_name(source, name) end

--- :param flags: OBS_SOURCE_FLAG_FORCE_MONO Forces audio to mono
---
--- C definition: `uint32_t obs_source_get_flags(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_flags(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_frame(param1) end

--- Calls the :c:member:`obs_source_info.get_width` or
--- :c:member:`obs_source_info.get_height` of the source to get its width
--- and/or height.
---
--- Author's Note: These functions should be consolidated in to a single
--- function/callback rather than having a function for both width and
--- height.
---
--- :return: The width or height of the source
---
--- C definition: `uint32_t obs_source_get_height(obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_height(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.obs_source_get_icon_type(param1) end

--- :return: The source's type identifier string
---
--- C definition: `const char *obs_source_get_id(const obs_source_t *source)`
--- @param source obs_source
--- @return string
function obslua.obs_source_get_id(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_last_obs_version(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_monitoring_type(param1) end

--- :return: The name of the source
---
--- C definition: `const char *obs_source_get_name(const obs_source_t *source)`
--- @param source obs_source
--- @return string
function obslua.obs_source_get_name(source) end

--- :return: Capability flags of a source
---
--- Author's Note: "Output flags" is poor wording in retrospect; this
--- should have been named "Capability flags", and the OBS_SOURCE_*
--- macros should really be OBS_SOURCE_CAP_* macros instead.
---
--- See :c:member:`obs_source_info.output_flags` for more information.
---
--- C definition: `uint32_t obs_source_get_output_flags(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_output_flags(source) end

--- Gets private front-end settings data.  This data is saved/loaded
--- automatically.  Returns an incremented reference.
---
--- C definition: `obs_data_t *obs_source_get_private_settings(obs_source_t *item)`
--- @param item obs_source
--- @return obs_data
function obslua.obs_source_get_private_settings(item) end

--- :return: The procedure handler for a source
---
--- C definition: `proc_handler_t *obs_source_get_proc_handler(const obs_source_t *source)`
--- @param source obs_source
--- @return proc_handler
function obslua.obs_source_get_proc_handler(source) end

--- Sets/gets the push-to-mute delay.
---
--- C definition: `uint64_t obs_source_get_push_to_mute_delay(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_push_to_mute_delay(source) end

--- Sets/gets the push-to-talk delay.
---
--- C definition: `uint64_t obs_source_get_push_to_talk_delay(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_push_to_talk_delay(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_ref(param1) end

--- :return: The settings string for a source.  The reference counter of the
---          returned settings data is incremented, so
---          :c:func:`obs_data_release()` must be called when the
---          settings are no longer used
---
--- C definition: `obs_data_t *obs_source_get_settings(const obs_source_t *source)`
--- @param source obs_source
--- @return obs_data
function obslua.obs_source_get_settings(source) end

--- :return: The source's signal handler
---
--- See the :ref:`source_signal_handler_reference` for more information
--- on signals that are available for sources.
---
--- C definition: `signal_handler_t *obs_source_get_signal_handler(const obs_source_t *source)`
--- @param source obs_source
--- @return signal_handler
function obslua.obs_source_get_signal_handler(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_speaker_layout(param1) end

--- Sets/gets the audio sync offset (in nanoseconds) for a source.
---
--- C definition: `int64_t obs_source_get_sync_offset(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_sync_offset(source) end

--- :return: | OBS_SOURCE_TYPE_INPUT for inputs
---          | OBS_SOURCE_TYPE_FILTER for filters
---          | OBS_SOURCE_TYPE_TRANSITION for transitions
---          | OBS_SOURCE_TYPE_SCENE for scenes
---
--- C definition: `enum obs_source_type obs_source_get_type(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_type(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_type_data(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_get_unversioned_id(param1) end

--- Sets/gets the user volume for a source that has audio output.
---
--- C definition: `float obs_source_get_volume(const obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_volume(source) end

--- These functions are used to get a weak reference from a strong source
--- reference, or a strong source reference from a weak reference.  If
--- the source is destroyed, *obs_weak_source_get_source* will return
--- *NULL*.
---
--- C definition: `obs_weak_source_t *obs_source_get_weak_source(obs_source_t *source)`
--- @param source obs_source
--- @return obs_weak_source
function obslua.obs_source_get_weak_source(source) end

--- Calls the :c:member:`obs_source_info.get_width` or
--- :c:member:`obs_source_info.get_height` of the source to get its width
--- and/or height.
---
--- Author's Note: These functions should be consolidated in to a single
--- function/callback rather than having a function for both width and
--- height.
---
--- :return: The width or height of the source
---
--- C definition: `uint32_t obs_source_get_width(obs_source_t *source)`
--- @param source obs_source
--- @return number
function obslua.obs_source_get_width(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_inc_active(param1) end

--- Increments/decrements a source's "showing" state.  Typically used
--- when drawing a source on a display manually.
---
--- C definition: `void obs_source_inc_showing(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_inc_showing(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_is_group(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_load(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_ended(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_get_duration(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_get_state(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_get_time(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_next(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 boolean
function obslua.obs_source_media_play_pause(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_previous(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_restart(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 number
function obslua.obs_source_media_set_time(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_started(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_media_stop(param1) end

--- Sets/gets whether the source's audio is muted.
---
--- C definition: `bool obs_source_muted(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_muted(source) end

--- Outputs audio data.
---
--- C definition: `void obs_source_output_audio(obs_source_t *source, const struct obs_source_audio *audio)`
--- @param source obs_source
--- @param audio obs_source_audio
function obslua.obs_source_output_audio(source, audio) end

--- Outputs asynchronous video data.  Set to NULL to deactivate the texture.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- enum video_format {
---         VIDEO_FORMAT_NONE,
---
---         /* planar 420 format */
---         VIDEO_FORMAT_I420, /* three-plane */
---         VIDEO_FORMAT_NV12, /* two-plane, luma and packed chroma */
---
---         /* packed 422 formats */
---         VIDEO_FORMAT_YVYU,
---         VIDEO_FORMAT_YUY2, /* YUYV */
---         VIDEO_FORMAT_UYVY,
---
---         /* packed uncompressed formats */
---         VIDEO_FORMAT_RGBA,
---         VIDEO_FORMAT_BGRA,
---         VIDEO_FORMAT_BGRX,
---         VIDEO_FORMAT_Y800, /* grayscale */
---
---         /* planar 4:4:4 */
---         VIDEO_FORMAT_I444,
--- };
---
--- struct obs_source_frame {
---         uint8_t             *data[MAX_AV_PLANES];
---         uint32_t            linesize[MAX_AV_PLANES];
---         uint32_t            width;
---         uint32_t            height;
---         uint64_t            timestamp;
---
---         enum video_format   format;
---         float               color_matrix[16];
---         bool                full_range;
---         float               color_range_min[3];
---         float               color_range_max[3];
---         bool                flip;
--- };
---
--- C definition: `void obs_source_output_video(obs_source_t *source, const struct obs_source_frame *frame)`
--- @param source obs_source
--- @param frame obs_source_frame
function obslua.obs_source_output_video(source, frame) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_source_frame2
function obslua.obs_source_output_video2(param1, param2) end

--- Preloads a video frame to ensure a frame is ready for playback as
--- soon as video playback starts.
---
--- C definition: `void obs_source_preload_video(obs_source_t *source, const struct obs_source_frame *frame)`
--- @param source obs_source
--- @param frame obs_source_frame
function obslua.obs_source_preload_video(source, frame) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_source_frame2
function obslua.obs_source_preload_video2(param1, param2) end

--- Default RGB filter handler for generic effect filters.  Processes the
--- filter chain and renders them to texture if needed, then the filter is
--- drawn with.
---
--- After calling this, set your parameters for the effect, then call
--- obs_source_process_filter_end to draw the filter.
---
--- :return: *true* if filtering should continue, *false* if the filter
---          is bypassed for whatever reason
---
--- C definition: `bool obs_source_process_filter_begin(obs_source_t *filter, enum gs_color_format format, enum obs_allow_direct_render allow_direct)`
--- @param filter obs_source
--- @param format number
--- @param allow_direct number
--- @return boolean
function obslua.obs_source_process_filter_begin(filter, format, allow_direct) end

--- Draws the filter using the effect's "Draw" technique.
---
--- Before calling this function, first call obs_source_process_filter_begin and
--- then set the effect parameters, and then call this function to finalize the
--- filter.
---
--- C definition: `void obs_source_process_filter_end(obs_source_t *filter, gs_effect_t *effect, uint32_t width, uint32_t height)`
--- @param filter obs_source
--- @param effect gs_effect
--- @param width number
--- @param height number
function obslua.obs_source_process_filter_end(filter, effect, width, height) end

--- Draws the filter with a specific technique in the effect.
---
--- Before calling this function, first call obs_source_process_filter_begin and
--- then set the effect parameters, and then call this function to finalize the
--- filter.
---
--- C definition: `void obs_source_process_filter_tech_end(obs_source_t *filter, gs_effect_t *effect, uint32_t width, uint32_t height, const char *tech_name)`
--- @param filter obs_source
--- @param effect gs_effect
--- @param width number
--- @param height number
--- @param tech_name string
function obslua.obs_source_process_filter_tech_end(filter, effect, width, height, tech_name) end

--- Use these functions to get the properties of a source or source type.
--- Properties are optionally used (if desired) to automatically generate
--- user interface widgets to allow users to update settings.
---
--- :return: The properties list for a specific existing source.  Free with
---          :c:func:`obs_properties_destroy()`
---
--- C definition: `obs_properties_t *obs_source_properties(const obs_source_t *source)`
--- @param source obs_source
--- @return obs_properties
function obslua.obs_source_properties(source) end

--- Sets/gets whether push-to-mute is enabled.
---
--- C definition: `bool obs_source_push_to_mute_enabled(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_push_to_mute_enabled(source) end

--- Sets/gets whether push-to-talk is enabled.
---
--- C definition: `bool obs_source_push_to_talk_enabled(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_push_to_talk_enabled(source) end

--- Adds/releases a reference to a source.  When the last reference is
--- released, the source is destroyed.
---
--- C definition: `void obs_source_release(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_release(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_source_frame
function obslua.obs_source_release_frame(param1, param2) end

--- Notifies all reference holders of the source (via
--- :c:func:`obs_source_removed()`) that the source should be released.
---
--- C definition: `void obs_source_remove(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_remove(source) end

--- Removes an active child source.  Must be called by parent sources on child
--- sources when the child is removed or inactive.  This ensures that the source
--- is properly deactivated if the parent is no longer active.
---
--- C definition: `void obs_source_remove_active_child(obs_source_t *parent, obs_source_t *child)`
--- @param parent obs_source
--- @param child obs_source
function obslua.obs_source_remove_active_child(parent, child) end

--- Adds/removes an audio capture callback for a source.  This allows the
--- ability to get the raw audio data of a source as it comes in.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_source_audio_capture_t)(void *param, obs_source_t *source,
---                 const struct audio_data *audio_data, bool muted);
---
--- C definition: `void obs_source_remove_audio_capture_callback(obs_source_t *source, obs_source_audio_capture_t callback, void *param)`
--- @param source obs_source
--- @param callback f_p_void_p_struct_obs_source_p_q_const__struct_audio_data_bool__void
--- @param param ref_void*
function obslua.obs_source_remove_audio_capture_callback(source, callback, param) end

--- :return: *true* if the source should be released
---
--- C definition: `bool obs_source_removed(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_removed(source) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_source_save(param1) end

--- Used for interacting with sources:  sends a got-focus or lost-focus
--- event to a source.
---
--- C definition: `void obs_source_send_focus(obs_source_t *source, bool focus)`
--- @param source obs_source
--- @param focus boolean
function obslua.obs_source_send_focus(source, focus) end

--- Used for interacting with sources:  sends a key up/down event to a
--- source.
---
--- C definition: `void obs_source_send_key_click(obs_source_t *source, const struct obs_key_event *event, bool key_up)`
--- @param source obs_source
--- @param event obs_key_event
--- @param key_up boolean
function obslua.obs_source_send_key_click(source, event, key_up) end

--- Used for interacting with sources: sends a mouse down/up event to a
--- source.
---
--- C definition: `void obs_source_send_mouse_click(obs_source_t *source, const struct obs_mouse_event *event, int32_t type, bool mouse_up, uint32_t click_count)`
--- @param source obs_source
--- @param event obs_mouse_event
--- @param type number
--- @param mouse_up boolean
--- @param click_count number
function obslua.obs_source_send_mouse_click(source, event, type, mouse_up, click_count) end

--- Used for interacting with sources: sends a mouse move event to a
--- source.
---
--- C definition: `void obs_source_send_mouse_move(obs_source_t *source, const struct obs_mouse_event *event, bool mouse_leave)`
--- @param source obs_source
--- @param event obs_mouse_event
--- @param mouse_leave boolean
function obslua.obs_source_send_mouse_move(source, event, mouse_leave) end

--- Used for interacting with sources:  sends a mouse wheel event to a
--- source.
---
--- C definition: `void obs_source_send_mouse_wheel(obs_source_t *source, const struct obs_mouse_event *event, int x_delta, int y_delta)`
--- @param source obs_source
--- @param event obs_mouse_event
--- @param x_delta number
--- @param y_delta number
function obslua.obs_source_send_mouse_wheel(source, event, x_delta, y_delta) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 boolean
function obslua.obs_source_set_async_decoupled(param1, param2) end

--- Allows the ability to set rotation (0, 90, 180, -90, 270) for an
--- async video source.  The rotation will be automatically applied to
--- the source.
---
--- C definition: `void obs_source_set_async_rotation(obs_source_t *source, long rotation)`
--- @param source obs_source
--- @param rotation number
function obslua.obs_source_set_async_rotation(source, rotation) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 boolean
function obslua.obs_source_set_async_unbuffered(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 boolean
function obslua.obs_source_set_audio_active(param1, param2) end

--- Sets/gets the audio mixer channels that a source outputs to
--- (depending on what bits are set).  Audio mixers allow filtering
--- specific using multiple audio encoders to mix different sources
--- together depending on what mixer channel they're set to.
---
--- For example, to output to mixer 1 and 3, you would perform a bitwise
--- OR on bits 0 and 2:  (1<<0) | (1<<2), or 0x5.
---
--- C definition: `void obs_source_set_audio_mixers(obs_source_t *source, uint32_t mixers)`
--- @param source obs_source
--- @param mixers number
function obslua.obs_source_set_audio_mixers(source, mixers) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 number
function obslua.obs_source_set_balance_value(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 number
function obslua.obs_source_set_default_flags(param1, param2) end

--- Sets/gets the deinterlace field order.
---
--- :param order: | OBS_DEINTERLACE_FIELD_ORDER_TOP - Start from top
---               | OBS_DEINTERLACE_FIELD_ORDER_BOTTOM - Start from bottom
---
--- C definition: `void obs_source_set_deinterlace_field_order(obs_source_t *source, enum obs_deinterlace_field_order order)`
--- @param source obs_source
--- @param order number
function obslua.obs_source_set_deinterlace_field_order(source, order) end

--- Sets/gets the deinterlace mode.
---
--- :param mode:   | OBS_DEINTERLACE_MODE_DISABLE    - Disables deinterlacing
---                | OBS_DEINTERLACE_MODE_DISCARD    - Discard
---                | OBS_DEINTERLACE_MODE_RETRO      - Retro
---                | OBS_DEINTERLACE_MODE_BLEND      - Blend
---                | OBS_DEINTERLACE_MODE_BLEND_2X   - Blend 2x
---                | OBS_DEINTERLACE_MODE_LINEAR     - Linear
---                | OBS_DEINTERLACE_MODE_LINEAR_2X  - Linear 2x
---                | OBS_DEINTERLACE_MODE_YADIF      - Yadif
---                | OBS_DEINTERLACE_MODE_YADIF_2X   - Yadif 2x
---
--- C definition: `void obs_source_set_deinterlace_mode(obs_source_t *source, enum obs_deinterlace_mode mode)`
--- @param source obs_source
--- @param mode number
function obslua.obs_source_set_deinterlace_mode(source, mode) end

--- Enables/disables a source, or returns the enabled state.
---
--- C definition: `void obs_source_set_enabled(obs_source_t *source, bool enabled)`
--- @param source obs_source
--- @param enabled boolean
function obslua.obs_source_set_enabled(source, enabled) end

--- :param flags: OBS_SOURCE_FLAG_FORCE_MONO Forces audio to mono
---
--- C definition: `void obs_source_set_flags(obs_source_t *source, uint32_t flags)`
--- @param source obs_source
--- @param flags number
function obslua.obs_source_set_flags(source, flags) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 number
function obslua.obs_source_set_monitoring_type(param1, param2) end

--- Sets/gets whether the source's audio is muted.
---
--- C definition: `void obs_source_set_muted(obs_source_t *source, bool muted)`
--- @param source obs_source
--- @param muted boolean
function obslua.obs_source_set_muted(source, muted) end

--- Sets the name of a source.  If the source is not private and the name
--- is not unique, it will automatically be given a unique name.
---
--- C definition: `void obs_source_set_name(obs_source_t *source, const char *name)`
--- @param source obs_source
--- @param name string
function obslua.obs_source_set_name(source, name) end

--- Sets/gets the push-to-mute delay.
---
--- C definition: `void obs_source_set_push_to_mute_delay(obs_source_t *source, uint64_t delay)`
--- @param source obs_source
--- @param delay number
function obslua.obs_source_set_push_to_mute_delay(source, delay) end

--- Sets/gets the push-to-talk delay.
---
--- C definition: `void obs_source_set_push_to_talk_delay(obs_source_t *source, uint64_t delay)`
--- @param source obs_source
--- @param delay number
function obslua.obs_source_set_push_to_talk_delay(source, delay) end

--- Sets/gets the audio sync offset (in nanoseconds) for a source.
---
--- C definition: `void obs_source_set_sync_offset(obs_source_t *source, int64_t offset)`
--- @param source obs_source
--- @param offset number
function obslua.obs_source_set_sync_offset(source, offset) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_source_frame
function obslua.obs_source_set_video_frame(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_source_frame2
function obslua.obs_source_set_video_frame2(param1, param2) end

--- Sets/gets the user volume for a source that has audio output.
---
--- C definition: `void obs_source_set_volume(obs_source_t *source, float volume)`
--- @param source obs_source
--- @param volume number
function obslua.obs_source_set_volume(source, volume) end

--- Shows any preloaded video frame.
---
--- C definition: `void obs_source_show_preloaded_video(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_show_preloaded_video(source) end

--- :return: *true* if showing, *false* if not.  A source is considered
---          showing if it's being displayed anywhere at all, whether on
---          a display context or on the final output
---
--- C definition: `bool obs_source_showing(const obs_source_t *source)`
--- @param source obs_source
--- @return boolean
function obslua.obs_source_showing(source) end

--- Skips the filter if the filter is invalid and cannot be rendered.
---
--- C definition: `void obs_source_skip_video_filter(obs_source_t *filter)`
--- @param filter obs_source
function obslua.obs_source_skip_video_filter(filter) end

--- Updates the settings for a source and calls the
--- :c:member:`obs_source_info.update` callback of the source.  If the
--- source is a video source, the :c:member:`obs_source_info.update` will
--- be not be called immediately; instead, it will be deferred to the
--- video thread to prevent threading issues.
---
--- C definition: `void obs_source_update(obs_source_t *source, obs_data_t *settings)`
--- @param source obs_source
--- @param settings obs_data
function obslua.obs_source_update(source, settings) end

--- Signal an update to any currently used properties.
---
--- C definition: `void obs_source_update_properties(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_update_properties(source) end

--- Renders a video source.  This will call the
--- :c:member:`obs_source_info.video_render` callback of the source.
---
--- C definition: `void obs_source_video_render(obs_source_t *source)`
--- @param source obs_source
function obslua.obs_source_video_render(source) end

--- Initializes the OBS core context.
---
--- :param  locale:             The locale to use for modules
---                             (E.G. "en-US")
--- :param  module_config_path: Path to module config storage directory
---                             (or *NULL* if none)
--- :param  store:              The profiler name store for OBS to use or NULL
--- :return:                    *false* if already initialized or failed
---                             to initialize
---
--- C definition: `bool obs_startup(const char *locale, const char *module_config_path, profiler_name_store_t *store)`
--- @param locale string
--- @param module_config_path string
--- @param store profiler_name_store_t
--- @return boolean
function obslua.obs_startup(locale, module_config_path, store) end

--- Helper function used for transitioning audio.  Typically you'd call
--- this in the obs_source_info.audio_render callback with its
--- parameters, and use the mix_a_callback and mix_b_callback to
--- determine the the audio fading of source A and source B.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef float (*obs_transition_audio_mix_callback_t)(void *data, float t);
---
--- C definition: `bool obs_transition_audio_render(obs_source_t *transition, uint64_t *ts_out, struct obs_source_audio_mix *audio, uint32_t mixers, size_t channels, size_t sample_rate, obs_transition_audio_mix_callback_t mix_a_callback, obs_transition_audio_mix_callback_t mix_b_callback)`
--- @param transition obs_source
--- @param ts_out unsigned_long_long
--- @param audio obs_source_audio_mix
--- @param mixers number
--- @param channels number
--- @param sample_rate number
--- @param mix_a_callback f_p_void_float__float
--- @param mix_b_callback f_p_void_float__float
--- @return boolean
function obslua.obs_transition_audio_render(transition, ts_out, audio, mixers, channels, sample_rate, mix_a_callback, mix_b_callback) end

--- Clears the transition.
---
--- C definition: `void obs_transition_clear(obs_source_t *transition)`
--- @param transition obs_source
function obslua.obs_transition_clear(transition) end

--- Sets/gets whether the transition uses a fixed duration.  Useful for
--- certain types of transitions such as stingers.  If this is set, the
--- *duration_ms* parameter of :c:func:`obs_transition_start()` has no
--- effect.
---
--- C definition: `void obs_transition_enable_fixed(obs_source_t *transition, bool enable, uint32_t duration_ms)`
--- @param transition obs_source
--- @param enable boolean
--- @param duration_ms number
function obslua.obs_transition_enable_fixed(transition, enable, duration_ms) end

--- Sets/gets whether the transition uses a fixed duration.  Useful for
--- certain types of transitions such as stingers.  If this is set, the
--- *duration_ms* parameter of :c:func:`obs_transition_start()` has no
--- effect.
---
--- C definition: `bool obs_transition_fixed(obs_source_t *transition)`
--- @param transition obs_source
--- @return boolean
function obslua.obs_transition_fixed(transition) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
function obslua.obs_transition_force_stop(param1) end

--- :return: An incremented reference to the currently active source of
---          the transition
---
--- C definition: `obs_source_t *obs_transition_get_active_source(obs_source_t *transition)`
--- @param transition obs_source
--- @return obs_source
function obslua.obs_transition_get_active_source(transition) end

--- Sets/gets the alignment used to draw the two sources within
--- transition the transition.
---
--- :param alignment: | Can be any bitwise OR combination of:
---                   | OBS_ALIGN_CENTER
---                   | OBS_ALIGN_LEFT
---                   | OBS_ALIGN_RIGHT
---                   | OBS_ALIGN_TOP
---                   | OBS_ALIGN_BOTTOM
---
--- C definition: `uint32_t obs_transition_get_alignment(const obs_source_t *transition)`
--- @param transition obs_source
--- @return number
function obslua.obs_transition_get_alignment(transition) end

--- Sets/gets the scale type for sources within the transition.
---
--- :param type: | OBS_TRANSITION_SCALE_MAX_ONLY - Scale to aspect ratio, but only to the maximum size of each source
---              | OBS_TRANSITION_SCALE_ASPECT   - Always scale the sources, but keep aspect ratio
---              | OBS_TRANSITION_SCALE_STRETCH  - Scale and stretch the sources to the size of the transition
---
--- C definition: `enum obs_transition_scale_type obs_transition_get_scale_type( const obs_source_t *transition)`
--- @param transition obs_source
--- @return number
function obslua.obs_transition_get_scale_type(transition) end

--- Sets/gets the dimensions of the transition.
---
--- C definition: `void obs_transition_get_size(const obs_source_t *transition, uint32_t *cx, uint32_t *cy)`
--- @param transition obs_source
--- @param cx unsigned_int
--- @param cy unsigned_int
function obslua.obs_transition_get_size(transition, cx, cy) end

--- :param target: | OBS_TRANSITION_SOURCE_A - Source being transitioned from, or the current source if not transitioning
---                | OBS_TRANSITION_SOURCE_B - Source being transitioned to
--- :return:       An incremented reference to the source or destination
---                sources of the transition
---
--- C definition: `obs_source_t *obs_transition_get_source(obs_source_t *transition, enum obs_transition_target target)`
--- @param transition obs_source
--- @param target number
--- @return obs_source
function obslua.obs_transition_get_source(transition, target) end

--- :return: The current transition time value (0.0f..1.0f)
---
--- C definition: `float obs_transition_get_time(obs_source_t *transition)`
--- @param transition obs_source
--- @return number
function obslua.obs_transition_get_time(transition) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 obs_source
function obslua.obs_transition_set(param1, param2) end

--- Sets/gets the alignment used to draw the two sources within
--- transition the transition.
---
--- :param alignment: | Can be any bitwise OR combination of:
---                   | OBS_ALIGN_CENTER
---                   | OBS_ALIGN_LEFT
---                   | OBS_ALIGN_RIGHT
---                   | OBS_ALIGN_TOP
---                   | OBS_ALIGN_BOTTOM
---
--- C definition: `void obs_transition_set_alignment(obs_source_t *transition, uint32_t alignment)`
--- @param transition obs_source
--- @param alignment number
function obslua.obs_transition_set_alignment(transition, alignment) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 number
function obslua.obs_transition_set_manual_time(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 number
--- @param param3 number
function obslua.obs_transition_set_manual_torque(param1, param2, param3) end

--- Sets/gets the scale type for sources within the transition.
---
--- :param type: | OBS_TRANSITION_SCALE_MAX_ONLY - Scale to aspect ratio, but only to the maximum size of each source
---              | OBS_TRANSITION_SCALE_ASPECT   - Always scale the sources, but keep aspect ratio
---              | OBS_TRANSITION_SCALE_STRETCH  - Scale and stretch the sources to the size of the transition
---
--- C definition: `void obs_transition_set_scale_type(obs_source_t *transition, enum obs_transition_scale_type type)`
--- @param transition obs_source
--- @param type number
function obslua.obs_transition_set_scale_type(transition, type) end

--- Sets/gets the dimensions of the transition.
---
--- C definition: `void obs_transition_set_size(obs_source_t *transition, uint32_t cx, uint32_t cy)`
--- @param transition obs_source
--- @param cx number
--- @param cy number
function obslua.obs_transition_set_size(transition, cx, cy) end

--- Starts the transition with the desired destination source.
---
--- :param mode:        Currently only OBS_TRANSITION_MODE_AUTO
--- :param duration_ms: Duration in milliseconds.  If the transition has
---                     a fixed duration set by
---                     :c:func:`obs_transition_enable_fixed`, this
---                     parameter will have no effect
--- :param dest:        The destination source to transition to
---
--- C definition: `bool obs_transition_start(obs_source_t *transition, enum obs_transition_mode mode, uint32_t duration_ms, obs_source_t *dest)`
--- @param transition obs_source
--- @param mode number
--- @param duration_ms number
--- @param dest obs_source
--- @return boolean
function obslua.obs_transition_start(transition, mode, duration_ms, dest) end

--- Swaps two transitions.  Call obs_transition_swap_begin, swap the
--- source, then call obs_transition_swap_end when complete.  This allows
--- the ability to seamlessly swap two different transitions without it
--- affecting the output.
---
--- For example, if a transition is assigned to output channel 0, you'd
--- call obs_transition_swap_begin, then you'd call obs_set_output_source
--- with the new transition, then call
--- :c:func:`obs_transition_swap_begin()`.
---
--- .. ---------------------------------------------------------------------------
---
--- .. _libobs/obs-source.h: https://github.com/jp9000/obs-studio/blob/master/libobs/obs-source.h
--- C definition: `void obs_transition_swap_begin(obs_source_t *tr_dest, obs_source_t *tr_source)`
--- @param tr_dest obs_source
--- @param tr_source obs_source
function obslua.obs_transition_swap_begin(tr_dest, tr_source) end

--- Swaps two transitions.  Call obs_transition_swap_begin, swap the
--- source, then call obs_transition_swap_end when complete.  This allows
--- the ability to seamlessly swap two different transitions without it
--- affecting the output.
---
--- For example, if a transition is assigned to output channel 0, you'd
--- call obs_transition_swap_begin, then you'd call obs_set_output_source
--- with the new transition, then call
--- :c:func:`obs_transition_swap_begin()`.
---
--- .. ---------------------------------------------------------------------------
---
--- .. _libobs/obs-source.h: https://github.com/jp9000/obs-studio/blob/master/libobs/obs-source.h
--- C definition: `void obs_transition_swap_end(obs_source_t *tr_dest, obs_source_t *tr_source)`
--- @param tr_dest obs_source
--- @param tr_source obs_source
function obslua.obs_transition_swap_end(tr_dest, tr_source) end

--- Helper function used for rendering transitions.  This function will
--- render two distinct textures for source A and source B of the
--- transition, allowing the ability to blend them together with a pixel
--- shader in a desired manner.
---
--- The *a* and *b* parameters of *callback* are automatically rendered
--- textures of source A and source B, *t* is the time value
--- (0.0f..1.0f), *cx* and *cy* are the current dimensions of the
--- transition, and *data* is the implementation's private data.
---
--- Relevant data types used with this function:
---
--- .. code:: cpp
---
--- typedef void (*obs_transition_video_render_callback_t)(void *data,
---                 gs_texture_t *a, gs_texture_t *b, float t,
---                 uint32_t cx, uint32_t cy);
---
--- C definition: `void obs_transition_video_render(obs_source_t *transition, obs_transition_video_render_callback_t callback)`
--- @param transition obs_source
--- @param callback f_p_void_p_struct_gs_texture_p_struct_gs_texture_float_unsigned_int_unsigned_int__void
function obslua.obs_transition_video_render(transition, callback) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_source
--- @param param2 number
function obslua.obs_transition_video_render_direct(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_video_active() end

--- Creates a video encoder with the specified settings.
---
--- The "encoder" context is used for encoding video/audio data.  Use
--- obs_encoder_release to release it.
---
--- :param   id:             The encoder type string identifier
--- :param   name:           The desired name of the encoder.  If this is
---                          not unique, it will be made to be unique
--- :param   settings:       The settings for the encoder, or *NULL* if
---                          none
--- :param   hotkey_data:    Saved hotkey data for the encoder, or *NULL*
---                          if none
--- :return:                 A reference to the newly created encoder, or
---                          *NULL* if failed
---
--- C definition: `obs_encoder_t *obs_video_encoder_create(const char *id, const char *name, obs_data_t *settings, obs_data_t *hotkey_data)`
--- @param id string
--- @param name string
--- @param settings obs_data
--- @param hotkey_data obs_data
--- @return obs_encoder
function obslua.obs_video_encoder_create(id, name, settings, hotkey_data) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
function obslua.obs_view_create() end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_view
function obslua.obs_view_destroy(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_view
--- @param param2 number
function obslua.obs_view_get_source(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_view
function obslua.obs_view_render(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_view
--- @param param2 number
--- @param param3 obs_source
function obslua.obs_view_set_source(param1, param2, param3) end

--- Adds/releases a weak reference to an encoder.
---
--- C definition: `void obs_weak_encoder_addref(obs_weak_encoder_t *weak)`
--- @param weak obs_weak_encoder
function obslua.obs_weak_encoder_addref(weak) end

--- These functions are used to get a weak reference from a strong encoder
--- reference, or a strong encoder reference from a weak reference.  If
--- the encoder is destroyed, *obs_weak_encoder_get_encoder* will return
--- *NULL*.
---
--- C definition: `obs_encoder_t *obs_weak_encoder_get_encoder(obs_weak_encoder_t *weak)`
--- @param weak obs_weak_encoder
--- @return obs_encoder
function obslua.obs_weak_encoder_get_encoder(weak) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_weak_encoder
--- @param param2 obs_encoder
function obslua.obs_weak_encoder_references_encoder(param1, param2) end

--- Adds/releases a weak reference to an encoder.
---
--- C definition: `void obs_weak_encoder_release(obs_weak_encoder_t *weak)`
--- @param weak obs_weak_encoder
function obslua.obs_weak_encoder_release(weak) end

--- Adds/releases a weak reference to an output.
---
--- C definition: `void obs_weak_output_addref(obs_weak_output_t *weak)`
--- @param weak obs_weak_output
function obslua.obs_weak_output_addref(weak) end

--- These functions are used to get a weak reference from a strong output
--- reference, or a strong output reference from a weak reference.  If
--- the output is destroyed, *obs_weak_output_get_output* will return
--- *NULL*.
---
--- C definition: `obs_output_t *obs_weak_output_get_output(obs_weak_output_t *weak)`
--- @param weak obs_weak_output
--- @return obs_output
function obslua.obs_weak_output_get_output(weak) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_weak_output
--- @param param2 obs_output
function obslua.obs_weak_output_references_output(param1, param2) end

--- Adds/releases a weak reference to an output.
---
--- C definition: `void obs_weak_output_release(obs_weak_output_t *weak)`
--- @param weak obs_weak_output
function obslua.obs_weak_output_release(weak) end

--- Adds/releases a weak reference to a service.
---
--- C definition: `void obs_weak_service_addref(obs_weak_service_t *weak)`
--- @param weak obs_weak_service
function obslua.obs_weak_service_addref(weak) end

--- These functions are used to get a weak reference from a strong service
--- reference, or a strong service reference from a weak reference.  If
--- the service is destroyed, *obs_weak_service_get_service* will return
--- *NULL*.
---
--- C definition: `obs_service_t *obs_weak_service_get_service(obs_weak_service_t *weak)`
--- @param weak obs_weak_service
--- @return obs_service
function obslua.obs_weak_service_get_service(weak) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_weak_service
--- @param param2 obs_service
function obslua.obs_weak_service_references_service(param1, param2) end

--- Adds/releases a weak reference to a service.
---
--- C definition: `void obs_weak_service_release(obs_weak_service_t *weak)`
--- @param weak obs_weak_service
function obslua.obs_weak_service_release(weak) end

--- Adds/releases a weak reference to a source.
---
--- C definition: `void obs_weak_source_addref(obs_weak_source_t *weak)`
--- @param weak obs_weak_source
function obslua.obs_weak_source_addref(weak) end

--- These functions are used to get a weak reference from a strong source
--- reference, or a strong source reference from a weak reference.  If
--- the source is destroyed, *obs_weak_source_get_source* will return
--- *NULL*.
---
--- C definition: `obs_source_t *obs_weak_source_get_source(obs_weak_source_t *weak)`
--- @param weak obs_weak_source
--- @return obs_source
function obslua.obs_weak_source_get_source(weak) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 obs_weak_source
--- @param param2 obs_source
function obslua.obs_weak_source_references_source(param1, param2) end

--- Adds/releases a weak reference to a source.
---
--- C definition: `void obs_weak_source_release(obs_weak_source_t *weak)`
--- @param weak obs_weak_source
function obslua.obs_weak_source_release(weak) end

--- Triggers a debugger breakpoint (or crashes the program if no debugger
--- present).
---
--- C definition: `void os_breakpoint(void)`
function obslua.os_breakpoint() end

--- Changes the current working directory.
---
--- C definition: `int os_chdir(const char *path)`
--- @param path string
--- @return number
function obslua.os_chdir(path) end

--- Closes a directory object.
---
--- C definition: `void os_closedir(os_dir_t *dir)`
--- @param dir os_dir
function obslua.os_closedir(dir) end

--- Copies a file.
---
--- C definition: `int os_copyfile(const char *file_in, const char *file_out)`
--- @param file_in string
--- @param file_out string
--- @return number
function obslua.os_copyfile(file_in, file_out) end

--- Destroys a CPU usage information object.
---
--- C definition: `void                os_cpu_usage_info_destroy(os_cpu_usage_info_t *info)`
--- @param info os_cpu_usage_info
function obslua.os_cpu_usage_info_destroy(info) end

--- Queries the current CPU usage.
---
--- C definition: `double              os_cpu_usage_info_query(os_cpu_usage_info_t *info)`
--- @param info os_cpu_usage_info
--- @return number
function obslua.os_cpu_usage_info_query(info) end

--- Creates a CPU usage information object.
---
--- C definition: `os_cpu_usage_info_t *os_cpu_usage_info_start(void)`
--- @return os_cpu_usage_info
function obslua.os_cpu_usage_info_start() end

--- Closes a dynamic library.
---
--- C definition: `void os_dlclose(void *module)`
--- @param module ref_void*
function obslua.os_dlclose(module) end

--- Opens a dynamic library.
---
--- C definition: `void *os_dlopen(const char *path)`
--- @param path string
--- @return void
function obslua.os_dlopen(path) end

--- Returns a symbol from a dynamic library.
---
--- C definition: `void *os_dlsym(void *module, const char *func)`
--- @param module ref_void*
--- @param func string
--- @return void
function obslua.os_dlsym(module, func) end

--- Converts a double to a string.
---
--- C definition: `int os_dtostr(double value, char *dst, size_t size)`
--- @param value number
--- @param dst string
--- @param size number
--- @return number
function obslua.os_dtostr(value, dst, size) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 ref_os_performance_token_t*
function obslua.os_end_high_performance(param1) end

--- Returns a file's size.
---
--- C definition: `int64_t os_fgetsize(FILE *file)`
--- @param file FILE
--- @return number
function obslua.os_fgetsize(file) end

--- Returns true if a file/directory exists, false otherwise.
---
--- C definition: `bool os_file_exists(const char *path)`
--- @param path string
--- @return boolean
function obslua.os_file_exists(path) end

--- Opens a file with a UTF8 string path.
---
--- C definition: `FILE *os_fopen(const char *path, const char *mode)`
--- @param path string
--- @param mode string
--- @return FILE
function obslua.os_fopen(path, mode) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 FILE
--- @param param2 p_char
function obslua.os_fread_mbs(param1, param2) end

--- Reads a UTF8 encoded file and allocates a pointer to the UTF8 string.
---
--- C definition: `size_t os_fread_utf8(FILE *file, char **pstr)`
--- @param file FILE
--- @param pstr p_char
--- @return number
function obslua.os_fread_utf8(file, pstr) end

--- Equivalent to fseek.
---
--- C definition: `int os_fseeki64(FILE *file, int64_t offset, int origin)`
--- @param file FILE
--- @param offset number
--- @param origin number
--- @return number
function obslua.os_fseeki64(file, offset, origin) end

--- Gets the current file position.
---
--- C definition: `int64_t os_ftelli64(FILE *file)`
--- @param file FILE
--- @return number
function obslua.os_ftelli64(file) end

--- Returns a new bmalloc-allocated filename generated from specific
--- formatting.
---
--- C definition: `char *os_generate_formatted_filename(const char *extension, bool space, const char *format)`
--- @param extension string
--- @param space boolean
--- @param format string
--- @return string
function obslua.os_generate_formatted_filename(extension, space, format) end

--- Converts a relative path to an absolute path.
---
--- C definition: `size_t os_get_abs_path(const char *path, char *abspath, size_t size)`
--- @param path string
--- @param abspath string
--- @param size number
--- @return number
function obslua.os_get_abs_path(path, abspath, size) end

--- Converts a relative path to an absolute path.
---
--- C definition: `char *os_get_abs_path_ptr(const char *path)`
--- @param path string
--- @return string
function obslua.os_get_abs_path_ptr(path) end

--- Gets the user-specific application configuration data path.
---
--- C definition: `int os_get_config_path(char *dst, size_t size, const char *name)`
--- @param dst string
--- @param size number
--- @param name string
--- @return number
function obslua.os_get_config_path(dst, size, name) end

--- Gets the user-specific application configuration data path.
---
--- C definition: `char *os_get_config_path_ptr(const char *name)`
--- @param name string
--- @return string
function obslua.os_get_config_path_ptr(name) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.os_get_executable_path_ptr(param1) end

--- Gets a file's size.
---
--- C definition: `int64_t os_get_file_size(const char *path)`
--- @param path string
--- @return number
function obslua.os_get_file_size(path) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.os_get_free_disk_space(param1) end

--- Gets free space of a specific file path.
---
--- C definition: `int64_t os_get_free_space(const char *path)`
--- @param path string
--- @return number
function obslua.os_get_free_space(path) end

--- Returns the number of logical cores available.
---
--- C definition: `int os_get_logical_cores(void)`
--- @return number
function obslua.os_get_logical_cores() end

--- Returns the extension portion of a path string.
---
--- C definition: `const char *os_get_path_extension(const char *path)`
--- @param path string
--- @return string
function obslua.os_get_path_extension(path) end

--- Returns the number of physical cores available.
---
--- C definition: `int os_get_physical_cores(void)`
--- @return number
function obslua.os_get_physical_cores() end

--- Gets memory usage of the current process.
---
--- C definition: `bool os_get_proc_memory_usage(os_proc_memory_usage_t *usage)`
--- @param usage os_proc_memory_usage
--- @return boolean
function obslua.os_get_proc_memory_usage(usage) end

--- Returns the resident memory size of the current process.
---
--- C definition: `uint64_t os_get_proc_resident_size(void)`
--- @return number
function obslua.os_get_proc_resident_size() end

--- Returns the virtual memory size of the current process.
--- C definition: `uint64_t os_get_proc_virtual_size(void)`
--- @return number
function obslua.os_get_proc_virtual_size() end

--- Gets the application configuration data path.
---
--- C definition: `int os_get_program_data_path(char *dst, size_t size, const char *name)`
--- @param dst string
--- @param size number
--- @param name string
--- @return number
function obslua.os_get_program_data_path(dst, size, name) end

--- Gets the application configuration data path.
---
--- C definition: `char *os_get_program_data_path_ptr(const char *name)`
--- @param name string
--- @return string
function obslua.os_get_program_data_path_ptr(name) end

--- Returns the amount of memory available.
---
--- C definition: `uint64_t os_get_sys_free_size(void)`
--- @return number
function obslua.os_get_sys_free_size() end

--- Returns a new bmalloc-allocated path to the current working
--- directory.
---
--- C definition: `char *os_getcwd(char *path, size_t size)`
--- @param path string
--- @param size number
--- @return string
function obslua.os_getcwd(path, size) end

--- Gets the current high-precision system time, in nanoseconds.
---
--- C definition: `uint64_t os_gettime_ns(void)`
--- @return number
function obslua.os_gettime_ns()
    local unit_nanoseconds_10e9 = math.pow(10, 9)
    return tonumber(socket.gettime() * unit_nanoseconds_10e9)
end

--- Enumerates files based upon a glob string.
---
--- C definition: `int os_glob(const char *pattern, int flags, os_glob_t **pglob)`
--- @param pattern string
--- @param flags number
--- @param pglob p_os_glob_info
--- @return number
function obslua.os_glob(pattern, flags, pglob) end

--- Frees a glob object.
---
--- C definition: `void os_globfree(os_glob_t *pglob)`
--- @param pglob os_glob_info
function obslua.os_globfree(pglob) end

--- Creates a sleep inhibition object.
---
--- C definition: `os_inhibit_t *os_inhibit_sleep_create(const char *reason)`
--- @param reason string
--- @return os_inhibit_info
function obslua.os_inhibit_sleep_create(reason) end

--- Destroys a sleep inhibition object.  If the sleep inhibition object
--- was active, it will be deactivated.
---
--- C definition: `void os_inhibit_sleep_destroy(os_inhibit_t *info)`
--- @param info os_inhibit_info
function obslua.os_inhibit_sleep_destroy(info) end

--- Activates/deactivates a sleep inhibition object.
---
--- C definition: `bool os_inhibit_sleep_set_active(os_inhibit_t *info, bool active)`
--- @param info os_inhibit_info
--- @param active boolean
--- @return boolean
function obslua.os_inhibit_sleep_set_active(info, active) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 number
--- @param param3 p_char
function obslua.os_mbs_to_utf8_ptr(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 number
--- @param param3 wchar_t
--- @param param4 number
function obslua.os_mbs_to_wcs(param1, param2, param3, param4) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 number
--- @param param3 p_wchar_t
function obslua.os_mbs_to_wcs_ptr(param1, param2, param3) end

--- Creates a directory.
---
--- C definition: `int os_mkdir(const char *path)`
--- @param path string
--- @return number
function obslua.os_mkdir(path) end

--- Creates a full directory path if it doesn't exist.
---
--- C definition: `int os_mkdirs(const char *path)`
--- @param path string
--- @return number
function obslua.os_mkdirs(path) end

--- Opens a directory object to enumerate files within the directory.
---
--- C definition: `os_dir_t *os_opendir(const char *path)`
--- @param path string
--- @return os_dir
function obslua.os_opendir(path) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.os_quick_read_mbs_file(param1) end

--- Reads a UTF8 encoded file and returns an allocated pointer to the
--- string.
---
--- C definition: `char *os_quick_read_utf8_file(const char *path)`
--- @param path string
--- @return string
function obslua.os_quick_read_utf8_file(path) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 string
--- @param param3 number
function obslua.os_quick_write_mbs_file(param1, param2, param3) end

--- Writes a UTF8 encoded file.
---
--- C definition: `bool os_quick_write_utf8_file(const char *path, const char *str, size_t len, bool marker)`
--- @param path string
--- @param str string
--- @param len number
--- @param marker boolean
--- @return boolean
function obslua.os_quick_write_utf8_file(path, str, len, marker) end

--- Writes a UTF8 encoded file with overwrite corruption prevention.
---
--- C definition: `bool os_quick_write_utf8_file_safe(const char *path, const char *str, size_t len, bool marker, const char *temp_ext, const char *backup_ext)`
--- @param path string
--- @param str string
--- @param len number
--- @param marker boolean
--- @param temp_ext string
--- @param backup_ext string
--- @return boolean
function obslua.os_quick_write_utf8_file_safe(path, str, len, marker, temp_ext, backup_ext) end

--- Returns the linked list of directory entries.
---
--- C definition: `struct os_dirent *os_readdir(os_dir_t *dir)`
--- @param dir os_dir
--- @return os_dirent
function obslua.os_readdir(dir) end

--- Renames a file.
---
--- C definition: `int os_rename(const char *old_path, const char *new_path)`
--- @param old_path string
--- @param new_path string
--- @return number
function obslua.os_rename(old_path, new_path) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
function obslua.os_request_high_performance(param1) end

--- Deletes a directory.
---
--- C definition: `int os_rmdir(const char *path)`
--- @param path string
--- @return number
function obslua.os_rmdir(path) end

--- Safely replaces a file.
---
--- C definition: `int os_safe_replace(const char *target_path, const char *from_path, const char *backup_path)`
--- @param target_path string
--- @param from_path string
--- @param backup_path string
--- @return number
function obslua.os_safe_replace(target_path, from_path, backup_path) end

--- Sleeps for a specific number of milliseconds.
---
--- C definition: `void os_sleep_ms(uint32_t duration)`
--- @param duration number
function obslua.os_sleep_ms(duration) end

--- Sleeps to a specific time with high precision, in nanoseconds.
---
--- C definition: `bool os_sleepto_ns(uint64_t time_target)`
--- @param time_target number
--- @return boolean
function obslua.os_sleepto_ns(time_target) end

--- Converts a string to a double.
---
--- C definition: `double os_strtod(const char *str)`
--- @param str string
--- @return number
function obslua.os_strtod(str) end

--- Deletes a file.
---
--- C definition: `int os_unlink(const char *path)`
--- @param path string
--- @return number
function obslua.os_unlink(path) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 string
--- @param param2 number
--- @param param3 p_char
function obslua.os_utf8_to_mbs_ptr(param1, param2, param3) end

--- Converts a UTF8 string to a wide string.
---
--- C definition: `size_t os_utf8_to_wcs(const char *str, size_t len, wchar_t *dst, size_t dst_size)`
--- @param str string
--- @param len number
--- @param dst wchar_t
--- @param dst_size number
--- @return number
function obslua.os_utf8_to_wcs(str, len, dst, dst_size) end

--- Gets an bmalloc-allocated wide string converted from a UTF8 string.
---
--- C definition: `size_t os_utf8_to_wcs_ptr(const char *str, size_t len, wchar_t **pstr)`
--- @param str string
--- @param len number
--- @param pstr p_wchar_t
--- @return number
function obslua.os_utf8_to_wcs_ptr(str, len, pstr) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 wchar_t
--- @param param2 number
--- @param param3 string
--- @param param4 number
function obslua.os_wcs_to_mbs(param1, param2, param3, param4) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 wchar_t
--- @param param2 number
--- @param param3 p_char
function obslua.os_wcs_to_mbs_ptr(param1, param2, param3) end

--- Converts a wide string to a UTF8 string.
---
--- C definition: `size_t os_wcs_to_utf8(const wchar_t *str, size_t len, char *dst, size_t dst_size)`
--- @param str wchar_t
--- @param len number
--- @param dst string
--- @param dst_size number
--- @return number
function obslua.os_wcs_to_utf8(str, len, dst, dst_size) end

--- Gets an bmalloc-allocated UTF8 string converted from a wide string.
---
--- C definition: `size_t os_wcs_to_utf8_ptr(const wchar_t *str, size_t len, char **pstr)`
--- @param str wchar_t
--- @param len number
--- @param pstr p_char
--- @return number
function obslua.os_wcs_to_utf8_ptr(str, len, pstr) end

--- Opens a file with a wide string path.
---
--- C definition: `FILE *os_wfopen(const wchar_t *path, const char *mode)`
--- @param path wchar_t
--- @param mode string
--- @return FILE
function obslua.os_wfopen(path, mode) end

--- Adds a procedure to a procedure handler.
---
--- :param handler:     Procedure handler object
--- :param decl_string: Procedure declaration string
--- :param proc:        Procedure callback
--- :param data:        Private data to pass to the callback
---
--- C definition: `void proc_handler_add(proc_handler_t *handler, const char *decl_string, proc_handler_proc_t proc, void *data)`
--- @param handler proc_handler
--- @param decl_string string
--- @param proc f_p_void_p_struct_calldata__void
--- @param data ref_void*
function obslua.proc_handler_add(handler, decl_string, proc, data) end

--- Calls a procedure within the procedure handler.
---
--- :param handler: Procedure handler object
--- :param name:    Name of procedure to call
--- :param params:  Calldata structure to pass to the procedure
--- C definition: `bool proc_handler_call(proc_handler_t *handler, const char *name, calldata_t *params)`
--- @param handler proc_handler
--- @param name string
--- @param params calldata
--- @return boolean
function obslua.proc_handler_call(handler, name, params) end

--- Creates a new procedure handler.
---
--- :return: A new procedure handler object
---
--- C definition: `proc_handler_t *proc_handler_create(void)`
--- @return proc_handler
function obslua.proc_handler_create() end

--- Destroys a procedure handler object.
---
--- :param handler: Procedure handler object
---
--- C definition: `void proc_handler_destroy(proc_handler_t *handler)`
--- @param handler proc_handler
function obslua.proc_handler_destroy(handler) end

--- Adds two quaternions
---
--- :param dst: Destination
--- :param v1:  Quaternion 1
--- :param v2:  Quaternion 2
---
--- C definition: `void quat_add(struct quat *dst, const struct quat *v1, const struct quat *v2)`
--- @param dst quat
--- @param v1 quat
--- @param v2 quat
function obslua.quat_add(dst, v1, v2) end

--- Adds a floating point to all components
---
--- :param dst: Destination
--- :param dst: Quaternion
--- :param f:   Floating point
---
--- C definition: `void quat_addf(struct quat *dst, const struct quat *v, float f)`
--- @param dst quat
--- @param v quat
--- @param f number
function obslua.quat_addf(dst, v, f) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 quat
--- @param param2 quat
--- @param param3 number
function obslua.quat_close(param1, param2, param3) end

--- Copies a quaternion
---
--- :param dst: Destination
--- :param v:   Quaternion to copy
---
--- C definition: `void quat_copy(struct quat *dst, const struct quat *v)`
--- @param dst quat
--- @param v quat
function obslua.quat_copy(dst, v) end

--- Gets the distance between two quaternions
---
--- :param v1: Quaternion 1
--- :param v2: Quaternion 2
--- :return:   Distance between the two quaternions
---
--- C definition: `float quat_dist(const struct quat *v1, const struct quat *v2)`
--- @param v1 quat
--- @param v2 quat
--- @return number
function obslua.quat_dist(v1, v2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 quat
--- @param param2 quat
--- @param param3 number
function obslua.quat_divf(param1, param2, param3) end

--- Performs a dot product between two quaternions
---
--- :param v1: Quaternion 1
--- :param v2: Quaternion 2
--- :return:   Result of the dot product
---
--- C definition: `float quat_dot(const struct quat *v1, const struct quat *v2)`
--- @param v1 quat
--- @param v2 quat
--- @return number
function obslua.quat_dot(v1, v2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 quat
--- @param param2 quat
function obslua.quat_exp(param1, param2) end

--- Converts an axis angle to a quaternion
---
--- :param dst: Destination quaternion
--- :param aa:  Axis angle
---
--- C definition: `void quat_from_axisang(struct quat *dst, const struct axisang *aa)`
--- @param dst quat
--- @param aa axisang
function obslua.quat_from_axisang(dst, aa) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 quat
--- @param param2 matrix3
function obslua.quat_from_matrix3(param1, param2) end

--- Converts the rotational properties of a matrix to a quaternion
---
--- :param dst: Destination quaternion
--- :param m:   Matrix to convert
---
--- C definition: `void quat_from_matrix4(struct quat *dst, const struct matrix4 *m)`
--- @param dst quat
--- @param m matrix4
function obslua.quat_from_matrix4(dst, m) end

--- Converts a quaternion to a directional vector
---
--- :param dst: Destination 3-component vector
--- :param q:   Quaternion
---
--- C definition: `void quat_get_dir(struct vec3 *dst, const struct quat *q)`
--- @param dst vec3
--- @param q quat
function obslua.quat_get_dir(dst, q) end

--- Gets a tangent value for the center of three rotational values
---
--- :param dst:  Destination quaternion
--- :param prev: Previous rotation
--- :param q:    Rotation to get tangent for
--- :param next: Next rotation
---
--- C definition: `void quat_get_tangent(struct quat *dst, const struct quat *prev, const struct quat *q, const struct quat *next)`
--- @param dst quat
--- @param prev quat
--- @param q quat
--- @param next quat
function obslua.quat_get_tangent(dst, prev, q, next) end

--- Sets a quaternion to {0.0f, 0.0f, 0.0f, 1.0f}.
---
--- :param dst: Destination
---
--- C definition: `void quat_identity(struct quat *dst)`
--- @param dst quat
function obslua.quat_identity(dst) end

--- Linearly interpolates two quaternions
---
--- :param dst: Destination quaternion
--- :param q1:  Quaternion 1
--- :param q2:  Quaternion 2
--- :param t:   Time value (0.0f..1.0f)
---
--- C definition: `void quat_interpolate(struct quat *dst, const struct quat *q1, const struct quat *q2, float t)`
--- @param dst quat
--- @param q1 quat
--- @param q2 quat
--- @param t number
function obslua.quat_interpolate(dst, q1, q2, t) end

--- Performs cubic interpolation between two quaternions
---
--- :param dst: Destination quaternion
--- :param q1:  Quaternion 1
--- :param q2:  Quaternion 2
--- :param m1:  Tangent 1
--- :param m2:  Tangent 2
--- :param t:   Time value (0.0f..1.0f)
--- C definition: `void quat_interpolate_cubic(struct quat *dst, const struct quat *q1, const struct quat *q2, const struct quat *m1, const struct quat *m2, float t)`
--- @param dst quat
--- @param q1 quat
--- @param q2 quat
--- @param m1 quat
--- @param m2 quat
--- @param t number
function obslua.quat_interpolate_cubic(dst, q1, q2, m1, m2, t) end

--- Inverts a quaternion
---
--- :param dst: Destination
--- :param v:   Quaternion to invert
---
--- C definition: `void quat_inv(struct quat *dst, const struct quat *v)`
--- @param dst quat
--- @param v quat
function obslua.quat_inv(dst, v) end

--- Gets the length of a quaternion
---
--- :param v: Quaternion
--- :return:  The quaternion's length
---
--- C definition: `float quat_len(const struct quat *v)`
--- @param v quat
--- @return number
function obslua.quat_len(v) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 quat
--- @param param2 quat
function obslua.quat_log(param1, param2) end

--- Multiplies two quaternions
---
--- :param dst: Destination
--- :param v1:  Quaternion 1
--- :param v2:  Quaternion 2
---
--- C definition: `void quat_mul(struct quat *dst, const struct quat *v1, const struct quat *v2)`
--- @param dst quat
--- @param v1 quat
--- @param v2 quat
function obslua.quat_mul(dst, v1, v2) end

--- Multiplies a floating point with all components
---
--- :param dst: Destination
--- :param dst: Quaternion
--- :param f:   Floating point
---
--- C definition: `void quat_mulf(struct quat *dst, const struct quat *v, float f)`
--- @param dst quat
--- @param v quat
--- @param f number
function obslua.quat_mulf(dst, v, f) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 quat
--- @param param2 quat
function obslua.quat_neg(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 quat
--- @param param2 quat
function obslua.quat_norm(param1, param2) end

--- Sets the individual components of a quaternion.
---
--- :param dst: Destination
--- :param x:   X component
--- :param y:   Y component
--- :param y:   Z component
--- :param w:   W component
---
--- C definition: `void quat_set(struct quat *dst, float x, float y)`
--- @param dst quat
--- @param x number
--- @param y number
--- @param param4 number
--- @param param5 number
function obslua.quat_set(dst, x, y, param4, param5) end

--- Creates a quaternion from a specific "look" direction
---
--- :param dst: Destination quaternion
--- :param dir: 3-component vector representing the look direction
---
--- C definition: `void quat_set_look_dir(struct quat *dst, const struct vec3 *dir)`
--- @param dst quat
--- @param dir vec3
function obslua.quat_set_look_dir(dst, dir) end

--- Subtracts two quaternions
---
--- :param dst: Destination
--- :param v1:  Quaternion being subtracted from
--- :param v2:  Quaternion being subtracted
---
--- C definition: `void quat_sub(struct quat *dst, const struct quat *v1, const struct quat *v2)`
--- @param dst quat
--- @param v1 quat
--- @param v2 quat
function obslua.quat_sub(dst, v1, v2) end

--- Subtracts a floating point from all components
---
--- :param dst: Destination
--- :param v:   Quaternion being subtracted from
--- :param f:   Floating point being subtracted
---
--- C definition: `void quat_subf(struct quat *dst, const struct quat *v, float f)`
--- @param dst quat
--- @param v quat
--- @param f number
function obslua.quat_subf(dst, v, f) end

--- Removes the current callback being executed.  Does nothing if not
--- within a callback.
---
--- C definition: Not available
--- @return unknown
function obslua.remove_current_callback() end

--- Releases the references of a scene item list.
---
--- :param item_list: Array of scene items to release.
---
--- C definition: Not available
--- @param item_list unknown
--- @return unknown
function obslua.sceneitem_list_release(item_list) end

--- script_log not found in OBS documentation nor C wrapper
obslua.script_log = function() end

--- Adds a signal to a signal handler.
---
--- :param handler:     Signal handler object
--- :param signal_decl: Signal declaration string
---
--- C definition: `bool signal_handler_add(signal_handler_t *handler, const char *signal_decl)`
--- @param handler signal_handler
--- @param signal_decl string
--- @return boolean
function obslua.signal_handler_add(handler, signal_decl) end

--- Adds multiple signals to a signal handler.
---
--- :param handler:      Signal handler object
--- :param signal_decls: An array of signal declaration strings,
---                      terminated by *NULL*
---
--- C definition: `bool signal_handler_add_array(signal_handler_t *handler, const char **signal_decls)`
--- @param handler signal_handler
--- @param signal_decls p_char
--- @return boolean
function obslua.signal_handler_add_array(handler, signal_decls) end

--- Adds a callback to a specific signal on a signal handler.  This
--- callback has one parameter:  the calldata_t object.
---
--- :param handler:  A signal_handler_t object.
--- :param signal:   The signal on the signal handler (string)
--- :param callback: The callback to connect to the signal.  Use
---                  :py:func:`signal_handler_disconnect()` or
---                  :py:func:`remove_current_callback()` to remove the
---                  callback.
---
--- C definition: Not available
--- @param handler unknown
--- @param signal unknown
--- @param callback unknown
--- @return unknown
function obslua.signal_handler_connect(handler, signal, callback) end

--- Adds a global callback to a signal handler.  This callback has two
--- parameters:  the first parameter is the signal string, and the second
--- parameter is the calldata_t object.
---
--- :param handler:  A signal_handler_t object.
--- :param callback: The callback to connect.  Use
---                  :py:func:`signal_handler_disconnect_global()` or
---                  :py:func:`remove_current_callback()` to remove the
---                  callback.
---
--- C definition: Not available
--- @param handler unknown
--- @param callback unknown
--- @return unknown
function obslua.signal_handler_connect_global(handler, callback) end

--- Connect a callback to a signal on a signal handler, and increments
--- the handler's internal reference counter, preventing it from being
--- destroyed until the signal has been disconnected.
---
--- :param handler:  Signal handler object
--- :param callback: Signal callback
--- :param data:     Private data passed the callback
---
--- C definition: `void signal_handler_connect_ref(signal_handler_t *handler, const char *signal, signal_callback_t callback, void *data)`
--- @param handler signal_handler
--- @param signal string
--- @param callback f_p_void_p_struct_calldata__void
--- @param data ref_void*
function obslua.signal_handler_connect_ref(handler, signal, callback, data) end

--- Creates a new signal handler object.
---
--- :return: A new signal handler object
---
--- C definition: `signal_handler_t *signal_handler_create(void)`
--- @return signal_handler
function obslua.signal_handler_create() end

--- Destroys a signal handler.
---
--- :param handler: Signal handler object
---
--- C definition: `void signal_handler_destroy(signal_handler_t *handler)`
--- @param handler signal_handler
function obslua.signal_handler_destroy(handler) end

--- Removes a callback from a specific signal of a signal handler.
---
--- :param handler:  A signal_handler_t object.
--- :param signal:   The signal on the signal handler (string)
--- :param callback: The callback to disconnect from the signal.
---
--- C definition: Not available
--- @param handler unknown
--- @param signal unknown
--- @param callback unknown
--- @return unknown
function obslua.signal_handler_disconnect(handler, signal, callback) end

--- Removes a global callback from a signal handler.
---
--- :param handler:  A signal_handler_t object.
--- :param callback: The callback to disconnect.
---
--- C definition: Not available
--- @param handler unknown
--- @param callback unknown
--- @return unknown
function obslua.signal_handler_disconnect_global(handler, callback) end

--- Triggers a signal, calling all connected callbacks.
---
--- :param handler: Signal handler object
--- :param signal:  Name of signal to trigger
--- :param params:  Parameters to pass to the signal
---
--- C definition: `void signal_handler_signal(signal_handler_t *handler, const char *signal, calldata_t *params)`
--- @param handler signal_handler
--- @param signal string
--- @param params calldata
function obslua.signal_handler_signal(handler, signal, params) end

--- Releases the references of a source list.
---
--- :param source_list: Array of sources to release.
---
--- C definition: Not available
--- @param source_list unknown
--- @return unknown
function obslua.source_list_release(source_list) end

---  Adds an timer callback which triggers every *millseconds*.
---
--- C definition: Not available
--- @param callback unknown
--- @param milliseconds unknown
--- @return unknown
function obslua.timer_add(callback, milliseconds) end

---  Removes a timer callback.  (Note: You can also use
---  :py:func:`remove_current_callback()` to terminate the timer from the
---  timer callback)
---
--- Script Sources (Lua Only)
--- C definition: Not available
--- @param callback unknown
--- @return unknown
function obslua.timer_remove(callback) end

--- Gets the absolute values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec2_abs(struct vec2 *dst, const struct vec2 *v)`
--- @param dst vec2
--- @param v vec2
function obslua.vec2_abs(dst, v) end

--- Adds two vectors
---
--- :param dst: Destination
--- :param v1:  Vector 1
--- :param v2:  Vector 2
---
--- C definition: `void vec2_add(struct vec2 *dst, const struct vec2 *v1, const struct vec2 *v2)`
--- @param dst vec2
--- @param v1 vec2
--- @param v2 vec2
function obslua.vec2_add(dst, v1, v2) end

--- Adds a floating point to all components
---
--- :param dst: Destination
--- :param dst: Vector
--- :param f:   Floating point
---
--- C definition: `void vec2_addf(struct vec2 *dst, const struct vec2 *v, float f)`
--- @param dst vec2
--- @param v vec2
--- @param f number
function obslua.vec2_addf(dst, v, f) end

--- Gets the ceiling values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec2_ceil(struct vec2 *dst, const struct vec2 *v)`
--- @param dst vec2
--- @param v vec2
function obslua.vec2_ceil(dst, v) end

--- Compares two vectors
---
--- :param v1:      Vector 1
--- :param v2:      Vector 2
--- :param epsilon: Maximum precision for comparison
---
--- C definition: `int vec2_close(const struct vec2 *v1, const struct vec2 *v2, float epsilon)`
--- @param v1 vec2
--- @param v2 vec2
--- @param epsilon number
--- @return number
function obslua.vec2_close(v1, v2, epsilon) end

--- Copies a vector
---
--- :param dst: Destination
--- :param v:   Vector to copy
---
--- C definition: `void vec2_copy(struct vec2 *dst, const struct vec2 *v)`
--- @param dst vec2
--- @param v vec2
function obslua.vec2_copy(dst, v) end

--- Gets the distance between two vectors
---
--- :param v1: Vector 1
--- :param v2: Vector 2
--- :return:   Distance between the two vectors
---
--- C definition: `float vec2_dist(const struct vec2 *v1, const struct vec2 *v2)`
--- @param v1 vec2
--- @param v2 vec2
--- @return number
function obslua.vec2_dist(v1, v2) end

--- Divides two vectors
---
--- :param dst: Destination
--- :param v1:  Dividend
--- :param v2:  Divisor
---
--- C definition: `void vec2_div(struct vec2 *dst, const struct vec2 *v1, const struct vec2 *v2)`
--- @param dst vec2
--- @param v1 vec2
--- @param v2 vec2
function obslua.vec2_div(dst, v1, v2) end

--- Divides a floating point from all components
---
--- :param dst: Destination
--- :param v:   Vector (dividend)
--- :param f:   Floating point (divisor)
---
--- C definition: `void vec2_divf(struct vec2 *dst, const struct vec2 *v, float f)`
--- @param dst vec2
--- @param v vec2
--- @param f number
function obslua.vec2_divf(dst, v, f) end

--- Performs a dot product between two vectors
---
--- :param v1: Vector 1
--- :param v2: Vector 2
--- :return:   Result of the dot product
---
--- C definition: `float vec2_dot(const struct vec2 *v1, const struct vec2 *v2)`
--- @param v1 vec2
--- @param v2 vec2
--- @return number
function obslua.vec2_dot(v1, v2) end

--- Gets the floor values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec2_floor(struct vec2 *dst, const struct vec2 *v)`
--- @param dst vec2
--- @param v vec2
function obslua.vec2_floor(dst, v) end

--- Gets the length of a vector
---
--- :param v: Vector
--- :return:  The vector's length
---
--- C definition: `float vec2_len(const struct vec2 *v)`
--- @param v vec2
--- @return number
function obslua.vec2_len(v) end

--- Gets the maximum values between two vectors
---
--- :param dst:   Destination
--- :param v:     Vector 1
--- :param max_v: Vector 2
---
--- C definition: `void vec2_max(struct vec2 *dst, const struct vec2 *v, const struct vec2 *max_v)`
--- @param dst vec2
--- @param v vec2
--- @param max_v vec2
function obslua.vec2_max(dst, v, max_v) end

--- Gets the maximum values between a vector's components and a floating point
---
--- :param dst: Destination
--- :param v:   Vector
--- :param val: Floating point
---
--- C definition: `void vec2_maxf(struct vec2 *dst, const struct vec2 *v, float val)`
--- @param dst vec2
--- @param v vec2
--- @param val number
function obslua.vec2_maxf(dst, v, val) end

--- Gets the minimum values between two vectors
---
--- :param dst:   Destination
--- :param v:     Vector 1
--- :param min_v: Vector 2
---
--- C definition: `void vec2_min(struct vec2 *dst, const struct vec2 *v, const struct vec2 *min_v)`
--- @param dst vec2
--- @param v vec2
--- @param min_v vec2
function obslua.vec2_min(dst, v, min_v) end

--- Gets the minimum values between a vector's components and a floating point
---
--- :param dst: Destination
--- :param v:   Vector
--- :param val: Floating point
---
--- C definition: `void vec2_minf(struct vec2 *dst, const struct vec2 *v, float val)`
--- @param dst vec2
--- @param v vec2
--- @param val number
function obslua.vec2_minf(dst, v, val) end

--- Multiplies two vectors
---
--- :param dst: Destination
--- :param v1:  Vector 1
--- :param v2:  Vector 2
---
--- C definition: `void vec2_mul(struct vec2 *dst, const struct vec2 *v1, const struct vec2 *v2)`
--- @param dst vec2
--- @param v1 vec2
--- @param v2 vec2
function obslua.vec2_mul(dst, v1, v2) end

--- Multiplies a floating point with all components
---
--- :param dst: Destination
--- :param dst: Vector
--- :param f:   Floating point
---
--- C definition: `void vec2_mulf(struct vec2 *dst, const struct vec2 *v, float f)`
--- @param dst vec2
--- @param v vec2
--- @param f number
function obslua.vec2_mulf(dst, v, f) end

--- Negates a vector
---
--- :param dst: Destination
--- :param v:   Vector to negate
---
--- C definition: `void vec2_neg(struct vec2 *dst, const struct vec2 *v)`
--- @param dst vec2
--- @param v vec2
function obslua.vec2_neg(dst, v) end

--- Normalizes a vector
---
--- :param dst: Destination
--- :param v:   Vector to normalize
--- C definition: `void vec2_norm(struct vec2 *dst, const struct vec2 *v)`
--- @param dst vec2
--- @param v vec2
function obslua.vec2_norm(dst, v) end

--- Sets the individual components of a 2-component vector.
---
--- :param dst: Destination
--- :param x:   X component
--- :param y:   Y component
---
--- C definition: `void vec2_set(struct vec2 *dst, float x, float y)`
--- @param dst vec2
--- @param x number
--- @param y number
function obslua.vec2_set(dst, x, y) end

--- Subtracts two vectors
---
--- :param dst: Destination
--- :param v1:  Vector being subtracted from
--- :param v2:  Vector being subtracted
---
--- C definition: `void vec2_sub(struct vec2 *dst, const struct vec2 *v1, const struct vec2 *v2)`
--- @param dst vec2
--- @param v1 vec2
--- @param v2 vec2
function obslua.vec2_sub(dst, v1, v2) end

--- Subtracts a floating point from all components
---
--- :param dst: Destination
--- :param v:   Vector being subtracted from
--- :param f:   Floating point being subtracted
---
--- C definition: `void vec2_subf(struct vec2 *dst, const struct vec2 *v, float f)`
--- @param dst vec2
--- @param v vec2
--- @param f number
function obslua.vec2_subf(dst, v, f) end

--- Zeroes a vector
---
--- :param dst: Destination
---
--- C definition: `void vec2_zero(struct vec2 *dst)`
--- @param dst vec2
function obslua.vec2_zero(dst) end

--- Gets the absolute values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec3_abs(struct vec3 *dst, const struct vec3 *v)`
--- @param dst vec3
--- @param v vec3
function obslua.vec3_abs(dst, v) end

--- Adds two vectors
---
--- :param dst: Destination
--- :param v1:  Vector 1
--- :param v2:  Vector 2
---
--- C definition: `void vec3_add(struct vec3 *dst, const struct vec3 *v1, const struct vec3 *v2)`
--- @param dst vec3
--- @param v1 vec3
--- @param v2 vec3
function obslua.vec3_add(dst, v1, v2) end

--- Adds a floating point to all components
---
--- :param dst: Destination
--- :param dst: Vector
--- :param f:   Floating point
---
--- C definition: `void vec3_addf(struct vec3 *dst, const struct vec3 *v, float f)`
--- @param dst vec3
--- @param v vec3
--- @param f number
function obslua.vec3_addf(dst, v, f) end

--- Gets the ceiling values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec3_ceil(struct vec3 *dst, const struct vec3 *v)`
--- @param dst vec3
--- @param v vec3
function obslua.vec3_ceil(dst, v) end

--- Compares two vectors
---
--- :param v1:      Vector 1
--- :param v2:      Vector 2
--- :param epsilon: Maximum precision for comparison
---
--- C definition: `int vec3_close(const struct vec3 *v1, const struct vec3 *v2, float epsilon)`
--- @param v1 vec3
--- @param v2 vec3
--- @param epsilon number
--- @return boolean
function obslua.vec3_close(v1, v2, epsilon) end

--- Copies a vector
---
--- :param dst: Destination
--- :param v:   Vector to copy
---
--- C definition: `void vec3_copy(struct vec3 *dst, const struct vec3 *v)`
--- @param dst vec3
--- @param v vec3
function obslua.vec3_copy(dst, v) end

--- Performs a cross product between two vectors
---
--- :param dst: Destination
--- :param v1:  Vector 1
--- :param v2:  Vector 2
---
--- C definition: `void vec3_cross(struct vec3 *dst, const struct vec3 *v1, const struct vec3 *v2)`
--- @param dst vec3
--- @param v1 vec3
--- @param v2 vec3
function obslua.vec3_cross(dst, v1, v2) end

--- Gets the distance between two vectors
---
--- :param v1: Vector 1
--- :param v2: Vector 2
--- :return:   Distance between the two vectors
---
--- C definition: `float vec3_dist(const struct vec3 *v1, const struct vec3 *v2)`
--- @param v1 vec3
--- @param v2 vec3
--- @return number
function obslua.vec3_dist(v1, v2) end

--- Divides two vectors
---
--- :param dst: Destination
--- :param v1:  Dividend
--- :param v2:  Divisor
---
--- C definition: `void vec3_div(struct vec3 *dst, const struct vec3 *v1, const struct vec3 *v2)`
--- @param dst vec3
--- @param v1 vec3
--- @param v2 vec3
function obslua.vec3_div(dst, v1, v2) end

--- Divides a floating point from all components
---
--- :param dst: Destination
--- :param v:   Vector (dividend)
--- :param f:   Floating point (divisor)
---
--- C definition: `void vec3_divf(struct vec3 *dst, const struct vec3 *v, float f)`
--- @param dst vec3
--- @param v vec3
--- @param f number
function obslua.vec3_divf(dst, v, f) end

--- Performs a dot product between two vectors
---
--- :param v1: Vector 1
--- :param v2: Vector 2
--- :return:   Result of the dot product
---
--- C definition: `float vec3_dot(const struct vec3 *v1, const struct vec3 *v2)`
--- @param v1 vec3
--- @param v2 vec3
--- @return number
function obslua.vec3_dot(v1, v2) end

--- Gets the floor values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec3_floor(struct vec3 *dst, const struct vec3 *v)`
--- @param dst vec3
--- @param v vec3
function obslua.vec3_floor(dst, v) end

--- Creates a 3-component vector from a 4-component vector
---
--- :param dst: 3-component vector destination
--- :param v:   4-component vector
---
--- C definition: `void vec3_from_vec4(struct vec3 *dst, const struct vec4 *v)`
--- @param dst vec3
--- @param v vec4
function obslua.vec3_from_vec4(dst, v) end

--- Gets the length of a vector
---
--- :param v: Vector
--- :return:  The vector's length
---
--- C definition: `float vec3_len(const struct vec3 *v)`
--- @param v vec3
--- @return number
function obslua.vec3_len(v) end

--- Gets the maximum values between two vectors
---
--- :param dst:   Destination
--- :param v:     Vector 1
--- :param max_v: Vector 2
---
--- C definition: `void vec3_max(struct vec3 *dst, const struct vec3 *v, const struct vec3 *max_v)`
--- @param dst vec3
--- @param v vec3
--- @param max_v vec3
function obslua.vec3_max(dst, v, max_v) end

--- Gets the maximum values between a vector's components and a floating point
---
--- :param dst: Destination
--- :param v:   Vector
--- :param val: Floating point
---
--- C definition: `void vec3_maxf(struct vec3 *dst, const struct vec3 *v, float val)`
--- @param dst vec3
--- @param v vec3
--- @param val number
function obslua.vec3_maxf(dst, v, val) end

--- Gets the minimum values between two vectors
---
--- :param dst:   Destination
--- :param v:     Vector 1
--- :param min_v: Vector 2
---
--- C definition: `void vec3_min(struct vec3 *dst, const struct vec3 *v, const struct vec3 *min_v)`
--- @param dst vec3
--- @param v vec3
--- @param min_v vec3
function obslua.vec3_min(dst, v, min_v) end

--- Gets the minimum values between a vector's components and a floating point
---
--- :param dst: Destination
--- :param v:   Vector
--- :param val: Floating point
---
--- C definition: `void vec3_minf(struct vec3 *dst, const struct vec3 *v, float val)`
--- @param dst vec3
--- @param v vec3
--- @param val number
function obslua.vec3_minf(dst, v, val) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec3
--- @param param2 vec3
--- @param param3 plane
function obslua.vec3_mirror(param1, param2, param3) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec3
--- @param param2 vec3
--- @param param3 vec3
function obslua.vec3_mirrorv(param1, param2, param3) end

--- Multiplies two vectors
---
--- :param dst: Destination
--- :param v1:  Vector 1
--- :param v2:  Vector 2
---
--- C definition: `void vec3_mul(struct vec3 *dst, const struct vec3 *v1, const struct vec3 *v2)`
--- @param dst vec3
--- @param v1 vec3
--- @param v2 vec3
function obslua.vec3_mul(dst, v1, v2) end

--- Multiplies a floating point with all components
---
--- :param dst: Destination
--- :param dst: Vector
--- :param f:   Floating point
---
--- C definition: `void vec3_mulf(struct vec3 *dst, const struct vec3 *v, float f)`
--- @param dst vec3
--- @param v vec3
--- @param f number
function obslua.vec3_mulf(dst, v, f) end

--- Negates a vector
---
--- :param dst: Destination
--- :param v:   Vector to negate
---
--- C definition: `void vec3_neg(struct vec3 *dst, const struct vec3 *v)`
--- @param dst vec3
--- @param v vec3
function obslua.vec3_neg(dst, v) end

--- Normalizes a vector
---
--- :param dst: Destination
--- :param v:   Vector to normalize
---
--- C definition: `void vec3_norm(struct vec3 *dst, const struct vec3 *v)`
--- @param dst vec3
--- @param v vec3
function obslua.vec3_norm(dst, v) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec3
--- @param param2 plane
function obslua.vec3_plane_dist(param1, param2) end

--- Generates a random vector
---
--- :param dst:           Destination
--- :param positive_only: *true* if positive only, *false* otherwise
--- C definition: `void vec3_rand(struct vec3 *dst, int positive_only)`
--- @param dst vec3
--- @param positive_only number
function obslua.vec3_rand(dst, positive_only) end

--- Rotates a vector
---
--- :param dst: Destination
--- :param v:   Vector
--- :param m:   Matrix
---
--- C definition: `void vec3_rotate(struct vec3 *dst, const struct vec3 *v, const struct matrix3 *m)`
--- @param dst vec3
--- @param v vec3
--- @param m matrix3
function obslua.vec3_rotate(dst, v, m) end

--- Sets the individual components of a 3-component vector.
---
--- :param dst: Destination
--- :param x:   X component
--- :param y:   Y component
--- :param y:   Z component
---
--- C definition: `void vec3_set(struct vec3 *dst, float x, float y)`
--- @param dst vec3
--- @param x number
--- @param y number
--- @param param4 number
function obslua.vec3_set(dst, x, y, param4) end

--- Subtracts two vectors
---
--- :param dst: Destination
--- :param v1:  Vector being subtracted from
--- :param v2:  Vector being subtracted
---
--- C definition: `void vec3_sub(struct vec3 *dst, const struct vec3 *v1, const struct vec3 *v2)`
--- @param dst vec3
--- @param v1 vec3
--- @param v2 vec3
function obslua.vec3_sub(dst, v1, v2) end

--- Subtracts a floating point from all components
---
--- :param dst: Destination
--- :param v:   Vector being subtracted from
--- :param f:   Floating point being subtracted
---
--- C definition: `void vec3_subf(struct vec3 *dst, const struct vec3 *v, float f)`
--- @param dst vec3
--- @param v vec3
--- @param f number
function obslua.vec3_subf(dst, v, f) end

--- Transforms a vector
---
--- :param dst: Destination
--- :param v:   Vector
--- :param m:   Matrix
---
--- C definition: `void vec3_transform(struct vec3 *dst, const struct vec3 *v, const struct matrix4 *m)`
--- @param dst vec3
--- @param v vec3
--- @param m matrix4
function obslua.vec3_transform(dst, v, m) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec3
--- @param param2 vec3
--- @param param3 matrix3
function obslua.vec3_transform3x4(param1, param2, param3) end

--- Zeroes a vector
---
--- :param dst: Destination
---
--- C definition: `void vec3_zero(struct vec3 *dst)`
--- @param dst vec3
function obslua.vec3_zero(dst) end

--- Gets the absolute values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec4_abs(struct vec4 *dst, const struct vec4 *v)`
--- @param dst vec4
--- @param v vec4
function obslua.vec4_abs(dst, v) end

--- Adds two vectors
---
--- :param dst: Destination
--- :param v1:  Vector 1
--- :param v2:  Vector 2
---
--- C definition: `void vec4_add(struct vec4 *dst, const struct vec4 *v1, const struct vec4 *v2)`
--- @param dst vec4
--- @param v1 vec4
--- @param v2 vec4
function obslua.vec4_add(dst, v1, v2) end

--- Adds a floating point to all components
---
--- :param dst: Destination
--- :param dst: Vector
--- :param f:   Floating point
---
--- C definition: `void vec4_addf(struct vec4 *dst, const struct vec4 *v, float f)`
--- @param dst vec4
--- @param v vec4
--- @param f number
function obslua.vec4_addf(dst, v, f) end

--- Gets the ceiling values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec4_ceil(struct vec4 *dst, const struct vec4 *v)`
--- @param dst vec4
--- @param v vec4
function obslua.vec4_ceil(dst, v) end

--- Compares two vectors
---
--- :param v1:      Vector 1
--- :param v2:      Vector 2
--- :param epsilon: Maximum precision for comparison
---
--- C definition: `int vec4_close(const struct vec4 *v1, const struct vec4 *v2, float epsilon)`
--- @param v1 vec4
--- @param v2 vec4
--- @param epsilon number
--- @return number
function obslua.vec4_close(v1, v2, epsilon) end

--- Copies a vector
---
--- :param dst: Destination
--- :param v:   Vector to copy
---
--- C definition: `void vec4_copy(struct vec4 *dst, const struct vec4 *v)`
--- @param dst vec4
--- @param v vec4
function obslua.vec4_copy(dst, v) end

--- Gets the distance between two vectors
---
--- :param v1: Vector 1
--- :param v2: Vector 2
--- :return:   Distance between the two vectors
---
--- C definition: `float vec4_dist(const struct vec4 *v1, const struct vec4 *v2)`
--- @param v1 vec4
--- @param v2 vec4
--- @return number
function obslua.vec4_dist(v1, v2) end

--- Divides two vectors
---
--- :param dst: Destination
--- :param v1:  Dividend
--- :param v2:  Divisor
---
--- C definition: `void vec4_div(struct vec4 *dst, const struct vec4 *v1, const struct vec4 *v2)`
--- @param dst vec4
--- @param v1 vec4
--- @param v2 vec4
function obslua.vec4_div(dst, v1, v2) end

--- Divides a floating point from all components
---
--- :param dst: Destination
--- :param v:   Vector (dividend)
--- :param f:   Floating point (divisor)
---
--- C definition: `void vec4_divf(struct vec4 *dst, const struct vec4 *v, float f)`
--- @param dst vec4
--- @param v vec4
--- @param f number
function obslua.vec4_divf(dst, v, f) end

--- Performs a dot product between two vectors
---
--- :param v1: Vector 1
--- :param v2: Vector 2
--- :return:   Result of the dot product
---
--- C definition: `float vec4_dot(const struct vec4 *v1, const struct vec4 *v2)`
--- @param v1 vec4
--- @param v2 vec4
--- @return number
function obslua.vec4_dot(v1, v2) end

--- Gets the floor values of each component
---
--- :param dst: Destination
--- :param v:   Vector
---
--- C definition: `void vec4_floor(struct vec4 *dst, const struct vec4 *v)`
--- @param dst vec4
--- @param v vec4
function obslua.vec4_floor(dst, v) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec4
--- @param param2 number
function obslua.vec4_from_bgra(param1, param2) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec4
--- @param param2 number
function obslua.vec4_from_rgba(param1, param2) end

--- Creates a 4-component vector from a 3-component vector
---
--- :param dst: 4-component vector destination
--- :param v:   3-component vector
---
--- C definition: `void vec4_from_vec3(struct vec4 *dst, const struct vec3 *v)`
--- @param dst vec4
--- @param v vec3
function obslua.vec4_from_vec3(dst, v) end

--- Gets the length of a vector
---
--- :param v: Vector
--- :return:  The vector's length
---
--- C definition: `float vec4_len(const struct vec4 *v)`
--- @param v vec4
--- @return number
function obslua.vec4_len(v) end

--- Gets the maximum values between two vectors
---
--- :param dst:   Destination
--- :param v:     Vector 1
--- :param max_v: Vector 2
---
--- C definition: `void vec4_max(struct vec4 *dst, const struct vec4 *v, const struct vec4 *max_v)`
--- @param dst vec4
--- @param v vec4
--- @param max_v vec4
function obslua.vec4_max(dst, v, max_v) end

--- Gets the maximum values between a vector's components and a floating point
---
--- :param dst: Destination
--- :param v:   Vector
--- :param val: Floating point
---
--- C definition: `void vec4_maxf(struct vec4 *dst, const struct vec4 *v, float val)`
--- @param dst vec4
--- @param v vec4
--- @param val number
function obslua.vec4_maxf(dst, v, val) end

--- Gets the minimum values between two vectors
---
--- :param dst:   Destination
--- :param v:     Vector 1
--- :param min_v: Vector 2
---
--- C definition: `void vec4_min(struct vec4 *dst, const struct vec4 *v, const struct vec4 *min_v)`
--- @param dst vec4
--- @param v vec4
--- @param min_v vec4
function obslua.vec4_min(dst, v, min_v) end

--- Gets the minimum values between a vector's components and a floating point
---
--- :param dst: Destination
--- :param v:   Vector
--- :param val: Floating point
---
--- C definition: `void vec4_minf(struct vec4 *dst, const struct vec4 *v, float val)`
--- @param dst vec4
--- @param v vec4
--- @param val number
function obslua.vec4_minf(dst, v, val) end

--- Multiplies two vectors
---
--- :param dst: Destination
--- :param v1:  Vector 1
--- :param v2:  Vector 2
---
--- C definition: `void vec4_mul(struct vec4 *dst, const struct vec4 *v1, const struct vec4 *v2)`
--- @param dst vec4
--- @param v1 vec4
--- @param v2 vec4
function obslua.vec4_mul(dst, v1, v2) end

--- Multiplies a floating point with all components
---
--- :param dst: Destination
--- :param dst: Vector
--- :param f:   Floating point
---
--- C definition: `void vec4_mulf(struct vec4 *dst, const struct vec4 *v, float f)`
--- @param dst vec4
--- @param v vec4
--- @param f number
function obslua.vec4_mulf(dst, v, f) end

--- Negates a vector
---
--- :param dst: Destination
--- :param v:   Vector to negate
---
--- C definition: `void vec4_neg(struct vec4 *dst, const struct vec4 *v)`
--- @param dst vec4
--- @param v vec4
function obslua.vec4_neg(dst, v) end

--- Normalizes a vector
---
--- :param dst: Destination
--- :param v:   Vector to normalize
---
--- C definition: `void vec4_norm(struct vec4 *dst, const struct vec4 *v)`
--- @param dst vec4
--- @param v vec4
function obslua.vec4_norm(dst, v) end

--- Sets the individual components of a 4-component vector.
---
--- :param dst: Destination
--- :param x:   X component
--- :param y:   Y component
--- :param z:   Z component
--- :param w:   W component
---
--- C definition: `void vec4_set(struct vec4 *dst, float x, float y, float z, float w)`
--- @param dst vec4
--- @param x number
--- @param y number
--- @param z number
--- @param w number
function obslua.vec4_set(dst, x, y, z, w) end

--- Subtracts two vectors
---
--- :param dst: Destination
--- :param v1:  Vector being subtracted from
--- :param v2:  Vector being subtracted
---
--- C definition: `void vec4_sub(struct vec4 *dst, const struct vec4 *v1, const struct vec4 *v2)`
--- @param dst vec4
--- @param v1 vec4
--- @param v2 vec4
function obslua.vec4_sub(dst, v1, v2) end

--- Subtracts a floating point from all components
---
--- :param dst: Destination
--- :param v:   Vector being subtracted from
--- :param f:   Floating point being subtracted
---
--- C definition: `void vec4_subf(struct vec4 *dst, const struct vec4 *v, float f)`
--- @param dst vec4
--- @param v vec4
--- @param f number
function obslua.vec4_subf(dst, v, f) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec4
function obslua.vec4_to_bgra(param1) end

--- Not mentioned in OBS documentation
---
--- C definition: Not available
--- @param param1 vec4
function obslua.vec4_to_rgba(param1) end

--- Transforms a vector
---
--- :param dst: Destination
--- :param v:   Vector
--- :param m:   Matrix
--- C definition: `void vec4_transform(struct vec4 *dst, const struct vec4 *v, const struct matrix4 *m)`
--- @param dst vec4
--- @param v vec4
--- @param m matrix4
function obslua.vec4_transform(dst, v, m) end

--- Zeroes a vector
---
--- :param dst: Destination
---
--- C definition: `void vec4_zero(struct vec4 *dst)`
--- @param dst vec4
function obslua.vec4_zero(dst) end

return obslua
