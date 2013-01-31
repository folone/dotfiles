-- Imports.
import qualified Data.Map    as M
import Data.Ratio

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig(additionalKeys, additionalKeysP)
import XMonad.Actions.CycleWS
import XMonad.Layout.Combo
import XMonad.Layout.Grid
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Circle
import XMonad.Layout.MosaicAlt
import XMonad.Layout.Spiral
import DBus.Client
import System.Taffybar.XMonadLog ( dbusLogWithPP, taffybarDefaultPP, taffybarColor, taffybarEscape )
import qualified Debug.Trace as D

-- The main function.
main = do
  client <- connectSession
  let pp = myTaffyBarPP
  xmonad $ myConfig { logHook = dbusLogWithPP client pp }

-- Custom PP.
myTaffyBarPP = taffybarDefaultPP {
    ppCurrent = taffybarColor "#f8f8f8" "DodgerBlue4"   . wrap " " " "
  , ppVisible = taffybarColor "#f8f8f8" "LightSkyBlue4" . wrap " " " "
  , ppUrgent  = taffybarColor "#f8f8f8" "red4"          . wrap " " " "
  , ppLayout  = taffybarColor "DarkOrange" "" . wrap " [" "] "
  , ppTitle   = taffybarColor "#61ce3c" "" . shorten 50
  }

-- Keybinding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

altMask    = mod1Mask
myModMask  = mod4Mask
myTerminal = "urxvt"

myWorkSpaces = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι"]

-- Layouts
basicLayout = Tall nmaster delta ratio where
    nmaster = 1
    delta   = 3/100
    ratio   = 1/2
tallLayout       = named "tall"     $ avoidStruts $ basicLayout
wideLayout       = named "wide"     $ avoidStruts $ Mirror basicLayout
singleLayout     = named "single"   $ avoidStruts $ noBorders Full
circleLayout     = named "circle"   $ Circle
twoPaneLayout    = named "two pane" $ TwoPane (2/100) (1/2)
mosaicLayout     = named "mosaic"   $ MosaicAlt M.empty
gridLayout       = named "grid"     $ Grid
spiralLayout     = named "spiral"   $ spiral (1 % 1)

myLayoutHook = smartBorders $ tallLayout ||| wideLayout   ||| singleLayout ||| circleLayout ||| twoPaneLayout
                                         ||| mosaicLayout ||| gridLayout   ||| spiralLayout

-- Main config.
myConfig = defaultConfig {
    modMask            = myModMask
  , terminal           = myTerminal
  , focusFollowsMouse  = False
  , workspaces         = myWorkSpaces
  , layoutHook         = myLayoutHook
  , manageHook         = manageHook defaultConfig <+> manageDocks
  , normalBorderColor  = "#2a2b2f"
  , focusedBorderColor = "DarkOrange"
  , borderWidth        = 1
  , startupHook        = spawn "taffybar"
  } `additionalKeysP`
        [ ("<XF86AudioRaiseVolume>", spawn "/home/folone/bin/volume_level.sh up")   -- volume up
        , ("<XF86AudioLowerVolume>", spawn "/home/folone/bin/volume_level.sh down") -- volume down
        , ("<XF86AudioMute>"       , spawn "/home/folone/bin/volume_level.sh mute") -- mute
        , ("<XF86Launch1>"         , spawn "dmenu_run")                             -- dmenu
        , ("<XF68ScreenSaver>"     , spawn "xlock")                                 -- lock screen
        ]
   `additionalKeys`
        [ ((controlMask .|. altMask, xK_l), spawn "xlock")                          -- lock screen
        , ((controlMask, xK_Print)        , spawn "sleep 0.2; scrot -s")            -- screenshot
        , ((0, xK_Print)                  , spawn "scrot")                          -- screenshot
        , ((mod4Mask, xK_p)               , spawn "dmenu_run")                      -- dmenu
        , ((mod4Mask, xK_Left  ), prevWS)
        , ((mod4Mask, xK_Right ), nextWS)
        , ((mod4Mask, xK_q)               , spawn "/home/folone/bin/xmonad-restart.sh")
        ]
