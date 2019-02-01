# Microsponsors.io ERC721 Contract - DEMO
For 0x Hackathon - Feb 2019

NOTE:
This is a very rough draft for demonstration purposes only.

This demo uses ERC721 NFTs as a marketplace for sponsorship of content creators.

Each token is a Non-Fungible Token (NFT) that represents a time window during
which a content creators' property is available to rent by sponsors.
Non-Fungible tokens are perfect for this use-case because each sponsorship
slot has a unique value, and will change given its time window.

Patterned after 0x Sample ERC721 ABI:
https://github.com/0xProject/0x-monorepo/blob/development/python-packages/contract_artifacts/src/zero_ex/contract_artifacts/artifacts/DummyERC721Token.json

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
`> u2 = web3.eth.accounts[2]`

1. Test `.mint()`:

`> i.mint(u1, 'sampleProperty', 1548890806025)`
... log output should show 2 events: PropertyCreated, Minted

2. Test ERC721 view methods:

`> i.ownerOf(0)` // 0 being id of the SponsorSlot created by u1
... should return u1 address

`i.balanceOf(u1)`
... should return 1 (as Big Number)

`> i.totalSupply()`
... should return 1 (as Big Number)

3. Test ERC721 .transfer() from owner

`> i.transfer(u2, 0, { from: u1 } `
Owner is u1, transfers SponsorSlot to u2.

`> i.ownerOf(0)`
... should return u2's address now

3. Test ERC721 .transfer() from non-owner -- should fail

Try the same .transfer, but now u1 is no longer the owner
`> i.transfer(u2, 0, { from: u1 })`
... should throw exception and revert

4. Test ERC721 .transferFrom() without authorizing first -- should fail

Owner is u2 but has not approve()'d u1 to transfer token back to themselves
`> i.transferFrom(u2, u1, 0, { from: u1 })`
... should throw exception and revert

5. Test ERC721 .transferFrom()

Owner u2 approves token to be transferred back to u1
`> i.approve(u1, 0, {from: u2})`
... success, 'Approval' event is logged

u1 calls .transferFrom() successfully
`> i.transferFrom(u2, u1, 0, { from: u1 })`
... success, 'Transfer' event is logged

Double check that token was transferred successfully:
`> i.ownerOf(0)`
... should be u1

Check balances of each user:
`> i.balanceOf(u0)` // ... should be 0
`> i.balanceOf(u1)` // ... should be 1
`> i.balanceOf(u2)` // ... should be 0

Check total supply:
`> i.totalSupply()` // ... should be 1

6. Test ERC721 tokensOfOwner()

`> i.tokensOfOwner(u1)`
... returns array of BigNumbers representing token ids
