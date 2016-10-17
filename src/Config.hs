{-# LANGUAGE OverloadedStrings #-}

module Config
  ( getPort
  ) where

import Data.Yaml
import Network.Wai.Handler.Warp (Port)
import System.Exit (exitFailure)
import qualified Option

data Config = Config { port :: Port
                     }

instance FromJSON Config where
  parseJSON (Object v) = Config <$>
                         v .: "port"

config :: IO Config
config = do
  maybeConfig <- Option.config >>= decodeFile
  case maybeConfig of
    Just config ->
      return config
    Nothing -> do
      putStrLn "no config"
      exitFailure

getPort :: IO Port
getPort = port <$> config
