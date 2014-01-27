import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Actions.SpawnOn
import XMonad.Hooks.SetWMName

myStartupHook = composeAll
  [
    spawn "pgadmin"
  , spawn "thunderbird"
  , spawn "google-chrome-stable"
  , spawn "gnome-terminal"
  , spawn "gnome-terminal"
  , spawn "hipchat"
  , setWMName "LG3D"
  ]

myManageHook = composeAll
  [
    className =? "google-chrome-stable" --> doShift "3:web"
  , className =? "Thunderbird"          --> doShift "2:mail"
  , className =? "HipChat"              --> doShift "8:chat"
  , className =? "Pgadmin3"             --> doShift "1:db"
  , manageDocks
  ]

main = do
  xmonad $ defaultConfig { 
      modMask     = mod4Mask
    , borderWidth = 3
    , terminal    = "gnome-terminal"
    , workspaces  = ["1:db", "2:mail", "3:web", "4:dev", "5", "6", "7", "8:chat", "9", "10"]
    , manageHook  = myManageHook
    , startupHook = myStartupHook
  }

