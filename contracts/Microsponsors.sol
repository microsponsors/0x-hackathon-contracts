/**
* Microsponsors.io ERC721 Contract - DEMO
* For 0x Hackathon -  Feb 2019
*
* NOTE:
* This is a very rough draft for demonstration purposes only.
*
* This demo uses ERC721 NFTs as a marketplace for sponsorship of content creators.
* Each token is a Non-Fungible Token (NFT) that represents a time window during
* which a content creators' property is available to rent by sponsors.
*
*/

pragma solidity ^0.4.24;

// TODO LATER:
// import "./Ownable.sol";

contract Microsponsors {

  string public constant name = "Microsponsors";
  string public constant symbol = "MSP";

  // TODO LATER duration is hard-coded to 24hr slots for demo purposes only;
  uint32 public constant duration = 24 hours;

  /**
  * Events emitted
  */
  event PropertyCreated(address owner, uint256 propertyId);
  event Transfer(address from, address to, uint256 tokenId);
  event Approval(address owner, address approved, uint256 tokenId);
  // TODO:
  // event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


  /**
   * Data
   */

  // The Microsponsors ERC721 Token:
  // A SponsorSlot is a window of time during which a Property can be
  // purchased by a sponsor
  struct SponsorSlot {
    uint256 propertyId; // the property that whose time slots are tokenized
    uint32 startTime; // timestamp for when sponsorship of a Property begins
    uint32 endTime; // max timestamp of sponsorship (when it ends)
  }

  struct Property {
    address owner; // content creators are the owners of properties
    string propertyName; // unique name of property (ex: 'microsponsors.io-banner-north')
  }

  SponsorSlot[] public sponsorSlots;
  Property[] public properties;

  mapping (uint256 => address) public sponsorSlotToOwner;
  mapping (address => uint256) public ownerToSponsorSlotCount;
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
   * TODO: Optimize minting process so that it does NOT cost content creators
   * extra gas to mint tokenized sponsor slot(s).
   * Can do this by reliably generating SponsorSlots with a formula
   * and minting (storing) in contract ONLY when the token is purchased,
   * so that gas fees are incurred by sponsor only when they buy it (and not
   * before).
   * -- h/t to FuelGames.io for the pointer
   */

  /**
   * Mint the new SponsorSlot token, assign its ownership to content creator
   * that is seeking sponsorship of token.
   * Token will then be transfered to the sponsor when they purchase it.
   *
   * TODO LATER: let anyone mint during demo, but production version should
   * restrict minting to msg.sender by removing _creator param and setting
   * SponsorSlot.owner to msg.sender.
   *
   * NOTE: The .mint() arguments used here are not standard, lets see if
   * 0x's Asset Buyer will accept it. --LG
   */
  function mint(
    address _creator,
    string _propertyName,
    uint32 _startTime
  ) public returns (uint256) {

    // TODO LATER enforce authorization per user onboarding:
    // require(isAuthorized(msg.sender));

    uint256 _propertyId = _createProperty(_creator, _propertyName);

    // TODO LATER can just hardcode to validate for demo
    // require(_isValidSponsorSlot(_creator, _propertyName, _startTime, _endTime));

    SponsorSlot memory _sponsorSlot = SponsorSlot({
      propertyId: uint256(_propertyId),
      startTime: uint32(_startTime),
      endTime: uint32(_startTime + duration)
    });

    uint256 tokenId = sponsorSlots.push(_sponsorSlot) - 1;
    sponsorSlotToOwner[tokenId] = _creator;
    ownerToSponsorSlotCount[_creator]++;
    emit Transfer(address(0), _creator, tokenId);

    return tokenId;
  }

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

  /** TODO
   * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721.sol
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param to operator address to set the approval
   * @param approved representing the status of the approval to be set
   */
  // function setApprovalForAll(address to, bool approved) public {
  //     require(to != msg.sender);
  //     _operatorApprovals[msg.sender][to] = approved;
  //     emit ApprovalForAll(msg.sender, to, approved);
  // }

  /** TODO
   * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721.sol
   * @dev Gets the approved address for a token ID, or zero if no address set
   * Reverts if the token ID does not exist.
   * @param tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  // function getApproved(uint256 tokenId) public view returns (address) {
      // require(_exists(tokenId));
      // return _tokenApprovals[tokenId];
  // }

  /** TODO
   * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721.sol
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg.sender to be the owner, approved, or operator
   * @param from current owner of the token
   * @param to address to receive the ownership of the given token ID
   * @param tokenId uint256 ID of the token to be transferred
   */
  // function safeTransferFrom(address from, address to, uint256 tokenId) public {
  //     safeTransferFrom(from, to, tokenId, "");
  // }

  /** TODO
   * @dev Tells whether an operator is approved by a given owner
   * @param owner owner address which you want to query the approval of
   * @param operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  // function isApprovedForAll(address owner, address operator) public view returns (bool) {
  //     return _operatorApprovals[owner][operator];
  // }

  /** TODO
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param tokenId uint256 ID of the token being burned
   */
  // function _burn(uint256 tokenId) internal {
  //     _burn(ownerOf(tokenId), tokenId);
  // }

  /** TODO
   * @dev Tells whether an operator is approved by a given owner
   * @param owner owner address which you want to query the approval of
   * @param operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  // function isApprovedForAll(address owner, address operator) public view returns (bool) {
  //     return _operatorApprovals[owner][operator];
  // }

  // TODO - ?
  // transferOwnership()
  // 0x Dummy ERC721 ABI specifies this function
  // Not sure if its really necessary:
  // https://github.com/0xProject/0x-monorepo/blob/development/python-packages/contract_artifacts/src/zero_ex/contract_artifacts/artifacts/DummyERC721Token.json


  /**
   * Private Methods
   */

  function _createProperty(address _creator, string _propertyName) private returns (uint256) {

    // TODO skip if property is already created
    // TODO LATER Ensure there are no duplicate properties created
    Property memory _newProp = Property({
      owner: _creator,
      propertyName: _propertyName
    });
    uint256 _propertyId = properties.push(_newProp) - 1;
    emit PropertyCreated(_creator, _propertyId);

    return _propertyId;
  }

  // Check if Property is available during time window specified by SponsorSlot
  function _isValidSponsorSlot(
    // address _creator,
    // string _propertyName,
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
      }
      // Emit the transfer event.
      emit Transfer(_from, _to, _tokenId);
  }

  /**
  * Withdraw from contract
  */

  // TODO LATER
  // function withdraw() external onlyOwner {
  // }

}
