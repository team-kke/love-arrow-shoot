module Main where

import Prelude

import App (app, State, AppEffects)
import Control.Monad.Eff (Eff)
import Halogen (runUI, HalogenEffects)
import Halogen.Util (runHalogenAff, awaitBody)

initialState :: State
initialState = []

main :: Eff (AppEffects ()) Unit
main = runHalogenAff do
  body <- awaitBody
  runUI app initialState body
