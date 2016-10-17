module Option
  ( config
  ) where

import Options.Applicative hiding (option)

data Option = Option { config' :: FilePath
                     }

parser :: Parser Option
parser = Option
         <$> strOption ( long "config"
                      <> short 'c'
                      <> metavar "FILE"
                      <> help "Config file"
                       )

option :: IO Option
option = execParser $
  info (helper <*> parser) ( fullDesc
                          <> header "love-arrow-shoot - A super simple reverse proxy on Warp"
                           )

config :: IO FilePath
config = config' <$> option
