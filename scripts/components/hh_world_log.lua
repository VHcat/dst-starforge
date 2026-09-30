local HH_UTILS = require("utils/hh_utils")
local function getLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("log", str_index)
end
----
---日志组件
---
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    --日志记录
    self["logs"] = {}
end)

function HH_COM:AddLog(log_type, log_message)
    --加上时间
    local log_date = HH_UTILS:GetCurrentDateTime()
    local log_str = HH_UTILS:Template("#{{data_date}}:white:25{{data_message}}", {
        ["data_date"] = log_date,
        ["data_message"] = log_message,
    })
    local save_type = {}
    if HH_UTILS:IsHHType(log_type, "table") then
        save_type = log_type
    elseif HH_UTILS:IsHHType(log_type, "string") then
        table["insert"](save_type, log_type)
    end
    local log_table = {
        ["ui_config"] = log_str,
        ["log_type"] = save_type,
        ["log_time"] = log_date,
    }
    table["insert"](self["logs"], log_table)
    --推实际及时更新 如果打开相关日志页面的话
    --self["inst"]:PushEvent("ovo_log_change")
end
----
---获取日志（联机传大批量数据会占带宽 默认100条吧 请求一次大概占十几k）
---@param log_type-日志类型 (如果传入，则筛选出 logs 中包含该类型的记录)
---@param limit_count-数量 (每页显示的数量)
---@param page_index-页数 (当前第几页)
---
local function isPositiveInteger(value)
    return type(value) == "number" and value > 0
        and value < math.huge and value % 1 == 0
end

function HH_COM:GetLogs(log_type, limit_count, page_index)
    if type(self.logs) ~= "table" or #self.logs == 0 then
        return {}
    end
    if log_type ~= nil and type(log_type) ~= "string" then
        return {}
    end
    if limit_count == nil then limit_count = 100 end
    if page_index == nil then page_index = 1 end
    if not isPositiveInteger(limit_count) or not isPositiveInteger(page_index) then
        return {}
    end
    limit_count = math.min(limit_count, 100)
    -- Bound the page before multiplying client-supplied numbers.
    if page_index > math.ceil(#self.logs / limit_count) then
        return {}
    end
    local skip = (page_index - 1) * limit_count
    local matched, page_data = 0, {}
    for i = #self.logs, 1, -1 do
        local entry = self.logs[i]
        if type(entry) == "table" and (log_type == nil or log_type == ""
                or (type(entry.log_type) == "table" and table.contains(entry.log_type, log_type))) then
            matched = matched + 1
            if matched > skip then
                table.insert(page_data, HH_UTILS:HHCopyTable(entry))
                if #page_data == limit_count then break end
            end
        end
    end
    return page_data
end
function HH_COM:OnSave()
    local save_data = {}
    if self["logs"] then
        save_data["logs"] = self["logs"]
    end
    return save_data
end
function HH_COM:OnLoad(data)
    if not data then
        return
    end
    self["logs"] = data["logs"] or {}
end
return HH_COM