module Main where

import Config (getPort)
import Network.Wai.Handler.Warp (run)
import Server (server)

main :: IO ()
main = do
  port <- getPort
  putStrLn $ "listen on http://0.0.0.0:" ++ show port
  run port server
