{-# LANGUAGE OverloadedStrings #-}

module Server.Proxy
  ( proxyServer
  ) where

import Database
import Network.HTTP.Client (newManager, defaultManagerSettings)
import Network.HTTP.ReverseProxy
import Network.HTTP.Types.Status (status502)
import Network.Wai
import Text.Regex.Posix ((=~))

proxyRules :: Request -> IO WaiProxyResponse
proxyRules req = do
  let path = rawPathInfo req
  rules <- map snd <$> getProxies
  case filter ((path =~) . pathPattern) rules of
    Proxy _ host port : _ -> return $ WPRProxyDest $ ProxyDest host port
    _ -> return $ WPRResponse $ responseLBS status502 [] "nah"

proxyServer :: Application
proxyServer req f = do
  m <- newManager defaultManagerSettings
  let proxy = waiProxyTo proxyRules defaultOnExc m
  proxy req f
