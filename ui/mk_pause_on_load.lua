-- Pause the game when the MD side reports the save has finished loading.
--
-- Pause() and Unpause() are globals of the menus environment (the base game's
-- ego_gameoptions/gameoptions.lua calls both). A bare Pause() is recoverable
-- because INPUT_ACTION_PAUSE is bound — P on the keyboard here — so the player
-- is never stuck; that is the assumption to re-check if the binding is cleared.
--
-- Registration happens at UI init, which also runs on /reloadui. That is
-- harmless: nothing pauses until the MD cue raises the event, and that cue
-- fires on md.Setup.Start, not on a UI reload.

local function onPauseOnLoad()
    if type(Pause) == "function" then
        Pause()
    else
        -- Visible in uidata.xml rather than silent, so a renamed global in a
        -- future patch is diagnosable instead of just "the mod stopped working".
        DebugError("mk_pause_on_load: Pause() is not available in this UI environment")
    end
end

RegisterEvent("mk_pause_on_load", onPauseOnLoad)
