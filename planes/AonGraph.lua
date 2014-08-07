require 'cairo'
require 'AonMath'

function AonGraph_Init()
  c_yellow = NewColor(255,255,100);
  c_black = NewColor(0,0,0);
  c_transparent = NewColor(40,40,40,0);
  c_white = NewColor(255,255,255);
  c_red = NewColor(255,0,0);
  c_celeste = NewColor(120,220,255);
  c_blue = NewColor(60, 120, 255);
  c_darkblue = NewColor( 60, 80, 120);
  c_gray = NewColor(100, 100, 100);
  c_orange = NewColor(255, 200, 100);
  c_darkorange = NewColor(100, 60, 40);
  c_darkgray = NewColor(20, 20, 20);
end

function AonGraph_FontInit(cr)
  c_font_size = 10;
  AonGraph_FontWidth(cr)
end

function AonGraph_FontWidth(cr)
  local stringtest = "ABCDEFGHIJKLMNOPQRSTUVWXYZ#@";
  local extents = cairo_text_extents_t:create();
  c_charwidth = 0;
  for i = 1, #stringtest, 1 do
    local c = stringtest:sub(i,i);
    cairo_text_extents(cr, c, extents);
    c_charwidth = math.max(extents.width, c_charwidth);
  end
end

function c_SetFont(cr, size)
  c_font_size = size;
  cairo_set_font_size(cr, c_font_size);
  AonGraph_FontWidth(cr)
end

function ArcStringWidth(cr, text)
  return c_charwidth * #text;
--[[
  local extents = cairo_text_extents_t:create();
  local stringwidth = 0;
  for i = 1, #text, 1 do
    local c = text:sub(i,i);
    cairo_text_extents(cr, c, extents);
    local charwidth = math.max(extents.width, c_font_size);
    stringwidth = stringwidth + charwidth;
  end
  return stringwidth;
--]]
end

function NewColor(red, green, blue, alpha)
  if (red > 1) then red = red/255; end
  if (green > 1) then green = green/255; end
  if (blue > 1) then blue = blue/255; end
  if(alpha == nil) then alpha = 1; end
  if (alpha > 1) then alpha = alpha/255; end
  col = {}
  col["r"] = red;
  col["g"] = green;
  col["b"] = blue;
  col["a"] = alpha;
  return col;
end

function SetColor(cr, color)
  if (color ~= nil) then
	  if (color["r"] == nil) then color["r"] = 1; end
	  if (color["g"] == nil) then color["g"] = 1; end
	  if (color["b"] == nil) then color["b"] = 1; end
	  if (color["a"] == nil) then color["a"] = 1; end
	  cairo_set_source_rgba (cr,color["r"],color["g"],color["b"],color["a"])
  end;
end

-- Cairo font slant enum:
--CAIRO_FONT_SLANT_NORMAL
--CAIRO_FONT_SLANT_ITALIC
--CAIRO_FONT_SLANT_OBLIQUE

-- Cairo font weight:
--CAIRO_FONT_WEIGHT_NORMAL
--CAIRO_FONT_WEIGHT_BOLD

function PolarText(cr, angle, radius, color, size, text, reversed)
  if(reversed == nil) then reversed = false; end;
  c_SetFont(cr, size);
  SetColor(cr, color);
  local xpos = HUDXPos(angle, radius);
  local ypos = HUDYPos(angle, radius);
  local extents = cairo_text_extents_t:create();
  cairo_text_extents(cr, text, extents);
  if (reversed) then
    xpos = xpos - PolarXPos(angle + 90, extents.height/2);
    ypos = ypos + PolarYPos(angle + 90, extents.height/2);
    xpos = xpos - PolarXPos(angle + 180, extents.width);
    ypos = ypos + PolarYPos(angle + 180, extents.width);
  else
    xpos = xpos - PolarXPos(angle - 90, extents.height/2);
    ypos = ypos + PolarYPos(angle - 90, extents.height/2);
  end
  cairo_move_to(cr, xpos, ypos);
  if (reversed) then
    cairo_rotate(cr, Deg2Rad(angle + 180));
  else
    cairo_rotate(cr, Deg2Rad(angle));
  end
  cairo_show_text(cr, text)
  if (reversed) then
    cairo_rotate(cr, -Deg2Rad(angle + 180));
  else
    cairo_rotate(cr, -Deg2Rad(angle));
  end
end


function ArcText(cr, angle, radius, color, size, text, reversed, rightalign)
  if(reversed == nil) then reversed = false; end;
  c_SetFont(cr, size);
  if(rightalign) then
    diff = DeltaAngle(radius, ArcStringWidth(cr, text));
  else
    diff = 0;
  end
  SetColor(cr, color);
  local extents = cairo_text_extents_t:create();
  cairo_text_extents(cr, text, extents);
  local cangle = ReduceAngle(angle - diff);
  local stringheight = extents.height;
  if(reversed) then
    start = #text;
    fine = 1;
    step = -1;
  else
    start = 1;
    fine = #text;
    step = 1;
  end
  for i = start, fine, step do
    local c = text:sub(i,i);
    cairo_text_extents(cr, c, extents);
    cangle = cangle + ReduceAngle(DeltaAngle(radius, c_charwidth * 0.8));
    local xpos = HUDXPos(cangle, radius);
    local ypos = HUDYPos(cangle, radius);
    if (reversed) then
      xpos = xpos - PolarXPos(cangle + 180, size);
      ypos = ypos + PolarYPos(cangle + 180, size);
      xpos = xpos - PolarXPos(cangle - 90, extents.width/2);
      ypos = ypos + PolarYPos(cangle - 90, extents.width/2);
    else
      xpos = xpos - PolarXPos(cangle - 180, size/2);
      ypos = ypos + PolarYPos(cangle - 180, size/2);
      xpos = xpos - PolarXPos(cangle + 90, extents.width/2);
      ypos = ypos + PolarYPos(cangle + 90, extents.width/2);
    end
    cairo_move_to(cr, xpos, ypos);
    if (reversed) then
      cairo_rotate(cr, Deg2Rad(cangle - 90));
    else
      cairo_rotate(cr, Deg2Rad(cangle + 90));
    end
      cairo_show_text(cr, c)
    if (reversed) then
      cairo_rotate(cr, -Deg2Rad(cangle - 90));
    else
      cairo_rotate(cr, -Deg2Rad(cangle + 90));
    end
  end
end

function ArcOut(cr, angle, radius, color, size, text, reversed)
  if(reversed == nil) then reversed = false; end;
  c_SetFont(cr, size);
  SetColor(cr, color);
  local extents = cairo_text_extents_t:create();
  cairo_text_extents(cr, text, extents);
  local cangle = angle;
  local stringheight = extents.height;
  if(reversed) then
    start = #text;
    fine = 1;
    step = -1;
  else
    start = 1;
    fine = #text;
    step = 1;
  end
  for i = start, fine, step do
    local c = text:sub(i,i);
    cairo_text_extents(cr, c, extents);
    cangle = cangle + ReduceAngle(DeltaAngle(radius, c_charwidth * 0.8));
    local xpos = HUDXPos(cangle, radius);
    local ypos = HUDYPos(cangle, radius);
    if (reversed) then
      xpos = xpos - PolarXPos(cangle + 180, size);
      ypos = ypos + PolarYPos(cangle + 180, size);
      xpos = xpos - PolarXPos(cangle - 90, extents.width/2);
      ypos = ypos + PolarYPos(cangle - 90, extents.width/2);
    else
      xpos = xpos - PolarXPos(cangle - 180, size/2);
      ypos = ypos + PolarYPos(cangle - 180, size/2);
      xpos = xpos - PolarXPos(cangle + 90, extents.width/2);
      ypos = ypos + PolarYPos(cangle + 90, extents.width/2);
    end
    cairo_move_to(cr, xpos, ypos);
    if (reversed) then
      cairo_rotate(cr, Deg2Rad(cangle - 90));
    else
      cairo_rotate(cr, Deg2Rad(cangle + 90));
    end
    cairo_text_path(cr, c)
    cairo_stroke(cr);
    if (reversed) then
      cairo_rotate(cr, -Deg2Rad(cangle - 90));
    else
      cairo_rotate(cr, -Deg2Rad(cangle + 90));
    end
  end
end


function ArcPadGauge(cr, startangle, endangle, radius, size, value, color, offcolor, thr1, color1, thr2, color2)
  for i = 0, 14, 1 do
    col = color;
    if(thr1 ~= nil) then
      if(tonumber(value) > tonumber(thr1)) then col = color1; end
    end
    if(thr2 ~= nil) then
      if(tonumber(value) > tonumber(thr2)) then col = color2; end
    end
    if((value * 0.14) -1 < i) then
      col = offcolor;
    end
    angle = startangle + (i * (endangle - startangle) * 0.06);
    ArcPad(cr, angle, radius, col, size * 0.8, math.abs(endangle - startangle)* 0.2)
  end
end

function ArcPad(cr, angle, radius, color, height, width)
  local endangle = ReduceAngle(angle + DeltaAngle(radius, width));
  local x1a = HUDXPos(angle, radius + 1);
  local y1a = HUDYPos(angle, radius + 1);
  local x1b = HUDXPos(angle + 0.5, radius);
  local y1b = HUDYPos(angle + 0.5, radius);
  local x2a = HUDXPos(endangle - 0.5, radius);
  local y2a = HUDYPos(endangle - 0.5, radius);
  local x2b = HUDXPos(endangle, radius + 1);
  local y2b = HUDYPos(endangle, radius + 1);
  local x3a = HUDXPos(endangle, radius + height - 1);
  local y3a = HUDYPos(endangle, radius + height - 1);
  local x3b = HUDXPos(endangle - 0.5, radius + height);
  local y3b = HUDYPos(endangle - 0.5, radius + height);
  local x4a = HUDXPos(angle + 0.5, radius + height);
  local y4a = HUDYPos(angle + 0.5, radius + height);
  local x4b = HUDXPos(angle, radius + height - 1);
  local y4b = HUDYPos(angle, radius + height - 1);
  cairo_move_to(cr,x1a,y1a);
  cairo_line_to(cr,x1b,y1b);
  cairo_line_to(cr,x2a,y2a);
  cairo_line_to(cr,x2b,y2b);
  cairo_line_to(cr,x3a,y3a);
  cairo_line_to(cr,x3b,y3b);
  cairo_line_to(cr,x4a,y4a);
  cairo_line_to(cr,x4b,y4b);
  cairo_line_to(cr,x1a,y1a);
  cairo_set_line_width(cr, 0.8);
  SetColor(cr, c_black);
  cairo_stroke_preserve(cr);
  SetColor(cr, color);
  cairo_fill(cr);
end


function AbsRect(cr, x1, y1, x2, y2)
  cairo_move_to(cr,x1,y1);
  cairo_line_to(cr,x1,y2);
  cairo_line_to(cr,x2,y2);
  cairo_line_to(cr,x2,y1);
  cairo_line_to(cr,x1,y1);
  cairo_stroke(cr);
end

function Rectangle(cr, xpos, ypos, width, height , line_width, color)
  if (line_width == nil) then line_width = cairo_get_line_width(cr); end
  if (color == nil) then color = cairo_get_source_rgba(cr); end
  cairo_move_to(cr,xpos,ypos);
  cairo_set_line_width(cr, 0.5);
  cairo_rel_line_to(cr, 0, -stringheight);
  cairo_rel_line_to(cr, charwidth, 0);
  cairo_rel_line_to(cr, 0, stringheight);
  cairo_rel_line_to(cr, -charwidth, 0);
end
