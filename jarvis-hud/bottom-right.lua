require 'cairo'
require 'imlib2'
require 'AonUtils'
require 'AonGraph'

HUD_CenterBase = {410,264}
HUD_CenterLeft = {370,264}
HUD_Center = HUD_CenterBase
HUD_Scale = 1;

function conky_main()
  if conky_window == nil then return end;
  AonGraph_Init()
  font="Sans";
  font_slant=CAIRO_FONT_SLANT_NORMAL
  font_plain = CAIRO_FONT_WEIGHT_NORMAL
  font_bold = CAIRO_FONT_WEIGHT_BOLD
  ----------------------------------
  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
  cr = cairo_create(cs)
  cairo_select_font_face(cr, font, font_slant, font_plain);
  -- LOADS BACKGROUND DIAL IMAGE
  image = imlib_load_image("img/HUD_right_base.png")
  if image == nil then return end

  -- RENDERS BACKGROUND IMAGE ON CONKY SURFACE
  imlib_context_set_image(image)
  imlib_render_image_on_drawable(0,0)
  imlib_free_image()

  AonGraph_FontInit(cr);

  HUD_Center = HUD_CenterBase

  -- PROCESS LIST
  local proc = io.popen("ps auxwwwc | awk '{print $3 \" \" $4 \" \" $11}' | sort -r | head -n40 | tail -n39", "r");
  io.input(proc);
  i = 0;
  for line in io.lines() do
    i = i + 1;
    angle = -90 + (i * 4);
    t = Split(line, ' ', 3);
    local color = c_blue;
    if (tonumber(t[1]) > 10) then color = c_red; end
    if (tonumber(t[1]) > 5) then color = c_yellow; end
    if (angle < -20) then maxchar = 14; else maxchar = 16; end
    PolarText(cr, angle, 97, color, 10, "______");
    PolarText(cr, angle, 134, color, 10, t[3]:sub(1,maxchar));
  end
  proc:close()

  -- PC NAME
  cairo_select_font_face(cr, font, font_slant, font_bold);
  ArcText(cr, -149, 205, c_orange, 16, conky_parse("${nodename}"));
  ArcText(cr, -149, 192, c_blue, 13, "Linux");
  ArcText(cr, -131, 192, c_celeste, 13, conky_parse("${kernel}"));
  ArcText(cr, -149, 175, c_yellow, 14, "Arch Linux");

  cairo_select_font_face(cr, font, font_slant, font_bold);
  ArcText(cr, -172.5, 386, c_white, 12, "SUIT DIAGNOSTICS");

  -- CLOCK
  cairo_select_font_face(cr, font, font_slant, font_bold);
  ArcText(cr, 87, 90, c_celeste, 14, conky_parse("${time %H:%M:%S}"), true);
  ArcText(cr, 85, 105, c_celeste, 14, conky_parse("${time %Y-%m-%d}"), true);

  HUD_Center = HUD_CenterLeft
  -- SWAP USAGE
  SetBarGauge(c_darkblue, c_blue, 70, c_red);
  local swaperc = trim(conky_parse("${swapperc}"));
  local swaused = trim(conky_parse("${swap}")) .. " ";
  BarGauge(cr, -175, -144, 310, 28, "SWAP", swaperc, swaused, swaperc .. "%");
  -- MEMORY USAGE
  local memperc = trim(conky_parse("${memperc}"));
  local memused = trim(conky_parse("${mem}"));
  BarGauge(cr, -175, -144, 270, 28, "MEM", memperc, memused, memperc .. "%");
  -- CPU USAGE
  local cpu = trim(conky_parse("${cpu}"));
  local load = trim(conky_parse("${loadavg 1}"));
  BarGauge(cr, -175, -144, 230, 28, "CPU", cpu, load, cpu .. "%");

  -- NET USAGE
  local ethname = conky_parse("${gw_iface}");
  local netup = tonumber(trim(conky_parse("${upspeedf " .. ethname .. "}"))) / 8;
  local netdn = tonumber(trim(conky_parse("${downspeedf " .. ethname .. "}"))) / 8;
  local lanip = "";
  local wanip = "";
  local tmpwanfile = "/tmp/conkyHUDwan";

  if (ethname == "(null)") then
    SetBarGauge(c_darkgray, c_darkgray);
    BarGauge(cr, -206, -175, 310, 28, "No network", 0, "", "");
    BarGauge(cr, -206, -175, 295, 28, " ", 0, "", "");
    wanip = "";
    lanip = "";
    if(file_exists(tmpwanfile)) then
      proc = io.popen("rm -f " .. tmpwanfile, "r");
      proc:close();
    end
  else
    SetBarGauge(c_darkorange, c_orange, 150, c_red);
    --string.format("%3.2f", netdn)
    BarGauge(cr, -206, -175, 310, 28, ethname, netdn, "", "");
    BarGauge(cr, -206, -175, 295, 28, " ", netup, "", "");
    -- recupero IP LAN e IP WAN
    lanip = trim(conky_parse("${addr " .. ethname .. "}"));
    update = trim(conky_parse("${if_updatenr 600}update${else}no${endif}"));
    if(update == "update") then
      proc = io.popen("timeout 3 curl -s http://www.alonerd.net/getip.php > " .. tmpwanfile, "r");
      proc:close();
    else
      if(not file_exists(tmpwanfile)) then
        proc = io.popen("timeout 3 curl -s http://www.alonerd.net/getip.php > " .. tmpwanfile, "r");
        proc:close();
      end
    end
    wanip = io.input(tmpwanfile):lines()();
    if(wanip == "") then
		os.remove(tmpwanfile);
    end
  end
  -- HDD DATI
  local hd2perc = trim(conky_parse("${fs_used_perc /home}"));
  local hd2used = trim(conky_parse("${fs_used /home}"));
  BarGauge(cr, -206, -175, 260, 28, "Home", hd2perc, hd2used, hd2perc .. "%");
  -- HDD ROOT
  local hd1perc = trim(conky_parse("${fs_used_perc /}"));
  local hd1used = trim(conky_parse("${fs_used /}"));
  BarGauge(cr, -206, -175, 230, 28, "Root", hd1perc, hd1used, hd1perc .. "%");


  -- UPTIME
  cairo_select_font_face(cr, font, font_slant, font_bold);
  ArcText(cr, -208, 340, c_white, 14, "UP:");
  cairo_select_font_face(cr, font, font_slant, font_plain);
  ArcText(cr, -199, 338, c_orange, 14, conky_parse("${uptime}"));

  HUD_Center = HUD_CenterBase

  -- IP DATA
  cairo_select_font_face(cr, font, font_slant, font_bold);
  ArcText(cr, 85, 185, c_blue, 14, "LAN", true);
  ArcText(cr, 97, 185, c_orange, 14, lanip, true);
  ArcText(cr, 85, 205, c_celeste, 14, "WAN", true);
  ArcText(cr, 97, 205, c_yellow, 14, wanip, true);

  ----------------------------------
  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr=nil
end
