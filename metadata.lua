-- Adapted from code by Carlos Scheidegger
-- https://github.com/cscheid/quarto-example-project-file-metadata

-- Write each page's metadata to JSON Lines format, for use in extracting a
-- table of datasets

function Meta(meta)
   local function safe_json(obj)
      -- strings of text are represented as a list of Inlines, for individual
      -- words and spaces; we want those collapsed into single strings for
      -- convenience
      if pandoc.utils.type(obj) == "Inlines" or type(obj) == "userdata" then
         return pandoc.utils.stringify(obj)
      end
      if type(obj) == "table" then
         local result = {}
         for k, v in pairs(obj) do
            result[k] = safe_json(v)
         end
         return result
      end
      return obj
   end
   local info = {
      filename = safe_json(quarto.doc.input_file),
      metadata = safe_json(meta)
   }
   local output = quarto.json.encode(info)
   local filename = pandoc.path.join({quarto.project.directory or ".", 'metadata.json'})
   local f = io.open(filename, 'a')
   if f == nil then
      error("Couldn't open file")
      return
   end
   f:write(output)
   f:write("\n")
   f:close()
end
