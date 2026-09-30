-- Client-side translation for custom item hover descriptions.
local titles = {
    ["特殊"] = "Special", ["附魔"] = "Enchanting", ["拆除"] = "Dismantling",
    ["效果"] = "Effect", ["可修复"] = "Repairable", ["炫彩特效"] = "Visual effect",
    ["画师"] = "Artist", ["特殊强化"] = "Special upgrades", ["宝藏"] = "Treasure",
    ["限制"] = "Accepts", ["功能"] = "Function", ["孵蛋"] = "Incubation",
    ["创意来源"] = "Inspired by", ["职业"] = "Job",
}
local descriptions = {
    ["放入不同的道具右键装备\n附魔石:装备附魔\n洗蕴石:清除词条\n其他道具见左下角帮助中拆除法杖功能"] =
        "Put an item in the staff and right-click equipment.\nEnchantment stone: add an affix.\nCleansing stone: remove an affix.\nSee Help for other dismantling staff uses.",
    ["放卷轴可以范围内装备随机附魔至3个"] = "With scrolls inside, randomly enchant up to 3 nearby items.",
    ["容器为空,右键地面拆除范围8码内的装备/附魔石"] = "With an empty container, right-click the ground to dismantle equipment and enchantment stones within 8 tiles.",
    ["攻击70%概率造成三段火焰沟壑,伤害:50(享受加成)"] = "Attacks have a 70% chance to create three fire fissures dealing 50 damage (affected by bonuses).",
    ["消耗水晶道具回复耐久"] = "Use a crystal item to restore durability.",
    ["右键召唤流星击打范围(4)目标(cd:10秒)"] = "Right-click to summon meteors against targets within 4 tiles (10-second cooldown).",
    ["水晶道具回复耐久,金块切换特效"] = "Use a crystal to restore durability or gold to switch the visual effect.",
    ["余音音"] = "Yu Yinyin",
    ["白板"] = "No upgrades", ["无效强化"] = "Invalid upgrade",
    ["有概率挖出携带宝藏的怪物(必须是玩家铲子挖才会出现)"] = "Digging may reveal a treasure-carrying monster (requires a player's shovel).",
    ["可以挖出月后巨鹿"] = "May reveal a lunar Deerclops.",
    ["可以挖出月后熊大"] = "May reveal a lunar Bearger.",
    ["可以挖出月后霜鲨"] = "May reveal a lunar frost shark.",
    ["可以挖出超级坎普斯"] = "May reveal a super Krampus.",
    ["可以挖出月后座狼"] = "May reveal a lunar Varg.",
    ["可以挖出甲虫猪"] = "May reveal a beetle pig.",
    ["可以挖出双持猪"] = "May reveal a dual-wielding pig.",
    ["附魔石/装备/特殊蛋"] = "Enchantment stones, equipment and special eggs.",
    ["右键寻找宝藏"] = "Right-click to search for treasure.",
    ["随身的便捷猪王"] = "A portable Pig King.",
    ["空"] = "Empty",
    ["踏雪寻梅3124"] = "Ta Xue Xun Mei 3124",
    ["特殊合成材料"] = "Special crafting material.",
    ["铁匠"] = "Blacksmith", ["无效职业"] = "Unknown job",
}
local upgrades = {
    ["寒冰之力"] = "Ice Power", ["火焰之力"] = "Fire Power",
    ["海皇之力"] = "Sea King's Power", ["生命女神祝福"] = "Goddess of Life's Blessing",
}
local visual_effects = {
    ["紫色法球"] = "Purple Orb", ["绿色法球"] = "Green Orb",
    ["红色法球"] = "Red Orb", ["蓝色法球"] = "Blue Orb",
    ["橙色法球"] = "Orange Orb", ["白色星星"] = "White Star",
    ["红色星星"] = "Red Star", ["橙色星星"] = "Orange Star",
    ["黄色星星"] = "Yellow Star", ["绿色星星"] = "Green Star",
    ["蓝色星星"] = "Blue Star", ["紫色星星"] = "Purple Star",
    ["白色猪猪"] = "White Pig", ["紫色猪猪"] = "Purple Pig",
    ["蓝色猪猪"] = "Blue Pig", ["橙色猪猪"] = "Orange Pig",
}

local treasure_titles = {
    ["超级坎普斯大王\n星级:∞\n受到一千以上伤害掉落附魔石"] = "Super Krampus King\nStars: infinite\nDrops enchantment stones when hit for over 1000 damage",
    ["超级猫悠大王\n星级:∞\n受到一千以上伤害掉落附魔的宝石"] = "Super Cat King\nStars: infinite\nDrops enchanted gems when hit for over 1000 damage",
    ["★★坦克猪猪★★\n超强的防御"] = "★★ Tank Pig ★★\nExceptional defense",
    ["★★暴力猪猪★★\n强化伤害"] = "★★ Berserker Pig ★★\nIncreased damage",
    ["★★打工猪猪★★\n我要爆炸了"] = "★★ Worker Pig ★★\nAbout to explode",
    ["★★沃时柱★★\n你是好人,我跟着你"] = "★★ Friendly Pig ★★\nYou're nice. I'll follow you.",
    ["★★★猪猪擂主★★★\n我要打十个"] = "★★★ Pig Champion ★★★\nI can take on ten!",
    ["★★★★★超级ADC★★★★★\n死亡掉落极品增伤(0.5)/无尽(0.5)"] = "★★★★★ Super Marksman ★★★★★\nDrops superior damage (0.5) / infinity (0.5) on death",
    ["★★★★★★巨鹿大王★★★★★★\n死亡掉落朱雀附魔石(免疫远程武器伤害)"] = "★★★★★★ Deerclops King ★★★★★★\nDrops a Vermilion Bird stone (immune to ranged weapon damage)",
    ["★★★★★★超级熊大★★★★★★\n死亡掉落白虎附魔石(免疫远程武器伤害)"] = "★★★★★★ Super Bearger ★★★★★★\nDrops a White Tiger stone (immune to ranged weapon damage)",
    ["★★★★★★超级鲨鱼★★★★★★\n死亡掉落护甲锁定附魔石(免疫远程武器伤害)"] = "★★★★★★ Super Shark ★★★★★★\nDrops an armor-lock stone (immune to ranged weapon damage)",
    ["★★★★★★附身狼王★★★★★★\n死亡掉落神龟守御附魔石(免疫远程武器伤害)"] = "★★★★★★ Possessed Varg ★★★★★★\nDrops a Divine Turtle stone (immune to ranged weapon damage)",
    ["★★★★★★大猪知非★★★★★★\n死亡掉落免疫控制附魔石(免疫远程武器伤害)"] = "★★★★★★ Zhifei the Pig ★★★★★★\nDrops a control-immunity stone (immune to ranged weapon damage)",
    ["★★★★★★笨比林猪★★★★★★\n死亡掉落真伤附魔石(免疫远程武器伤害)"] = "★★★★★★ Lin Pig ★★★★★★\nDrops a true-damage stone (immune to ranged weapon damage)",
    ["★★树精★★\n低概率掉落免疫过热"] = "★★ Treeguard ★★\nSmall chance to drop heat immunity",
    ["★★树精★★\n低概率掉落免疫过冷"] = "★★ Treeguard ★★\nSmall chance to drop cold immunity",
}

local Special = { titles = titles, descriptions = descriptions, upgrades = upgrades, visual_effects = visual_effects, treasure_titles = treasure_titles }

function Special.Translate(title, description, data)
    local original_title = type(title) == "string" and title:gsub(":$", "") or "特殊"
    local translated_title = (titles[original_title] or "Special") .. ":"
    description = tostring(description or "")
    if original_title == "孵蛋" and type(data) == "table" and type(data.egg_id) == "string" then
        local name = STRINGS and STRINGS.NAMES and STRINGS.NAMES[string.upper(data.egg_id)] or data.egg_id
        return translated_title, string.format("%s (%s seconds)", name, tostring(data.egg_seconds or 0))
    end
    if descriptions[description] then return translated_title, descriptions[description] end
    if original_title == "特殊强化" then
        local parts = {}
        for name in description:gmatch("%S+") do
            table.insert(parts, upgrades[name] or "Unknown upgrade")
        end
        return translated_title, table.concat(parts, ", ")
    end
    if original_title == "炫彩特效" then
        local name, current, total = description:match("^(.-)%((%d+)/(%d+)%)$")
        if name then return translated_title, string.format("%s (%s/%s)", visual_effects[name] or "Visual effect", current, total) end
    end
    if original_title == "孵蛋" then return translated_title, "Incubating egg" end
    return translated_title, description
end

return Special
