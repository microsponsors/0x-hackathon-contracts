pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./Safemath.sol";
import "./ERC721.sol";

contract Microsponsors is Ownable, ERC721 {

  // TODO
  // using SafeMath for uint256;
  // using SafeMath32 for uint64;
  // using SafeMath32 for uint32;

  /**
  * Events emitted in logs
  */
  // event Clap(uint numClaps, address sponsor, address creator);
  event SponsorSlotCreated(address creator, uint slotId);
  event SponsorSlotPurchased();

  struct SponsorSlot {
    uint256 slotId;
    string websiteOrProperty; // website or property that contains slot
    uint64 startTime; // timestamp for the block when ad begins
    uint64 endTime; // max timestamp for (when the ad ends)
    uint256 price; // in $
  }

  SponsorSlot[] public sponsorSlots;

  mapping (uint => address) public SponsorSlotToCreator;
  mapping (uint => address) public SponsorSlotToSponsor;

  /**
  * Init contract
  */

  constructor() public {
  }

  /**
  * Primary public methods
  */

  // function Clap() public payable {
    // TODO: enforce authorization per user
    // require(isAuthorized(msg.sender));
  // }

  function createSponsorSlot() public {
    // TODO: enforce authorization per user
    // require(isAuthorized(msg.sender));
  }

  function purchaseSponsorSlot() public payable {
    // TODO: enforce authorization per user
    // require(isAuthorized(msg.sender));

    // ad slot is reserved by msg.sender for msg.value
  }


  /**
  * Withdraw transaction fees from contract
  */

  function withdraw() public onlyOwner {
  }
}
