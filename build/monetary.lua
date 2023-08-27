local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local math = _tl_compat and _tl_compat.math or math; local string = _tl_compat and _tl_compat.string or string








require("common")



















local function parsefmt(fmt)

   local res = {}
   local i = 1
   local c


   c = fmt:sub(i, i)
   if c ~= "%" then return nil, "incorrectly prefixed monetary format" end
   i = i + 1


   c = fmt:sub(i, i)
   if c == '^' then res.isgroup = false; i = i + 1
   else res.isgroup = true
   end



   c = fmt:sub(i, i)
   if c == '+' then res.issign = true; i = i + 1
   elseif c == '(' then res.issign = false; i = i + 1
   else res.issign = true
   end


   c = fmt:sub(i, i)
   if c == '!' then res.iscur = false; i = i + 1
   else res.iscur = true
   end


   c = fmt:sub(i, i)
   if c == '-' then res.isright = false; i = i + 1
   else res.isright = true
   end


   local str = fmt:sub(i)
   local width = str:match("^(%d+)")
   if width then res.width = tonumber(width); i = i + #width
   else res.width = 0
   end


   c = fmt:sub(i, i)
   local context = "no#"
   if c == '#' then
      i = i + 1
      context = "in#"
      str = fmt:sub(i)
      local leftw = str:match("^(%d*)")
      if leftw then res.leftw = tonumber(leftw); i = i + #leftw
      else res.leftw = 0
      end
   else
      res.leftw = 0
   end


   if context == "in#" then
      c = fmt:sub(i, i)
      if c == '.' then
         i = i + 1
         str = fmt:sub(i)
         local rightw = str:match("^(%d+)")
         if rightw then res.rightw = tonumber(rightw); i = i + #rightw
         else res.rightw = -1
         end
      else
         res.rightw = -1
      end
   else
      res.rightw = -1
   end


   c = fmt:sub(i, i)
   if c ~= 'n' then return nil, "incorrectly terminated monetary format" end
   i = i + 1


   return res, ""

end





local thou = ","
local dec = "."
local finddig = "%d%."


local M = {}





function M.setsep(t, d)
   thou = t
   dec = d
   finddig = string.format("%%d%%%s", dec)
end


local mul = {
   10,
   10 * 10,
   10 * 10 * 10,
   10 * 10 * 10 * 10,
   10 * 10 * 10 * 10 * 10,
}



local function round(val, d)
   if d == -1 then return val end

   local pos = val >= 0
   val = math.abs(val)
   local m = mul[d] or 10 ^ d
   local tmp = (val * m) + 0.5
   tmp = math.floor(tmp)
   local res = tmp / m
   if not pos then res = -res end
   if d == 0 then
      return math.tointeger(res)
   else
      return res
   end
end



local function isgroup(flag, val)
   local pos = val >= 0
   val = math.abs(val)
   local res = tostring(val)
   if flag then
      local nsep = math.floor(math.log(val, 10 * 10 * 10))
      local j = res:find(finddig) or #res
      for _ = 1, nsep do
         res = res:sub(1, j - 3) .. thou .. res:sub(j - 2)
         j = j - 3
      end
   end
   if not pos then res = "-" .. res end
   return res
end


local function issign(flag, str)
   local res = str


   if flag then return res end


   if res:sub(1, 1) == '-' then
      res = '(' .. str:sub(2) .. ')'
   else
      res = ' ' .. res .. ' '
   end
   return res
end


local function iscur(flag, str)
   local res = str
   if flag then res = "$" .. res end
   return res
end




local function leftw(flag, isgroupflag, issignflag,
   str)
   local res = str

   if flag == 0 then return res end


   local total = flag
   if isgroupflag then total = total + (flag - 1) // 3 end
   local i = 0
   if issignflag == false then
      total = total + 1
      i = res:find("%d") - 1
   else
      i = res:find("%-?%d")
   end
   local j = res:find(finddig) or #res
   local pad = total - (j - i + 1)
   local a = res:sub(1, i - 1) or ""
   local b = string.rep(" ", pad)
   local c = res:sub(i)
   res = a .. b .. c

   return res end



local function rightw(flag, str)
   local res = str

   if flag == -1 then
      return res
   end

   if flag == 0 then
      return res
   end


   local decptdigs = sprintf("%%%s%%d*", dec)
   local j, k = res:find(decptdigs)
   local count = 0
   if k then count = k - j end


   if count <= flag then
      res = res:sub(1, k) .. string.rep("0", flag - count) .. res:sub(k + 1)
      return res
   end

end



local function frame(isrightflag, widthflag, str)
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



local function printflags(flags)
   printf("[t: [%s], d: [%s]] ", thou, dec)
   printf("[g: %s, s: %s, c: %s, r: %s] ", flags.isgroup, flags.issign, flags.iscur,
   flags.isright)
   printf("[w: %d, l: %d, r: %d]\n", flags.width, flags.leftw, flags.rightw)
end


function M.strfmon(fmt, val)

   local flags, err = parsefmt(fmt)
   if not flags then
      print(err)
      return ("*****")
   end

   if arg[1] == '-v' then printflags(flags) end



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
