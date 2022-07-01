:: import type definitions from sur
/-  *hut
::
:: mark takes an action type - calling it "a"
|_  a=act
::
:: grow defines methods to convert from our mark to other marks
++  grow
  |%
  ::
  :: define a simple method to convert our mark to a noun
  :: by merely returning the sample "a"
  ++  noun  a
  --
::
:: grab defines methods to convert from OTHER marks to our mark
++  grab
  |%
  ::
  :: convert _from_ a noun by molding the data with our act type
  ++  noun  act
  ::
  :: define function to convert JSON from front end -> to our mark and act type
  ++  json
    ::
    =,  dejs:format
    |=  jon=json
    |^  ^-  act
    %.  jon
    %-  of
    :~  join+de-hut
        quit+de-hut
        make+de-huts
        whit+(ot ~[hut+de-hut who+(se %p)])
        kick+(ot ~[hut+de-hut who+(se %p)])
        post+(ot ~[hut+de-hut msg+(ot ~[who+(se %p) what+so])])
    ::
    ==
    ++  de-hut  (ot ~[host+(se %p) name+(su sym)])
    --
  --
::
:: grad defines revision control and merge functions. not used here because we're
:: not storing data in Arvo's filesystem.
:: delegate to generic noun mark
++  grad  %noun
--
  