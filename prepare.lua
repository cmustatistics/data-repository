-- Adapted from code by Carlos Scheidegger
-- https://github.com/cscheid/quarto-example-project-file-metadata

-- Open metadata file and truncate it, so we start fresh
local f = io.open('metadata.json','w')
if f == nil then
    error("couldn't open file for writing")
end
f:close()
