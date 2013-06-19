import Yi hiding (Block, (.))
import qualified Yi.Mode.Haskell as H
import Yi.Hoogle (hoogle)
import Yi.String (mapLines)
import Yi.Modes (removeAnnots)
import Yi.UI.Pango as Pango

config :: Config
config = defaultEmacsConfig

-- | Increase the indentation of the selection
increaseIndent :: BufferM ()
increaseIndent = do
  r <- getSelectRegionB
  r' <- unitWiseRegion Yi.Line r
     -- extend the region to full lines
  modifyRegionB (mapLines (' ':)) r'
     -- prepend each line with a space

main :: IO ()
main = yi $ config
  { defaultKm = defaultKm config
  , modeTable =
    -- My precise mode with my hooks added
    AnyMode (haskellModeHooks H.preciseMode)
    -- My no annotations mode with mode hooks
    : modeTable defaultConfig
  , startFrontEnd = Pango.start
  }

-- | Set my hooks for nice features
haskellModeHooks mode =
   mode { modeName = "my " ++ modeName mode
        , modeKeymap =
            topKeymapA ^: ((ctrlCh 'c' ?>>
                            choice [ ctrlCh 'l' ?>>! H.ghciLoadBuffer
                                   , ctrl (char 'z') ?>>! H.ghciGet
                                   , ctrl (char 'h') ?>>! hoogle
                                   , ctrlCh 'r' ?>>! H.ghciSend ":r"
                                   , ctrlCh 't' ?>>! H.ghciInferType
                                   , ctrlCh 'n' ?>>! increaseIndent
                                   ])
                           <||) }
