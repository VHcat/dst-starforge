-- Translate Starforge announcements after they reach each client.
local Notice = {}
local monsters = {
    ["坎普斯大王"] = "Krampus King", ["超级猫悠大王"] = "Super Cat King",
    ["大猪知非"] = "Zhifei the Pig", ["双持林猪"] = "Dual-wielding Lin Pig",
    ["超级巨鹿"] = "Super Deerclops", ["超级熊大"] = "Super Bearger",
    ["超级鲨鱼"] = "Super Shark", ["附身狼王"] = "Possessed Varg",
    ["笨比林猪"] = "Lin Pig", ["月后巨鹿"] = "Lunar Deerclops",
    ["月后座狼"] = "Lunar Varg", ["装甲熊獾"] = "Armored Bearger",
}
local spawns = {
    ["强化的大猪知非已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Enhanced Zhifei the Pig has appeared. Defeat it for a last-hit reward.",
    ["强化的林猪已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Enhanced Lin Pig has appeared. Defeat it for a last-hit reward.",
    ["携带宝石的超级猫悠已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Gem-carrying Super Cat King has appeared. Defeat it for a last-hit reward.",
    ["携带宝藏的坎普斯已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Treasure-carrying Krampus has appeared. Defeat it for a last-hit reward.",
    ["强化的巨鹿大王已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Enhanced Deerclops King has appeared. Defeat it for a last-hit reward.",
    ["强化的附身狼王已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Enhanced Possessed Varg has appeared. Defeat it for a last-hit reward.",
    ["强化的超级熊大已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Enhanced Super Bearger has appeared. Defeat it for a last-hit reward.",
    ["强化的超级鲨鱼已经出现,请及时击杀(补刀的玩家有特殊奖励)"] = "Enhanced Super Shark has appeared. Defeat it for a last-hit reward.",
}

function Notice.Translate(message, affix_name, localized_monster)
    if type(message) ~= "string" then return "" end
    if spawns[message] then return spawns[message] end
    local player, amount = message:match("^(.-)连续转换(%d+)次未获得稀有附魔石，奖励黑蛋一枚，怎么有人能黑成这样~$")
    if player then return string.format("%s made %s conversions without a rare stone and earned a Black Egg!", player, amount) end
    player, amount = message:match("^(.-)将装备提升至(%d+)★$")
    if player then return string.format("%s upgraded equipment to %s stars.", player, amount) end
    local monster, effect = message:match("^(.-)掉落极品附魔石%-(.+)$")
    if monster then return string.format("%s dropped a premium enchantment stone: %s.", localized_monster or monsters[monster] or monster, affix_name and affix_name(effect) or effect) end
    monster = message:match("^(.-)掉落特殊装备包裹$")
    if monster then return string.format("%s dropped a special equipment bundle.", localized_monster or monsters[monster] or monster) end
    player, effect = message:match("^(.-)好运当头，合成出:超超超稀有的(.+)$")
    if player then return string.format("Lucky %s crafted an exceptionally rare %s!", player, affix_name and affix_name(effect) or effect) end
    player, effect = message:match("^(.-)运气爆棚，合成出%-(.+)$")
    if player then return string.format("%s crafted a rare %s!", player, affix_name and affix_name(effect) or effect) end
    player, effect = message:match("^(.-)合成出%-(.+)$")
    if player then return string.format("%s crafted %s.", player, affix_name and affix_name(effect) or effect) end
    player, effect = message:match("^(.-)拆解出词条%-(.+)$")
    if player then return string.format("%s dismantled an affix: %s.", player, affix_name and affix_name(effect) or effect) end
    player, monster = message:match("^(.-)拿下(.-)的尾刀，奖励特殊宝石一份$")
    if player then return string.format("%s defeated %s and earned a special gem.", player, monsters[monster] or monster) end
    player = message:match("^(.-)拿下坎普斯大王的尾刀，奖励特殊宝石三份$")
    if player then return string.format("%s defeated the Krampus King and earned three special gems.", player) end
    player = message:match("^(.-)暴打超级猫悠大王，奖励稀有附魔石三份$")
    if player then return string.format("%s defeated the Super Cat King and earned three rare enchantment stones.", player) end
    return message
end

return Notice
