

local m = require("monetary")
local strfmon = m.strfmon

local val1 = 10499.50
local val2 = 1234567

print(strfmon("%#8.2n", val1))
print(strfmon("%#8.2n", val2))
print()
print(strfmon("%#8.0n", val1))
print(strfmon("%#8.0n", val2))
