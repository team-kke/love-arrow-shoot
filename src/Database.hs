{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}

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
import Data.Aeson
import Data.ByteString (ByteString)
import Data.List (sortBy)
import Data.SafeCopy
import Data.Text (Text)
import Data.Text.Encoding (encodeUtf8, decodeUtf8)

data Proxy = Proxy { pathPattern :: Text
                   , proxyHost :: ByteString
                   , proxyPort :: Int
                   } deriving Show

instance ToJSON Proxy where
  toJSON proxy = object [ "pathPattern" .= pathPattern proxy
                        , "proxyHost" .= decodeUtf8 (proxyHost proxy)
                        , "proxyPort" .= proxyPort proxy
                        ]

instance FromJSON Proxy where
  parseJSON = withObject "Proxy" $ \obj ->
    Proxy <$> obj .: "pathPattern"
          <*> (encodeUtf8 <$> obj .: "proxyHost")
          <*> obj .: "proxyPort"

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
  put . Database $ filter ((/= id) . fst) proxies

getProxies' :: Query Database [(ID, Proxy)]
getProxies' = do
  Database proxies <- ask
  return $ sortBy (\x y -> compare (fst x) (fst y)) proxies

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

getProxies :: IO [(ID, Proxy)]
getProxies = withAcidState $ \acid ->
  query acid GetProxies'
