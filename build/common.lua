local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local io = _tl_compat and _tl_compat.io or io; local string = _tl_compat and _tl_compat.string or string






function printf(fmt, ...)
   io.write(string.format(fmt, ...))
end

function sprintf(fmt, ...)
   return string.format(fmt, ...)
end


Eqn = {}
