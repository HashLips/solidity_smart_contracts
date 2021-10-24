// SPDX-License-Identifier: MIT

// Amended by HashLips
/**
    !Disclaimer!
    These contracts have been used to create tutorials,
    and was created for the purpose to teach people
    how to create smart contracts on the blockchain.
    please review this code on your own before using any of
    the following code for production.
    HashLips will not be liable in any way if for the use 
    of the code. That being said, the code has been tested 
    to the best of the developers' knowledge to work as intended.
*/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract PrettyAwesomeWords is ERC721Enumerable, Ownable {
  using Strings for uint256;
  
  string[] public wordsValues = ["accomplish","accepted","absolutely","admire","achievement","active","adorable","affirmative","appealing","approve","amazing","awesome","beautiful","believe","beneficial","bliss","brave","brilliant","calm","celebrated","champion","charming","congratulation","cool","courageous","creative","dazzling","delightful","divine","effortless","electrifying","elegant","enchanting","energetic","enthusiastic","excellent","exciting","exquisite","fabulous","fantastic","fine","fortunate","friendly","fun","funny","generous","giving","great","happy","harmonious","healthy","heavenly","honest","honorable","impressive","independent","innovative","intelligent","intuitive","kind","knowledgeable","legendary","lucky","lovely","marvelous","motivating","nice","perfect","phenomenal","popular","positive","productive","refreshing","remarkable","skillful","sparkling","stunning","successful","supporting","terrific","tranquil","trusting","vibrant","wholesome","worthy","wonderful"];
  
   struct Word { 
      string name;
      string description;
      string bgHue;
      string textHue;
      string value;
   }
  
  mapping (uint256 => Word) public words;
  
  constructor() ERC721("Pretty Awesome Words", "PWA") {}

  // public
  function mint() public payable {
    uint256 supply = totalSupply();
    require(supply + 1 <= 1000);
    
    Word memory newWord = Word(
        string(abi.encodePacked('PWA #', uint256(supply + 1).toString())), 
        "Pretty Awesome Words are all you need to feel good. These NFTs are there to inspire and uplift your spirit.",
        randomNum(361, block.difficulty, supply).toString(),
        randomNum(361, block.timestamp, supply).toString(),
        wordsValues[randomNum(wordsValues.length, block.difficulty, supply)]);
    
    if (msg.sender != owner()) {
      require(msg.value >= 0.005 ether);
    }
    
    words[supply + 1] = newWord;
    _safeMint(msg.sender, supply + 1);
  }

  function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }
  
  function buildImage(uint256 _tokenId) public view returns(string memory) {
      Word memory currentWord = words[_tokenId];
      return Base64.encode(bytes(
          abi.encodePacked(
              '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
              '<rect height="500" width="500" fill="hsl(',currentWord.bgHue,', 50%, 25%)"/>',
              '<text x="50%" y="50%" dominant-baseline="middle" fill="hsl(',currentWord.textHue,', 100%, 80%)" text-anchor="middle" font-size="41">',currentWord.value,'</text>',
              '</svg>'
          )
      ));
  }
  
  function buildMetadata(uint256 _tokenId) public view returns(string memory) {
      Word memory currentWord = words[_tokenId];
      return string(abi.encodePacked(
              'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                          '{"name":"', 
                          currentWord.name,
                          '", "description":"', 
                          currentWord.description,
                          '", "image": "', 
                          'data:image/svg+xml;base64,', 
                          buildImage(_tokenId),
                          '"}')))));
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
      require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
      return buildMetadata(_tokenId);
  }

  function withdraw() public payable onlyOwner {
    // This will pay HashLips 5% of the initial sale.
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 5 / 100}("");
    require(hs);
    // =============================================================================
    
    // This will payout the owner 95% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}
