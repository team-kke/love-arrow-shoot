{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Server.Setting.API
  ( settingAPIServer
  ) where

import Data.Aeson
import Data.ByteString.Char8 (readInteger)
import Database
import GHC.Generics
import Network.HTTP.Types (status200, status404)
import Network.HTTP.Types.Header (hContentType)
import Network.Wai

data ProxyResponse = ProxyResponse { id :: ID
                                   , proxy :: Proxy
                                   } deriving Generic

data Ok = Ok { success :: Bool } deriving Generic

instance ToJSON ProxyResponse where
  toEncoding = genericToEncoding defaultOptions

instance ToJSON Ok where
  toEncoding = genericToEncoding defaultOptions

toRes :: (ID, Proxy) -> ProxyResponse
toRes (id, proxy) = ProxyResponse id proxy

responseJSON :: ToJSON a => a -> Response
responseJSON = responseLBS status200 [(hContentType, "application/json")] . encode

badRequest :: Response
badRequest = responseLBS status404 [] "bad request"

settingAPIServer :: Application
settingAPIServer req f =
  case requestMethod req of
    "GET" -> get req f
    "POST" -> post req f
    "DELETE" -> delete req f
  where
    get req f= getProxies >>= (f . responseJSON . map toRes)

    post req f= do
      maybeProxy <- decode <$> lazyRequestBody req
      case maybeProxy of
        Just proxy -> do
          addProxy proxy
          f . responseJSON $ Ok True
        _ -> f badRequest

    delete req f = do
      let id = (snd $ queryString req !! 0) >>= readInteger
      case id of
        Just (id, _) -> do
          removeProxy id
          f . responseJSON $ Ok True
        _ -> f badRequest
