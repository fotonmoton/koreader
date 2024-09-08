--[[--
This is a  plugin to export book annotations.

@module koplugin.annotationsExport
--]] --

-- local Dispatcher = require("dispatcher")  -- luacheck:ignore
local DataStorage = require("datastorage")
local DocSettings = require("docsettings")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local logger = require("logger")

local ANNOTATIONS_EXPORT = 'annotationsExport';
local DEFAULT_EXPORT_PATH = DataStorage:getFullDataDir() .. '/annotations'

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

local function l(message)
    logger.dbg(ANNOTATIONS_EXPORT .. ": " .. dump(message))
end


local AnnotationsExport = WidgetContainer:extend {
    name = ANNOTATIONS_EXPORT,
    is_doc_only = false,
}

function AnnotationsExport:init()
    -- we are registring for all modes: reader and file manager.
    self:initSettings()
    self.ui.menu:registerToMainMenu(self)
end

function AnnotationsExport:initSettings()
    local stored_settings = G_reader_settings:readSetting(ANNOTATIONS_EXPORT);

    l(stored_settings)

    if (stored_settings == nil) then
        G_reader_settings:saveSetting(
            ANNOTATIONS_EXPORT,
            {
                annotations_path = nil
            }
        )
    end
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
    l(event)

    local annotation = unpack(event)

    self:updateExports(annotation)
end

function AnnotationsExport:updateExports(annotation)
    --[[
    files to check:
    frontend/apps/reader/modules/readerhighlight.lua
        local index = self.ui.annotation:addItem(item)
    frontend/apps/reader/modules/readerannotation.lua
        function ReaderAnnotation:addItem(item)
    plugins/exporter.koplugin/clip.lua
    frontend/docsettings.lua
    frontend/apps/reader/readerui.lua
    self.doc_settings = DocSettings:open(self.document.file)
    --]]

    local doc_settings = DocSettings:open(self.ui.view.document.file).data;


    local export_path = self:getExportPath(doc_settings);

    l(export_path)
    self:writeAnnotations(export_path, doc_settings.annotations)
end

-- get path from settings or where documet is located
function AnnotationsExport:getExportPath(doc_settings)
    -- local default_path = G_reader_settings:readSetting(ANNOTATIONS_EXPORT).annotations_path;

    return doc_settings.doc_path .. '.annotations.txt'
end

function AnnotationsExport:writeAnnotations(path, annotations)
    local file = io.open(path, "w")
    if not file then return false end
    file:write(dump(annotations))
    local ts = os.date("%Y-%m-%d-%H-%M-%S", os.time())
    file:write("\n\n_Generated at: " .. ts .. "_")
    file:close()
end

return AnnotationsExport
