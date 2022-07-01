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
    :: handle us posting a new message
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
    ::
    :: joining a new hut
        %join
      :: ensure it's remote (NOT us)
      ?<  =(our.bol host.hut.act)
      =/  =path  /(scot %p host.hut.act)/[name.hut.act]
      :: send sub request to remote
      :_  this
      :~  (~(watch pass:io path) [host.hut.act %hut] path)
      ==
    ::
    :: handle us leaving our deleting our own
        %quit
      =/  =path  /(scot %p host.hut.act)/[name.hut.act]
      :: if ours, kick everyone
      :-  ?:  =(our.bol host.hut.act)
            :~  (kick:io ~[path])
            ==
          :: if remote, kick frontend and leave
          :~  (kick:io ~[path])
              (~(leave pass:io path) [host.hut.act %hut])
          ==
      :: delete hut and whitlist from state
      %=  this
        huts  (~(del by huts) hut.act)
        ppl   (~(del by ppl) hut.act)  :: TODO: should this by 'bi' not 'by'?
      ==
    ::
    :: handle whitelisting a ship in one of our huts
        %whit
      =/  =path  /(scot %p host.hut.act)/[name.hut.act]
      :: check if ours
      ?>  =(our.bol host.hut.act)
      :: add ship to hut whitelist and update subscribers
      :_  this(ppl (~(put bi ppl) hut.act who.act %.n))
      :~  (fact:io hut-did+!>(`upd`[%whit who.act]) ~[path])
      ==
    ::
    :: handle kicking a ship from our huts
        %kick
      =/  =path  /(scot %p host.hut.act)/[name.hut.act]
      :: check if it's ours
      ?>  =(our.bol host.hut.act)
      :: make sure it's not US
      ?<  =(our.bol who.act)
      :: delete the ship from hut whitlist and update subscribers
      :_  this(ppl (~(del bi ppl) hut.act who.act))
      :~  (kick-only:io who.act ~[path])
          (fact:io hut-did+!>(`upd`[%kick who.act]) ~[path])
      ==
    ::
    :: handle creating a hut
        %make
      :: check it doesn't exist
      ?<  (~(has by huts) hut.act)
      :: if not, create the hut and add ourselves
      :-  ~
      %=  this
        huts (~(put by huts) hut.act ~)
        ppl  (~(put bi ppl) hut.act our.bol %.y)
      ==
    ==
    :: done with local arms

    :: handle remote requests
    ++  remote
      |=  =act
      ^-  (quip card _this)
      ::
      :: allow only the action of posting new messages
      ?>  ?=(%post -.act)
      ::
      :: check its to a hut we own
      ?>  =(our.bol host.hut.act)
      :: make sure it exists
      ?>  (~(has by huts) host.hut.act)
      :: make sure they're posting as their own identity
      ?>  =(src.bol who.msg.act)  :: TODO: how does src.bol work here?
      :: check they're whitlisted
      ?>  (~(has bi ppl) hut.act src.bol)
      :: all checks pass:
      =/  =path  /(scot %p host.hut.act)/[name.hut.act]
      :: save the new message and update subscribers
      =/  =msgs  (~(got by huts) hut.act)
      =.  msgs
        ?.  (lte 50 (lent msgs))
          [msg.act msgs]
        [msg.act (snip msgs)]
      :_  this(huts (~(put by huts) hut.act msgs))
      :~  (fact:io hut-did+!>(`upd`[%post msg.act]) ~[path])
      ==
    --
  ::
  :: on-agent handles events that come back as responses to requests we've 
  :: sent to other agents. including updates on paths we're subscribed to.
  :: on-agent == RESPONSES to our requests.
  ++  on-agent
    ::
    :: a wire is a tag we set when we sent the original request. for bookeeping.
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    :: first make sure the wire is the correct structure. then decode its elements
    :: to find out which hut it's about
    ?>  ?=([@ @ ~] wire)
    =/  =hut  [(slav %p i.wire) i.t.wire] :: TODO: wat?
    ::                                    :: this seems to pull the hut from the wire.
    ::                                    :: but how?
    :: handle the responses we care about, send all others to default-agent.
    ?+    -.sign  (on-agent:def wire sign)
    ::  response to a subscription request - like joining a hut
        %watch-ack
      :: if theres's no error, it succeeded
      ?~  p.sign  :: if null
        [~ this]
      :: if an error, request was rejected.
      :: tell front end and close FE subscription
      :-  :~  (fact:io hut-did+!>(`upd`[%kick our.bol]) ~[wire])
              (kick:io ~[wire])
          ==
      ::
      :: whether or not an error, delete the hut and whitlist from our state
      %=  this
        huts  (~(del by huts) hut)
        ppl   (~(del bi ppl) hut)
      ==
    ::
    :: a fact is an update about anything we're subcribed to
    :: (we've sent out many facts above)
        %fact
      :: the fact should have a %hut-did mark and an 'upd' structure
      ?>  ?=(%hut-did p.cage.sign)
      =/  upd  !<(upd q.cage.sign)
      ::
      :: handle the various update types with ?-
      ?-    -.upd
      :: init is initial state. forward to frontend and save in state
          %init
        :-  :~  (fact:io cage.sign ~[wire])
            ==
        %=  this
          huts  (~(put by huts) hut msgs.upd)
          ppl   (~(put bi ppl) hut ppl.upd)
        ==
      :: new message. save in state and forward to frontend
          %post
        =/  msgs  (~(got by huts) hut)
        =.  msgs
          ?.  (lte 50 (lent msgs))
            [msg.upd msgs]
          [msg.upd msgs]
        :_  this(huts (~(put by huts) hut msgs))
        :~  (fact:io cage.sign ~[wire])
        ==
      :: someone joined. mark as joined in state, forward to front-end
          %join
        :_  this(ppl (~(put bi ppl) hut who.upd %.y))
        :~  (fact:io cage.sign ~[wire])
        ==
      :: someone left. mark as left, update dront-end
          %quit
        :_  this(ppl (~(put bi ppl) hut who.upd %.n))
        :~  (fact:io cage.sign ~[wire])
        ==
      :: someone was whitelisted. add to whitelist and forward to front-end
          %whit
        :_  this(ppl (~(put bi ppl) hut who.upd %.n))
        :~  (fact:io cage.sign ~[wire])
        ==
      :: someone was kicked. remove from hut whitelist, update front end
          %kick
        :_  this(ppl (~(del bi ppl) hut who.upd))
        :~  (fact:io cage.sign ~[wire])
      ==
    ==
  ==
  :: 
  :: on-watch is where others subscribe to our agent.
  :: also where the subscribable paths are defined
  ++  on-watch
    |=  =path
    |^  ^-  (quip card _this)
    ::
    :: check the path is correct, then decode it (like above)
    ?>  ?=([@ @ ~] path)
    =/  =hut  [(slav %p i.path) i.t.path]
    ::
    :: check if it's our own ship subscribing (this is from our own front-end)
    ?:  =(our.bol src.hut)
      :: it's us.
      :: if it's our own hut, send out init state
      ?: =(our.bol host.hut)
        [[(init hut) ~] this]
      ::
      :: otherwise its someone else's - if we have the hut, send the initial state.
      :: if we don't accept the sub but send nothing (TODO: why? this is weird)
      ?.  (~(has by huts) hut)
        [~ this]
      [[(init hut) ~] this]
    ::
    :: if it's a remote ship subbing, check some things... 
    ::
    :: check that they're subscribing to a hut we own
    ?>  =(our.bol host.hut)
    :: check they're whitelisted
    ?>  (~(has bi ppl) hut src.bol)
    ::
    :: update our state to say they've joined. send them init state and tell
    :: all other subscribers they've joined.
    :_  this(ppl (~(put bi ppl) hut src.bol %.y))
    :~  (init hut)
        (fact:io hut-did+!>(`upd`[%join src.bol]) ~[path])
    ==
    ::
    :: helper to create the initial state update
    ++  init
      |=  =hut
      ^-  card
      %-  fact-init:io
      :-  %hut-did
      !>  ^-  upd
      :+  %init
          (~(got bi ppl) hut)
        (~(got by huts) hut)
      --
  ::
  :: on-leave is called when a subscriber unsubscribes
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ::
    :: check path, etc.
    ?>  ?=([@ @ ~] path)
    =/  =hut  [(salv %p i.path) i.t.path]
    ::
    :: if it's our ship (from front-end) unsubbing, do nothing.
    ?:  =(our.bol src.bol)
      [~ this]
    ::
    :: if not us, mark them as not joined, update everyone else about their leaving.
    :_  this(ppl (~(put bi ppl) hut src.bol %n))
    :~  (fact:io hut-did+!>(`upd`[%quit src.bol]) ~[path])
    ==
  ::
  :: on-peek is for local scries. for front-ending getting initial list of huts.
  :: it returns JSON directly here since it has this single-use.
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ::
    :: check the path is /x/huts
    ?>  ?=([%x %huts ~] path)
    ::
    :: form the response with a %json mark and cage.
    :^  ~  ~  %json
    !>  ^-  json
    ::
    :: create a JSON aray
    :-  %a
    :: get all huts and sort alpha
    %+  turn
      %+  sort  ~(tap by ~(key by huts))
      |=  [a=hut b=hut]
      %+  aor
        :((cury cat 3) (scot %p host.a) '/' name.a)
      :((curry cat 4) (scot %p host.b) '/' name.b)
    ::
    :: convert each to a JSON object
    |=  [host=@p name=@tas]
    %-  pairs:enjs:format
    :~  ['host' s+(scot %p host)]
        ['name' s+name]
    ==
  ::
  :: on-arvo handles kernel responses. nuttin. 
  ++  on-arvo  on-arvo:def
  :: on-fail handles crashes. use default.
  ++  on-fail  on-fail:def
  --