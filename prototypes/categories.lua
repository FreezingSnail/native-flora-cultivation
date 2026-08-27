data:extend({
  {
    type = "item-group",
    name = "native-flora-cultivation",
    order = "z[native-flora]",
    icon = "__base__/graphics/icons/tree-01.png",
    icon_size = 64
  },
  {
    type = "item-subgroup",
    name = "native-flora-gleba-seeds",
    group = "native-flora-cultivation",
    order = "a[gleba-seed]"
  },
  {
    type = "item-subgroup",
    name = "native-flora-gleba",
    group = "native-flora-cultivation",
    order = "b[gleba-plant]"
  },
  {
    type = "item-subgroup",
    name = "native-flora-nauvis",
    group = "native-flora-cultivation",
    order = "c[nauvis-tree]"
  }
})
