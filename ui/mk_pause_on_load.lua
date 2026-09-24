-- Pause the game when the MD side reports the save has finished loading, by
-- opening the Options menu. ESC closes it and the game resumes.
--
-- Why a menu and not a bare Pause(): Pause() and Unpause() are the MENU pause,
-- and every base-game caller pairs them. A menu calls Pause() in onShowMenu and
-- Unpause() in cleanup (ego_gameoptions/gameoptions.lua, gamemodified.lua). The
-- pause key (P) toggles a separate player pause and cannot lift a menu pause.
-- Earlier builds called Pause() alone: P then did nothing visible, and only
-- ESC ESC freed the game, because opening and closing Options ran its Unpause().
-- Measured 2026-09-24. Opening the Options menu gives the pause an owner, and
-- ESC is its sanctioned exit. It is also what kuertee's Autocamera does.
--
-- OpenMenu from an event handler follows the base game's own
-- gamemodified.lua, which opens GameModifiedMenu the same way on load.
--
-- Registration happens at UI init, which also runs on /reloadui. That is
-- harmless: nothing opens until the MD cue raises the event, and that cue
-- fires on md.Setup.Start, not on a UI reload.

local function onPauseOnLoad()
    if type(OpenMenu) == "function" then
        OpenMenu("OptionsMenu", nil, nil)
    else
        -- Visible in uidata.xml rather than silent, so a renamed global in a
        -- future patch is diagnosable instead of just "the mod stopped working".
        DebugError("mk_pause_on_load: OpenMenu() is not available in this UI environment")
    end
end

RegisterEvent("mk_pause_on_load", onPauseOnLoad)
