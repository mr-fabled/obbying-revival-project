<strong> #TODO: </strong> fix the textures of cylinders, at the moment they are completely blank white.

<b>
For the exporter change:
</b>

<pre>
<!-- necessary b/c it goes nil if you check a truss' shape -->
local shape = if obj:IsA("Part") then obj.Shape.Name else "Block"

local data = {
  ...
  Shape = shape,
}
</pre>
