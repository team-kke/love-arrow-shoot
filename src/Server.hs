{-# LANGUAGE OverloadedStrings #-}

module Server where

import Data.Maybe (fromJust)
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Application.Static
import Option (static)
import WaiAppStatic.Types (toPieces)
import qualified Data.ByteString.Lazy as B

staticHandler :: FilePath -> Application
staticHandler dir = staticApp
  (defaultWebAppSettings dir) { ssAddTrailingSlash = True
                              , ssIndices = fromJust $ toPieces ["index.html"]
                              }

server :: Application
server req f =
  case pathInfo req of
    "__setting__" : sub -> do
      dir <- static
      staticHandler dir req { pathInfo = sub } f
