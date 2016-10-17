module Config
  ( getPort
  ) where

import Network.Wai.Handler.Warp (Port)

getPort :: IO Port
getPort = return 3000
