module Option
  ( config
  ) where

config :: IO FilePath
config = return "./config.sample.yaml"
