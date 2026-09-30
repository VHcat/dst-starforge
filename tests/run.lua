-- Run from the repository root: lua tests/run.lua [suite ...]
local suites = {
    "bulk_clear",
    "permissions",
}
if arg and #arg > 0 then suites = arg end
local assertions = 0
for _, name in ipairs(suites) do
    assert(name:match("^[a-z_]+$"), "Invalid suite name")
    print("Suite: " .. name)
    assertions = assertions + dofile("tests/" .. name .. ".lua")
end
print(string.format("PASS: %d regression cases across %d suites", assertions, #suites))
