{-# LANGUAGE OverloadedStrings #-}

module Config
  ( getPort
  , getAuth
  ) where

import Control.Arrow ((***))
import Control.Monad (liftM2)
import Data.ByteString (ByteString)
import Data.ByteString.Char8 (pack)
import Data.Yaml
import Network.Wai.Handler.Warp (Port)
import System.Exit (exitFailure)
import qualified Option

data Config = Config { port :: Port
                     , username :: String
                     , password :: String
                     }

instance FromJSON Config where
  parseJSON (Object v) = Config <$>
                         v .: "port" <*>
                         v .: "username" <*>
                         v .: "password"

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

getAuth :: IO (ByteString, ByteString)
getAuth = (pack *** pack) <$> liftM2 (,) (username <$> config) (password <$> config)
