require 'imlib2'
require 'tween'
require 'planeslist'

function conky_main()
  if conky_window == nil then return end;
  local angle = tonumber(trim(conky_parse("${time %S}")))*4;
  drawPlane(1,100,100,angle);
end

function drawPlane(plane,x,y,angle)
  planefile = planes[plane]
  if (planefile == nil) then planefile = planes[1] end;
  -- LOADS PLANE IMAGE
  image = imlib_load_image("img/" .. planefile)
  if image == nil then return end
  imlib_context_set_image(image)
  -- RENDERS BACKGROUND IMAGE ON CONKY SURFACE
  drawImage(x,y,-angle)
  imlib_free_image()
end

function drawImage(x,y,alpha)
  side = 100
  halfside = (side * math.sqrt(2))/2
  destx = x - PolarXPos(alpha-45, halfside)
  desty = y - PolarYPos(alpha-45, halfside)
  imlib_render_image_on_drawable_at_angle(  0,  0, 100, 100, destx, desty, PolarXPos(alpha, side), PolarYPos(alpha, side))	
end
