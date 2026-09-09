import Foundation

struct Inspiration: Identifiable, Hashable {
    let id: String
    let collection: String
    let title: String
    let imageName: String
    let tags: [String]
    let summary: String
}

enum BundledStill: String, CaseIterable, Identifiable {
    case sculpture = "tile_sculpture"
    case moodboard = "tile_moodboard"
    case palette = "banner_palette"

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .sculpture: return "Sculpture Tile"
        case .moodboard: return "Moodboard Tile"
        case .palette: return "Palette Banner"
        }
    }
}

enum InspirationCatalog {
    static let collections = ["Clay Studies", "Palette Studies", "Mood Walls"]

    static let items: [Inspiration] = [
        Inspiration(
            id: "clay-thrown-silhouette",
            collection: "Clay Studies",
            title: "Thrown Silhouette",
            imageName: BundledStill.sculpture.rawValue,
            tags: ["clay", "form", "sculpture"],
            summary: "A still of a thrown vessel used to study weight, lip, and contour."
        ),
        Inspiration(
            id: "clay-coil-rhythm",
            collection: "Clay Studies",
            title: "Coil Rhythm",
            imageName: BundledStill.sculpture.rawValue,
            tags: ["clay", "texture", "coil"],
            summary: "Coil stacking as a reference for paced, tactile building."
        ),
        Inspiration(
            id: "clay-slip-bloom",
            collection: "Clay Studies",
            title: "Slip Bloom",
            imageName: BundledStill.sculpture.rawValue,
            tags: ["clay", "glaze", "surface"],
            summary: "Surface bloom and slip trails for glaze-layer planning."
        ),
        Inspiration(
            id: "palette-magenta-field",
            collection: "Palette Studies",
            title: "Magenta Field",
            imageName: BundledStill.palette.rawValue,
            tags: ["color", "palette", "pigment", "magenta"],
            summary: "A saturated magenta wash against cooler studio navy."
        ),
        Inspiration(
            id: "palette-navy-undertone",
            collection: "Palette Studies",
            title: "Navy Undertone",
            imageName: BundledStill.palette.rawValue,
            tags: ["navy", "contrast", "pigment"],
            summary: "Deep navy as an undertone for high-contrast color blocking."
        ),
        Inspiration(
            id: "palette-warm-residual",
            collection: "Palette Studies",
            title: "Warm Residual",
            imageName: BundledStill.palette.rawValue,
            tags: ["palette", "warmth", "mix"],
            summary: "Residual warmth left on the mixing slab after a session."
        ),
        Inspiration(
            id: "mood-midnight-collage",
            collection: "Mood Walls",
            title: "Midnight Collage",
            imageName: BundledStill.moodboard.rawValue,
            tags: ["mood", "collage", "wall"],
            summary: "A dense wall of night-toned clippings and fabric swatches."
        ),
        Inspiration(
            id: "mood-soft-reference",
            collection: "Mood Walls",
            title: "Soft Reference",
            imageName: BundledStill.moodboard.rawValue,
            tags: ["mood", "atmosphere", "reference"],
            summary: "Quiet atmospheric cuts for a gentler reference wall."
        ),
        Inspiration(
            id: "mood-layered-silence",
            collection: "Mood Walls",
            title: "Layered Silence",
            imageName: BundledStill.moodboard.rawValue,
            tags: ["wall", "layer", "mood"],
            summary: "Overlapping stills that leave breathing room between layers."
        )
    ]
}
