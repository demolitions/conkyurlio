function initData()
		data = {};
		data["cpu"] = {};
		for i = 1,config["cpunr"] do 
			data["cpu_" .. i] = {};
		end   
		data["mem"] = {};
		data["swp"] = {};
    for key,value in pairs(config["hdd"]) do
			data["hdd_" .. key] = {};
		end
		data["netdn"] = {};
		data["netup"] = {};
--    print("AFTER  INIT: " .. #data["cpu"]);
		return data;
end

function readData()
	data = initData();
--  print("BEFORE READ: " .. #data["cpu"]);
  local datafile = io.open(config["datafile"], "r");
  if datafile == nil then
		print "nofile";
		table.insert(data["cpu"], 0);
		for i = 1,config["cpunr"] do 
			table.insert(data["cpu_" .. i], 0);
		end   
		table.insert(data["mem"], 0);
		table.insert(data["swp"], 0);
		for key,value in pairs(config["hdd"]) do
			table.insert(data["hdd_" .. key], 0);
		end
		table.insert(data["netdn"], 0);
		table.insert(data["netup"], 0);
  else 
		for line in datafile:lines(config["datafile"]) do 
			for key,tab in pairs(data) do
				if (string.sub(line,0,string.len(key .. ":")) == key .. ":") then
--          if(key == "cpu") then
--            print("BEFORE LOAD: " .. #data["cpu"]);
--          end
					table.insert(data[key], tonumber(trim(string.sub(line,string.len(key .. ": ")))))
--          if(key == "cpu") then
--            print("AFTER  LOAD: " .. #data["cpu"]);
--          end
				end
			end
		end 
		datafile:close(datafile);
	end
--  print("AFTER  READ: " .. #data["cpu"]);
  return data;
end

function gatherData()
	data = readData();
--  print("BEFORE DATA: " .. #data["cpu"]);
	-- CPU LOAD
	table.insert(data["cpu"], tonumber(trim(conky_parse("${cpu}"))));
	for i = 1,config["cpunr"] do 
		table.insert(data["cpu_" .. i],tonumber(trim(conky_parse("${cpu cpu".. i  .."}"))));
	end
  -- MEMORY USAGE
	table.insert(data["mem"],tonumber(trim(conky_parse("${memperc}"))));
	table.insert(data["swp"],tonumber(trim(conky_parse("${swapperc}"))));
	-- NET USAGE
	local ethname = conky_parse("${gw_iface}");
	table.insert(data["netup"],tonumber(trim(conky_parse("${upspeedf " .. ethname .. "}"))));
	table.insert(data["netdn"],tonumber(trim(conky_parse("${downspeedf " .. ethname .. "}"))));
  -- FILESYSTEM USAGE
  for key,value in pairs(config["hdd"]) do
		table.insert(data["hdd_" .. key], tonumber(trim(conky_parse("${fs_used_perc " .. value .. "}"))));
	end
--  print("AFTER  DATA: " .. #data["cpu"]);
	writeData(data)
  return data;
end

function writeData(data)
--  print("BEFORE SAVE: " .. #data["cpu"]);
  local datafile = io.open(config["datafile"], "w");
	for key,tab in pairs(data) do
    while (#tab > tonumber(config["samples"])) do
      table.remove(tab,1);
    end
		for id,value in pairs(tab) do
			local str = key .. ":" .. value .. "\n";
			datafile:write(str);
		end
  end
  datafile:close();
--  print("AFTER  SAVE: " .. #data["cpu"]);
end
