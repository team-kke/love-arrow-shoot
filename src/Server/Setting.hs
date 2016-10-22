{-# LANGUAGE OverloadedStrings #-}

module Server.Setting
  ( settingServer
  ) where

import Config (getAuth)
import Network.Wai
import Network.Wai.Middleware.HttpAuth
import Server.Setting.API (settingAPIServer)
import Server.Setting.Static (settingStaticServer)

auth :: Middleware
auth = basicAuth checkCredentials "My Realm"
  where
    checkCredentials username password = ((username, password) ==) <$> getAuth

settingServer :: Application
settingServer = auth $ \req f ->
  case pathInfo req of
    "api" : sub -> settingAPIServer req { pathInfo = sub } f
    _ -> settingStaticServer req f
