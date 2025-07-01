-- Fixes reference to nonexistent "item_id"
-- (I'm not really sure what fixing it does)

local PATCH_actor_on_item_take = itms_manager.actor_on_item_take

function itms_manager.actor_on_item_take(obj)
  -- redo the check with the correct "obj:id()" instead
  if IsWeapon(obj) and se_load_var(obj:id(), nil, "strapped_item") then
    se_save_var(obj:id(), nil, "strapped_item", nil)
  end

  return PATCH_actor_on_item_take(obj)
end
