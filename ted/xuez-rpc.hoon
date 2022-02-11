::  Note: these are for XUEZ testnet
::
/-  spider, rpc=json-rpc
/+  strandio, xz=xuez
=,  strand=strand:spider
=>
|%
++  addr  ^-(address:xz [%bech32 'xz1q39wus23jwe7m2j7xmrfr2svhrtejmsn262x3j2'])
:: TO DO: Sort out %bec32 above      ^^
++  parse-json-rpc
  |=  jon=json
  ^-  response:rpc
  =/  res=(unit [@t json])
    %.  jon
    =,  dejs-soft:format
    (ot id+so result+some ~)
  ?^  res  [%result u.res]
  ~|  parse-one-response=jon
  :-  %error
  %-  need
  %.  jon
  =,  dejs-soft:format
  (ot id+so error+(ot code+no message+so ~) ~)
::
++  parse-response
  |=  =client-response:iris
  =/  m  (strand:strandio ,response:rpc)
  ^-  form:m
  |^
  ?>  ?=(%finished -.client-response)
  =*  status  status-code.response-header.client-response
  =*  headers  headers.response-header.client-response
  ?~  full-file.client-response
    (pure:m (mk-fail status headers ~))
  =*  file  u.full-file.client-response
  =/  jon=(unit json)
    (de-json:html q.data.file)
  ?~  jon
    (pure:m (mk-fail 500 headers `data.file))
  (pure:m (parse-json-rpc u.jon))
  ++  mk-fail
    |=  [status=@ud hs=header-list:http data=(unit octs)]
    [%fail status hs data]
  --
++  run-rpc
  |=  [rpc-url=tape req=request:http]
  =/  m  (strand:strandio ,response:rpc)
  ^-  form:m
  ;<  ~  bind:m  (send-request:strandio req)
  ;<  rep=client-response:iris  bind:m
    take-client-response:strandio
  ;<  rpc-resp=response:rpc  bind:m
    (parse-response rep)
  (pure:m rpc-resp)
::
++  types
  |%
  +$  block-info
    $:  block=@ud
        fee=sats:xz
        block-hash=hexb:xz
        block-filter=hexb:xz
    ==
  --
++  api
  |_  rpc-url=tape
  ++  block-info
    =/  m  (strand:strandio ,block-info:types)
    ^-  form:m
    :: TODO: put all chained calls here
    (pure:m *block-info:types)
  --
::
++  brpc
  |%
  ++  req
    |=  [rpc-url=tape type=?(%xuez %electrs) rpc-call=json]
    ^-  request:http
    =/  url=@ta
      %-  crip
      %+  weld  rpc-url
      ?:  ?=(%xuez type)
        "/xuez-rpc"
      "/electrs-rpc"
    :*  method=%'POST'
      url
      header-list=['Content-Type'^'application/json' ~]
      ^=  body
      %-  some
      %-  as-octt:mimes:html
      (en-json:html rpc-call)
    ==
  ::
  ++  call
    =,  enjs:format
    |=  [id=@t method=@t params=(list json)]
    ^-  json
    %-  pairs
    :~  jsonrpc+s+'2.0'
        id+s+id
        method+s+method
        params+a+params
    ==
  ::  convert address to Electrs ScriptHash that it uses to index
  ::   big-endian sha256 of the output script
  ::
  ++  electrs-scripthash
    |=  a=address:xz
    ^-  hexb:xz
    %-  flip:byt:xz
    %-  sha256:xz
    (to-script-pubkey:adr:xz a)
  ::
  ++  calls
    |%
    ::  BTC
    ::
    ++  block-count
      (call 'block-count' 'getblockcount' ~)
    ::
    ++  block-hash
      |=  block=@ud
      (call 'block-hash' 'getblockhash' ~[[%n (scot %ud block)]])
    ::
    ++  block-filter
      |=  blockhash=@t
      (call 'block-filter' 'getblockfilter' ~[[%s blockhash]])
    ::
    ++  fee
      (call 'fee' 'estimatesmartfee' ~[[%n '1']])
    ::  Electrs
    ::
    ++  list-unspent
      |=  a=address:xz
      %^  call  'list-unspent'  'blockchain.scripthash.listunspent'
      ~[[%s (scot %ux dat:(electrs-scripthash a))]]
    --
  --
--
^-  thread:spider
|=  arg=vase
::  =+  !<([~ a=@ud] arg)
=/  m  (strand ,vase)
^-  form:m
=/  rpc-url=tape  "http://localhost:50002"
;<  rpc-resp=response:rpc  bind:m
  (run-rpc rpc-url (req:brpc rpc-url %xuez block-count:calls:brpc))
~&  >  rpc-resp
;<  rpc-resp=response:rpc  bind:m
  (run-rpc rpc-url (req:brpc rpc-url %xuez fee:calls:brpc))
(pure:m !>(rpc-resp))
