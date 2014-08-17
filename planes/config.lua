config = {
  ["cpunr"] = 4,     -- No. of CPUs to acquire
  ["datafile"] = "/tmp/planes_conky.dat",  -- Tempfile for data storage
  ["hdd"] = {       -- Filesystems to monitor
    ["root"]="/",
    ["home"]="/home",
    ["boot"]="/boot",
    ["windows"]="/home/leandro/Windows/Data",
    ["data"]="/home/leandro/Windows/OS",
  },
  ["samples"] = 20,   -- Number of samples used to draw trails
  ["hspace"] = 20,    -- Horizontal space between samples
  ["vspace"] = 30,    -- Vertical space between trails
  ["smoothing"] = 8,  -- Number of interpolations to calculate at vertexes
}
