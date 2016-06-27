require 'cairo'
require 'imlib2'
require 'AonGraph'
require 'AonUtils'
require 'AonMath'

function conky_main()
  if conky_window == nil then return end;
  font="Sans";
  font_slant=CAIRO_FONT_SLANT_NORMAL
  font_plain = CAIRO_FONT_WEIGHT_NORMAL
  font_bold = CAIRO_FONT_WEIGHT_BOLD
  ----------------------------------
  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
  cr = cairo_create(cs)
  cairo_select_font_face(cr, font, font_slant, font_plain);
  -- LOADS BACKGROUND DIAL IMAGE

  AonGraph_Init()
  SetColor(cr, NewColor(0,0,0,80));
  cairo_move_to(cr,0,0);
  cairo_line_to(cr,conky_window.width, 0)
  cairo_line_to(cr,conky_window.width, conky_window.height)
  cairo_line_to(cr,0, conky_window.height)
  cairo_line_to(cr,0, 0)
  cairo_fill(cr)
  cairo_set_font_size(cr,12)
  cairo_move_to(cr,12,140)
  cairo_rotate(cr, Deg2Rad(-90));
  SetColor(cr, c_celeste);
  cairo_show_text(cr, "dmesg");
  cairo_rotate(cr, -Deg2Rad(-90));

  -- PROCESS LIST
  cairo_set_font_size(cr,10)
  local proc = io.popen("dmesg | tail -n15", "r");
  io.input(proc);
  i = 0;
  SetColor(cr, c_yellow);
  for line in io.lines() do
    i = i + 1;
    cairo_move_to(cr, 40, 15 + i * 10);
    cairo_show_text(cr, line);

  end
  proc:close()

  --image = imlib_load_image("img/HUD_left_front.png")
  --if image == nil then return end

  --imlib_context_set_image(image)
  --imlib_render_image_on_drawable(0,0)
  --imlib_free_image()

  ----------------------------------
  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr=nil
end
