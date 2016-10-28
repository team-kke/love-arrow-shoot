module App
  ( app
  , State
  , Query
  , AppEffects
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Data.Either (Either(..))
import Data.Foreign.Class (readJSON)
import Data.Maybe (Maybe(..))
import Element as E
import Halogen
import Proxy
import Network.HTTP.Affjax (AJAX, get)

type State = Array IdentifiedProxy


data Query a = Reload a

type AppEffects eff = HalogenEffects (ajax :: AJAX | eff)

app :: forall eff. Component State Query (Aff (AppEffects eff))
app = lifecycleComponent { render
                         , eval
                         , initializer: Just (action Reload)
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

  eval :: Query ~> ComponentDSL State Query (Aff (AppEffects eff))
  eval (Reload next) = do
    proxies <- fromAff fetchProxies
    set proxies
    pure next


fetchProxies :: forall eff. Aff (ajax :: AJAX | eff) State
fetchProxies = do
  result <- get "/__setting__/api/"
  pure case readJSON result.response of
    Right state -> state
    Left _ -> []
