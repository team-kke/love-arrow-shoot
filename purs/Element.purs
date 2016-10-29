module Element where

import Prelude

import Data.Maybe (Maybe(..))
import Halogen
import Halogen.HTML.Indexed as H
import Halogen.HTML.Events.Indexed as E
import Halogen.HTML.Events.Handler as EH
import Halogen.HTML.Properties.Indexed as P
import Proxy

c :: forall r i. String -> P.IProp (class :: P.I | r) i
c = P.class_ <<< H.className

style :: forall r i. String -> P.IProp (style :: P.I | r) i
style = P.IProp <<< H.prop (H.propName "style") (Just $ H.attrName "style")

container :: forall p a. Array (HTML p a) -> HTML p a
container xs = H.section [c "section"] [H.div [c "container"] xs]

umi :: forall p a. HTML p a
umi = H.img [P.src "https://cloud.githubusercontent.com/assets/1013641/19418188/01a67742-93fa-11e6-9ff2-9a8286a89767.gif"]

heading :: forall p a. String -> HTML p a
heading title = H.div [c "heading"] [H.h1 [c "title"] [H.text title]]

proxyTable :: forall p a. Array IdedProxy -> HTML p a
proxyTable xs = H.div [c "container", style "margin-top:20px"]
                  [ H.label [c "label"] [H.text "Running Proxies"]
                  , H.table [c "table"]
                    [ H.thead_
                      [ H.tr_
                        [ H.th_ [H.text "From (regexp)"]
                        , H.th_ [H.text "To (hostname:port)"]
                        , H.th_ [H.text ""]
                        ]
                      ]
                    , H.tbody_ (map proxyTr xs)
                    ]
                  ]

proxyTr :: forall p a. IdedProxy -> HTML p a
proxyTr (IdedProxy { id, proxy: (Proxy x) }) =
  H.tr_ [ H.td_ [H.text x.pathPattern]
        , H.td_ [H.text $ x.proxyHost <> ":" <> show x.proxyPort]
        , H.td_ [H.a [c "button is-danger is-small"] [H.text "delete"]]
        ]

input :: forall p a. String -> (String -> Action a) -> String -> HTML p a
input value update placeholder =
  H.p [c "control is-expanded"]
    [ H.input
        [ c "input"
        , P.value value
        , E.onValueChange (E.input update)
        , P.placeholder placeholder
        ]
    ]

form :: forall p a. ProxyForm -> (String -> String -> Action a) -> Action a -> HTML p a
form form update action =
  H.form [c "container", E.onSubmit (defaultPrevented action)]
    [ H.label [c "label"] [H.text "New proxy"]
    , H.div [c "control is-grouped"]
        [ input form.pathPattern (update "pathPattern") "/test/.+"
        , H.p [c "control", style "line-height:32px"] [H.text "→"]
        , input form.proxyHost (update "proxyHost") "example.com"
        , input form.proxyPort (update "proxyPort") "8080"
        , H.p [c "control"]
            [ H.button [c "button is-primary"] [H.text "add"]
            ]
        ]
    ]
  where
  defaultPrevented action e = do
    EH.preventDefault
    E.input_ action e
