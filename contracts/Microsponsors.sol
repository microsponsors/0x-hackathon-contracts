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
   * Data types
   */

  // The Microsponsors ERC721 Token:
  // A SponsorSlot is a window of time during which a Property can be purchased by a sponsor
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

  function ownerOf(uint256 _tokenId) external view returns (address owner) {
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

  function _owns(address _claimant, uint256 _tokenId) private pure returns (bool) {
    return ownerOf(_tokenId) == _claimant;
  }

  /**
  * Withdraw from contract
  */

  // function withdraw() external onlyOwner {
  // }
}
