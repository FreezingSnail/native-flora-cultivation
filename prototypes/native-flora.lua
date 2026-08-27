local seconds = 60
local growth_ticks = 5 * seconds * 60

-- Gleba plants each get their own seed, tinted so the 10 seed items stay distinguishable
-- at a glance. Nauvis trees have no seed of their own: they reuse the vanilla tree-seed.
local gleba_flora = {
  {source = "cuttlepop", tint = {r = 0.95, g = 0.45, b = 0.60, a = 1}},
  {source = "slipstack", tint = {r = 0.65, g = 0.80, b = 0.90, a = 1}},
  {source = "funneltrunk", tint = {r = 0.85, g = 0.55, b = 0.30, a = 1}},
  {source = "hairyclubnub", tint = {r = 0.70, g = 0.50, b = 0.85, a = 1}},
  {source = "teflilly", tint = {r = 0.35, g = 0.80, b = 0.75, a = 1}},
  {source = "lickmaw", tint = {r = 0.80, g = 0.25, b = 0.25, a = 1}},
  {source = "stingfrond", tint = {r = 0.70, g = 0.90, b = 0.35, a = 1}},
  {source = "boompuff", tint = {r = 0.95, g = 0.85, b = 0.35, a = 1}},
  {source = "sunnycomb", tint = {r = 0.95, g = 0.65, b = 0.25, a = 1}},
  {source = "water-cane", tint = {r = 0.45, g = 0.85, b = 0.45, a = 1}}
}

local nauvis_trees = {
  "tree-01", "tree-02", "tree-03", "tree-04", "tree-05",
  "tree-06", "tree-07", "tree-08", "tree-09"
}

local gleba_pressure = 2000

local new_prototypes = {}

local function add(prototype)
  new_prototypes[#new_prototypes + 1] = prototype
end

local function unlock(technology, recipe)
  table.insert(data.raw.technology[technology].effects, {type = "unlock-recipe", recipe = recipe})
end

local function assign_surface(sprite, surface)
  if not sprite then
    return
  end
  if sprite.layers then
    for _, layer in ipairs(sprite.layers) do
      assign_surface(layer, surface)
    end
  else
    sprite.surface = surface
  end
end

-- The plant sprite-table builder dereferences every variation's normal map unconditionally
-- (PlantPrototype assignSortingIndices), so a source missing normals segfaults the engine
-- during atlas post-build.
local function has_normals(source)
  for _, variation in ipairs(source.variations or {}) do
    if not variation.normal then
      return false
    end
  end
  return true
end

local function seed_icons(tint)
  return {{icon = "__space-age__/graphics/icons/tree-seed.png", icon_size = 64, tint = tint}}
end

-- Decorations are hand-placeable clones that return themselves when mined, so curated
-- placement is never disposable. They are cultured in a biochamber from a seed.
local function register_decoration(source_name, planet, ingredient)
  local source = assert(data.raw.tree[source_name], "Missing native flora prototype: " .. source_name)
  local name = "native-flora-" .. source_name .. "-decoration"
  local label = {"item-name.native-flora-decoration", {"entity-name." .. source_name}}

  local decoration = table.deepcopy(source)
  decoration.name = name
  decoration.localised_name = label
  decoration.autoplace = {probability_expression = 0}
  decoration.minable = {mining_time = 0.2, result = name}
  decoration.dying_explosion = nil
  decoration.remains_when_mined = nil
  decoration.created_effect = nil
  add(decoration)

  add({
    type = "item",
    name = name,
    localised_name = label,
    localised_description = {"item-description.native-flora-decoration"},
    icon = source.icon,
    icon_size = source.icon_size or 64,
    subgroup = planet.decoration_subgroup,
    order = "b[decoration]-" .. source_name,
    place_result = name,
    stack_size = 20,
    weight = 10 * kg
  })

  add({
    type = "recipe",
    name = name,
    localised_name = label,
    localised_description = {"recipe-description.native-flora-decoration"},
    categories = {"organic"},
    enabled = false,
    energy_required = 5,
    ingredients = {ingredient},
    results = {{type = "item", name = name, amount = 1}}
  })
  unlock("biochamber", name)
end

-- Gleba crops close their own loop: wild plants drop the tinted seed, the agricultural tower
-- plants it, and harvesting the grown crop yields two seeds back.
local function register_gleba_crop(entry)
  local source = assert(data.raw.tree[entry.source], "Missing native flora prototype: " .. entry.source)
  local seed_name = "native-flora-" .. entry.source .. "-seed"
  local crop_name = "native-flora-" .. entry.source .. "-crop"
  local growth_template = assert(data.raw.plant["tree-plant"], "Space Age planted-tree prototype is required")

  local crop = table.deepcopy(source)
  crop.type = "plant"
  crop.name = crop_name
  crop.localised_name = {"entity-name.native-flora-crop", {"entity-name." .. entry.source}}
  crop.autoplace = {probability_expression = 0}
  crop.surface_conditions = {{property = "pressure", min = gleba_pressure, max = gleba_pressure}}
  crop.growth_ticks = growth_ticks
  crop.harvest_emissions = {spores = 1}
  crop.agricultural_tower_tint = {primary = entry.tint, secondary = {r = 0.45, g = 0.35, b = 0.20, a = 1}}
  crop.minable = {mining_time = 0.5, results = {{type = "item", name = seed_name, amount = 2}}}
  crop.dying_explosion = nil
  crop.remains_when_mined = nil
  crop.created_effect = nil

  for _, variation in ipairs(crop.variations) do
    assign_surface(variation.trunk, "gleba")
    assign_surface(variation.leaves, "gleba")
    assign_surface(variation.normal, "gleba")
    assign_surface(variation.shadow, "gleba")
    if variation.water_reflection then
      assign_surface(variation.water_reflection.pictures, "gleba")
    end
  end

  crop.growth_variations = {}
  crop.growth_mounds = {}
  for index = 1, #crop.variations do
    local growth_variation = table.deepcopy(growth_template.growth_variations[(index - 1) % #growth_template.growth_variations + 1])
    for _, field in ipairs({"growth_warp", "trunk_warp", "shadow_warp", "harvest_warp", "trunk_alpha", "shadow_alpha", "harvest_alpha"}) do
      assign_surface(growth_variation[field], "gleba")
    end
    crop.growth_variations[index] = growth_variation

    local growth_mound = table.deepcopy(growth_template.growth_mounds[(index - 1) % #growth_template.growth_mounds + 1])
    assign_surface(growth_mound, "gleba")
    crop.growth_mounds[index] = growth_mound
  end
  add(crop)

  add({
    type = "item",
    name = seed_name,
    localised_name = {"item-name.native-flora-seed", {"entity-name." .. entry.source}},
    localised_description = {"item-description.native-flora-seed"},
    icons = seed_icons(entry.tint),
    subgroup = "native-flora-gleba-seeds",
    order = "a[seed]-" .. entry.source,
    plant_result = crop_name,
    place_result = crop_name,
    stack_size = 10,
    weight = 10 * kg
  })

  -- Wild flora is the only source of the first seeds, so harvesting it must drop them.
  local minable = source.minable
  if minable.result then
    minable.results = {{type = "item", name = minable.result, amount = minable.count or 1}}
    minable.result = nil
    minable.count = nil
  end
  table.insert(minable.results, {type = "item", name = seed_name, amount = 1})
end

local gleba = {decoration_subgroup = "native-flora-gleba"}
local nauvis = {decoration_subgroup = "native-flora-nauvis"}

for _, entry in ipairs(gleba_flora) do
  if has_normals(data.raw.tree[entry.source]) then
    register_gleba_crop(entry)
    register_decoration(entry.source, gleba, {type = "item", name = "native-flora-" .. entry.source .. "-seed", amount = 1})
  else
    log("native-flora-cultivation: skipping " .. entry.source .. " (variations lack normal maps, unsupported by plant rendering)")
  end
end

for _, source_name in ipairs(nauvis_trees) do
  register_decoration(source_name, nauvis, {type = "item", name = "tree-seed", amount = 1})
end

data:extend(new_prototypes)
