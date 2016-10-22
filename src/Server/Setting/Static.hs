{-# LANGUAGE OverloadedStrings #-}

module Server.Setting.Static
  ( settingStaticServer
  ) where

import Data.Maybe (fromJust)
import Network.Wai
import Network.Wai.Application.Static
import Option (static)
import WaiAppStatic.Types (toPieces)

staticHandler :: FilePath -> Application
staticHandler dir = staticApp
  (defaultWebAppSettings dir) { ssAddTrailingSlash = True
                              , ssIndices = fromJust $ toPieces ["index.html"]
                              }

settingStaticServer :: Application
settingStaticServer req f = do
  dir <- static
  (staticHandler dir) req f
