{-# LANGUAGE OverloadedStrings #-}

module Server where

import Network.HTTP.Types
import Network.Wai

server :: Application
server req respond =
  respond $ responseLBS status200 [] "Hello World"
