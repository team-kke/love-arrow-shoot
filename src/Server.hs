{-# LANGUAGE OverloadedStrings #-}

module Server where

import Config (getAuth)
import Data.Maybe (fromJust)
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Application.Static
import Network.Wai.Middleware.HttpAuth
import Option (static)
import WaiAppStatic.Types (toPieces)
import qualified Data.ByteString.Lazy as B

staticHandler :: FilePath -> Application
staticHandler dir = staticApp
  (defaultWebAppSettings dir) { ssAddTrailingSlash = True
                              , ssIndices = fromJust $ toPieces ["index.html"]
                              }

auth :: Middleware
auth = basicAuth checkCredentials "My Realm"
  where
    checkCredentials u p = do
      (username, password) <- getAuth
      return $ u == username && p == password

server :: Application
server req f =
  case pathInfo req of
    "__setting__" : sub -> do
      dir <- static
      auth (staticHandler dir) req { pathInfo = sub } f
