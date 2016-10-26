module Main where

import Prelude

import App (app, State)
import Control.Monad.Eff (Eff)
import Halogen (runUI, HalogenEffects)
import Halogen.Util (runHalogenAff, awaitBody)

initialState :: State
initialState = []

main :: Eff (HalogenEffects ()) Unit
main = runHalogenAff do
  body <- awaitBody
  runUI app initialState body
