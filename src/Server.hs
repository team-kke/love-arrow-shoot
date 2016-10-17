{-# LANGUAGE OverloadedStrings #-}

module Server where

import Network.HTTP.Types
import Network.Wai

server :: Application
server req respond = do
  putStrLn "Allocating scarce resource"
  putStrLn "Cleaning up"
  respond $ responseLBS status200 [] "Hello World"
