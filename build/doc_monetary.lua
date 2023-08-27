

local m = require("monetary")
local strfmon = m.strfmon
local localize = m.localize

local val1 = 10499.50
local val2 = 1234567

local fmt1 = "%#8.2n"
local fmt2 = "%#8.0n"

print(strfmon(fmt1, val1))
print(strfmon(fmt1, val2))
print()
print(strfmon(fmt2, val1))
print(strfmon(fmt2, val2))

print()
print("localized...")
localize(".", ",", "€")

print(strfmon(fmt1, val1))
print(strfmon(fmt1, val2))
print()
print(strfmon(fmt2, val1))
print(strfmon(fmt2, val2))
