require 'AonUtils'
require 'imlib2'
require 'string'
require 'planeslist'
require 'config'
require 'data'

function conky_main()
  if conky_window == nil then return end;
  imgwidth = tonumber(config["samples"]) * tonumber(config["hspace"]) * 2.2;
  imgheight = tonumber(config["vspace"]) * 20;
  image = imlib_create_image(imgwidth, imgheight);
  imlib_context_set_image(image)
  local data = gatherData();
  local tween = require 'tween'
  startx = 0;
  starty = imgheight;
--  steps = tonumber(config["smoothing"]);
  steps = 60;
  deltax = tonumber(config["hspace"]);
  traily = starty + tonumber(config["vspace"]);
  for key,tab in pairs(data) do
--    key = "cpu";
--    tab = data["cpu"]; 
    trailx = startx;
    point = { x=trailx, y=traily }
    for id,value in pairs(tab) do
      if(trailx == startx) then
        point = {x=trailx+deltax, y=traily-(value*5)};
      else
        trailTween = tween.new(steps, point, {x=trailx+deltax, y=traily-(value*10)}, tween.easing.inOutCubic);
        for i = 1,steps do 
          oldpoint = tableCopy(point);
          trailTween:update(1)
  --        print(key .. "(" .. id .. "): coords: " .. point.x .. "," .. point.y);
          imlib_image_draw_line((oldpoint.x) - deltax, oldpoint.y, (point.x) - deltax, point.y, 0);
        end
      end
      trailx = point.x;
    end
    traily = traily - tonumber(config["vspace"]);
  end
  imlib_render_image_on_drawable(0,0);
  imlib_free_image();
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
