module App
  ( app
  , State
  , Query
  ) where

import Prelude

import Data.Array (length)
import Halogen
import Halogen.HTML.Indexed as H
import Halogen.HTML.Properties.Indexed as P
import Proxy (Proxy(..))

type State = Array Proxy

data Query a = DoNothing a

app :: forall g. Component State Query g
app = component { render, eval }
  where

  render :: State -> ComponentHTML Query
  render proxies =
    H.div_
      [ H.h1_ [ H.text "love-arrow-shoot" ]
      , H.div_ (map proxyEl proxies)
      ]

  eval :: Query ~> ComponentDSL State Query g
  eval (DoNothing next) = pure next

proxyEl :: Proxy -> ComponentHTML Query
proxyEl _ = H.div_ []
