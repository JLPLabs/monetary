-- for documentation of monetary.tl

local m = require "monetary"
local strfmon = m.strfmon

local val1 = 10499.50
local val2 = 1234567

print(strfmon("%#8.2n", val1))   -- space for 8 digits to left, ...
print(strfmon("%#8.2n", val2))   --    and 2 to right of decimal
print()
print(strfmon("%#8.0n", val1))   -- space for 8 digits to left, ...
print(strfmon("%#8.0n", val2))   --    and none to the right of decimal

