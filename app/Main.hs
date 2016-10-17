module Main where

import Config (getPort)
import Network.Wai.Handler.Warp (run)
import Server (server)

main :: IO ()
main = do
  port <- getPort
  run port server
