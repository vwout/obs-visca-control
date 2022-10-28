-- Workaround for Alpine environment - package lua5.2-bitop is broken
-- OBS includes bitop instead of bit32
return require("bit32")