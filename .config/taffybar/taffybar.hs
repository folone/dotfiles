import System.Taffybar

import System.Taffybar.Systray
import System.Taffybar.XMonadLog
import System.Taffybar.SimpleClock
import System.Taffybar.FreedesktopNotifications
import System.Taffybar.Weather
import System.Taffybar.Battery
import System.Taffybar.MPRIS

import System.Taffybar.Widgets.PollingBar
import System.Taffybar.Widgets.PollingLabel
import System.Taffybar.Widgets.PollingGraph

import System.Information.Memory
import System.Information.CPU

memCallback = do
  mi <- parseMeminfo
  return [memoryUsedRatio mi]

cpuCallback = do
  (userLoad, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

main = do
  let memCfg = defaultGraphConfig { graphDataColors = [(1, 0, 0, 1)]
                                  , graphLabel = Just "mem"
                                  , graphDirection = RIGHT_TO_LEFT
                                  }
      cpuCfg = defaultGraphConfig { graphDataColors = [ (0, 1, 0, 1)
                                                      , (1, 0, 1, 0.5)
                                                      ]
                                  , graphLabel = Just "cpu"
                                  , graphDirection = RIGHT_TO_LEFT
                                  }
  let clock = textClockNew Nothing "<span fgcolor='orange'>%a %b %_d %H:%M</span>" 1
      log   = xmonadLogNew
      note  = notifyAreaNew defaultNotificationConfig
      wea   = weatherNew (defaultWeatherConfig "EDBB") { weatherTemplate = "$tempC$°C @ $humidity$" } 10
      mpris = mprisNew
      mem   = pollingGraphNew memCfg 1 memCallback
      cpu   = pollingGraphNew cpuCfg 0.5 cpuCallback
      batt  = batteryBarNew defaultBatteryConfig 30
      tray  = systrayNew
  defaultTaffybar defaultTaffybarConfig { startWidgets = [ log, note ]
                                        , endWidgets = [ tray, wea, clock, mem, cpu, batt, mpris]
                                        , barHeight = 20
                                        }
