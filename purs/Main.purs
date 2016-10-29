module Main where

import Prelude

import App (app, State, AppEffects)
import Control.Monad.Eff (Eff)
import Halogen (runUI)
import Halogen.Util (runHalogenAff, awaitBody)

initialState :: State
initialState = { proxies: []
               , form: { pathPattern: ""
                       , proxyHost: ""
                       , proxyPort: ""
                       }
               }

main :: Eff (AppEffects ()) Unit
main = runHalogenAff do
  body <- awaitBody
  runUI app initialState body
