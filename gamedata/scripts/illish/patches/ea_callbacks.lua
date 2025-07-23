-- disable the individual functions instead of blanking the files to prevent crashes

if ea_callbacks and not ea_callbacks.EA_RegisterScriptCallback then
  function ea_callbacks.EA_RegisterScriptCallback() end
end

if ea_callbacks and not ea_callbacks.EA_UnregisterScriptCallback then
  function ea_callbacks.EA_UnregisterScriptCallback() end
end

if ea_callbacks and not ea_callbacks.EA_SendScriptCallback then
  function ea_callbacks.EA_SendScriptCallback() end
end
