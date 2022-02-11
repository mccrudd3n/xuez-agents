# Xuez Demo/Integration Test
Use only one of `%main` or `%testnet` for `=network` in the examples below, and use the corresponding `xpubmain` or `xpubtest`.

## Start Services
Runs the full node API services.
```
./local-start.sh
```

## Start Agents and set XPUBs
On `~zod`. Uses "abandon abandon..." mnemonic
```
=network %testnet
=network %main
|commit %home
|start %xuez-provider
|start %xuez-wallet

:xuez-provider|command [%set-credentials api-url='http://localhost:50002' network]
:xuez-wallet|command [%set-provider ~zod]
:xuez-provider|command [%add-whitelist %users `(set ship)`(sy ~[~dopzod])]

=fprint [%4 0xbeef.dead]
=xpubmain 'zpub6rFR7y4Q2AijBEqTUquhVz398htDFrtymD9xYYfG1m4wAcvPhXNfE3EfH1r1ADqtfSdVCToUG868RvUUkgDKf31mGDtKsAYz2oz2AGutZYs'
=xpubtest 'vpub5Y6cjg78GGuNLsaPhmYsiw4gYX3HoQiRBiSwDaBXKUafCt9bNwWQiitDk5VZ5BVxYnQdwoTyXSs2JHRPAgjAvtbBrf8ZhDYe2jWAqvZVnsc'
```

On `~dopzod`. Uses "absurd sick..." mnemonic from PRIVATE.scratch.md
```
|commit %home
|start %xuez-wallet

:xuez-wallet|command [%set-provider ~zod]

=fprint [%4 0xdead.beef]
=xpubmain 'zpub6r8dKyWJ31XF6n69KKeEwLjVC5ruqAbiJ4QCqLsrV36Mvx9WEjUaiPNPGFLHNCCqgCdy6iZC8ZgHsm6a1AUTVBMVbKGemNcWFcwBGSjJKbD'
=xpubtest 'vpub5ZpY66FvUHYMSST9uWoUSFYBYxGx3aSFfQP8qg2HqGUuL8k9ReiWuKxSKZBwFmBKug8YStuGTmxsnL8ySc9dfPJQdJTM4dYAZcgJhSfRWKL'
```

### Add Wallets
On both `~zod`/`dopzod`, choose depending on whether you're on test or main

Using 1 confirmation for testing.
```
:xuez-wallet|command [%add-wallet xpubmain fprint ~ [~ 8] [~ 1]]

:xuez-wallet|command [%add-wallet xpubtest fprint ~ [~ 8] [~ 1]]
```

## Check Balance
`~dopzod`
```
.^((unit @ud) %gx /=xuez-wallet=/balance/[xpubmain]/noun)

.^((unit @ud) %gx /=xuez-wallet=/balance/[xpubtest]/noun)
```

## Pay a Ship
`~dopzod` will pay `~zod`. Both are acting as clients here (and use `~zod` as the provider).

`~dopzod`
```
:xuez-wallet|command [%init-payment ~zod 20.000 feyb=10]
```

### Check State on ~zod/~dopzod
`~dopzod`: outgoing
```
:xuez-wallet +dbug [%state 'poym']
```

`~zod`: incoming
```
:xuez-wallet +dbug [%state 'piym']
```

### Idempotent
`~dopzod`
```
:xuez-wallet|command [%init-payment ~zod 3.000 feyb=100]
```
Or can change amount:
```
:xuez-wallet|command [%init-payment ~zod 3.000 feyb=100]
```

### Broadcast the Signed TX
```
:xuez-wallet|command [%broadcast-tx tx]
```


## Scan a Real Xpub
```
=realxpub 'zpub6qvniDfrk9sRxz7H9Cbr8fccuGNd4RGMmifPVvbQtqtsG7VwCUrNsnNt8DiCH8kxh3vsDuJkfNqZQspVq2xEbE64fgXT5hVJiD8WkRhvuJc'
=fprint [%4 0xc93d.865c]
:xuez-wallet|command [%add-wallet realxpub fprint ~ [~ 6] [~ 6]]

.^(@ud %gx /=xuez-wallet=/balance/[realxpub]/noun)
```
