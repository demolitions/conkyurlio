
function Split(str, delim, maxNb)
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function SetBarGauge(coff, cact, twarn, cwarn, tcrit, ccrit)
  g_coff = coff;
  g_cact = cact;
  if(twarn == nil) then
    g_twarn = nil;
    g_cwarn = nil;
  else
    g_twarn = twarn;
    g_cwarn = cwarn;
  end
  if(tcrit == nil) then
    g_tcrit = nil;
    g_ccrit = nil;
  else
    g_tcrit = tcrit;
    g_ccrit = ccrit;
  end
end

function BarGauge(cr, startangle, endangle, radius, height, name, valueperc, valuetext, valueradial)
  if(type(tonumber(valueperc)) ~= "number") then
    -- print ("converted "..valueperc.."("..type(valueperc)..") to 0\n");
    valueperc = 0; 
  end
  cairo_select_font_face(cr, font, font_slant, font_bold);
  -- name
  ArcText(cr, startangle - 1, radius + (height * 0.32), c_white, height * 0.5, name);
  -- gauge
--ArcPadGauge(cr, startangle, endangle, radius, size, value, color, offcolor, thr1, color1, thr2, color2)
  ArcPadGauge(cr, startangle, endangle, radius, height * 0.5, valueperc, g_cact, g_coff, g_twarn, g_cwarn, g_tcrit, g_ccrit);
  cairo_select_font_face(cr, font, font_slant, font_plain);
  -- valuetext
  textsize = height * 0.4;
  ArcText(cr, endangle - 2.5, radius + (height * 0.35), c_white, height * 0.4, valuetext, false, true);
  -- valueradial
  PolarText(cr, endangle - 1.5, radius + (height * 0.1), c_white, height * 0.4, valueradial, true);
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function DebugString(cr,str)
  SetColor(cr, c_white);
  cairo_move_to(cr,10,10);
  cairo_show_text(cr, str);
end
