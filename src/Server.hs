{-# LANGUAGE OverloadedStrings #-}

module Server where

import Network.Wai
import Server.Proxy (proxyServer)
import Server.Setting (settingServer)

server :: Application
server req f =
  case pathInfo req of
    "__setting__" : sub -> settingServer req { pathInfo = sub } f
    _ -> proxyServer req f
