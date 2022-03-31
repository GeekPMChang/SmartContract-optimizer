{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": false,
      "runs": 200
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/ERC721.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC721.sol\";\nimport \"./IERC721Receiver.sol\";\nimport \"./extensions/IERC721Metadata.sol\";\nimport \"../../utils/Address.sol\";\nimport \"../../utils/Context.sol\";\nimport \"../../utils/Strings.sol\";\nimport \"../../utils/introspection/ERC165.sol\";\n\n/**\n * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including\n * the Metadata extension, but not including the Enumerable extension, which is available separately as\n * {ERC721Enumerable}.\n */\ncontract ERC721 is Context, ERC165, IERC721, IERC721Metadata {\n    using Address for address;\n    using Strings for uint256;\n\n    // Token name\n    string private _name;\n\n    // Token symbol\n    string private _symbol;\n\n    // Mapping from token ID to owner address\n    mapping(uint256 => address) private _owners;\n\n    // Mapping owner address to token count\n    mapping(address => uint256) private _balances;\n\n    // Mapping from token ID to approved address\n    mapping(uint256 => address) private _tokenApprovals;\n\n    // Mapping from owner to operator approvals\n    mapping(address => mapping(address => bool)) private _operatorApprovals;\n\n    /**\n     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {\n        return\n            interfaceId == type(IERC721).interfaceId ||\n            interfaceId == type(IERC721Metadata).interfaceId ||\n            super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev See {IERC721-balanceOf}.\n     */\n    function balanceOf(address owner) public view virtual override returns (uint256) {\n        require(owner != address(0), \"ERC721: balance query for the zero address\");\n        return _balances[owner];\n    }\n\n    /**\n     * @dev See {IERC721-ownerOf}.\n     */\n    function ownerOf(uint256 tokenId) public view virtual override returns (address) {\n        address owner = _owners[tokenId];\n        require(owner != address(0), \"ERC721: owner query for nonexistent token\");\n        return owner;\n    }\n\n    /**\n     * @dev See {IERC721Metadata-name}.\n     */\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev See {IERC721Metadata-symbol}.\n     */\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev See {IERC721Metadata-tokenURI}.\n     */\n    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {\n        require(_exists(tokenId), \"ERC721Metadata: URI query for nonexistent token\");\n\n        string memory baseURI = _baseURI();\n        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : \"\";\n    }\n\n    /**\n     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each\n     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty\n     * by default, can be overriden in child contracts.\n     */\n    function _baseURI() internal view virtual returns (string memory) {\n        return \"\";\n    }\n\n    /**\n     * @dev See {IERC721-approve}.\n     */\n    function approve(address to, uint256 tokenId) public virtual override {\n        address owner = ERC721.ownerOf(tokenId);\n        require(to != owner, \"ERC721: approval to current owner\");\n\n        require(\n            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),\n            \"ERC721: approve caller is not owner nor approved for all\"\n        );\n\n        _approve(to, tokenId);\n    }\n\n    /**\n     * @dev See {IERC721-getApproved}.\n     */\n    function getApproved(uint256 tokenId) public view virtual override returns (address) {\n        require(_exists(tokenId), \"ERC721: approved query for nonexistent token\");\n\n        return _tokenApprovals[tokenId];\n    }\n\n    /**\n     * @dev See {IERC721-setApprovalForAll}.\n     */\n    function setApprovalForAll(address operator, bool approved) public virtual override {\n        require(operator != _msgSender(), \"ERC721: approve to caller\");\n\n        _operatorApprovals[_msgSender()][operator] = approved;\n        emit ApprovalForAll(_msgSender(), operator, approved);\n    }\n\n    /**\n     * @dev See {IERC721-isApprovedForAll}.\n     */\n    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {\n        return _operatorApprovals[owner][operator];\n    }\n\n    /**\n     * @dev See {IERC721-transferFrom}.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) public virtual override {\n        //solhint-disable-next-line max-line-length\n        require(_isApprovedOrOwner(_msgSender(), tokenId), \"ERC721: transfer caller is not owner nor approved\");\n\n        _transfer(from, to, tokenId);\n    }\n\n    /**\n     * @dev See {IERC721-safeTransferFrom}.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) public virtual override {\n        safeTransferFrom(from, to, tokenId, \"\");\n    }\n\n    /**\n     * @dev See {IERC721-safeTransferFrom}.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) public virtual override {\n        require(_isApprovedOrOwner(_msgSender(), tokenId), \"ERC721: transfer caller is not owner nor approved\");\n        _safeTransfer(from, to, tokenId, _data);\n    }\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * `_data` is additional data, it has no specified format and it is sent in call to `to`.\n     *\n     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.\n     * implement alternative mechanisms to perform token transfer, such as signature-based.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _safeTransfer(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) internal virtual {\n        _transfer(from, to, tokenId);\n        require(_checkOnERC721Received(from, to, tokenId, _data), \"ERC721: transfer to non ERC721Receiver implementer\");\n    }\n\n    /**\n     * @dev Returns whether `tokenId` exists.\n     *\n     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.\n     *\n     * Tokens start existing when they are minted (`_mint`),\n     * and stop existing when they are burned (`_burn`).\n     */\n    function _exists(uint256 tokenId) internal view virtual returns (bool) {\n        return _owners[tokenId] != address(0);\n    }\n\n    /**\n     * @dev Returns whether `spender` is allowed to manage `tokenId`.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {\n        require(_exists(tokenId), \"ERC721: operator query for nonexistent token\");\n        address owner = ERC721.ownerOf(tokenId);\n        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));\n    }\n\n    /**\n     * @dev Safely mints `tokenId` and transfers it to `to`.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must not exist.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _safeMint(address to, uint256 tokenId) internal virtual {\n        _safeMint(to, tokenId, \"\");\n    }\n\n    /**\n     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is\n     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.\n     */\n    function _safeMint(\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) internal virtual {\n        _mint(to, tokenId);\n        require(\n            _checkOnERC721Received(address(0), to, tokenId, _data),\n            \"ERC721: transfer to non ERC721Receiver implementer\"\n        );\n    }\n\n    /**\n     * @dev Mints `tokenId` and transfers it to `to`.\n     *\n     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible\n     *\n     * Requirements:\n     *\n     * - `tokenId` must not exist.\n     * - `to` cannot be the zero address.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _mint(address to, uint256 tokenId) internal virtual {\n        require(to != address(0), \"ERC721: mint to the zero address\");\n        require(!_exists(tokenId), \"ERC721: token already minted\");\n\n        _beforeTokenTransfer(address(0), to, tokenId);\n\n        _balances[to] += 1;\n        _owners[tokenId] = to;\n\n        emit Transfer(address(0), to, tokenId);\n    }\n\n    /**\n     * @dev Destroys `tokenId`.\n     * The approval is cleared when the token is burned.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _burn(uint256 tokenId) internal virtual {\n        address owner = ERC721.ownerOf(tokenId);\n\n        _beforeTokenTransfer(owner, address(0), tokenId);\n\n        // Clear approvals\n        _approve(address(0), tokenId);\n\n        _balances[owner] -= 1;\n        delete _owners[tokenId];\n\n        emit Transfer(owner, address(0), tokenId);\n    }\n\n    /**\n     * @dev Transfers `tokenId` from `from` to `to`.\n     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _transfer(\n        address from,\n        address to,\n        uint256 tokenId\n    ) internal virtual {\n        require(ERC721.ownerOf(tokenId) == from, \"ERC721: transfer of token that is not own\");\n        require(to != address(0), \"ERC721: transfer to the zero address\");\n\n        _beforeTokenTransfer(from, to, tokenId);\n\n        // Clear approvals from the previous owner\n        _approve(address(0), tokenId);\n\n        _balances[from] -= 1;\n        _balances[to] += 1;\n        _owners[tokenId] = to;\n\n        emit Transfer(from, to, tokenId);\n    }\n\n    /**\n     * @dev Approve `to` to operate on `tokenId`\n     *\n     * Emits a {Approval} event.\n     */\n    function _approve(address to, uint256 tokenId) internal virtual {\n        _tokenApprovals[tokenId] = to;\n        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);\n    }\n\n    /**\n     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.\n     * The call is not executed if the target address is not a contract.\n     *\n     * @param from address representing the previous owner of the given token ID\n     * @param to target address that will receive the tokens\n     * @param tokenId uint256 ID of the token to be transferred\n     * @param _data bytes optional data to send along with the call\n     * @return bool whether the call correctly returned the expected magic value\n     */\n    function _checkOnERC721Received(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes memory _data\n    ) private returns (bool) {\n        if (to.isContract()) {\n            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {\n                return retval == IERC721Receiver.onERC721Received.selector;\n            } catch (bytes memory reason) {\n                if (reason.length == 0) {\n                    revert(\"ERC721: transfer to non ERC721Receiver implementer\");\n                } else {\n                    assembly {\n                        revert(add(32, reason), mload(reason))\n                    }\n                }\n            }\n        } else {\n            return true;\n        }\n    }\n\n    /**\n     * @dev Hook that is called before any token transfer. This includes minting\n     * and burning.\n     *\n     * Calling conditions:\n     *\n     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be\n     * transferred to `to`.\n     * - When `from` is zero, `tokenId` will be minted for `to`.\n     * - When `to` is zero, ``from``'s `tokenId` will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(\n        address from,\n        address to,\n        uint256 tokenId\n    ) internal virtual {}\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/IERC721.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../../utils/introspection/IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC721 compliant contract.\n */\ninterface IERC721 is IERC165 {\n    /**\n     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\n     */\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\n     */\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /**\n     * @dev Returns the number of tokens in ``owner``'s account.\n     */\n    function balanceOf(address owner) external view returns (uint256 balance);\n\n    /**\n     * @dev Returns the owner of the `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Transfers `tokenId` token from `from` to `to`.\n     *\n     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n     * The approval is cleared when the token is transferred.\n     *\n     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n     *\n     * Requirements:\n     *\n     * - The caller must own the token or be an approved operator.\n     * - `tokenId` must exist.\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address to, uint256 tokenId) external;\n\n    /**\n     * @dev Returns the account approved for `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function getApproved(uint256 tokenId) external view returns (address operator);\n\n    /**\n     * @dev Approve or remove `operator` as an operator for the caller.\n     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n     *\n     * Requirements:\n     *\n     * - The `operator` cannot be the caller.\n     *\n     * Emits an {ApprovalForAll} event.\n     */\n    function setApprovalForAll(address operator, bool _approved) external;\n\n    /**\n     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n     *\n     * See {setApprovalForAll}\n     */\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes calldata data\n    ) external;\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @title ERC721 token receiver interface\n * @dev Interface for any contract that wants to support safeTransfers\n * from ERC721 asset contracts.\n */\ninterface IERC721Receiver {\n    /**\n     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}\n     * by `operator` from `from`, this function is called.\n     *\n     * It must return its Solidity selector to confirm the token transfer.\n     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.\n     *\n     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.\n     */\n    function onERC721Received(\n        address operator,\n        address from,\n        uint256 tokenId,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC721.sol\";\n\n/**\n * @title ERC-721 Non-Fungible Token Standard, optional metadata extension\n * @dev See https://eips.ethereum.org/EIPS/eip-721\n */\ninterface IERC721Metadata is IERC721 {\n    /**\n     * @dev Returns the token collection name.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the token collection symbol.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.\n     */\n    function tokenURI(uint256 tokenId) external view returns (string memory);\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/ERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "contracts/ApeCoinNFT.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.7;\nimport \"@openzeppelin/contracts/token/ERC721/ERC721.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract ApeCoinNFT is ERC721, Ownable {\n    string private baseURI;\n    bool public hasMinted;\n\n    constructor(string memory name, string memory symbol)\n        ERC721(name, symbol)\n    {}\n\n    function _baseURI() internal view override returns (string memory) {\n        return baseURI;\n    }\n\n    function setBaseURI(string memory uri) external onlyOwner {\n        baseURI = uri;\n    }\n\n    function mintLogo() external onlyOwner {\n        require(!hasMinted, \"Logo already minted\"); \n        hasMinted = true;\n        _safeMint(msg.sender, 0);        \n    }\n}\n"
    }
  }
}}