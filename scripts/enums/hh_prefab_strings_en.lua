-- English names and descriptions for prefabs registered outside main/hh_string.lua.
local same = function(name)
    return { name = name, recipe_str = name, desc = name }
end

local egg = function(name, description)
    return { name = name, recipe_str = description, desc = description }
end

local strings = {
    hh_cat_box = egg("Enchantment Box", "Stores enchantment stones."),
    hh_treasure_tally = same("Treasure Scroll"),
    hh_treasure_build = same("Treasure Site"),
    hh_treasure_jl = same("Treasure Site: Lunar Deerclops"),
    hh_treasure_xd = same("Treasure Site: Lunar Bearger"),
    hh_treasure_sy = same("Treasure Site: Lunar Frost Shark"),
    hh_treasure_kps = same("Treasure Site: Super Krampus"),
    hh_treasure_warg = same("Treasure Site: Possessed Varg"),
    hh_treasure_zf = same("Treasure Site: Beetle Pig"),
    hh_treasure_lz = same("Treasure Site: Dual-Wielding Pig"),
    hh_treasure_text = same("Treasure Title Effect"),
    hh_duck_box = egg("Duck Box", "Converts items to gold in one step."),
    hh_shark_ice_start_fx = egg("Ice Spike Effect", "Ice spike effect."),
    hh_shark_ice_fx = egg("Mineable Ice Spike", "Ice spike effect."),
    hh_white_equip_body = egg("Plain Equipment", "Gains a random enhancement."),
    hh_egg_nest = same("Egg Nest"),
    hh_egg_exhibition_table = egg("Egg Display Stand", "Displays different eggs."),
    hh_hat_star = same("Star Crown"),
    hh_hat_star_fx = same("Star Crown Effect"),
    hh_talk_fx = same("Speech Effect"),
    hh_egg_common = egg("Ordinary Egg", "It looks quite ordinary."),
    hh_egg_gold = egg("Large Golden Egg", "Something good may hatch from it."),
    hh_egg_silver = egg("Large Silver Egg", "A fairly ordinary egg."),
    hh_egg_black = egg("Large Black Egg", "For a lucky person."),
    hh_egg_cat_claw_orange = egg("Patterned Egg: Orange Cat Paw", "An egg with an unusual pattern."),
    hh_egg_cat_claw_purple = egg("Patterned Egg: Purple Cat Paw", "An egg with an unusual pattern."),
    hh_egg_cat_claw_green = egg("Patterned Egg: Green Cat Paw", "An egg with an unusual pattern."),
    hh_egg_cat_claw_blue = egg("Patterned Egg: Blue Cat Paw", "An egg with an unusual pattern."),
    hh_egg_figure_blue_star = egg("Patterned Egg: Blue Star", "An egg with an unusual pattern."),
    hh_egg_figure_green_black = egg("Patterned Egg: Green and Black", "An egg with an unusual pattern."),
    hh_egg_figure_purple_black = egg("Patterned Egg: Purple and Black", "An egg with an unusual pattern."),
    hh_egg_figure_red_black = egg("Patterned Egg: Red and Black", "An egg with an unusual pattern."),
    hh_egg_figure_red_blue = egg("Patterned Egg: Red and Blue", "An egg with an unusual pattern."),
    hh_egg_figure_yellow_green = egg("Patterned Egg: Yellow and Green", "An egg with an unusual pattern."),
    hh_egg_figure_yellow_green_purple = egg("Patterned Egg: Three Colors", "An egg with an unusual pattern."),
    hh_egg_starry_sky = egg("Starry Sky Egg: Limited", "A mysterious treasure lies within."),
    hh_sharkboi = same("Frost Shark"),
    hh_beetle_pig = same("Beetle Pig"),
    hh_dual_wield_pig = same("Dual-Wielding Pig"),
    hh_job_card = egg("Job Card", "Changes your profession."),
    hh_job_container = same("Job Storage"),
    hh_cat_staff = same("Cat Staff"),
}

return strings
