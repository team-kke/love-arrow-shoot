module Proxy
  ( Proxy (..)
  , IdedProxy (..)
  , getId
  , getProxy
  ) where

import Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.?))

newtype Proxy = Proxy { pathPattern :: String
                      , proxyHost :: String
                      , proxyPort :: Int
                      }

instance showProxy :: Show Proxy where
  show (Proxy {pathPattern, proxyHost, proxyPort}) =
    "(Proxy " <> pathPattern <> " -> " <> proxyHost <> ":" <> show proxyPort <> ")"

instance decodeJsonProxy :: DecodeJson Proxy where
  decodeJson json = do
    j <- decodeJson json
    pathPattern <- j .? "pathPattern"
    proxyHost <- j .? "proxyHost"
    proxyPort <- j .? "proxyPort"
    pure $ Proxy { pathPattern, proxyHost, proxyPort }

newtype IdedProxy = IdedProxy { id :: Int
                              , proxy :: Proxy
                              }

instance decodeJsonIdedProxy :: DecodeJson IdedProxy where
  decodeJson json = do
    j <- decodeJson json
    id <- j .? "id"
    proxy <- j .? "proxy"
    pure $ IdedProxy { id, proxy }

getId :: IdedProxy -> Int
getId (IdedProxy x) = x.id

getProxy :: IdedProxy -> Proxy
getProxy (IdedProxy x) = x.proxy
