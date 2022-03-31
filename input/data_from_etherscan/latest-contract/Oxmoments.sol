{{
  "language": "Solidity",
  "sources": {
    "0xmoments.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"ERC1155.sol\";\nimport \"Ownable.sol\";\n\n\ncontract Oxmoments is ERC1155, Ownable {\n    string private baseURLImage;\n    mapping(uint256 => string) private tokenToLocation;\n    mapping(uint256 => string) private tokenToName;\n    mapping(uint256 => string) private tokenToDescription;\n\n\n    constructor(string memory baseURLImageInput) public ERC1155(\"\") {\n        baseURLImage = baseURLImageInput;\n    }\n\n    function setBaseImageUrl(string memory baseURLImageInput) external onlyOwner {\n        baseURLImage = baseURLImageInput;\n    }\n\n    function setLocation(uint256 tokenId, string memory location) external onlyOwner {\n        tokenToLocation[tokenId] = string(abi.encodePacked(baseURLImage, location));\n    }  \n\n    function setDescription(uint256 tokenId, string memory description) external onlyOwner {\n        tokenToDescription[tokenId] = description;\n    } \n\n    function mint(uint256 tokenId, string memory name, uint256 quantity) external onlyOwner {\n        tokenToName[tokenId] = name;\n        _mint(msg.sender, tokenId, quantity, \"\");\n    }\n\n    function uri(uint256 tokenId) public view virtual override returns (string memory) {\n        string memory nameT = string(abi.encodePacked('{\"name\": \"', tokenToName[tokenId] , '\",'));\n        string memory imageLocation = string(abi.encodePacked('\"image\": \"', tokenToLocation[tokenId] , '\"}'));\n        string memory description = string(abi.encodePacked('\"description\": \"', tokenToDescription[tokenId] , '\",'));\n\n\n        return string(abi.encodePacked('data:application/json,', nameT, \n            description,\n            imageLocation));\n    }\n}\n"
    },
    "ERC1155.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC1155.sol\";\nimport \"IERC1155Receiver.sol\";\nimport \"IERC1155MetadataURI.sol\";\nimport \"Address.sol\";\nimport \"Context.sol\";\nimport \"ERC165.sol\";\n\n/**\n * @dev Implementation of the basic standard multi-token.\n * See https://eips.ethereum.org/EIPS/eip-1155\n * Originally based on code by Enjin: https://github.com/enjin/erc-1155\n *\n * _Available since v3.1._\n */\ncontract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {\n    using Address for address;\n\n    // Mapping from token ID to account balances\n    mapping(uint256 => mapping(address => uint256)) private _balances;\n\n    // Mapping from account to operator approvals\n    mapping(address => mapping(address => bool)) private _operatorApprovals;\n\n    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json\n    string private _uri;\n\n    /**\n     * @dev See {_setURI}.\n     */\n    constructor(string memory uri_) {\n        _setURI(uri_);\n    }\n\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {\n        return\n            interfaceId == type(IERC1155).interfaceId ||\n            interfaceId == type(IERC1155MetadataURI).interfaceId ||\n            super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev See {IERC1155MetadataURI-uri}.\n     *\n     * This implementation returns the same URI for *all* token types. It relies\n     * on the token type ID substitution mechanism\n     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].\n     *\n     * Clients calling this function must replace the `\\{id\\}` substring with the\n     * actual token type ID.\n     */\n    function uri(uint256) public view virtual override returns (string memory) {\n        return _uri;\n    }\n\n    /**\n     * @dev See {IERC1155-balanceOf}.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     */\n    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {\n        require(account != address(0), \"ERC1155: balance query for the zero address\");\n        return _balances[id][account];\n    }\n\n    /**\n     * @dev See {IERC1155-balanceOfBatch}.\n     *\n     * Requirements:\n     *\n     * - `accounts` and `ids` must have the same length.\n     */\n    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)\n        public\n        view\n        virtual\n        override\n        returns (uint256[] memory)\n    {\n        require(accounts.length == ids.length, \"ERC1155: accounts and ids length mismatch\");\n\n        uint256[] memory batchBalances = new uint256[](accounts.length);\n\n        for (uint256 i = 0; i < accounts.length; ++i) {\n            batchBalances[i] = balanceOf(accounts[i], ids[i]);\n        }\n\n        return batchBalances;\n    }\n\n    /**\n     * @dev See {IERC1155-setApprovalForAll}.\n     */\n    function setApprovalForAll(address operator, bool approved) public virtual override {\n        _setApprovalForAll(_msgSender(), operator, approved);\n    }\n\n    /**\n     * @dev See {IERC1155-isApprovedForAll}.\n     */\n    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {\n        return _operatorApprovals[account][operator];\n    }\n\n    /**\n     * @dev See {IERC1155-safeTransferFrom}.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes memory data\n    ) public virtual override {\n        require(\n            from == _msgSender() || isApprovedForAll(from, _msgSender()),\n            \"ERC1155: caller is not owner nor approved\"\n        );\n        _safeTransferFrom(from, to, id, amount, data);\n    }\n\n    /**\n     * @dev See {IERC1155-safeBatchTransferFrom}.\n     */\n    function safeBatchTransferFrom(\n        address from,\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) public virtual override {\n        require(\n            from == _msgSender() || isApprovedForAll(from, _msgSender()),\n            \"ERC1155: transfer caller is not owner nor approved\"\n        );\n        _safeBatchTransferFrom(from, to, ids, amounts, data);\n    }\n\n    /**\n     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.\n     *\n     * Emits a {TransferSingle} event.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - `from` must have a balance of tokens of type `id` of at least `amount`.\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the\n     * acceptance magic value.\n     */\n    function _safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes memory data\n    ) internal virtual {\n        require(to != address(0), \"ERC1155: transfer to the zero address\");\n\n        address operator = _msgSender();\n\n        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);\n\n        uint256 fromBalance = _balances[id][from];\n        require(fromBalance >= amount, \"ERC1155: insufficient balance for transfer\");\n        unchecked {\n            _balances[id][from] = fromBalance - amount;\n        }\n        _balances[id][to] += amount;\n\n        emit TransferSingle(operator, from, to, id, amount);\n\n        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);\n    }\n\n    /**\n     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.\n     *\n     * Emits a {TransferBatch} event.\n     *\n     * Requirements:\n     *\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the\n     * acceptance magic value.\n     */\n    function _safeBatchTransferFrom(\n        address from,\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) internal virtual {\n        require(ids.length == amounts.length, \"ERC1155: ids and amounts length mismatch\");\n        require(to != address(0), \"ERC1155: transfer to the zero address\");\n\n        address operator = _msgSender();\n\n        _beforeTokenTransfer(operator, from, to, ids, amounts, data);\n\n        for (uint256 i = 0; i < ids.length; ++i) {\n            uint256 id = ids[i];\n            uint256 amount = amounts[i];\n\n            uint256 fromBalance = _balances[id][from];\n            require(fromBalance >= amount, \"ERC1155: insufficient balance for transfer\");\n            unchecked {\n                _balances[id][from] = fromBalance - amount;\n            }\n            _balances[id][to] += amount;\n        }\n\n        emit TransferBatch(operator, from, to, ids, amounts);\n\n        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);\n    }\n\n    /**\n     * @dev Sets a new URI for all token types, by relying on the token type ID\n     * substitution mechanism\n     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].\n     *\n     * By this mechanism, any occurrence of the `\\{id\\}` substring in either the\n     * URI or any of the amounts in the JSON file at said URI will be replaced by\n     * clients with the token type ID.\n     *\n     * For example, the `https://token-cdn-domain/\\{id\\}.json` URI would be\n     * interpreted by clients as\n     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`\n     * for token type ID 0x4cce0.\n     *\n     * See {uri}.\n     *\n     * Because these URIs cannot be meaningfully represented by the {URI} event,\n     * this function emits no events.\n     */\n    function _setURI(string memory newuri) internal virtual {\n        _uri = newuri;\n    }\n\n    /**\n     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.\n     *\n     * Emits a {TransferSingle} event.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the\n     * acceptance magic value.\n     */\n    function _mint(\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes memory data\n    ) internal virtual {\n        require(to != address(0), \"ERC1155: mint to the zero address\");\n\n        address operator = _msgSender();\n\n        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);\n\n        _balances[id][to] += amount;\n        emit TransferSingle(operator, address(0), to, id, amount);\n\n        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);\n    }\n\n    /**\n     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.\n     *\n     * Requirements:\n     *\n     * - `ids` and `amounts` must have the same length.\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the\n     * acceptance magic value.\n     */\n    function _mintBatch(\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) internal virtual {\n        require(to != address(0), \"ERC1155: mint to the zero address\");\n        require(ids.length == amounts.length, \"ERC1155: ids and amounts length mismatch\");\n\n        address operator = _msgSender();\n\n        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);\n\n        for (uint256 i = 0; i < ids.length; i++) {\n            _balances[ids[i]][to] += amounts[i];\n        }\n\n        emit TransferBatch(operator, address(0), to, ids, amounts);\n\n        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens of token type `id` from `from`\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `from` must have at least `amount` tokens of token type `id`.\n     */\n    function _burn(\n        address from,\n        uint256 id,\n        uint256 amount\n    ) internal virtual {\n        require(from != address(0), \"ERC1155: burn from the zero address\");\n\n        address operator = _msgSender();\n\n        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), \"\");\n\n        uint256 fromBalance = _balances[id][from];\n        require(fromBalance >= amount, \"ERC1155: burn amount exceeds balance\");\n        unchecked {\n            _balances[id][from] = fromBalance - amount;\n        }\n\n        emit TransferSingle(operator, from, address(0), id, amount);\n    }\n\n    /**\n     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.\n     *\n     * Requirements:\n     *\n     * - `ids` and `amounts` must have the same length.\n     */\n    function _burnBatch(\n        address from,\n        uint256[] memory ids,\n        uint256[] memory amounts\n    ) internal virtual {\n        require(from != address(0), \"ERC1155: burn from the zero address\");\n        require(ids.length == amounts.length, \"ERC1155: ids and amounts length mismatch\");\n\n        address operator = _msgSender();\n\n        _beforeTokenTransfer(operator, from, address(0), ids, amounts, \"\");\n\n        for (uint256 i = 0; i < ids.length; i++) {\n            uint256 id = ids[i];\n            uint256 amount = amounts[i];\n\n            uint256 fromBalance = _balances[id][from];\n            require(fromBalance >= amount, \"ERC1155: burn amount exceeds balance\");\n            unchecked {\n                _balances[id][from] = fromBalance - amount;\n            }\n        }\n\n        emit TransferBatch(operator, from, address(0), ids, amounts);\n    }\n\n    /**\n     * @dev Approve `operator` to operate on all of `owner` tokens\n     *\n     * Emits a {ApprovalForAll} event.\n     */\n    function _setApprovalForAll(\n        address owner,\n        address operator,\n        bool approved\n    ) internal virtual {\n        require(owner != operator, \"ERC1155: setting approval status for self\");\n        _operatorApprovals[owner][operator] = approved;\n        emit ApprovalForAll(owner, operator, approved);\n    }\n\n    /**\n     * @dev Hook that is called before any token transfer. This includes minting\n     * and burning, as well as batched variants.\n     *\n     * The same hook is called on both single and batched variants. For single\n     * transfers, the length of the `id` and `amount` arrays will be 1.\n     *\n     * Calling conditions (for each `id` and `amount` pair):\n     *\n     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens\n     * of token type `id` will be  transferred to `to`.\n     * - When `from` is zero, `amount` tokens of token type `id` will be minted\n     * for `to`.\n     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`\n     * will be burned.\n     * - `from` and `to` are never both zero.\n     * - `ids` and `amounts` have the same, non-zero length.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(\n        address operator,\n        address from,\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) internal virtual {}\n\n    function _doSafeTransferAcceptanceCheck(\n        address operator,\n        address from,\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes memory data\n    ) private {\n        if (to.isContract()) {\n            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {\n                if (response != IERC1155Receiver.onERC1155Received.selector) {\n                    revert(\"ERC1155: ERC1155Receiver rejected tokens\");\n                }\n            } catch Error(string memory reason) {\n                revert(reason);\n            } catch {\n                revert(\"ERC1155: transfer to non ERC1155Receiver implementer\");\n            }\n        }\n    }\n\n    function _doSafeBatchTransferAcceptanceCheck(\n        address operator,\n        address from,\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) private {\n        if (to.isContract()) {\n            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (\n                bytes4 response\n            ) {\n                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {\n                    revert(\"ERC1155: ERC1155Receiver rejected tokens\");\n                }\n            } catch Error(string memory reason) {\n                revert(reason);\n            } catch {\n                revert(\"ERC1155: transfer to non ERC1155Receiver implementer\");\n            }\n        }\n    }\n\n    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {\n        uint256[] memory array = new uint256[](1);\n        array[0] = element;\n\n        return array;\n    }\n}\n"
    },
    "IERC1155.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC1155 compliant contract, as defined in the\n * https://eips.ethereum.org/EIPS/eip-1155[EIP].\n *\n * _Available since v3.1._\n */\ninterface IERC1155 is IERC165 {\n    /**\n     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.\n     */\n    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);\n\n    /**\n     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all\n     * transfers.\n     */\n    event TransferBatch(\n        address indexed operator,\n        address indexed from,\n        address indexed to,\n        uint256[] ids,\n        uint256[] values\n    );\n\n    /**\n     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to\n     * `approved`.\n     */\n    event ApprovalForAll(address indexed account, address indexed operator, bool approved);\n\n    /**\n     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.\n     *\n     * If an {URI} event was emitted for `id`, the standard\n     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value\n     * returned by {IERC1155MetadataURI-uri}.\n     */\n    event URI(string value, uint256 indexed id);\n\n    /**\n     * @dev Returns the amount of tokens of token type `id` owned by `account`.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     */\n    function balanceOf(address account, uint256 id) external view returns (uint256);\n\n    /**\n     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.\n     *\n     * Requirements:\n     *\n     * - `accounts` and `ids` must have the same length.\n     */\n    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)\n        external\n        view\n        returns (uint256[] memory);\n\n    /**\n     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,\n     *\n     * Emits an {ApprovalForAll} event.\n     *\n     * Requirements:\n     *\n     * - `operator` cannot be the caller.\n     */\n    function setApprovalForAll(address operator, bool approved) external;\n\n    /**\n     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.\n     *\n     * See {setApprovalForAll}.\n     */\n    function isApprovedForAll(address account, address operator) external view returns (bool);\n\n    /**\n     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.\n     *\n     * Emits a {TransferSingle} event.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.\n     * - `from` must have a balance of tokens of type `id` of at least `amount`.\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the\n     * acceptance magic value.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes calldata data\n    ) external;\n\n    /**\n     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.\n     *\n     * Emits a {TransferBatch} event.\n     *\n     * Requirements:\n     *\n     * - `ids` and `amounts` must have the same length.\n     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the\n     * acceptance magic value.\n     */\n    function safeBatchTransferFrom(\n        address from,\n        address to,\n        uint256[] calldata ids,\n        uint256[] calldata amounts,\n        bytes calldata data\n    ) external;\n}\n"
    },
    "IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "IERC1155Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC165.sol\";\n\n/**\n * @dev _Available since v3.1._\n */\ninterface IERC1155Receiver is IERC165 {\n    /**\n        @dev Handles the receipt of a single ERC1155 token type. This function is\n        called at the end of a `safeTransferFrom` after the balance has been updated.\n        To accept the transfer, this must return\n        `bytes4(keccak256(\"onERC1155Received(address,address,uint256,uint256,bytes)\"))`\n        (i.e. 0xf23a6e61, or its own function selector).\n        @param operator The address which initiated the transfer (i.e. msg.sender)\n        @param from The address which previously owned the token\n        @param id The ID of the token being transferred\n        @param value The amount of tokens being transferred\n        @param data Additional data with no specified format\n        @return `bytes4(keccak256(\"onERC1155Received(address,address,uint256,uint256,bytes)\"))` if transfer is allowed\n    */\n    function onERC1155Received(\n        address operator,\n        address from,\n        uint256 id,\n        uint256 value,\n        bytes calldata data\n    ) external returns (bytes4);\n\n    /**\n        @dev Handles the receipt of a multiple ERC1155 token types. This function\n        is called at the end of a `safeBatchTransferFrom` after the balances have\n        been updated. To accept the transfer(s), this must return\n        `bytes4(keccak256(\"onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)\"))`\n        (i.e. 0xbc197c81, or its own function selector).\n        @param operator The address which initiated the batch transfer (i.e. msg.sender)\n        @param from The address which previously owned the token\n        @param ids An array containing ids of each token being transferred (order and length must match values array)\n        @param values An array containing amounts of each token being transferred (order and length must match ids array)\n        @param data Additional data with no specified format\n        @return `bytes4(keccak256(\"onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)\"))` if transfer is allowed\n    */\n    function onERC1155BatchReceived(\n        address operator,\n        address from,\n        uint256[] calldata ids,\n        uint256[] calldata values,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n"
    },
    "IERC1155MetadataURI.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC1155.sol\";\n\n/**\n * @dev Interface of the optional ERC1155MetadataExtension interface, as defined\n * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].\n *\n * _Available since v3.1._\n */\ninterface IERC1155MetadataURI is IERC1155 {\n    /**\n     * @dev Returns the URI for token type `id`.\n     *\n     * If the `\\{id\\}` substring is present in the URI, it must be replaced by\n     * clients with the actual token type ID.\n     */\n    function uri(uint256 id) external view returns (string memory);\n}\n"
    },
    "Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "ERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "0xmoments.sol": {}
    },
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
  }
}}