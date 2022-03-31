{"Address.sol":{"content":"pragma solidity ^0.5.0;\n\n\n/**\n * Utility library of inline functions on addresses\n */\nlibrary Address {\n\n    /**\n     * Returns whether the target address is a contract\n     * @dev This function will return false if invoked during the constructor of a contract,\n     * as the code is not actually created until after the constructor finishes.\n     * @param account address of the account to check\n     * @return whether the target address is a contract\n     */\n    function isContract(address account) internal view returns (bool) {\n        uint256 size;\n        // XXX Currently there is no better way to check if there is a contract in an address\n        // than to check the size of the code at that address.\n        // See https://ethereum.stackexchange.com/a/14016/36603\n        // for more details about how this works.\n        // TODO Check this again before the Serenity release, because all addresses will be\n        // contracts then.\n        // solium-disable-next-line security/no-inline-assembly\n        assembly { size := extcodesize(account) }\n        return size \u003e 0;\n    }\n\n}"},"Common.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n    Note: Simple contract to use as base for const vals\n*/\ncontract CommonConstants {\n\n    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256(\"onERC1155Received(address,address,uint256,uint256,bytes)\"))\n    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256(\"onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)\"))\n}"},"ERC1155.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./SafeMath.sol\";\nimport \"./Address.sol\";\nimport \"./Common.sol\";\nimport \"./IERC1155TokenReceiver.sol\";\nimport \"./IERC1155.sol\";\n\n// A sample implementation of core ERC1155 function.\ncontract ERC1155 is IERC1155, ERC165, CommonConstants\n{\n    using SafeMath for uint256;\n    using Address for address;\n\n    // id =\u003e (owner =\u003e balance)\n    mapping (uint256 =\u003e mapping(address =\u003e uint256)) internal balances;\n\n    // owner =\u003e (operator =\u003e approved)\n    mapping (address =\u003e mapping(address =\u003e bool)) internal operatorApproval;\n\n/////////////////////////////////////////// ERC165 //////////////////////////////////////////////\n\n    /*\n        bytes4(keccak256(\u0027supportsInterface(bytes4)\u0027));\n    */\n    bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;\n\n    /*\n        bytes4(keccak256(\"safeTransferFrom(address,address,uint256,uint256,bytes)\")) ^\n        bytes4(keccak256(\"safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)\")) ^\n        bytes4(keccak256(\"balanceOf(address,uint256)\")) ^\n        bytes4(keccak256(\"balanceOfBatch(address[],uint256[])\")) ^\n        bytes4(keccak256(\"setApprovalForAll(address,bool)\")) ^\n        bytes4(keccak256(\"isApprovedForAll(address,address)\"));\n    */\n    bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;\n\n    function supportsInterface(bytes4 _interfaceId)\n    public\n    view\n    returns (bool) {\n         if (_interfaceId == INTERFACE_SIGNATURE_ERC165 ||\n             _interfaceId == INTERFACE_SIGNATURE_ERC1155) {\n            return true;\n         }\n\n         return false;\n    }\n\n/////////////////////////////////////////// ERC1155 //////////////////////////////////////////////\n\n    /**\n        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).\n        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see \"Approval\" section of the standard).\n        MUST revert if `_to` is the zero address.\n        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.\n        MUST revert on any other error.\n        MUST emit the `TransferSingle` event to reflect the balance change (see \"Safe Transfer Rules\" section of the standard).\n        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size \u003e 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see \"Safe Transfer Rules\" section of the standard).\n        @param _from    Source address\n        @param _to      Target address\n        @param _id      ID of the token type\n        @param _value   Transfer amount\n        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`\n    */\n    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {\n\n        require(_to != address(0x0), \"_to must be non-zero.\");\n        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, \"Need operator approval for 3rd party transfers.\");\n\n        // SafeMath will throw with insuficient funds _from\n        // or if _id is not valid (balance will be 0)\n        balances[_id][_from] = balances[_id][_from].sub(_value);\n        balances[_id][_to]   = _value.add(balances[_id][_to]);\n\n        // MUST emit event\n        emit TransferSingle(msg.sender, _from, _to, _id, _value);\n\n        // Now that the balance is updated and the event was emitted,\n        // call onERC1155Received if the destination is a contract.\n        if (_to.isContract()) {\n            _doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);\n        }\n    }\n\n    /**\n        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).\n        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see \"Approval\" section of the standard).\n        MUST revert if `_to` is the zero address.\n        MUST revert if length of `_ids` is not the same as length of `_values`.\n        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.\n        MUST revert on any other error.\n        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see \"Safe Transfer Rules\" section of the standard).\n        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).\n        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size \u003e 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see \"Safe Transfer Rules\" section of the standard).\n        @param _from    Source address\n        @param _to      Target address\n        @param _ids     IDs of each token type (order and length must match _values array)\n        @param _values  Transfer amounts per token type (order and length must match _ids array)\n        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`\n    */\n    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external {\n\n        // MUST Throw on errors\n        require(_to != address(0x0), \"destination address must be non-zero.\");\n        require(_ids.length == _values.length, \"_ids and _values array lenght must match.\");\n        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, \"Need operator approval for 3rd party transfers.\");\n\n        for (uint256 i = 0; i \u003c _ids.length; ++i) {\n            uint256 id = _ids[i];\n            uint256 value = _values[i];\n\n            // SafeMath will throw with insuficient funds _from\n            // or if _id is not valid (balance will be 0)\n            balances[id][_from] = balances[id][_from].sub(value);\n            balances[id][_to]   = value.add(balances[id][_to]);\n        }\n\n        // Note: instead of the below batch versions of event and acceptance check you MAY have emitted a TransferSingle\n        // event and a subsequent call to _doSafeTransferAcceptanceCheck in above loop for each balance change instead.\n        // Or emitted a TransferSingle event for each in the loop and then the single _doSafeBatchTransferAcceptanceCheck below.\n        // However it is implemented the balance changes and events MUST match when a check (i.e. calling an external contract) is done.\n\n        // MUST emit event\n        emit TransferBatch(msg.sender, _from, _to, _ids, _values);\n\n        // Now that the balances are updated and the events are emitted,\n        // call onERC1155BatchReceived if the destination is a contract.\n        if (_to.isContract()) {\n            _doSafeBatchTransferAcceptanceCheck(msg.sender, _from, _to, _ids, _values, _data);\n        }\n    }\n\n    /**\n        @notice Get the balance of an account\u0027s Tokens.\n        @param _owner  The address of the token holder\n        @param _id     ID of the Token\n        @return        The _owner\u0027s balance of the Token type requested\n     */\n    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {\n        // The balance of any account can be calculated from the Transfer events history.\n        // However, since we need to keep the balances to validate transfer request,\n        // there is no extra cost to also privide a querry function.\n        return balances[_id][_owner];\n    }\n\n\n    /**\n        @notice Get the balance of multiple account/token pairs\n        @param _owners The addresses of the token holders\n        @param _ids    ID of the Tokens\n        @return        The _owner\u0027s balance of the Token types requested (i.e. balance for each (owner, id) pair)\n     */\n    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {\n\n        require(_owners.length == _ids.length);\n\n        uint256[] memory balances_ = new uint256[](_owners.length);\n\n        for (uint256 i = 0; i \u003c _owners.length; ++i) {\n            balances_[i] = balances[_ids[i]][_owners[i]];\n        }\n\n        return balances_;\n    }\n\n    /**\n        @notice Enable or disable approval for a third party (\"operator\") to manage all of the caller\u0027s tokens.\n        @dev MUST emit the ApprovalForAll event on success.\n        @param _operator  Address to add to the set of authorized operators\n        @param _approved  True if the operator is approved, false to revoke approval\n    */\n    function setApprovalForAll(address _operator, bool _approved) external {\n        operatorApproval[msg.sender][_operator] = _approved;\n        emit ApprovalForAll(msg.sender, _operator, _approved);\n    }\n\n    /**\n        @notice Queries the approval status of an operator for a given owner.\n        @param _owner     The owner of the Tokens\n        @param _operator  Address of authorized operator\n        @return           True if the operator is approved, false if not\n    */\n    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {\n        return operatorApproval[_owner][_operator];\n    }\n\n/////////////////////////////////////////// Internal //////////////////////////////////////////////\n\n    function _doSafeTransferAcceptanceCheck(address _operator, address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) internal {\n\n        // If this was a hybrid standards solution you would have to check ERC165(_to).supportsInterface(0x4e2312e0) here but as this is a pure implementation of an ERC-1155 token set as recommended by\n        // the standard, it is not necessary. The below should revert in all failure cases i.e. _to isn\u0027t a receiver, or it is and either returns an unknown value or it reverts in the call to indicate non-acceptance.\n\n\n        // Note: if the below reverts in the onERC1155Received function of the _to address you will have an undefined revert reason returned rather than the one in the require test.\n        // If you want predictable revert reasons consider using low level _to.call() style instead so the revert does not bubble up and you can revert yourself on the ERC1155_ACCEPTED test.\n        require(ERC1155TokenReceiver(_to).onERC1155Received(_operator, _from, _id, _value, _data) == ERC1155_ACCEPTED, \"contract returned an unknown value from onERC1155Received\");\n    }\n\n    function _doSafeBatchTransferAcceptanceCheck(address _operator, address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) internal {\n\n        // If this was a hybrid standards solution you would have to check ERC165(_to).supportsInterface(0x4e2312e0) here but as this is a pure implementation of an ERC-1155 token set as recommended by\n        // the standard, it is not necessary. The below should revert in all failure cases i.e. _to isn\u0027t a receiver, or it is and either returns an unknown value or it reverts in the call to indicate non-acceptance.\n\n        // Note: if the below reverts in the onERC1155BatchReceived function of the _to address you will have an undefined revert reason returned rather than the one in the require test.\n        // If you want predictable revert reasons consider using low level _to.call() style instead so the revert does not bubble up and you can revert yourself on the ERC1155_BATCH_ACCEPTED test.\n        require(ERC1155TokenReceiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _values, _data) == ERC1155_BATCH_ACCEPTED, \"contract returned an unknown value from onERC1155BatchReceived\");\n    }\n}\n"},"ERC1155Mintable.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./ERC1155.sol\";\n\n/**\n    @dev Mintable form of ERC1155\n    Shows how easy it is to mint new items.\n*/\ncontract StarsExchange is ERC1155 {\n\n    bytes4 constant private INTERFACE_SIGNATURE_URI = 0x0e89341c;\n\n    // id =\u003e creators\n    mapping (uint256 =\u003e address) public creators;\n    \n    mapping (uint256 =\u003e uint256) public totalsupport;\n\n    // A nonce to ensure we have a unique id each time we mint.\n    uint256 public nonce;\n\n    modifier creatorOnly(uint256 _id) {\n        require(creators[_id] == msg.sender);\n        _;\n    }\n\n    function supportsInterface(bytes4 _interfaceId)\n    public\n    view\n    returns (bool) {\n        if (_interfaceId == INTERFACE_SIGNATURE_URI) {\n            return true;\n        } else {\n            return super.supportsInterface(_interfaceId);\n        }\n    }\n\n    // Creates a new token type and assings _initialSupply to minter\n    function create(uint256 _initialSupply, string calldata _uri) external returns(uint256 _id) {\n\n        _id = ++nonce;\n        creators[_id] = msg.sender;\n        balances[_id][msg.sender] = _initialSupply;\n\n        // Transfer event with mint semantic\n        emit TransferSingle(msg.sender, address(0x0), msg.sender, _id, _initialSupply);\n\n        if (bytes(_uri).length \u003e 0)\n            emit URI(_uri, _id);\n    }\n\n    // Batch mint tokens. Assign directly to _to[].\n    function mint(uint256 _id, address[] calldata _to, uint256[] calldata _quantities) external creatorOnly(_id) {\n        \n        for (uint256 i = 0; i \u003c _to.length; ++i) {\n            uint256 quantity = _quantities[i];\n            totalsupport[_id] = quantity.add(totalsupport[_id]);\n        }\n        \n        require(totalsupport[_id] \u003c= 360000, \"_to must be non-zero.\");\n        \n        for (uint256 i = 0; i \u003c _to.length; ++i) {\n\n            address to = _to[i];\n            uint256 quantity = _quantities[i];\n\n            // Grant the items to the caller\n            balances[_id][to] = quantity.add(balances[_id][to]);\n\n            // Emit the Transfer/Mint event.\n            // the 0x0 source address implies a mint\n            // It will also provide the circulating supply info.\n            emit TransferSingle(msg.sender, address(0x0), to, _id, quantity);\n\n            if (to.isContract()) {\n                _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, to, _id, quantity, \u0027\u0027);\n            }\n        }\n    }\n\n    function setURI(string calldata _uri, uint256 _id) external creatorOnly(_id) {\n        emit URI(_uri, _id);\n    }\n}"},"ERC165.sol":{"content":"pragma solidity ^0.5.0;\n\n\n/**\n * @title ERC165\n * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md\n */\ninterface ERC165 {\n\n    /**\n     * @notice Query if a contract implements an interface\n     * @param _interfaceId The interface identifier, as specified in ERC-165\n     * @dev Interface identification is specified in ERC-165. This function\n     * uses less than 30,000 gas.\n     */\n    function supportsInterface(bytes4 _interfaceId)\n    external\n    view\n    returns (bool);\n}"},"IERC1155.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./ERC165.sol\";\n\n/**\n    @title ERC-1155 Multi Token Standard\n    @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md\n    Note: The ERC-165 identifier for this interface is 0xd9b67a26.\n */\ninterface IERC1155 /* is ERC165 */ {\n    /**\n        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see \"Safe Transfer Rules\" section of the standard).\n        The `_operator` argument MUST be msg.sender.\n        The `_from` argument MUST be the address of the holder whose balance is decreased.\n        The `_to` argument MUST be the address of the recipient whose balance is increased.\n        The `_id` argument MUST be the token type being transferred.\n        The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.\n        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).\n        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).\n    */\n    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);\n\n    /**\n        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see \"Safe Transfer Rules\" section of the standard).\n        The `_operator` argument MUST be msg.sender.\n        The `_from` argument MUST be the address of the holder whose balance is decreased.\n        The `_to` argument MUST be the address of the recipient whose balance is increased.\n        The `_ids` argument MUST be the list of tokens being transferred.\n        The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.\n        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).\n        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).\n    */\n    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);\n\n    /**\n        @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absense of an event assumes disabled).\n    */\n    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);\n\n    /**\n        @dev MUST emit when the URI is updated for a token ID.\n        URIs are defined in RFC 3986.\n        The URI MUST point a JSON file that conforms to the \"ERC-1155 Metadata URI JSON Schema\".\n    */\n    event URI(string _value, uint256 indexed _id);\n\n    /**\n        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).\n        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see \"Approval\" section of the standard).\n        MUST revert if `_to` is the zero address.\n        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.\n        MUST revert on any other error.\n        MUST emit the `TransferSingle` event to reflect the balance change (see \"Safe Transfer Rules\" section of the standard).\n        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size \u003e 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see \"Safe Transfer Rules\" section of the standard).\n        @param _from    Source address\n        @param _to      Target address\n        @param _id      ID of the token type\n        @param _value   Transfer amount\n        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`\n    */\n    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;\n\n    /**\n        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).\n        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see \"Approval\" section of the standard).\n        MUST revert if `_to` is the zero address.\n        MUST revert if length of `_ids` is not the same as length of `_values`.\n        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.\n        MUST revert on any other error.\n        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see \"Safe Transfer Rules\" section of the standard).\n        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).\n        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size \u003e 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see \"Safe Transfer Rules\" section of the standard).\n        @param _from    Source address\n        @param _to      Target address\n        @param _ids     IDs of each token type (order and length must match _values array)\n        @param _values  Transfer amounts per token type (order and length must match _ids array)\n        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`\n    */\n    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;\n\n    /**\n        @notice Get the balance of an account\u0027s Tokens.\n        @param _owner  The address of the token holder\n        @param _id     ID of the Token\n        @return        The _owner\u0027s balance of the Token type requested\n     */\n    function balanceOf(address _owner, uint256 _id) external view returns (uint256);\n\n    /**\n        @notice Get the balance of multiple account/token pairs\n        @param _owners The addresses of the token holders\n        @param _ids    ID of the Tokens\n        @return        The _owner\u0027s balance of the Token types requested (i.e. balance for each (owner, id) pair)\n     */\n    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);\n\n    /**\n        @notice Enable or disable approval for a third party (\"operator\") to manage all of the caller\u0027s tokens.\n        @dev MUST emit the ApprovalForAll event on success.\n        @param _operator  Address to add to the set of authorized operators\n        @param _approved  True if the operator is approved, false to revoke approval\n    */\n    function setApprovalForAll(address _operator, bool _approved) external;\n\n    /**\n        @notice Queries the approval status of an operator for a given owner.\n        @param _owner     The owner of the Tokens\n        @param _operator  Address of authorized operator\n        @return           True if the operator is approved, false if not\n    */\n    function isApprovedForAll(address _owner, address _operator) external view returns (bool);\n}"},"IERC1155TokenReceiver.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n    Note: The ERC-165 identifier for this interface is 0x4e2312e0.\n*/\ninterface ERC1155TokenReceiver {\n    /**\n        @notice Handle the receipt of a single ERC1155 token type.\n        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.\n        This function MUST return `bytes4(keccak256(\"onERC1155Received(address,address,uint256,uint256,bytes)\"))` (i.e. 0xf23a6e61) if it accepts the transfer.\n        This function MUST revert if it rejects the transfer.\n        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.\n        @param _operator  The address which initiated the transfer (i.e. msg.sender)\n        @param _from      The address which previously owned the token\n        @param _id        The ID of the token being transferred\n        @param _value     The amount of tokens being transferred\n        @param _data      Additional data with no specified format\n        @return           `bytes4(keccak256(\"onERC1155Received(address,address,uint256,uint256,bytes)\"))`\n    */\n    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);\n\n    /**\n        @notice Handle the receipt of multiple ERC1155 token types.\n        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.\n        This function MUST return `bytes4(keccak256(\"onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)\"))` (i.e. 0xbc197c81) if it accepts the transfer(s).\n        This function MUST revert if it rejects the transfer(s).\n        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.\n        @param _operator  The address which initiated the batch transfer (i.e. msg.sender)\n        @param _from      The address which previously owned the token\n        @param _ids       An array containing ids of each token being transferred (order and length must match _values array)\n        @param _values    An array containing amounts of each token being transferred (order and length must match _ids array)\n        @param _data      Additional data with no specified format\n        @return           `bytes4(keccak256(\"onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)\"))`\n    */\n    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.5.0;\n\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\nlibrary SafeMath {\n\n    /**\n    * @dev Multiplies two numbers, throws on overflow.\n    */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\n        // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        c = a * b;\n        assert(c / a == b);\n        return c;\n    }\n\n    /**\n    * @dev Integer division of two numbers, truncating the quotient.\n    */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\n        // uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n        return a / b;\n    }\n\n    /**\n    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\n    */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        assert(b \u003c= a);\n        return a - b;\n    }\n\n    /**\n    * @dev Adds two numbers, throws on overflow.\n    */\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\n        c = a + b;\n        assert(c \u003e= a);\n        return c;\n    }\n}"}}