module Element where

import Prelude

import Halogen
import Halogen.HTML.Indexed as H
import Halogen.HTML.Properties.Indexed as P
import Proxy (Proxy(..))

c :: forall r i. String -> P.IProp (class :: P.I | r) i
c = P.class_ <<< H.className

container :: forall p a. Array (HTML p a) -> HTML p a
container xs = H.section [c "section"] [H.div [c "container"] xs]

umi :: forall p a. HTML p a
umi = H.img [P.src "https://cloud.githubusercontent.com/assets/1013641/19418188/01a67742-93fa-11e6-9ff2-9a8286a89767.gif"]

heading :: forall p a. String -> HTML p a
heading title = H.div [c "heading"] [H.h1 [c "title"] [H.text title]]

proxyTable :: forall p a. Array Proxy -> HTML p a
proxyTable xs = H.div_ [] -- FIXME

proxy :: forall p a. Proxy -> HTML p a
proxy _ = H.div_ [] -- FIXME
