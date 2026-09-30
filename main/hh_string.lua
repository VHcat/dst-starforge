local HH_STRING = {}
local function addString(prefab_id, hh_name, hh_desc, hh_recipe_str)
    HH_STRING[prefab_id] = {
        ["name"] = hh_name,
        ["desc"] = hh_desc,
        ["recipe_str"] = hh_recipe_str,
    }
end
addString("hh_effect_stone", "特殊附魔石", "含有特殊的附魔词条", "含有特殊的附魔词条")
addString("hh_effect_tally", "普通附魔卷轴", "普通附魔卷轴", "普通附魔卷轴")
addString("hh_remove_stone", "洗蕴石", "洗掉装备的词条", "洗掉装备的词条")
addString("hh_knife_atk", "bbbb", "bbbb", "bbbb")
addString("hh_knife_atk_super", "vvvv\nvvvvvv", "vvvv", "vvvv")
addString("hh_sword_angry", "dddd", "dddd", "dddd")
addString("hh_sword_atk", "qqqq", "qqqq", "qqqq")
addString("hh_sword_atk_super", "rrrr", "rrrr", "rrrr")
addString("hh_red_spear", "hh_red_spear", "hh_red_spear", "hh_red_spear")
addString("hh_epee", "hh_epee", "hh_epee", "hh_epee")

addString("hh_true_damage", "hh_true_damage", "描述", "描述")
addString("hh_suit_build", "附魔合成台", "右键进行操作", "右键进行操作")
addString("hh_staff_dis", "拆除法杖", "拆解装备", "拆解装备")
addString("hh_essence", "水晶道具", "水晶道具", "水晶道具")
addString("hh_ui_container", "附魔容器", "附魔容器", "附魔容器")
addString("hh_forge_container", "套装容器", "套装容器", "套装容器")
addString("hh_staff_star", "星星法杖", "直上青天揽星辰", "直上青天揽星辰")
addString("hh_ice_knife", "冰刃", "攻击造成火焰沟壑", "火焰的威力")
--buff伤害描述
addString("hh_bramble_damage", "反甲词条", "反甲词条", "反甲词条")
addString("hh_turret_poison", "毒炮塔-流血", "毒炮塔-流血", "毒炮塔-流血")
addString("hh_poison", "中毒词条", "中毒词条", "中毒词条")
addString("hh_monster_kj", "恐惧词条", "恐惧词条", "恐惧词条")
addString("hh_turret", "炮塔", "炮塔", "炮塔")
addString("hh_turret_ice", "寒冰炮塔", "炮塔", "炮塔")
addString("hh_turret_fire", "火焰炮塔", "炮塔", "炮塔")
addString("hh_turret_poison", "剧毒炮塔", "炮塔", "炮塔")
addString("hh_treasure_tally_a", "寻宝卷轴", "寻宝卷轴", "寻宝卷轴")
addString("hh_treasure_tally_b", "寻宝卷轴", "寻宝卷轴", "寻宝卷轴")
addString("hh_treasure_tally_a_blueprint", "寻宝卷轴蓝图", "寻宝卷轴", "寻宝卷轴")
addString("hh_treasure_tally_b_blueprint", "寻宝卷轴蓝图", "寻宝卷轴", "寻宝卷轴")
local HH_I18N = require("utils/hh_i18n")
local HH_STRING_EN = {
    hh_effect_stone = { name = "Enchantment Stone", desc = "Contains a special affix.", recipe_str = "Contains a special affix." },
    hh_effect_tally = { name = "Enchantment Scroll", desc = "Adds a random affix.", recipe_str = "Adds a random affix." },
    hh_remove_stone = { name = "Cleansing Stone", desc = "Removes an equipment affix.", recipe_str = "Removes an equipment affix." },
    hh_true_damage = { name = "True Damage", desc = "True damage.", recipe_str = "True damage." },
    hh_suit_build = { name = "Enchantment Forge", desc = "Right-click to use.", recipe_str = "Right-click to use." },
    hh_staff_dis = { name = "Dismantling Staff", desc = "Dismantles equipment.", recipe_str = "Dismantles equipment." },
    hh_essence = { name = "Crystal Essence", desc = "A crystal crafting material.", recipe_str = "A crystal crafting material." },
    hh_ui_container = { name = "Enchantment Container", desc = "Stores enchanting materials.", recipe_str = "Stores enchanting materials." },
    hh_forge_container = { name = "Set Container", desc = "Stores set materials.", recipe_str = "Stores set materials." },
    hh_staff_star = { name = "Star Staff", desc = "Reach for the stars.", recipe_str = "Reach for the stars." },
    hh_ice_knife = { name = "Ice Blade", desc = "Attacks create trails of fire.", recipe_str = "The power of fire." },
    hh_bramble_damage = { name = "Thorns Affix", desc = "Reflects damage.", recipe_str = "Reflects damage." },
    hh_turret_poison = { name = "Poison Turret", desc = "A poison turret.", recipe_str = "A poison turret." },
    hh_poison = { name = "Poison Affix", desc = "Poisons the target.", recipe_str = "Poisons the target." },
    hh_monster_kj = { name = "Fear Affix", desc = "Causes fear.", recipe_str = "Causes fear." },
    hh_turret = { name = "Turret", desc = "A turret.", recipe_str = "A turret." },
    hh_turret_ice = { name = "Ice Turret", desc = "A turret.", recipe_str = "A turret." },
    hh_turret_fire = { name = "Fire Turret", desc = "A turret.", recipe_str = "A turret." },
    hh_treasure_tally_a = { name = "Treasure Scroll", desc = "Reveals treasure.", recipe_str = "Reveals treasure." },
    hh_treasure_tally_b = { name = "Treasure Scroll", desc = "Reveals treasure.", recipe_str = "Reveals treasure." },
    hh_treasure_tally_a_blueprint = { name = "Treasure Scroll Blueprint", desc = "Makes a Treasure Scroll.", recipe_str = "Makes a Treasure Scroll." },
    hh_treasure_tally_b_blueprint = { name = "Treasure Scroll Blueprint", desc = "Makes a Treasure Scroll.", recipe_str = "Makes a Treasure Scroll." },
}
for i, v in pairs(HH_STRING) do
    if HH_I18N.GetLocale() == "en" and HH_STRING_EN[i] then
        v = HH_STRING_EN[i]
    end
    STRINGS["NAMES"][string["upper"](i)] = v["name"] or "未定义"
    STRINGS["RECIPE_DESC"][string["upper"](i)] = v["recipe_str"] or "未定义"
    STRINGS["CHARACTERS"]["GENERIC"]["DESCRIBE"][string["upper"](i)] = v["desc"] or "未定义"
end