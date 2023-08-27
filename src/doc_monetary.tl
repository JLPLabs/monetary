-- for documentation of monetary.tl

local m = require "monetary"
local strfmon = m.strfmon
local localize = m.localize

local val1 = 10499.50
local val2 = 1234567

local fmt1 = "%#8.2n"    -- 8 digits to left of decimal; 2 to right
local fmt2 = "%#8.0n"    --               "            ; 0 to right

print( strfmon(fmt1, val1) )   -- $    10,499.50
print( strfmon(fmt1, val2) )   -- $ 1,234,567.00
print()
print( strfmon(fmt2, val1) )   -- $    10,500
print( strfmon(fmt2, val2) )   -- $ 1,234,567

print()
print("localized...")
localize(".",",","€")

print( strfmon(fmt1, val1) )   -- €    10.499,50
print( strfmon(fmt1, val2) )   -- € 1.234.567,00
print()
print( strfmon(fmt2, val1) )   -- €    10.500
print( strfmon(fmt2, val2) )   -- € 1.234.567

