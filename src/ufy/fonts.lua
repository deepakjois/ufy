local fonts = {}

function fonts.load_font(file, size)
  size = tex.sp(string.format('%dpt',size))


  -- Load file using fontloader.open
   local f = fontloader.open (file)
   local fonttable = fontloader.to_table(f)
   fontloader.close(f)

   local metrics = {
     name = fonttable.fontname,
     fullname = fonttable.fontname,
     psname = fonttable.fontname,
     type = "real",
     filename = file,
     format = string.match(string.lower(file), "otf$") and "opentype" or string.match(string.lower(file), "ttf$") and "truetype",
     embedding = 'subset',
     size = size,
     designsize = fonttable.design_size*6553.6,
     cidinfo = fonttable.cidinfo,
     units_per_em = fonttable.units_per_em
   }

   -- Scaling for font metrics
   local mag = size / fonttable.units_per_em

   -- Find glyph for 0x20, and get width for spacing glue.
   local space_glyph = fonttable.map.map[0x20]
   local space_glyph_table = fonttable.glyphs[space_glyph]
   local space_glyph_width = space_glyph_table.width * mag

   metrics.parameters = {
     slant = 0,
     space = space_glyph_width,
     space_stretch = 1.5 * space_glyph_width,
     space_shrink = 0.5 * space_glyph_width,
     x_height = fonttable.pfminfo.os2_xheight * mag,
     quad = 1.0 * size,
     extra_space = 0
   }

   metrics.characters = { }
   for char, glyph in pairs(fonttable.map.map) do
     local glyph_table = fonttable.glyphs[glyph]
     metrics.characters[char] = {
       index = glyph,
       width = glyph_table.width * mag,
       name = glyph_table.name,
     }
     if glyph_table.boundingbox[4] then
       metrics.characters[char].height = glyph_table.boundingbox[4] * mag
     end
     if glyph_table.boundingbox[2] then
       metrics.characters[char].depth = -glyph_table.boundingbox[2] * mag
     end
   end

   return font.define(metrics)
end

return fonts