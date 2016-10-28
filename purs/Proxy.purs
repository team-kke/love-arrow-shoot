module Proxy
  ( Proxy (..)
  , IdentifiedProxy (..)
  , getId
  , getProxy
  ) where

import Prelude

import Data.Foreign.Class (class IsForeign, readProp)

newtype Proxy = Proxy { pathPattern :: String
                      , proxyHost :: String
                      , proxyPort :: Int
                      }

instance showProxy :: Show Proxy where
  show (Proxy {pathPattern, proxyHost, proxyPort}) =
    "(Proxy " <> pathPattern <> " -> " <> proxyHost <> ":" <> show proxyPort <> ")"

instance proxyIsForeign :: IsForeign Proxy where
  read value = map Proxy $ { pathPattern: _, proxyHost: _, proxyPort: _ }
                             <$> readProp "pathPattern" value
                             <*> readProp "proxyHost" value
                             <*> readProp "proxyPort" value

newtype IdentifiedProxy = IdentifiedProxy { id :: Int
                                          , proxy :: Proxy
                                          }

instance identifiedProxyIsForeign :: IsForeign IdentifiedProxy where
  read value = map IdentifiedProxy $ { id: _, proxy: _ }
                                       <$> readProp "id" value
                                       <*> readProp "proxy" value

getId :: IdentifiedProxy -> Int
getId (IdentifiedProxy x) = x.id

getProxy :: IdentifiedProxy -> Proxy
getProxy (IdentifiedProxy x) = x.proxy
