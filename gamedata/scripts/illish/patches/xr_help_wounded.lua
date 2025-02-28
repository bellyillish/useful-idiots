local NPC = require "illish.lib.npc"


-- Change help_wounded_enabled to support a condlist
local PATCH_help_wounded_evaluate = xr_help_wounded.evaluator_wounded_exist.evaluate

function xr_help_wounded.evaluator_wounded_exist:evaluate()
  if NPC.isCompanion(self.object) then
    local npc = self.object
    local st  = self.a

    if not st.help_wounded_cond then
      st.help_wounded_cond = xr_logic.parse_condlist(npc, "beh", "help_wounded_enabled", st.help_wounded_enabled)
    end

    st.help_wounded_enabled = xr_logic.pick_section_from_condlist(db.actor, npc, st.help_wounded_cond) == "true"
  end

  return PATCH_help_wounded_evaluate(self)
end
