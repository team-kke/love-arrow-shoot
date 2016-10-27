module Proxy
  ( Proxy (..)
  ) where

import Prelude

import Data.Foreign.Class (class IsForeign, readProp)

newtype Proxy = Proxy { pathPattern :: String
                      , proxyHost :: String
                      , proxyPort :: Int
                      }

instance showProxy :: Show Proxy where
  show (Proxy {pathPattern, proxyHost, proxyPort}) =
    "(Proxy " <> pathPattern <> " -> " <> proxyHost <> ":" <> show proxyPort

instance proxyIsForeign :: IsForeign Proxy where
  read value = map Proxy $ { pathPattern: _, proxyHost: _, proxyPort: _ }
                             <$> readProp "pathPattern" value
                             <*> readProp "proxyHost" value
                             <*> readProp "proxyPort" value
