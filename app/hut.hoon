:: import types from sur
/-  *hut

/+  *mip, default-agent, dbug, agentio

:: define the types of agent states
|%
+$  versioned-state
  $%  state-0
  ==
:: the agent's state type
+$  state-0 [%0 =huts =ppl]
:: convenience:
+$  card  card:agent:gall
--

:: wrap with dbug
%-  agent:dbug

:: instantiate the state
=|  state-0
=*  state -   :: TODO: wat? is this wing-notation accessing something?
^-  agent:gall

:: proper agent core begins.
:: sample is a 'bowl' which is populated every time an event is applied.
|_  bol=bowl:gall

:: convenience aliases
::  "this" is the whole agent including state
+*  this  .   :: TODO: what is +* ?
::  "def" is default-agent, sane default handler
    def   ~(. (default-agent this %.n) bol)
::  "io" is agentio, library with conveneicen functions
    io    ~(. agentio bol)

::  called when agent is first started
++  on-init on-init:def

::  exports agent state during upgrade.
++  on-save !>(state)  :: pack the current state in a vase. !> "wrap a hoon noun in its type"

::  called when exported state is re-imported after upgrade.
::  extract state from vase and put it back in agent state
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this) :: TODO: wat is underscore_this
  [~ this(state !<(state-0 old-vase))]

::  handle actions/direct requests
++  on-poke
  |=  [=mark =vase]
  |^  ^-  (quip card _this)
  :: check the mark of incoming poke (want %hut-do)
  ?>  ?=(%hut-do mark)
  :: if it's ours, call ++local. otherwise call ++remote
  ?:  =(our.bol src.bol)
    (local !<(act vase))
  (remote !<(act vase))

  ++  local :: handle our local, on-ship requests
    |=  =act
    ^-  (quip card _this)
    :: ?- tests which action the poke contains and handles it (switch against a union)
    ?-   -.act
        :: 
        %post  :: handle us posting a new message
      =/  =path /(scot %p host.hut.act)/[name.hut.act]
      ?.  =(our.bol host.hut.act) :: remote. send our message
        :_  this
        :~  (~(poke pass:io path) [host.hut.act %hut] [mark vase])
        ==
      :: ours. update message and send to subscribers
      =/  =msgs  (~(got by huts) hut.act)
      =.  msgs
        ?.  (lte 50 (lent msgs))  :: make sure not more than 50
          [msg.act msgs]
        [msg.act (snip msgs)]
      :_  this(huts (~(put by huts) hut.act msgs))
      :~  (fact:io hut-did+!>(`upd`[%post msg.act]) ~[path])  :: send fact of shape %post
      ==
      ::
      :: TODO: %join





