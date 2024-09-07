--[[--
This is a  plugin to export book notes and highlights.

@module koplugin.highlightsExport
--]]--

-- local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local HighlightsExport = WidgetContainer:extend{
    name = "highlightsExport",
    is_doc_only = false,
}

function HighlightsExport:init()
    self.ui.menu:registerToMainMenu(self)
end

function HighlightsExport:addToMainMenu(menu_items)
    menu_items.hello_world = {
        text = _("Highlights export"),
        sorting_hint = 'tools',
        callback = function ()
            UIManager:show(InfoMessage:new{
                text = _("Highlights exported.")
            })
        end
    }
end

return HighlightsExport
