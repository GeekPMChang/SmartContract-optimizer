{"Address.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\n/**\n * Utility library of inline functions on addresses\n */\nlibrary Address {\n    /**\n     * Returns whether the target address is a contract\n     * @dev This function will return false if invoked during the constructor of a contract,\n     * as the code is not actually created until after the constructor finishes.\n     * @param account address of the account to check\n     * @return whether the target address is a contract\n     */\n    function isContract(address account) internal view returns (bool) {\n        uint256 size;\n        // XXX Currently there is no better way to check if there is a contract in an address\n        // than to check the size of the code at that address.\n        // See https://ethereum.stackexchange.com/a/14016/36603\n        // for more details about how this works.\n        // TODO Check this again before the Serenity release, because all addresses will be\n        // contracts then.\n        // solhint-disable-next-line no-inline-assembly\n        assembly { size := extcodesize(account) }\n        return size \u003e 0;\n    }\n}\n"},"Counters.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\nimport \"./SafeMath.sol\";\n\n/**\n * @title Counters\n * @author Matt Condon (@shrugs)\n * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number\n * of elements in a mapping, issuing ERC721 ids, or counting request ids\n *\n * Include with `using Counters for Counters.Counter;`\n * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath\n * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never\n * directly accessed.\n */\nlibrary Counters {\n    using SafeMath for uint256;\n\n    struct Counter {\n        // This variable should never be directly accessed by users of the library: interactions must be restricted to\n        // the library\u0027s function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add\n        // this feature: see https://github.com/ethereum/solidity/issues/4637\n        uint256 _value; // default: 0\n    }\n\n    function current(Counter storage counter) internal view returns (uint256) {\n        return counter._value;\n    }\n\n    function increment(Counter storage counter) internal {\n        counter._value += 1;\n    }\n\n    function decrement(Counter storage counter) internal {\n        counter._value = counter._value.sub(1);\n    }\n}\n"},"ERC165.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @title ERC165\n * @author Matt Condon (@shrugs)\n * @dev Implements ERC165 using a lookup table.\n */\ncontract ERC165 is IERC165 {\n    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;\n    /*\n     * 0x01ffc9a7 ===\n     *     bytes4(keccak256(\u0027supportsInterface(bytes4)\u0027))\n     */\n\n    /**\n     * @dev a mapping of interface id to whether or not it\u0027s supported\n     */\n    mapping(bytes4 =\u003e bool) private _supportedInterfaces;\n\n    /**\n     * @dev A contract implementing SupportsInterfaceWithLookup\n     * implement ERC165 itself\n     */\n    constructor () internal {\n        _registerInterface(_INTERFACE_ID_ERC165);\n    }\n\n    /**\n     * @dev implement supportsInterface(bytes4) using a lookup table\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool) {\n        return _supportedInterfaces[interfaceId];\n    }\n\n    /**\n     * @dev internal method for registering an interface\n     */\n    function _registerInterface(bytes4 interfaceId) internal {\n        require(interfaceId != 0xffffffff);\n        _supportedInterfaces[interfaceId] = true;\n    }\n}\n"},"ERC721.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\nimport \"./IERC721.sol\";\nimport \"./IERC721Receiver.sol\";\nimport \"./SafeMath.sol\";\nimport \"./Address.sol\";\nimport \"./Counters.sol\";\nimport \"./ERC165.sol\";\n\n/**\n * @title ERC721 Non-Fungible Token Standard basic implementation\n * @dev see https://eips.ethereum.org/EIPS/eip-721\n */\ncontract ERC721 is ERC165, IERC721 {\n    using SafeMath for uint256;\n    using Address for address;\n    using Counters for Counters.Counter;\n\n    // Equals to `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`\n    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`\n    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;\n\n    // Mapping from token ID to owner\n    mapping (uint256 =\u003e address) private _tokenOwner;\n\n    // Mapping from token ID to approved address\n    mapping (uint256 =\u003e address) private _tokenApprovals;\n\n    // Mapping from owner to number of owned token\n    mapping (address =\u003e Counters.Counter) private _ownedTokensCount;\n\n    // Mapping from owner to operator approvals\n    mapping (address =\u003e mapping (address =\u003e bool)) private _operatorApprovals;\n\n    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;\n    /*\n     * 0x80ac58cd ===\n     *     bytes4(keccak256(\u0027balanceOf(address)\u0027)) ^\n     *     bytes4(keccak256(\u0027ownerOf(uint256)\u0027)) ^\n     *     bytes4(keccak256(\u0027approve(address,uint256)\u0027)) ^\n     *     bytes4(keccak256(\u0027getApproved(uint256)\u0027)) ^\n     *     bytes4(keccak256(\u0027setApprovalForAll(address,bool)\u0027)) ^\n     *     bytes4(keccak256(\u0027isApprovedForAll(address,address)\u0027)) ^\n     *     bytes4(keccak256(\u0027transferFrom(address,address,uint256)\u0027)) ^\n     *     bytes4(keccak256(\u0027safeTransferFrom(address,address,uint256)\u0027)) ^\n     *     bytes4(keccak256(\u0027safeTransferFrom(address,address,uint256,bytes)\u0027))\n     */\n\n    constructor () public {\n        // register the supported interfaces to conform to ERC721 via ERC165\n        _registerInterface(_INTERFACE_ID_ERC721);\n    }\n\n    /**\n     * @dev Gets the balance of the specified address\n     * @param owner address to query the balance of\n     * @return uint256 representing the amount owned by the passed address\n     */\n    function balanceOf(address owner) public view returns (uint256) {\n        require(owner != address(0));\n        return _ownedTokensCount[owner].current();\n    }\n\n    /**\n     * @dev Gets the owner of the specified token ID\n     * @param tokenId uint256 ID of the token to query the owner of\n     * @return address currently marked as the owner of the given token ID\n     */\n    function ownerOf(uint256 tokenId) public view returns (address) {\n        address owner = _tokenOwner[tokenId];\n        require(owner != address(0));\n        return owner;\n    }\n\n    /**\n     * @dev Approves another address to transfer the given token ID\n     * The zero address indicates there is no approved address.\n     * There can only be one approved address per token at a given time.\n     * Can only be called by the token owner or an approved operator.\n     * @param to address to be approved for the given token ID\n     * @param tokenId uint256 ID of the token to be approved\n     */\n    function approve(address to, uint256 tokenId) public {\n        address owner = ownerOf(tokenId);\n        require(to != owner);\n        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));\n\n        _tokenApprovals[tokenId] = to;\n        emit Approval(owner, to, tokenId);\n    }\n\n    /**\n     * @dev Gets the approved address for a token ID, or zero if no address set\n     * Reverts if the token ID does not exist.\n     * @param tokenId uint256 ID of the token to query the approval of\n     * @return address currently approved for the given token ID\n     */\n    function getApproved(uint256 tokenId) public view returns (address) {\n        require(_exists(tokenId));\n        return _tokenApprovals[tokenId];\n    }\n\n    /**\n     * @dev Sets or unsets the approval of a given operator\n     * An operator is allowed to transfer all tokens of the sender on their behalf\n     * @param to operator address to set the approval\n     * @param approved representing the status of the approval to be set\n     */\n    function setApprovalForAll(address to, bool approved) public {\n        require(to != msg.sender);\n        _operatorApprovals[msg.sender][to] = approved;\n        emit ApprovalForAll(msg.sender, to, approved);\n    }\n\n    /**\n     * @dev Tells whether an operator is approved by a given owner\n     * @param owner owner address which you want to query the approval of\n     * @param operator operator address which you want to query the approval of\n     * @return bool whether the given operator is approved by the given owner\n     */\n    function isApprovedForAll(address owner, address operator) public view returns (bool) {\n        return _operatorApprovals[owner][operator];\n    }\n\n    /**\n     * @dev Transfers the ownership of a given token ID to another address\n     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible\n     * Requires the msg.sender to be the owner, approved, or operator\n     * @param from current owner of the token\n     * @param to address to receive the ownership of the given token ID\n     * @param tokenId uint256 ID of the token to be transferred\n     */\n    function transferFrom(address from, address to, uint256 tokenId) public {\n        require(_isApprovedOrOwner(msg.sender, tokenId));\n\n        _transferFrom(from, to, tokenId);\n    }\n\n    /**\n     * @dev Safely transfers the ownership of a given token ID to another address\n     * If the target address is a contract, it must implement `onERC721Received`,\n     * which is called upon a safe transfer, and return the magic value\n     * `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`; otherwise,\n     * the transfer is reverted.\n     * Requires the msg.sender to be the owner, approved, or operator\n     * @param from current owner of the token\n     * @param to address to receive the ownership of the given token ID\n     * @param tokenId uint256 ID of the token to be transferred\n     */\n    function safeTransferFrom(address from, address to, uint256 tokenId) public {\n        safeTransferFrom(from, to, tokenId, \"\");\n    }\n\n    /**\n     * @dev Safely transfers the ownership of a given token ID to another address\n     * If the target address is a contract, it must implement `onERC721Received`,\n     * which is called upon a safe transfer, and return the magic value\n     * `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`; otherwise,\n     * the transfer is reverted.\n     * Requires the msg.sender to be the owner, approved, or operator\n     * @param from current owner of the token\n     * @param to address to receive the ownership of the given token ID\n     * @param tokenId uint256 ID of the token to be transferred\n     * @param _data bytes data to send along with a safe transfer check\n     */\n    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {\n        transferFrom(from, to, tokenId);\n        require(_checkOnERC721Received(from, to, tokenId, _data));\n    }\n\n    /**\n     * @dev Returns whether the specified token exists\n     * @param tokenId uint256 ID of the token to query the existence of\n     * @return bool whether the token exists\n     */\n    function _exists(uint256 tokenId) internal view returns (bool) {\n        address owner = _tokenOwner[tokenId];\n        return owner != address(0);\n    }\n\n    /**\n     * @dev Returns whether the given spender can transfer a given token ID\n     * @param spender address of the spender to query\n     * @param tokenId uint256 ID of the token to be transferred\n     * @return bool whether the msg.sender is approved for the given token ID,\n     * is an operator of the owner, or is the owner of the token\n     */\n    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {\n        address owner = ownerOf(tokenId);\n        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));\n    }\n\n    /**\n     * @dev Internal function to mint a new token\n     * Reverts if the given token ID already exists\n     * @param to The address that will own the minted token\n     * @param tokenId uint256 ID of the token to be minted\n     */\n    function _mint(address to, uint256 tokenId) internal {\n        require(to != address(0));\n        require(!_exists(tokenId));\n\n        _tokenOwner[tokenId] = to;\n        _ownedTokensCount[to].increment();\n\n        emit Transfer(address(0), to, tokenId);\n    }\n\n    /**\n     * @dev Internal function to burn a specific token\n     * Reverts if the token does not exist\n     * Deprecated, use _burn(uint256) instead.\n     * @param owner owner of the token to burn\n     * @param tokenId uint256 ID of the token being burned\n     */\n    function _burn(address owner, uint256 tokenId) internal {\n        require(ownerOf(tokenId) == owner);\n\n        _clearApproval(tokenId);\n\n        _ownedTokensCount[owner].decrement();\n        _tokenOwner[tokenId] = address(0);\n\n        emit Transfer(owner, address(0), tokenId);\n    }\n\n    /**\n     * @dev Internal function to burn a specific token\n     * Reverts if the token does not exist\n     * @param tokenId uint256 ID of the token being burned\n     */\n    function _burn(uint256 tokenId) internal {\n        _burn(ownerOf(tokenId), tokenId);\n    }\n\n    /**\n     * @dev Internal function to transfer ownership of a given token ID to another address.\n     * As opposed to transferFrom, this imposes no restrictions on msg.sender.\n     * @param from current owner of the token\n     * @param to address to receive the ownership of the given token ID\n     * @param tokenId uint256 ID of the token to be transferred\n     */\n    function _transferFrom(address from, address to, uint256 tokenId) internal {\n        require(ownerOf(tokenId) == from);\n        require(to != address(0));\n\n        _clearApproval(tokenId);\n\n        _ownedTokensCount[from].decrement();\n        _ownedTokensCount[to].increment();\n\n        _tokenOwner[tokenId] = to;\n\n        emit Transfer(from, to, tokenId);\n    }\n\n    /**\n     * @dev Internal function to invoke `onERC721Received` on a target address\n     * The call is not executed if the target address is not a contract\n     * @param from address representing the previous owner of the given token ID\n     * @param to target address that will receive the tokens\n     * @param tokenId uint256 ID of the token to be transferred\n     * @param _data bytes optional data to send along with the call\n     * @return bool whether the call correctly returned the expected magic value\n     */\n    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)\n        internal returns (bool)\n    {\n        if (!to.isContract()) {\n            return true;\n        }\n\n        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);\n        return (retval == _ERC721_RECEIVED);\n    }\n\n    /**\n     * @dev Private function to clear current approval of a given token ID\n     * @param tokenId uint256 ID of the token to be transferred\n     */\n    function _clearApproval(uint256 tokenId) private {\n        if (_tokenApprovals[tokenId] != address(0)) {\n            _tokenApprovals[tokenId] = address(0);\n        }\n    }\n}\n"},"ERC721Enumerable.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\nimport \"./IERC721Enumerable.sol\";\nimport \"./ERC721.sol\";\nimport \"./ERC165.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token with optional enumeration extension logic\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ncontract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {\n    // Mapping from owner to list of owned token IDs\n    mapping(address =\u003e uint256[]) private _ownedTokens;\n\n    // Mapping from token ID to index of the owner tokens list\n    mapping(uint256 =\u003e uint256) private _ownedTokensIndex;\n\n    // Array with all token ids, used for enumeration\n    uint256[] private _allTokens;\n\n    // Mapping from token id to position in the allTokens array\n    mapping(uint256 =\u003e uint256) private _allTokensIndex;\n\n    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;\n    /*\n     * 0x780e9d63 ===\n     *     bytes4(keccak256(\u0027totalSupply()\u0027)) ^\n     *     bytes4(keccak256(\u0027tokenOfOwnerByIndex(address,uint256)\u0027)) ^\n     *     bytes4(keccak256(\u0027tokenByIndex(uint256)\u0027))\n     */\n\n    /**\n     * @dev Constructor function\n     */\n    constructor () public {\n        // register the supported interface to conform to ERC721Enumerable via ERC165\n        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);\n    }\n\n    /**\n     * @dev Gets the token ID at a given index of the tokens list of the requested owner\n     * @param owner address owning the tokens list to be accessed\n     * @param index uint256 representing the index to be accessed of the requested tokens list\n     * @return uint256 token ID at the given index of the tokens list owned by the requested address\n     */\n    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {\n        require(index \u003c balanceOf(owner), \u0027Owner does not own\u0027);\n        return _ownedTokens[owner][index];\n    }\n\n    /**\n     * @dev Gets the total amount of tokens stored by the contract\n     * @return uint256 representing the total amount of tokens\n     */\n    function totalSupply() public view returns (uint256) {\n        return _allTokens.length;\n    }\n\n    /**\n     * @dev Gets the token ID at a given index of all the tokens in this contract\n     * Reverts if the index is greater or equal to the total number of tokens\n     * @param index uint256 representing the index to be accessed of the tokens list\n     * @return uint256 token ID at the given index of the tokens list\n     */\n    function tokenByIndex(uint256 index) public view returns (uint256) {\n        require(index \u003c totalSupply(), \u0027Index out of range\u0027);\n        return _allTokens[index];\n    }\n\n    /**\n     * @dev Internal function to transfer ownership of a given token ID to another address.\n     * As opposed to transferFrom, this imposes no restrictions on msg.sender.\n     * @param from current owner of the token\n     * @param to address to receive the ownership of the given token ID\n     * @param tokenId uint256 ID of the token to be transferred\n     */\n    function _transferFrom(address from, address to, uint256 tokenId) internal {\n        super._transferFrom(from, to, tokenId);\n\n        _removeTokenFromOwnerEnumeration(from, tokenId);\n\n        _addTokenToOwnerEnumeration(to, tokenId);\n    }\n\n    /**\n     * @dev Internal function to mint a new token\n     * Reverts if the given token ID already exists\n     * @param to address the beneficiary that will own the minted token\n     * @param tokenId uint256 ID of the token to be minted\n     */\n    function _mint(address to, uint256 tokenId) internal {\n        super._mint(to, tokenId);\n\n        _addTokenToOwnerEnumeration(to, tokenId);\n\n        _addTokenToAllTokensEnumeration(tokenId);\n    }\n\n    /**\n     * @dev Internal function to burn a specific token\n     * Reverts if the token does not exist\n     * Deprecated, use _burn(uint256) instead\n     * @param owner owner of the token to burn\n     * @param tokenId uint256 ID of the token being burned\n     */\n    function _burn(address owner, uint256 tokenId) internal {\n        super._burn(owner, tokenId);\n\n        _removeTokenFromOwnerEnumeration(owner, tokenId);\n        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund\n        _ownedTokensIndex[tokenId] = 0;\n\n        _removeTokenFromAllTokensEnumeration(tokenId);\n    }\n\n    /**\n     * @dev Gets the list of token IDs of the requested owner\n     * @param owner address owning the tokens\n     * @return uint256[] List of token IDs owned by the requested address\n     */\n    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {\n        return _ownedTokens[owner];\n    }\n\n    /**\n     * @dev Private function to add a token to this extension\u0027s ownership-tracking data structures.\n     * @param to address representing the new owner of the given token ID\n     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address\n     */\n    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {\n        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;\n        _ownedTokens[to].push(tokenId);\n    }\n\n    /**\n     * @dev Private function to add a token to this extension\u0027s token tracking data structures.\n     * @param tokenId uint256 ID of the token to be added to the tokens list\n     */\n    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {\n        _allTokensIndex[tokenId] = _allTokens.length;\n        _allTokens.push(tokenId);\n    }\n\n    /**\n     * @dev Private function to remove a token from this extension\u0027s ownership-tracking data structures. Note that\n     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for\n     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).\n     * This has O(1) time complexity, but alters the order of the _ownedTokens array.\n     * @param from address representing the previous owner of the given token ID\n     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address\n     */\n    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {\n        // To prevent a gap in from\u0027s tokens array, we store the last token in the index of the token to delete, and\n        // then delete the last slot (swap and pop).\n\n        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);\n        uint256 tokenIndex = _ownedTokensIndex[tokenId];\n\n        // When the token to delete is the last token, the swap operation is unnecessary\n        if (tokenIndex != lastTokenIndex) {\n            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];\n\n            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token\n            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token\u0027s index\n        }\n\n        // This also deletes the contents at the last position of the array\n        _ownedTokens[from].length--;\n\n        // Note that _ownedTokensIndex[tokenId] hasn\u0027t been cleared: it still points to the old slot (now occupied by\n        // lastTokenId, or just over the end of the array if the token was the last one).\n    }\n\n    /**\n     * @dev Private function to remove a token from this extension\u0027s token tracking data structures.\n     * This has O(1) time complexity, but alters the order of the _allTokens array.\n     * @param tokenId uint256 ID of the token to be removed from the tokens list\n     */\n    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {\n        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and\n        // then delete the last slot (swap and pop).\n\n        uint256 lastTokenIndex = _allTokens.length.sub(1);\n        uint256 tokenIndex = _allTokensIndex[tokenId];\n\n        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so\n        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding\n        // an \u0027if\u0027 statement (like in _removeTokenFromOwnerEnumeration)\n        uint256 lastTokenId = _allTokens[lastTokenIndex];\n\n        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token\n        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token\u0027s index\n\n        // This also deletes the contents at the last position of the array\n        _allTokens.length--;\n        _allTokensIndex[tokenId] = 0;\n    }\n}\n"},"IERC165.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\n/**\n * @title IERC165\n * @dev https://eips.ethereum.org/EIPS/eip-165\n */\ninterface IERC165 {\n    /**\n     * @notice Query if a contract implements an interface\n     * @param interfaceId The interface identifier, as specified in ERC-165\n     * @dev Interface identification is specified in ERC-165. This function\n     * uses less than 30,000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"},"IERC721.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @title ERC721 Non-Fungible Token Standard basic interface\n * @dev see https://eips.ethereum.org/EIPS/eip-721\n */\ncontract IERC721 is IERC165 {\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    function balanceOf(address owner) public view returns (uint256 balance);\n    function ownerOf(uint256 tokenId) public view returns (address owner);\n\n    function approve(address to, uint256 tokenId) public;\n    function getApproved(uint256 tokenId) public view returns (address operator);\n\n    function setApprovalForAll(address operator, bool _approved) public;\n    function isApprovedForAll(address owner, address operator) public view returns (bool);\n\n    function transferFrom(address from, address to, uint256 tokenId) public;\n    function safeTransferFrom(address from, address to, uint256 tokenId) public;\n\n    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;\n}\n"},"IERC721Enumerable.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\nimport \"./IERC721.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ncontract IERC721Enumerable is IERC721 {\n    function totalSupply() public view returns (uint256);\n    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);\n\n    function tokenByIndex(uint256 index) public view returns (uint256);\n}\n"},"IERC721Receiver.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\n/**\n * @title ERC721 token receiver interface\n * @dev Interface for any contract that wants to support safeTransfers\n * from ERC721 asset contracts.\n */\ncontract IERC721Receiver {\n    /**\n     * @notice Handle the receipt of an NFT\n     * @dev The ERC721 smart contract calls this function on the recipient\n     * after a `safeTransfer`. This function MUST return the function selector,\n     * otherwise the caller will revert the transaction. The selector to be\n     * returned can be obtained as `this.onERC721Received.selector`. This\n     * function MAY throw to revert and reject the transfer.\n     * Note: the ERC721 contract address is always the message sender.\n     * @param operator The address which called `safeTransferFrom` function\n     * @param from The address which previously owned the token\n     * @param tokenId The NFT identifier which is being transferred\n     * @param data Additional data with no specified format\n     * @return bytes4 `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`\n     */\n    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)\n    public returns (bytes4);\n}\n"},"Migrations.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\ncontract Migrations {\n  address public owner;\n  uint public last_completed_migration;\n\n  constructor() public {\n    owner = msg.sender;\n  }\n\n  modifier restricted() {\n    if (msg.sender == owner) _;\n  }\n\n  function setCompleted(uint completed) public restricted {\n    last_completed_migration = completed;\n  }\n\n  function upgrade(address new_address) public restricted {\n    Migrations upgraded = Migrations(new_address);\n    upgraded.setCompleted(last_completed_migration);\n  }\n}\n"},"MinterRole.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\nimport \"./Roles.sol\";\n\ncontract MinterRole {\n    using Roles for Roles.Role;\n\n    event MinterAdded(address indexed account);\n    event MinterRemoved(address indexed account);\n\n    Roles.Role private _minters;\n\n    constructor () internal {\n        _addMinter(msg.sender);\n    }\n\n    modifier onlyMinter() {\n        require(isMinter(msg.sender), \u0027Only minter can mint\u0027);\n        _;\n    }\n\n    function isMinter(address account) public view returns (bool) {\n        return _minters.has(account);\n    }\n\n    function addMinter(address account) public onlyMinter {\n        _addMinter(account);\n    }\n\n    function renounceMinter() public {\n        _removeMinter(msg.sender);\n    }\n\n    function _addMinter(address account) internal {\n        _minters.add(account);\n        emit MinterAdded(account);\n    }\n\n    function _removeMinter(address account) internal {\n        _minters.remove(account);\n        emit MinterRemoved(account);\n    }\n}\n"},"Roles.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\n/**\n * @title Roles\n * @dev Library for managing addresses assigned to a Role.\n */\nlibrary Roles {\n    struct Role {\n        mapping (address =\u003e bool) bearer;\n    }\n\n    /**\n     * @dev give an account access to this role\n     */\n    function add(Role storage role, address account) internal {\n        require(account != address(0));\n        require(!has(role, account));\n\n        role.bearer[account] = true;\n    }\n\n    /**\n     * @dev remove an account\u0027s access to this role\n     */\n    function remove(Role storage role, address account) internal {\n        require(account != address(0));\n        require(has(role, account));\n\n        role.bearer[account] = false;\n    }\n\n    /**\n     * @dev check if an account has this role\n     * @return bool\n     */\n    function has(Role storage role, address account) internal view returns (bool) {\n        require(account != address(0));\n        return role.bearer[account];\n    }\n}\n"},"SafeMath.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\n\n/**\n * @title SafeMath\n * @dev Unsigned math operations with safety checks that revert on error\n */\nlibrary SafeMath {\n    /**\n     * @dev Multiplies two unsigned integers, reverts on overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b);\n\n        return c;\n    }\n\n    /**\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Adds two unsigned integers, reverts on overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a);\n\n        return c;\n    }\n\n    /**\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\n     * reverts when dividing by zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0);\n        return a % b;\n    }\n}\n"},"XYProducts721.sol":{"content":"pragma solidity \u003e=0.5.0 \u003c0.6.0;\nimport \"./ERC721Enumerable.sol\";\nimport \"./MinterRole.sol\";\n\n\n/**\n * @title A 721 Token Contract - A non-fungible token contract\n * @dev Basic version of ERC721Token.\n */\ncontract XYProducts721 is ERC721Enumerable, MinterRole {\n    // Token name\n    string private _name;\n\n    // Token symbol\n    string private _symbol;\n\n    // Mapping from product ID to list of owned token IDs\n\n    event TokenMinted(address beneficiary, uint tokenType, uint index, uint tokenId);\n\n    mapping(uint =\u003e uint) public tokenTypeSupply;\n    mapping(uint =\u003e uint[]) public tokensByType;\n    mapping(uint =\u003e uint) public tokenType;\n    mapping(uint =\u003e uint) public tokenIndexInTypeArray;\n    uint[] public tokenTypes;\n\n    /**\n     * @dev Constructor function\n     */\n    constructor (\n      string memory name,\n      string memory symbol,\n      uint[] memory types,\n      uint[] memory supplies\n    )\n        public\n        ERC721Enumerable()\n        MinterRole()\n      {\n        _name = name;\n        _symbol = symbol;\n        tokenTypes = types;\n        for (uint i = 0; i \u003c types.length; i++) {\n          tokenTypeSupply[types[i]] = supplies[i];\n        }\n    }\n\n    /**\n     * @dev Gets the token name\n     * @return string representing the token name\n     */\n    function name() external view returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Gets the token symbol\n     * @return string representing the token symbol\n     */\n    function symbol() external view returns (string memory) {\n        return _symbol;\n    }\n\n    function numTokensByOwner(address owner) public view returns (uint) {\n      return _tokensOfOwner(owner).length;\n    }\n    function numTokensByType(uint tType) public view returns (uint) {\n      return tokensByType[tType].length;\n    }\n\n    function getTokenId(uint tType, uint index) public pure returns (uint) {\n      return uint(keccak256(abi.encode(tType, index)));\n    }\n\n    function batchMint(\n      address[] memory beneficiaries,\n      uint[] memory types\n    ) public returns (uint[] memory) {\n      uint[] memory tokens = new uint[](beneficiaries.length);\n      for (uint i = 0; i \u003c beneficiaries.length; i++) {\n        uint tokenId = mint(beneficiaries[i], types[i]);\n        tokens[i] = tokenId;\n      }\n      return tokens;\n    }\n\n    function batchMintAllTypes(\n      address[] memory beneficiaries\n    ) public returns (uint[] memory) {\n      uint[] memory tokens = new uint[](beneficiaries.length*tokenTypes.length);\n      uint index = 0;\n      for (uint i = 0; i \u003c beneficiaries.length; i++) {\n        for (uint j = 0; j \u003c tokenTypes.length; j++) {\n          uint tokenId = mint(beneficiaries[i], tokenTypes[j]);\n          tokens[index] = tokenId;\n          index++;\n        }\n      }\n      return tokens;\n    }\n\n    /*\n      Let\u0027s at least allow some minting of tokens!\n      @param beneficiary - who should receive it\n      @param tokenId - the id of the 721 token\n    */\n    function mint\n    (\n        address beneficiary,\n        uint tType\n    )\n      public\n      onlyMinter()\n      returns (uint tokenId)\n    {\n      uint index = tokensByType[tType].length;\n      require (index \u003c tokenTypeSupply[tType], \"Token supply limit reached\");\n      tokenId = getTokenId(tType, index);\n      tokensByType[tType].push(tokenId);\n      tokenType[tokenId] = tType;\n      tokenIndexInTypeArray[tokenId] = index;\n      \n      _mint(beneficiary, tokenId);\n      emit TokenMinted(beneficiary, tType, index, tokenId);\n    }\n    \n}"}}