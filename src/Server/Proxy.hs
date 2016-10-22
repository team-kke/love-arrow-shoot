{-# LANGUAGE OverloadedStrings #-}

module Server.Proxy
  ( proxyServer
  ) where

import Network.HTTP.Client (newManager, defaultManagerSettings)
import Network.HTTP.ReverseProxy
import Network.Wai

proxyRules :: Request -> IO WaiProxyResponse
proxyRules _ = return $ WPRProxyDest $ ProxyDest "127.0.0.1" 8000 -- FIXME

proxyServer :: Application
proxyServer req f = do
  m <- newManager defaultManagerSettings
  let proxy = waiProxyTo proxyRules defaultOnExc m
  proxy req f
