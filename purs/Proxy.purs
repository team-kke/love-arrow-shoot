module Proxy
  ( Proxy (..)
  , IdedProxy (..)
  , ProxyForm
  , fromProxyForm
  , getId
  , getProxy
  ) where

import Prelude

import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.?))
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=))
import Data.StrMap as M

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

instance encodeJsonProxy :: EncodeJson Proxy where
  encodeJson (Proxy x) = encodeJson $
    M.fromFoldable [ "pathPattern" := encodeJson x.pathPattern
                   , "proxyHost" := encodeJson x.proxyHost
                   , "proxyPort" := encodeJson x.proxyPort
                   ]

newtype IdedProxy = IdedProxy { id :: Int
                              , proxy :: Proxy
                              }

instance decodeJsonIdedProxy :: DecodeJson IdedProxy where
  decodeJson json = do
    j <- decodeJson json
    id <- j .? "id"
    proxy <- j .? "proxy"
    pure $ IdedProxy { id, proxy }

type ProxyForm = { pathPattern :: String
                 , proxyHost :: String
                 , proxyPort :: String
                 }

fromProxyForm :: ProxyForm -> Proxy
fromProxyForm f = Proxy { pathPattern: f.pathPattern
                        , proxyHost: f.proxyHost
                        , proxyPort: fromMaybe 80 (fromString f.proxyPort)
                        }

getId :: IdedProxy -> Int
getId (IdedProxy x) = x.id

getProxy :: IdedProxy -> Proxy
getProxy (IdedProxy x) = x.proxy
