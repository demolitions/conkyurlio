require 'cairo'
require 'imlib2'

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
  -- LOADS PLANE IMAGE
  image = imlib_load_image("img/F16-Fighting-Falcon.png")
  if image == nil then return end

  -- RENDERS BACKGROUND IMAGE ON CONKY SURFACE
  imlib_context_set_image(image)
  imlib_render_image_on_drawable(0,0)
  imlib_free_image()

  AonGraph_FontInit(cr);

  HUD_Center = HUD_CenterBase
  -- SWAP USAGE
  local swaperc = trim(conky_parse("${swapperc}"));
  local swaused = trim(conky_parse("${swap}"));
  
  -- MEMORY USAGE
  local memperc = trim(conky_parse("${memperc}"));
  local memused = trim(conky_parse("${mem}"));
  -- CPU USAGE
  local cpu = trim(conky_parse("${cpu}"));
  local load = trim(conky_parse("${loadavg 1}"));

  -- NET USAGE
  local ethname = conky_parse("${gw_iface}");
  local netup = tonumber(trim(conky_parse("${upspeedf " .. ethname .. "}"))) / 8;
  local netdn = tonumber(trim(conky_parse("${downspeedf " .. ethname .. "}"))) / 8;
  local lanip = "";
  local wanip = "";
  local tmpwanfile = "/tmp/conkyHUDwan";

  if (ethname == "(null)") then
    BarGauge(cr, -206, -175, 310, 28, "No network", 0, "", "");
    BarGauge(cr, -206, -175, 295, 28, " ", 0, "", "");
    wanip = "";
    lanip = "";
    if(file_exists(tmpwanfile)) then
      proc = io.popen("rm -f " .. tmpwanfile, "r");
      proc:close();
    end
  else
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
  -- HDD ROOT
  local hd1perc = trim(conky_parse("${fs_used_perc /}"));
  local hd1used = trim(conky_parse("${fs_used /}"));

  -- UPTIME
  cairo_select_font_face(cr, font, font_slant, font_bold);
  cairo_select_font_face(cr, font, font_slant, font_plain);
  -- conky_parse("${uptime}")

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr=nil
end
