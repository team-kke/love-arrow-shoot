{-# LANGUAGE OverloadedStrings #-}

module Server where

import Network.HTTP.Types
import Network.Wai
import Network.Wai.Predicate
import Network.Wai.Routing
import qualified Data.ByteString.Lazy as B

routes :: Routes a IO ()
routes = do
  get "/" (continue hello) $ constant "ya"
  get "/:name" (continue hello) $ capture "name"

hello :: B.ByteString -> IO Response
hello name = return $
  responseLBS status200 [] $ B.concat ["hello, ", name]

server :: Application
server = route $ prepare routes
