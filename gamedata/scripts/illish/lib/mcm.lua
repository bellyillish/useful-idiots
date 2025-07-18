local TABLE = require "illish.lib.table"


local MCM = {}


function MCM.getTitle(overrides)
  return TABLE.merge({
    id      = "title",
    type    = "slide",
    text    = "ui_mcm_title",
    link    = "ui_options_slider_player",
    size    = {512, 50},
    spacing = 20,
  }, overrides or {})
end


function MCM.getSubtitle(overrides)
  return TABLE.merge({
    id    = "subtitle",
    type  = "desc",
    text  = "ui_mcm_subtitle",
    clr   = {255, 255, 255, 255},
  }, overrides or {})
end


function MCM.getNote(overrides)
  return TABLE.merge({
    id   = "note",
    type = "desc",
    text = "ui_mcm_note",
    clr  = {255, 112, 112, 112},
  }, overrides or {})
end


function MCM.getLine(overrides)
  return TABLE.merge({
    id = "line",
    type = "line",
  }, overrides or {})
end


function MCM.getScaleField(overrides)
  return TABLE.merge({
    id   = "scale",
    type = "track",
    val  = 2,
    def  = 1,
    min  = 0.1,
    max  = 8,
    step = 0.05,
    prec = 2,
  }, overrides or {})
end


function MCM.getOffsetXField(overrides)
  return TABLE.merge({
    id   = "offsetX",
    type = "track",
    val  = 2,
    def  = 0,
    min  = -1024,
    max  = 1024,
    step = 1,
    prec = 0,
  }, overrides or {})
end


function MCM.getOffsetYField(overrides)
  return TABLE.merge({
    id   = "offsetY",
    type = "track",
    val  = 2,
    def  = 0,
    min  = -1024,
    max  = 1024,
    step = 1,
    prec = 0,
  }, overrides or {})
end


function MCM.getAlphaField(overrides)
  return TABLE.merge({
    id   = "alpha",
    type = "track",
    val  = 2,
    def  = 255,
    min  = 0,
    max  = 255,
    step = 1,
    prec = 0,
  }, overrides or {})
end


function MCM.getCheckboxField(overrides)
  return TABLE.merge({
    id   = "checkbox",
    type = "check",
    val  = 1,
    def  = false,
  }, overrides or {})
end


function MCM.getListField(overrides)
  return TABLE.merge({
    id   = "list",
    type = ui_mcm.kb_mod_list,
    val  = 0,
  }, overrides or {})
end


function MCM.getKeybindKey(overrides)
  return TABLE.merge({
    id   = "key",
    type = "key_bind",
    val  = 2,
    def  = -1,
  }, overrides or {})
end


function MCM.getKeybindMod(overrides)
  return TABLE.merge({
    id         = "mod",
    type       = ui_mcm.kb_mod_list,
    val        = 2,
    def        = 0,
    content    = {{0, "mod_none"}, {1, "mod_shift"}, {2, "mod_ctrl"}, {3, "mod_alt"}}
  }, overrides or {})
end


function MCM.getKeybindMode(overrides)
  return TABLE.merge({
    id         = "mode",
    type       = ui_mcm.kb_mod_list,
    val        = 2,
    def        = 0,
    content    = {{0, "mode_press"}, {1, "mode_dtap"}, {2, "mode_hold"}}
  }, overrides or {})
end


return MCM
