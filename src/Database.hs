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
import Data.Acid.Local (createCheckpointAndClose)
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

withAcidState :: (AcidState Database -> IO a) -> IO a
withAcidState f = do
  dir <- database
  acid <- openLocalStateFrom dir (Database [])
  result <- f acid
  createCheckpointAndClose acid
  return result

addProxy :: Proxy -> IO ()
addProxy proxy = withAcidState $ \acid ->
  update acid (AddProxy' proxy)

removeProxy :: ID -> IO ()
removeProxy id = withAcidState $ \acid ->
  update acid (RemoveProxy' id)

getProxies :: IO [Proxy]
getProxies = withAcidState $ \acid ->
  query acid GetProxies'
