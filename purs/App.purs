module App
  ( app
  , State
  , Query
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Halogen
import Halogen.HTML.Indexed as H
import Proxy (Proxy(..))

type State = Array Proxy

data Query a = Initialize a

app :: forall g. Component State Query g
app = lifecycleComponent { render
                         , eval
                         , initializer: Just (action Initialize)
                         , finalizer: Nothing
                         }
  where

  render :: State -> ComponentHTML Query
  render proxies =
    H.div_
      [ H.h1_ [ H.text "love-arrow-shoot" ]
      , H.div_ (map proxyEl proxies)
      ]

  eval :: Query ~> ComponentDSL State Query g
  eval (Initialize next) = pure next

proxyEl :: Proxy -> ComponentHTML Query
proxyEl _ = H.div_ []
