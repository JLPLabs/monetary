-- common.tl
-- Common provides functions used in many places
--
-- use:
-- require "common"          -- loads utilities as globally accessible

-- utilities ==================================================================
global function printf(fmt: string, ...:any)
  io.write(string.format(fmt, ...))
end

global function sprintf(fmt: string, ...:any): string
  return string.format(fmt, ...)
end

-- types ======================================================================
global type Eqn = function(integer): number
