:: import the mip library for map of maps.
/+  *mip
|%
:: chat message is pair of author and string
+$  msg   [who=@p what=@t]
:: msgs in a hut: list of msg
+$  msgs  (list msg)
:: hut is host ship and name
+$  hut   [host=@p name=@tas]
:: all huts we've created or joined. in a map with the hut as key and msgs (array) as value
+$  huts  (jar hut msg)
:: whitelist - a map of maps. first key is hut, second key is ship, value is bool
+$  ppl   (mip hut @p ?)
:: the possible actions. a tagged union
+$  act
  $%  [%make =hut]
      [%post =hut =msg]
      [%whit =hut who=@p]
      [%kick =hut who=@p]
      [%join =hut]
      [%quit =hut]
  ==
::
:: possible updates agent can send out
+$  upd
  $%  [%init ppl=(map @p ?) =msgs]  :: init state for new subs
      [%post =msg]                  :: new msg posted
      [%whit who=@p]                :: new ship whitelisted
      [%kick who=@p]                :: ship kicked
      [%join who=@p]                :: ship joined
      [%quit who=@p]                :: ship left
  ==
--