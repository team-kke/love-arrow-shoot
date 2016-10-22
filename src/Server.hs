{-# LANGUAGE OverloadedStrings #-}

module Server where

import Config (getAuth)
import Data.Maybe (fromJust)
import Network.HTTP.Client (newManager, defaultManagerSettings)
import Network.HTTP.ReverseProxy
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Application.Static
import Network.Wai.Middleware.HttpAuth
import Option (static)
import WaiAppStatic.Types (toPieces)
import qualified Data.ByteString.Lazy as B

auth :: Middleware
auth = basicAuth checkCredentials "My Realm"
  where
    checkCredentials username password = ((username, password) ==) <$> getAuth

staticHandler :: FilePath -> Application
staticHandler dir = staticApp
  (defaultWebAppSettings dir) { ssAddTrailingSlash = True
                              , ssIndices = fromJust $ toPieces ["index.html"]
                              }

settingAPIServer :: Application
settingAPIServer req f = undefined -- FIXME

settingServer :: Application
settingServer req f =
  case pathInfo req of
    "api" : sub -> settingAPIServer req { pathInfo = sub } f
    sub -> do
      dir <- static
      auth (staticHandler dir) req { pathInfo = sub } f

proxyRules :: Request -> IO WaiProxyResponse
proxyRules _ = return $ WPRProxyDest $ ProxyDest "127.0.0.1" 8000 -- FIXME

proxyServer :: Application
proxyServer req f = do
  m <- newManager defaultManagerSettings
  let proxy = waiProxyTo proxyRules defaultOnExc m
  proxy req f

server :: Application
server req f =
  case pathInfo req of
    "__setting__" : sub -> auth settingServer req { pathInfo = sub } f
    _ -> proxyServer req f
