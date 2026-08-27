# Native Flora Cultivation

Factorio 2.1 / Space Age mod for renewable, hand-placeable native Gleba flora and Nauvis-tree decorations.

## Gameplay

Harvest wild Gleba flora for a distinct tinted seed, multiply it with an agricultural tower, then culture it into a placeable decoration. Nauvis tree decorations use the vanilla `tree-seed`.

The crafting menu separates **Gleba Seeds**, **Gleba Plants**, and **Nauvis Trees** under **Native Flora Cultivation**.

## Recipes and yields

### Gleba seed loop

| Step | Machine | Input | Output |
| --- | --- | --- | --- |
| Find a seed | Mine wild Gleba flora | Native plant | 1 matching tinted seed |
| Multiply a seed | Agricultural tower, any Gleba land tile | 1 matching seed | Mature matching crop |
| Harvest crop | Mine mature crop | Mature matching crop | 2 matching seeds |
| Create placable | Biochamber, 5 s | 1 matching seed | 1 matching Gleba decoration |

Each of the ten Gleba flora types has its own seed and crop. Seeds can be planted only on Gleba; decoration placement has no planetary surface restriction.

### Nauvis tree decorations

| Machine | Input | Output |
| --- | --- | --- |
| Biochamber, 5 s | 1 vanilla `tree-seed` | 1 selected Nauvis-tree decoration |

Every Nauvis tree variant can be made from the same vanilla `tree-seed`; the mod adds no duplicate tree-seed items or recipes.

### Decorations

Placed decorations mine back into themselves, allowing them to be moved without loss. All decoration recipes unlock with **Biochamber** technology.

## Requirements

- Factorio 2.1
- Space Age

## Install

1. Download the release ZIP.
2. Place it in Factorio's `mods` directory without extracting it.
3. Enable **Native Flora Cultivation** in the mod manager.

## Releases

Pushing a tag such as `v1.0.0` runs the packaging workflow. It creates a Mod Portal-compatible archive named from `info.json` (for example, `native-flora-cultivation_1.0.0.zip`) and attaches it to the matching GitHub Release.

## License

[MIT](LICENSE)
