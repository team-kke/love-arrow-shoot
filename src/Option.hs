module Option
  ( config
  , static
  , database
  ) where

import Options.Applicative hiding (option)

data Option = Option { config' :: FilePath
                     , static' :: FilePath
                     , database' :: FilePath
                     }

parser :: Parser Option
parser = Option
         <$> strOption ( long "config"
                      <> short 'c'
                      <> metavar "FILE"
                      <> help "Config file"
                       )
         <*> strOption ( long "static"
                      <> short 's'
                      <> metavar "DIR"
                      <> help "Directory to static files"
                       )
         <*> strOption ( long "database"
                      <> short 'd'
                      <> metavar "DIR"
                      <> help "Directory to save acid-state files"
                       )

option :: IO Option
option = execParser $
  info (helper <*> parser) ( fullDesc
                          <> header "love-arrow-shoot - A super simple reverse proxy on Warp"
                           )

config :: IO FilePath
config = config' <$> option

static :: IO FilePath
static = static' <$> option

database :: IO FilePath
database = database' <$> option
