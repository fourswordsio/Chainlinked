pragma solidity ^0.4.24;

import "chainlink/solidity/contracts/Chainlinked.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract MyContract is Chainlinked, Ownable {
  uint256 public currentPrice;

  event RequestFulfilled(
    bytes32 indexed requestId,
    uint256 indexed price
  );

  constructor() public Ownable() {}

  function publicSetLinkToken(address _link) public onlyOwner {
    setLinkToken(_link);
  }

  function publicSetOracle(address _oracle) public onlyOwner {
    setOracle(_oracle);
  }

  function requestEthereumPrice(bytes32 _jobId, string _currency) public onlyOwner returns (bytes32 requestId) {
    ChainlinkLib.Run memory run = newRun(_jobId, this, "fulfill(bytes32,uint256)");
    run.add("url", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD,EUR,JPY");
    string[] memory path = new string[](1);
    path[0] = _currency;
    run.addStringArray("path", path);
    run.addInt("times", 100);
    requestId = chainlinkRequest(run, LINK(1));
  }

  function cancelRequest(bytes32 _requestId) public onlyOwner {
    cancelChainlinkRequest(_requestId);
  }

  function fulfill(bytes32 _requestId, uint256 _price) public checkChainlinkFulfillment(_requestId) {
    emit RequestFulfilled(_requestId, _price);
    currentPrice = _price;
  }

  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkToken());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

}