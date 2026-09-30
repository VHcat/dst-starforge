-- Run from the repository root: lua tests/run.lua [suite ...]
local suites = {
    "affixes_i18n",
    "hoverer_i18n",
    "buff_i18n",
    "prefab_strings_i18n",
    "items_i18n",
    "i18n",
    "gems",
    "stars",
    "skins",
    "logs",
    "bulk_clear",
    "permissions",
}
if arg and #arg > 0 then suites = arg end
local assertions = 0
for _, name in ipairs(suites) do
    assert(name:match("^[a-z0-9_]+$"), "Invalid suite name")
    print("Suite: " .. name)
    assertions = assertions + dofile("tests/" .. name .. ".lua")
end
print(string.format("PASS: %d regression cases across %d suites", assertions, #suites))
