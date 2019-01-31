# README

## Test Scripts

## Local Dev Test Setup
In a terminal, fire up ganache:
`$ ganache-cli -p 8545`

In another terminal, deploy contract
`$ rm -rf build` <-- if is stale junk in /build dir from old deployments
`$ truffle compile`
`$ truffle migrate --network development`

Fire up truffle console:
`$ truffle console --network development`

`> Microsponsors.deployed().then(instance => { i = instance })`
`> u0 = web3.eth.accounts[0]`
`> u1 = web3.eth.accounts[1]`

1. Test `.mintSponsorSlot()`:

`> i.mintSponsorSlot(u1, 'sampleProperty', 1548890806025)`

2. Test basic ERC721 methods:

`> i.ownerOf(0)`
... should return u1 address

`i.balanceOf(u1)`
... should return 1 (as Big Number)

`> i.totalSupply()`
... should return 1 (as Big Number)
