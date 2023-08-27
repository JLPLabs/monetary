-- monetary.tl
-- monetary.tl is a library for creating monetary strings. It that provides a
-- function to set locale specific separators and another function to format
-- values in a return string (like sprintf).
-- 
-- it provides a subset of what is provided by strfmon.
-- see: https://www.gnu.org/software/libc/manual/html_node/Formatting-Numbers.html
--

require "common"

-- state variables with default values
local type Flags = record
  isgroup: boolean    -- true, use 000's grouping symbol
  issign:  boolean    -- true, use '-' for negative values (otherwise use parenthesis).
  iscur:   boolean    -- true, use the currency symbol
  isright: boolean    -- true, string is right-justified

  width:   integer    -- minimum size of the formatted string
  leftw:   integer    -- minimum # of digit positions (excluding thou) left of decimal point
                      -- '0' means there is no minimum width
  rightw:  integer    -- minimum # of digit positions right of decimal point 
                      -- '-1' means there is no minimum width
                      -- '0'  means no decimal point
end



-- update flags based on fmt
local function parsefmt(fmt: string): Flags, string
  
  local res: Flags = {}
  local i = 1         -- index into fmt
  local c: string

  -- opening char
  c = fmt:sub(i,i)
  if c ~= "%" then return nil, "incorrectly prefixed monetary format" end
  i = i + 1

  -- grouping?
  c = fmt:sub(i,i)
  if c == '^' then res.isgroup = false; i = i + 1
  else             res.isgroup = true
  end


  -- sign?
  c = fmt:sub(i,i)
  if     c == '+' then res.issign = true;  i = i + 1
  elseif c == '(' then res.issign = false; i = i + 1
  else                 res.issign = true 
  end

  -- currency symbol?
  c = fmt:sub(i,i)
  if c == '!' then res.iscur = false; i = i + 1
  else             res.iscur = true
  end

  --justified
  c = fmt:sub(i,i)
  if c == '-' then res.isright = false; i = i + 1
  else             res.isright = true
  end

  -- overall width
  local str = fmt:sub(i)
  local width = str:match("^(%d+)")
  if width then res.width = tonumber(width); i = i + #width
  else          res.width = 0
  end

  -- width left of decimal
  c = fmt:sub(i,i)
  local context = "no#"
  if c == '#' then
    i = i + 1
    context = "in#"
    str = fmt:sub(i)
    local leftw = str:match("^(%d*)")
    if leftw then res.leftw = tonumber(leftw); i = i + #leftw
    else          res.leftw = 0
    end
  else
    res.leftw = 0
  end

  -- width right of decimal (applies only in the context of # flag)
  if context == "in#" then
    c = fmt:sub(i,i)
    if c == '.' then
      i = i + 1
      str = fmt:sub(i)
      local rightw = str:match("^(%d+)")
      if rightw then res.rightw = tonumber(rightw); i = i + #rightw
      else           res.rightw = -1
      end
    else
      res.rightw = -1
    end
  else
    res.rightw = -1
  end

  -- terminating char
  c = fmt:sub(i,i)
  if c ~= 'n' then return nil, "incorrectly terminated monetary format" end
  i = i + 1

  -- done
  return res, ""

end


-- the Module, M --------------------------------------------------------------

-- separators & currency, default
local thou = ","
local dec  = "."
local finddig = "%d%."  -- find digit immediately before decimal point
local cur = "$"

-- module as record
local type M = record
  localize: function(thou: string, dec: string, cur: string)
  strfmon:  function(fmt: string, val: number): string
end

-- set separators
-- currency symbol should not be UTF-8
function M.localize(t: string, d: string, c: string)
  thou = t or thou
  dec = d or dec
  cur = c or cur
  finddig = string.format("%%d%%%s", dec)
end

-- table to accelerate execution of the rounding process
local mul: {integer} = {
  10,
  10 * 10,
  10 * 10 * 10,
  10 * 10 * 10 * 10,
  10 * 10 * 10 * 10 * 10,
}

-- rounds number to d decimal places.
-- note that a width of 0 requires an integer value
local function round(val: number, d: integer): number
  if d == -1 then return val end    -- explicit request to not round

  local pos = val >= 0
  val = math.abs(val)
  local m = mul[d] or 10^d
  local tmp = (val * m) + 0.5
  tmp = math.floor(tmp)
  local res = tmp / m
  if not pos then res = -res end
  if d == 0 then 
    res = math.tointeger(res)
  end
  return res
end


-- convert number to string, update decimal point, add 000's separator
local function isgroup(flag: boolean, val: number): string
  -- to string
  local pos = val >= 0
  val = math.abs(val)
  local res = tostring(val)

  -- update decimal point to localized version
  local i = res:find("%.")
  if i then res = res:sub(1,i-1)..dec..res:sub(i+1) end

  -- add 000's separator
  if flag then
    local nsep = math.floor(math.log(val, 10*10*10))  -- number of 000's separators
    local j = res:find(finddig) or #res         -- find digit left of decimal point 
     for _ = 1, nsep do
      res = res:sub(1,j-3)..thou..res:sub(j-2)
      j = j - 3
    end
  end
  if not pos then res = "-"..res end
  return res
end

-- use '-' or '()' for negative values
local function issign(flag: boolean, str: string): string
  local res = str

  -- use '-' (it is already there from previous step)
  if flag then return res end

  -- apply '()' rules
  if res:sub(1,1) == '-' then
    res = '('..str:sub(2)..')'        -- negative number gets ()
  else
    res = ' '..res..' '               -- positive number gets pad
  end
  return res
end

-- use currency symbol or not
local function iscur(flag: boolean, str: string): string
  local res = str
  if flag then res = cur..res end
  return res
end

-- padding "on the left" of decimal point
-- ensure the number of digits to the left of the decimal point == flag
-- (trickier when thousand grouping or () for negative are used)
local function leftw(flag: integer, isgroupflag: boolean, issignflag: boolean,
                     str: string): string
  local res = str

  if flag == 0 then return res end      -- no left padding requested; done

  -- map flag into total string length
  local total = flag
  if isgroupflag then total = total + (flag-1)//3 end
  local i = 0
  if issignflag == false then 
    total = total + 1
    i = res:find("%d") - 1   -- find digit, offset for space reserved for '('
  else
    i = res:find("%-?%d")    -- find either leading '-' or first digit
  end
  local j = res:find(finddig) or #res -- find digit before decimal point
  local pad = total - (j - i + 1)
  local a = res:sub(1,i-1) or ""
  local b = string.rep(" ", pad)
  local c = res:sub(i)
  res = a .. b .. c

  return res end


-- padding/rounding "on the right" of decimal point
local function rightw(flag: integer, str: string): string
  local res = str

  if flag == -1 then    -- no minimum width requested; DONE
    return res
  end     

  if flag == 0 then     -- requested no decimal point; DONE
    return res          -- (the rounding step took care of this for us)
  end

  -- count number of digits right of decimal point
  local decptdigs = sprintf("%%%s%%d*", dec) -- decimal point and digits to right
  local j, k = res:find(decptdigs)
  local count = 0
  if k then count = k - j end

  -- too few? (or just right), Pad with 0; DONE
  if count <= flag then
    res = res:sub(1,k) .. string.rep("0", flag-count) .. res:sub(k+1)
    return res
  end

end


-- frame up the string into at least a total width, and justified
local function frame(isrightflag: boolean, widthflag: integer, str: string): string
  local res = str
  if #str >= widthflag then return res end

  local pad = widthflag - #str
  if isrightflag then
    res = string.rep(" ", pad) .. res
  else
    res = res .. string.rep(" ", pad)
  end
  return res
end


-- debug tool
local function printflags(flags: Flags)
  printf("[t: [%s], d: [%s]] ", thou, dec)
  printf("[g: %s, s: %s, c: %s, r: %s] ", flags.isgroup, flags.issign, flags.iscur, 
                                          flags.isright)
  printf("[w: %d, l: %d, r: %d]\n", flags.width, flags.leftw, flags.rightw)
end

-- string format monetary
function M.strfmon(fmt: string, val: number): string

  local flags, err = parsefmt(fmt)
  if not flags then
    print(err)
    return("*****")
  end

  if arg[1] == '-v' then printflags(flags) end

  -- rounding and grouping is easier on a number; 
  -- the rest of the process is string manipulation
  val = round(val, flags.rightw)
  local res = isgroup(flags.isgroup, val)
  res = issign(flags.issign, res)
  res = iscur(flags.iscur, res)
  res = leftw(flags.leftw, flags.isgroup, flags.issign, res)
  res = rightw(flags.rightw, res)
  res = frame(flags.isright, flags.width, res)

  return res 
end


return M
