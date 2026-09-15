# BQ Sqwad Game — Asset Pipeline

This document defines how BQ Sqwad Game handles reference material and production assets.

## 1. Source-of-truth rule

Original BQ Sqwad material supplied by the project owner is preserved as reference material. Generated concepts are kept separate from source references. No generated concept should silently replace an original asset.

## 2. Supported reference material

The project may receive:

- Character photographs and artwork
- Building and architecture photographs
- Landly City photographs and videos
- Vehicle photographs and videos
- Interior references
- Logos and visual identity references
- Music and sound references
- Story and cinematic references
- Animation references

Videos are valuable because they can show multiple angles, scale, movement, lighting, traffic, interiors, and environmental context.

## 3. Asset lifecycle

`RAW REFERENCE → ANALYSIS → CLASSIFICATION → ORIGINAL CONCEPT → PRODUCTION ASSET → GAME INTEGRATION`

Reference material is not automatically treated as final game content.

## 4. Landly City expansion workflow

A single useful building, street, vehicle, or environment reference may be used to establish a visual language for a larger original set. New concepts should vary:

- Silhouette
- Proportions
- Materials
- Facade patterns
- Windows and entrances
- Street placement
- Lighting
- Signage
- Landscaping
- Color/material combinations

The goal is a coherent Landly City, not duplicated objects.

## 5. Repository structure

```text
assets/
├── characters/
├── world/
│   └── landly_city/
│       ├── reference_photos/
│       ├── reference_videos/
│       ├── buildings/
│       ├── streets/
│       ├── vehicles/
│       ├── landmarks/
│       ├── interiors/
│       └── generated_concepts/
├── audio/
│   ├── music/
│   ├── sfx/
│   └── voices/
├── cinematics/
├── ui/
├── logos/
└── temporary/
```

## 6. Naming convention

Use descriptive lowercase names with underscores:

`landly_city_downtown_building_001_reference.jpg`

`ziking_ability_energy_burst_01.wav`

`landly_city_vehicle_sedan_003_concept.png`

Avoid names such as `IMG_001.jpg`, `newnew.mp3`, or `finalfinal2.png` for production assets.

## 7. Asset catalog

Every important production asset should eventually have a catalog entry containing:

- Asset ID
- File path
- Asset type
- Character/location/category
- Source/reference status
- Intended game use
- Production status
- Notes

## 8. Quality and rights

Use original BQ Sqwad material or material that the project has permission to use. Do not add copied game assets, copyrighted music, logos, characters, maps, or other protected material from unrelated franchises.

## 9. Large uploads

Large batches should be organized by category rather than mixed randomly. When practical, keep original reference files and optimized game-ready files separate.

## 10. Future automation

The game pipeline can later add import presets, compression, texture processing, audio normalization, asset validation, and automated catalog generation. These should be introduced only after the Godot project structure is stable.
