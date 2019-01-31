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
`> Microsponsors.deployed().then(inst => { msInstance = inst })`
`> u0 = web3.eth.accounts[0]`
`> u1 = web3.eth.accounts[1]`

1. Test `.mintSponsorSlot()`
`> msInstance.mintSponsorSlot(u1, 'sampleProperty', 1548890806025)`
