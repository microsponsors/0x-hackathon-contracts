// Microsponsors.io - DEMO ONLY!
// This demo uses ERC721 NFTs as a marketplace for sponsorships of content creators.
// This is a rough draft for demo purposes only (not nearly production-ready!).

pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./Safemath.sol";
import "./ERC721.sol";


contract Microsponsors is Ownable, ERC721 {

  /**
  * Events emitted
  */
  event PropertyCreated(bytes32 propertyId, address creator, string property);
  event SponsorSlotMinted(bytes32 slotId, bytes32 propertyId, address creator, uint32 startTime, uint32 endTime, bool isPurchased);
  event SponsorSlotPurchased(bytes32 slotId, bytes32 propertyId, address creator, address sponsor);


  /**
   * Data types
   */

  // The Microsponsors ERC721 Token:
  // A SponsorSlot is a window of time during which a Property can be purchased by a sponsor
  struct SponsorSlot {
    bytes32 id; // token id that represents the SponsorSlot
    bytes32 propertyId; // maps to Property id
    address owner; // owner of slot; defaults to content creator when minted
    uint32 startTime; // timestamp for when sponsorship of a Property begins
    uint32 endTime; // max timestamp of sponsorship (when it ends)
    bool isPurchased; // defaults to false when minted
  }

  struct Property {
    bytes32 id;
    address creator; // the content creator who will be sponsored
    string property; // website or property that contains the SponsorSlot (ex: "microsponsors.io-banner-north")
  }

  SponsorSlot[] public sponsorSlots;
  Property[] public properties;
  mapping (bytes32 => address) public sponsorSlotToCreator;
  mapping (bytes32 => address) public sponsorSlotToSponsor;


  /**
  * Init contract
  */

  constructor() public {
  }


  /**
  * Primary public methods
  */

  /**
   * TODO: optimize minting process so that it does NOT cost content creators
   * any gas to mint a tokenized sponsor slot.
   * Can do this by reliably generating SponsorSlots with a formula
   * and minting (storing) in contract ONLY when the token is purchased
   */

  /**
   * Mint the new SponsorSlot NFT, assign its ownership to content creator
   * Which will then be transfered to the sponsor when they purchase it
   */
  function mintSponsorSlot(
    address _creator,
    string _property,
    uint32 _startTime
  ) public returns (bytes32) {

    // TODO LATER enforce authorization per user
    // require(isAuthorized(msg.sender));

    bytes32 _propertyId = _createProperty(_creator, _property);

    // TODO LATER duration is hard-coded to 10 min slots for demo purposes only;
    // these will obviously be longer/ more varied and schedule-able in production
    uint32 _duration = 10 minutes;
    uint32 _endTime = uint32(_startTime + _duration);
    bytes32 id = keccak256(abi.encodePacked(_creator, _propertyId, _startTime, _duration));

    require(_isValidSponsorSlot(_creator, _property, _startTime, _endTime));

    sponsorSlots.push(SponsorSlot(id, _propertyId, _creator, _startTime, _endTime, false));
    emit SponsorSlotMinted(id, _propertyId, _creator, _startTime, _endTime, false);

    sponsorSlotToCreator[id] = _creator;

    return id;
  }

  // function purchaseSponsorSlot() public payable {
    // TODO LATER enforce authorization per user
    // require(isAuthorized(msg.sender));
  // }


  /**
   * Private Methods
   */

  function _createProperty(
    address _creator,
    string _property
  ) private returns (bytes32) {

    // propertyId is a hash of _creator + _property, so we can enforce uniqueness
    bytes32 propertyId = keccak256(abi.encodePacked(_creator, _property));

    // Ensure there are no duplicate properties created:
    if (!properties[propertyId]) {
      properties.push(Property(propertyId, _creator, _property));
      emit PropertyCreated(propertyId, _creator, _property);
    }

    return propertyId;
  }

  // Check if Property is available during time window specified by SponsorSlot
  function _isValidSponsorSlot(
    address _creator,
    string _property,
    uint32 _startTime,
    uint32 _endTime
  ) private view returns (bool) {

    // TODO
    // ensure start time is valid/ not duplicate
    // ensure duration time is valid/ not overlapping w others
    return true;
  }


  /**
  * Withdraw from contract
  */

  // function withdraw() external onlyOwner {
  // }
}
