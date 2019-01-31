// Microsponsors.io - DEMO ONLY!
// This demo uses ERC721 NFTs as a marketplace for sponsorships of content creators.
// This is a rough draft for demo purposes only (not nearly production-ready!).

pragma solidity ^0.4.24;

import "./ERC721.sol";
// TODO LATER:
// import "./Ownable.sol";
// import "./Safemath.sol";


contract Microsponsors is ERC721 {

  /**
  * Events emitted
  */
  event PropertyCreated(uint256 propertyId, address creator, string desciption);
  event SponsorSlotMinted(uint256 slotId, uint256 propertyId, address creator, uint32 startTime, uint32 endTime, bool isSponsored);
  event SponsorSlotPurchased(uint256 slotId, uint256 propertyId, address creator, address sponsor);


  /**
   * Data
   */

  // The Microsponsors ERC721 Token:
  // A SponsorSlot is a window of time during which a Property can be
  // purchased by a sponsor
  struct SponsorSlot {
    uint256 propertyId; // maps to Property id
    address owner; // creator of slot; defaults to content creator when minted
    uint32 startTime; // timestamp for when sponsorship of a Property begins
    uint32 endTime; // max timestamp of sponsorship (when it ends)
    bool isSponsored; // defaults to false when minted
  }

  struct Property {
    address creator; // the content creator who will be sponsored
    string description; // website or property that contains the SponsorSlot (ex: "microsponsors.io-banner-north")
  }

  SponsorSlot[] public sponsorSlots;
  Property[] public properties;

  mapping (uint256 => address) public propertyToCreator;
  mapping (uint256 => address) public sponsorSlotToOwner;
  mapping (address => uint256) public ownerToSponsorSlotCount;
  mapping (uint256 => address) public sponsorSlotToSponsor;

  // Mapping from SponsorSlot ids to an address that has been approved to call
  // transferFrom(). Each  can only have one approved address for transfer
  // at any time.
  mapping (uint256 => address) public sponsorSlotIdToApproved;


  /**
  * Init contract
  */

  constructor() public {}


  /**
  * Primary public methods
  */

  /**
   * TODO: optimize minting process so that it does NOT cost content creators
   * extra gas to mint tokenized sponsor slot(s).
   * Can do this by reliably generating SponsorSlots with a formula
   * and minting (storing) in contract ONLY when the token is purchased.
   */

  /**
   * Mint the new SponsorSlot NFT, assign its ownership to content creator
   * Which will then be transfered to the sponsor when they purchase it.
   *
   * TODO LATER: let anyone mint during demo, but prod version should restrict
   * minting to msg.sender by removing _creator param and setting
   * SponsorSlot.owner to msg.sender
   */
  function mintSponsorSlot(
    address _creator,
    string _propertyDescription,
    uint32 _startTime
  ) public returns (uint256) {

    // TODO LATER enforce authorization per user onboarding:
    // require(isAuthorized(msg.sender));

    uint256 _propertyId = _createProperty(_creator, _propertyDescription);

    // TODO LATER duration is hard-coded to 10 min slots for demo purposes only;
    // these will obviously be longer/ more varied and schedule-able in production
    uint32 _duration = 10 minutes;
    uint32 _endTime = uint32(_startTime + _duration);

    // TODO
    // require(_isValidSponsorSlot(_creator, _propertyDescription, _startTime, _endTime));

    SponsorSlot memory _sponsorSlot = SponsorSlot({
      propertyId: uint256(_propertyId),
      owner: _creator,
      startTime: uint32(_startTime),
      endTime: uint32(_endTime),
      isSponsored: false
    });

    uint256 id = sponsorSlots.push(_sponsorSlot) - 1;
    emit SponsorSlotMinted(id, _propertyId, _creator, _startTime, _endTime, false);
    sponsorSlotToOwner[id] = _creator;
    ownerToSponsorSlotCount[_creator]++;

    return id;
  }

  // TODO:
  // function purchaseSponsorSlot() public payable {
    // TODO LATER enforce authorization per user onboarding:
    // require(isAuthorized(msg.sender));

    // sponsorSlotToCreator[id] = msg.sender;

  // }


  /**
   * ERC721 methods
   */
  function totalSupply() public view returns (uint) {
    return sponsorSlots.length;
  }

  function balanceOf(address _owner) public view returns (uint256 count) {
    return ownerToSponsorSlotCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address owner) {
    owner = sponsorSlotToOwner[_tokenId];
    require(owner != address(0));
  }

  // Creator approves transfer of the token (a SponsorSlot) to the sponsor
  // Bidding and order-matching takes place off-chain, so the slot will only
  // change hands once, from creator to sponsor.
  function approve(address _to, uint256 _tokenId) external {
    require(_owns(msg.sender, _tokenId));
    _approve(_tokenId, _to);
    emit Approval(msg.sender, _to, _tokenId);
  }

  // Creators may transfer their own SponsorSlot tokens to another address.
  function transfer(address _to, uint256 _tokenId) external {
    // Safety check to prevent against an unexpected 0x0 default.
    require(_to != address(0));
    // Disallow transfers to this contract to prevent accidental misuse.
    // The contract should never own any tokenized SponsorSlots
    require(_to != address(this));
    // Only creators can transfer tokenized SponsorSlots to sponsors.
    require(_owns(msg.sender, _tokenId));
    // Reassign ownership, clear pending approvals, emit Transfer event.
    _transfer(msg.sender, _to, _tokenId);
  }

  // Transfer a SponsorSlot token owned by another address, for which the
  // calling address has previously been granted transfer approval by the owner.
  function transferFrom(address _from, address _to, uint256 _tokenId) external {
    // Safety check to prevent against an unexpected 0x0 default.
    require(_to != address(0));
    // Disallow transfers to this contract to prevent accidental misuse.
    require(_to != address(this));
    // Check for approval and valid ownership
    require(_approvedFor(msg.sender, _tokenId));
    require(_owns(_from, _tokenId));

    // Reassign ownership (also clears pending approvals and emits Transfer event).
    _transfer(_from, _to, _tokenId);
  }

  // Returns list of all SponsorSlot ids belonging to an address
  // Returns a dynamic array, therefore does not support contract-to-contract
  // calls. Only supported for web3 calls.
  function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds) {
    uint256 tokenCount = balanceOf(_owner);

    if (tokenCount == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalSlots = totalSupply();
      uint256 resultIndex = 0;

      uint256 slotId; // SponsorSlot id

      for (slotId = 0; slotId <= totalSlots; slotId++) {
          if (sponsorSlotToOwner[slotId] == _owner) {
              result[resultIndex] = slotId;
              resultIndex++;
          }
      }

      return result;
    }
  }

  /**
   * Private Methods
   */

  function _createProperty(
    address _creator,
    string _description
  ) private returns (uint256) {

    Property memory _property = Property({
      creator: _creator,
      description: _description
    });

    // TODO LATER Ensure there are no duplicate properties created
    uint256 propertyId = properties.push(_property) - 1;
    emit PropertyCreated(propertyId, _creator, _description);
    propertyToCreator[propertyId] = _creator;

    return propertyId;
  }

  // Check if Property is available during time window specified by SponsorSlot
  function _isValidSponsorSlot(
    // address _creator,
    // string _propertyDescription,
    // uint32 _startTime,
    // uint32 _endTime
  ) private pure returns (bool) {

    // TODO
    // ensure start time is valid/ not duplicate
    // ensure duration time is valid/ not overlapping w others
    return true;
  }

  function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return (ownerOf(_tokenId) == _claimant);
  }

  function _approve(uint256 _tokenId, address _approved) internal {
    sponsorSlotIdToApproved[_tokenId] = _approved;
  }

  // TODO: for demo purposes, we may want to disable this check
  function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return sponsorSlotIdToApproved[_tokenId] == _claimant;
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
      // transfer ownership
      sponsorSlotToOwner[_tokenId] = _to;
      // decrement creator's SponsorSlot token count
      ownerToSponsorSlotCount[_from]--;

      if (_from != address(0)) {
        // increment sponsors' SponsorSlot token count
        ownerToSponsorSlotCount[_to]++;
        // clear previous ownership approval
        delete sponsorSlotIdToApproved[_tokenId];
        // map sponsor slot to sponsor
        sponsorSlotToSponsor[_tokenId] = _to;
      }
      // Emit the transfer event.
      emit Transfer(_from, _to, _tokenId);
  }

  /**
  * Withdraw from contract
  */

  // function withdraw() external onlyOwner {
  // }
}
