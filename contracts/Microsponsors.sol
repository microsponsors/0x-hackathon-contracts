pragma solidity ^0.4.18;

import "./ownable.sol";
import "./safemath.sol";
import "./erc721.sol";

contract Microsponsors is Ownable, ERC721 {

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  // TODO?:
  // 2. Declare using SafeMath16 for uint16

  /**
  * Events emitted in logs
  */
  event Clap(uint numClaps, address sponsor, address creator);
  event AdSlotRegistered();
  event AdPurchased();


  struct AdSlot {
    string adSlotId;
    uint32 startTime;
    uint32 endTime;
  }

  AdSlot[] public adSlots;

  mapping (uint => address) public AdSlotToSponsor;

  /**
  * Init contract
  */

  constructor() public {
    sponsorshipExchange = msg.sender;
  }

  /**
  * Primary public methods
  */

  function Clap() public payable {
    // TODO: enforce authorization per user
    // require(isAuthorized(msg.sender));
  }

  function createAdSlot() public {
    // TODO: enforce authorization per user
    // require(isAuthorized(msg.sender));
  }

  function purchaseAdSlot() public payable {
    // TODO: enforce authorization per user
    // require(isAuthorized(msg.sender));

    // ad slot is reserved by msg.sender for msg.value
  }


  /**
  * Withdraw transaction fees from contract
  */

  function withdraw() public onlyOwner {
    owner.transfer(this.balance);
  }
}
