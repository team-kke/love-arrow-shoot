module Proxy
  ( Proxy (..)
  ) where

import Prelude

import Data.Generic (class Generic)
import Data.Foreign.Class (class IsForeign)
import Data.Foreign.Generic (readGeneric, defaultOptions)

data Proxy = Proxy { pathPattern :: String
                   , proxyHost :: String
                   , proxyPort :: Int
                   }

derive instance genericProxy :: Generic Proxy

instance showProxy :: Show Proxy where
  show (Proxy {pathPattern, proxyHost, proxyPort}) =
    "(Proxy " <> pathPattern <> " -> " <> proxyHost <> ":" <> show proxyPort

instance proxyIsForeign :: IsForeign Proxy where
  read = readGeneric defaultOptions
