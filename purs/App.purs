module App
  ( app
  , State
  , Query
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Element as E
import Halogen
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
    E.container
      [ E.heading "love-arrow-shoot"
      , E.umi
      , E.proxyTable proxies
      ]

  eval :: Query ~> ComponentDSL State Query g
  eval (Initialize next) = pure next
