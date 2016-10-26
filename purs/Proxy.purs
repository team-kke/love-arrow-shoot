module Proxy
  ( Proxy (..)
  ) where

import Prelude

data Proxy = Proxy { pathPattern :: String
                   , proxyHost :: String
                   , proxyPort :: Int
                   }
