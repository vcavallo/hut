/-  *hut
::
|_  u=upd
::
++  grow
  |%
  ::
  ++  noun  u
  ::
  ++  json
    =,  enjs:format
    |^  ^-  ^json  :: TODO: access the name json one up from here?
    ?-  -.u
      %join  (frond 'join' s+(scot %p who.u)) :: make json with frond
      %quit  (frond 'quit' s+(scot %p who.u))
      %whit  (frond 'whit' s+(scot %p who.u))
      %kick  (frond 'kick' s+(scot %p who.u))
      %post  %+  frond  'post'
             %-  pairs
             :~  ['who' s+(scot %p who.msg.u)]
                 ['what' s+what.msg.u]
             ==
      %init  %+  frond  'init'
             %-  pairs
             :~  ['ppl' (ppl-array ppl.u)]
                 ['msgs' (msg-array msgs.u)]
    ==       ==
    ++  msg-array
      |=  =msgs
      ^-  ^json
      :-  %a
      %+  turn  (flop msgs)
      |=  =msg
      %-  pairs
      :~  ['who' s+(scot %p who.msg)]
          ['what' s+what.msg]
      ==
    ++  ppl-array
      |=  ppl=(map @p ?)
      ^-  ^json
      :-  %a
      %+  turn
        %+  sort  ~(tap by ppl)
        |=  [[a=@ @] [b=@ @]]
        (aor (scot %p a) (scot %p b))
      |=  [p=@p q=?]
      a+~[s+(scot %p p) b+q]
    --
  --
::
++  grab  :: other marks to our mark
  |%
  ::
  ++  noun  upd
  --
++  grad  %noun
--
