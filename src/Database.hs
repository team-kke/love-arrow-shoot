{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Database
  ( addProxy
  , removeProxy
  , getProxies
  , Proxy (..)
  , ID
  ) where

import Option (database)
import Control.Monad.Reader (ask)
import Control.Monad.State (get, put)
import Data.Acid
import Data.ByteString (ByteString)
import Data.List (sortBy)
import Data.SafeCopy
import Data.Text (Text)

data Proxy = Proxy { pathPattern :: Text
                   , proxyHost :: ByteString
                   , proxyPort :: Int
                   } deriving Show

type ID = Integer

data Database = Database [(ID, Proxy)]

$(deriveSafeCopy 0 'base ''Proxy)
$(deriveSafeCopy 0 'base ''Database)

addProxy' :: Proxy -> Update Database ()
addProxy' proxy = do
  Database proxies <- get
  put . Database $ case proxies of
    [] -> [(1, proxy)]
    db@((id, _):_) -> (id + 1, proxy) : db

removeProxy' :: ID -> Update Database ()
removeProxy' id = do
  Database proxies <- get
  put . Database $ filter ((== id) . fst) proxies

getProxies' :: Query Database [Proxy]
getProxies' = do
  Database proxies <- ask
  return $ map snd $ sortBy (\x y -> compare (fst x) (fst y)) proxies

$(makeAcidic ''Database ['addProxy', 'removeProxy', 'getProxies'])

acidState :: IO (AcidState Database)
acidState = do
  dir <- database
  openLocalStateFrom dir (Database [])

addProxy :: Proxy -> IO ()
addProxy proxy = do
  acid <- acidState
  update acid (AddProxy' proxy)

removeProxy :: ID -> IO ()
removeProxy id = do
  acid <- acidState
  update acid (RemoveProxy' id)

getProxies :: IO [Proxy]
getProxies = do
  acid <- acidState
  query acid GetProxies'
