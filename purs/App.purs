module App
  ( app
  , State
  , Query
  , AppEffects
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Element as E
import Halogen
import Proxy (Proxy, IdedProxy, ProxyForm, fromProxyForm)
import Network.HTTP.Affjax as Afx

type State = { proxies :: Array IdedProxy
             , form :: ProxyForm
             }

data Query a = Reload a
             | UpdateForm String String a
             | AddProxy a

type AppEffects eff = HalogenEffects (ajax :: Afx.AJAX | eff)

app :: forall eff. Component State Query (Aff (AppEffects eff))
app = lifecycleComponent { render
                         , eval
                         , initializer: Just (action Reload)
                         , finalizer: Nothing
                         }
  where

  render :: State -> ComponentHTML Query
  render state =
    E.container
      [ E.heading "love-arrow-shoot"
      , E.umi
      , E.proxyTable state.proxies
      , E.proxyForm state.form UpdateForm AddProxy
      ]

  eval :: Query ~> ComponentDSL State Query (Aff (AppEffects eff))
  eval (Reload next) = do
    proxies <- fromAff fetchProxies
    modify (_ { proxies = proxies })
    pure next
  eval (UpdateForm field value next) = do
    case field of
      "pathPattern" ->
        modify \ state -> state { form = state.form { pathPattern = value } }
      "proxyHost" ->
        modify \ state -> state { form = state.form { proxyHost = value } }
      "proxyPort" ->
        modify \ state -> state { form = state.form { proxyPort = value } }
      _ -> pure unit
    pure next
  eval (AddProxy next) = do
    form <- gets _.form
    fromAff $ addProxy (fromProxyForm form)
    modify (_ { form = { pathPattern: "", proxyHost: "", proxyPort: "" } })
    eval (Reload next)

fetchProxies :: forall eff. Aff (ajax :: Afx.AJAX | eff) (Array IdedProxy)
fetchProxies = do
  result <- Afx.get "/__setting__/api/"
  pure case decodeJson result.response of
    Right idedProxies -> idedProxies
    Left _ -> []

addProxy :: forall eff. Proxy -> Aff (ajax :: Afx.AJAX | eff) Unit
addProxy proxy =
  Afx.post_ "/__setting__/api/" (encodeJson proxy) $> unit
