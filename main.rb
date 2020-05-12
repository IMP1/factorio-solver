require_relative 'calculator'

FactorioCalculator.load_recipes

ENDGAME_PARTS = {
    "rocket-part" => nil,
}

SCIENCE_PACKS = {
    "automation-science-pack" => 2,
    "logistic-science-pack" => 2,
    "military-science-pack" => 2,
    "production-science-pack" => 2,
    "chemical-science-pack" => 2,
    "utility-science-pack" => 2,
}

LOGISTIC_ITEMS = [
    "transport-belt",
    "underground-belt",
    "splitter",
    "fast-transport-belt",
    "fast-underground-belt",
    "fast-splitter",

    "fast-inserter",
    "long-handed-inserter",

    "small-lamp",
    
    "stone-furnace",
    "oil-refinery",
    "lab",
    "assembling-machine-2",
    "chemical-plant",

    "big-electric-pole",
    "medium-electric-pole",

    "pumpjack",
    "electric-mining-drill",
    "offshore-pump",

    "pipe",
    "pipe-to-ground",
    "pump",
    "boiler",
    "steam-engine",

    "storage-tank",
    "steel-chest",

    "locomotive",
    "fluid-wagon",
    "cargo-wagon",
    "train-stop",
    "rail",
    "rail-signal",
    "rail-chain-signal",

    "solar-panel",

    # THE FOLLOWING REQUIRE OIL

    # "centrifuge",
    # "accumulator",
    # "roboport",
    # "logistic-robot",
    # "construction-robot",

    # "landfill",
]

science_trees = SCIENCE_PACKS.map do |pack_name, amount_per_second|
    FactorioCalculator.recipe_tree(pack_name, amount_per_second)
end
science_graph = FactorioCalculator.collapsed_graph(*science_trees)
puts science_graph
# FactorioCalculator.show_svg(science_graph)

logistic_trees = LOGISTIC_ITEMS.map do |item_name|
    FactorioCalculator.recipe_tree(item_name)
end
logistic_graph = FactorioCalculator.collapsed_graph(*logistic_trees)
puts logistic_graph
# FactorioCalculator.show_svg(logistic_graph)
