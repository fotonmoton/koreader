--[[--
This is a  plugin to export book annotations.

@module koplugin.annotationsExport
--]] --

-- local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local logger = require("logger")

local function l(message)
    logger.dbg("ANNOTATIONS_EXPORT: " .. message)
end

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end


local AnnotationsExport = WidgetContainer:extend {
    name = "annotationsExport",
    is_doc_only = false,
}

function AnnotationsExport:init()
    -- we are registring for all modes: reader and file manager.
    self.ui.menu:registerToMainMenu(self)
end

-- registring settings to the main menu.
function AnnotationsExport:addToMainMenu(menu_items)
    menu_items.annotations_export = {
        text = _("Annotations export"),
        sorting_hint = 'tools',
        callback = function()
            UIManager:show(InfoMessage:new {
                text = _("Annotations exported.")
            })
        end
    }
end

-- we want to react to each annotation change and update exported files.
function AnnotationsExport:onAnnotationsModified(event)
    local annotation = unpack(event)

    UIManager:show(InfoMessage:new {
        text = _(annotation.text)
    })
end

return AnnotationsExport
