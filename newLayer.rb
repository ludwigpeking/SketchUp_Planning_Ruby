# Default code, use or delete...
mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection

layers = mod.layers
layerPl = layers.add 'propertyLine'
mod.active_layer = layerPl
