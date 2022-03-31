{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"CryptoCollegeCohort2.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity 0.8.11;\n\nerror NoEthBalance();\n\nimport {Ownable} from \"./Ownable.sol\";\nimport {SafeTransferLib} from \"./SafeTransferLib.sol\";\n\nimport {ERC1155} from \"./ERC1155.sol\";\n\n/// @title CryptoCollegeCohort2\n/// @author Julian \u003cjulian@latecheckout.studio\u003e\ncontract CryptoCollegeCohort2 is ERC1155, Ownable {\n    /*///////////////////////////////////////////////////////////////\n                            TOKEN METADATA\n    //////////////////////////////////////////////////////////////*/\n    string public name;\n    string public symbol;\n    address public vaultAddress;\n\n    /*///////////////////////////////////////////////////////////////\n                            TOKEN DATA\n    //////////////////////////////////////////////////////////////*/\n    uint256 public immutable blackMaxSupply = 166;\n    uint256 public immutable generalMaxSupply = 330;\n    uint256 public immutable blackScholarshipTotal = 17;\n    uint256 public immutable generalScholarshipTotal = 33;\n\n    uint256 public immutable blackPrice = 0.75 ether;\n    uint256 public immutable generalPrice = 0.15 ether;\n\n    uint256 public immutable blackTokenId = 1;\n    uint256 public immutable generalTokenId = 2;\n\n    bool public hasSaleStarted = false;\n\n    /*///////////////////////////////////////////////////////////////\n                            STORAGE\n    //////////////////////////////////////////////////////////////*/\n    mapping(uint256 =\u003e uint256) private _totalSupply;\n    mapping(uint256 =\u003e string) public tokenURI;\n    mapping(address =\u003e uint256) public generalMinted;\n    mapping(address =\u003e uint256) public blackMinted;\n\n    /*///////////////////////////////////////////////////////////////\n                            CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n    constructor(\n        string memory _name,\n        string memory _symbol,\n        address _vaultAddress,\n        string memory _blackTokenUri,\n        string memory _generalTokenUri\n    ) {\n        name = _name;\n        symbol = _symbol;\n        vaultAddress = _vaultAddress;\n        tokenURI[generalTokenId] = _generalTokenUri;\n        tokenURI[blackTokenId] = _blackTokenUri;\n    }\n\n    /// @notice totalSupply of a token ID\n    /// @param id is the ID, either generalTokenId or blackTokenId\n    function totalSupply(uint256 id) public view virtual returns (uint256) {\n        return _totalSupply[id];\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                            public mint\n    //////////////////////////////////////////////////////////////*/\n    /// @notice function to mint the black version of the token. can only mint 1 per transaction.\n    function mintBlack() external payable {\n        require(hasSaleStarted, \"CCC2: Sale not started yet.\");\n        require(\n            1 + totalSupply(blackTokenId) \u003c=\n                blackMaxSupply - blackScholarshipTotal,\n            \"CCC2: Black membership sold out.\"\n        );\n        require(blackMinted[msg.sender] \u003c 5, \"CCC2: you can only mint 5.\");\n        require(msg.value == blackPrice, \"CCC2: Wrong ether value.\");\n\n        _mint(msg.sender, blackTokenId, 1, \"\");\n\n        unchecked {\n            blackMinted[msg.sender]++;\n        }\n    }\n\n    /// @notice function to mint the general version of the token. can only mint 1 per transaction.\n    function mintGeneral() external payable {\n        require(hasSaleStarted, \"CCC2: Sale not started yet.\");\n        require(\n            1 + totalSupply(generalTokenId) \u003c=\n                generalMaxSupply - generalScholarshipTotal,\n            \"CCC2: General membership sold out.\"\n        );\n        require(generalMinted[msg.sender] \u003c 5, \"CCC2: You can only mint 5.\");\n        require(msg.value == generalPrice, \"CCC2: Wrong ether value.\");\n\n        _mint(msg.sender, generalTokenId, 1, \"\");\n\n        unchecked {\n            generalMinted[msg.sender]++;\n        }\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                        ownerOnly FUNCTIONS\n    //////////////////////////////////////////////////////////////*/\n\n    /// @notice function to toggle sale state\n    function startSale() external onlyOwner {\n        hasSaleStarted = true;\n    }\n\n    function pauseSale() external onlyOwner {\n        hasSaleStarted = false;\n    }\n\n    /// @notice function to change the tokenURI\n    /// @param _newTokenURI this is the new token uri\n    /// @param tokenId this is the token ID that will be set\n    function setTokenURI(string memory _newTokenURI, uint256 tokenId)\n        external\n        onlyOwner\n    {\n        tokenURI[tokenId] = _newTokenURI;\n    }\n\n    /// @notice function for owner to mint (LC)\n    /// @param to address to mint it to.\n    function mintScholarship(address to) external onlyOwner {\n        // mint black\n        _mint(to, blackTokenId, blackScholarshipTotal, \"\");\n        // mint general\n        _mint(to, generalTokenId, generalScholarshipTotal, \"\");\n    }\n\n    /// @notice function for owner to mint the token,\n    /// just in case it\u0027s needed, mintScholarship() will be used to mint all the scholarships\n    /// @param to address to mint it to.\n    /// @param amount the amount that the owner wants to mint.\n    /// @param tokenId which token ID 1 for black 2 for general\n    function ownerMint(\n        address to,\n        uint256 amount,\n        uint256 tokenId\n    ) external onlyOwner {\n        require(\n            tokenId == generalTokenId || tokenId == blackTokenId,\n            \"CCC2: Nonexistent token ID.\"\n        );\n\n        if (tokenId == generalTokenId) {\n            require(\n                amount + totalSupply(generalTokenId) \u003c= generalMaxSupply,\n                \"CCC2: Amount is larger than totalSupply.\"\n            );\n            _mint(to, tokenId, amount, \"\");\n        } else {\n            require(\n                amount + totalSupply(blackTokenId) \u003c= blackMaxSupply,\n                \"CCC2: Amount is larger than totalSupply.\"\n            );\n            _mint(to, tokenId, amount, \"\");\n        }\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                            ETH WITHDRAWAL\n    //////////////////////////////////////////////////////////////*/\n\n    /// @notice Withdraw all ETH from the contract to the vault addres.\n    function withdraw() external onlyOwner {\n        if (address(this).balance == 0) revert NoEthBalance();\n        SafeTransferLib.safeTransferETH(vaultAddress, address(this).balance);\n    }\n\n    /// @notice changing vault address\n    /// @param _vaultAddress is the new vaultAddress\n    function setVault(address _vaultAddress) external onlyOwner {\n        vaultAddress = _vaultAddress;\n    }\n\n    /// @notice returns the token URI\n    /// @param tokenId which token ID to return 1 or 2.\n    function uri(uint256 tokenId)\n        public\n        view\n        virtual\n        override\n        returns (string memory)\n    {\n        if (bytes(tokenURI[tokenId]).length == 0) {\n            return \"\";\n        }\n\n        return tokenURI[tokenId];\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                    OVERRIDE INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n    // override _mint to increase total supply of a token\n    function _mint(\n        address account,\n        uint256 id,\n        uint256 amount,\n        bytes memory data\n    ) internal virtual override {\n        super._mint(account, id, amount, data);\n\n        // Cannot overflow because the sum of all user\n        // balances can\u0027t exceed the max uint256 value.\n        unchecked {\n            _totalSupply[id] += amount;\n        }\n    }\n\n    function _batchMint(\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) internal virtual override {\n        super._batchMint(to, ids, amounts, data);\n\n        for (uint256 i = 0; i \u003c ids.length; ++i) {\n            _totalSupply[ids[i]] += amounts[i];\n        }\n    }\n\n    function _burn(\n        address account,\n        uint256 id,\n        uint256 amount\n    ) internal virtual override {\n        super._burn(account, id, amount);\n\n        // Cannot underflow because a user\u0027s balance\n        // will never be larger than the total supply.\n        unchecked {\n            _totalSupply[id] -= amount;\n        }\n    }\n\n    function _batchBurn(\n        address account,\n        uint256[] memory ids,\n        uint256[] memory amounts\n    ) internal virtual override {\n        super._batchBurn(account, ids, amounts);\n\n        for (uint256 i = 0; i \u003c ids.length; ++i) {\n            _totalSupply[ids[i]] -= amounts[i];\n        }\n    }\n}\n"},"ERC1155.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity \u003e=0.8.0;\n\n/// @notice Minimalist and gas efficient standard ERC1155 implementation.\n/// @author Modified from Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC1155.sol)\nabstract contract ERC1155 {\n    /*///////////////////////////////////////////////////////////////\n                                EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event TransferSingle(\n        address indexed operator,\n        address indexed from,\n        address indexed to,\n        uint256 id,\n        uint256 amount\n    );\n\n    event TransferBatch(\n        address indexed operator,\n        address indexed from,\n        address indexed to,\n        uint256[] ids,\n        uint256[] amounts\n    );\n\n    event ApprovalForAll(\n        address indexed owner,\n        address indexed operator,\n        bool approved\n    );\n\n    event URI(string value, uint256 indexed id);\n\n    /*///////////////////////////////////////////////////////////////\n                            ERC1155 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    mapping(address =\u003e mapping(uint256 =\u003e uint256)) public balanceOf;\n\n    mapping(address =\u003e mapping(address =\u003e bool)) public isApprovedForAll;\n\n    /*///////////////////////////////////////////////////////////////\n                             METADATA LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function uri(uint256 id) public view virtual returns (string memory);\n\n    /*///////////////////////////////////////////////////////////////\n                             ERC1155 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function setApprovalForAll(address operator, bool approved) public virtual {\n        isApprovedForAll[msg.sender][operator] = approved;\n\n        emit ApprovalForAll(msg.sender, operator, approved);\n    }\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes memory data\n    ) public virtual {\n        require(\n            msg.sender == from || isApprovedForAll[from][msg.sender],\n            \"NOT_AUTHORIZED\"\n        );\n\n        balanceOf[from][id] -= amount;\n        balanceOf[to][id] += amount;\n\n        emit TransferSingle(msg.sender, from, to, id, amount);\n\n        require(\n            to.code.length == 0\n                ? to != address(0)\n                : ERC1155TokenReceiver(to).onERC1155Received(\n                    msg.sender,\n                    from,\n                    id,\n                    amount,\n                    data\n                ) == ERC1155TokenReceiver.onERC1155Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function safeBatchTransferFrom(\n        address from,\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) public virtual {\n        uint256 idsLength = ids.length; // Saves MLOADs.\n\n        require(idsLength == amounts.length, \"LENGTH_MISMATCH\");\n\n        require(\n            msg.sender == from || isApprovedForAll[from][msg.sender],\n            \"NOT_AUTHORIZED\"\n        );\n\n        for (uint256 i = 0; i \u003c idsLength; ) {\n            uint256 id = ids[i];\n            uint256 amount = amounts[i];\n\n            balanceOf[from][id] -= amount;\n            balanceOf[to][id] += amount;\n\n            // An array can\u0027t have a total length\n            // larger than the max uint256 value.\n            unchecked {\n                i++;\n            }\n        }\n\n        emit TransferBatch(msg.sender, from, to, ids, amounts);\n\n        require(\n            to.code.length == 0\n                ? to != address(0)\n                : ERC1155TokenReceiver(to).onERC1155BatchReceived(\n                    msg.sender,\n                    from,\n                    ids,\n                    amounts,\n                    data\n                ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function balanceOfBatch(address[] memory owners, uint256[] memory ids)\n        public\n        view\n        virtual\n        returns (uint256[] memory balances)\n    {\n        uint256 ownersLength = owners.length; // Saves MLOADs.\n\n        require(ownersLength == ids.length, \"LENGTH_MISMATCH\");\n\n        balances = new uint256[](owners.length);\n\n        // Unchecked because the only math done is incrementing\n        // the array index counter which cannot possibly overflow.\n        unchecked {\n            for (uint256 i = 0; i \u003c ownersLength; i++) {\n                balances[i] = balanceOf[owners[i]][ids[i]];\n            }\n        }\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC165 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function supportsInterface(bytes4 interfaceId)\n        public\n        pure\n        virtual\n        returns (bool)\n    {\n        return\n            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165\n            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155\n            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                        INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes memory data\n    ) internal virtual {\n        balanceOf[to][id] += amount;\n\n        emit TransferSingle(msg.sender, address(0), to, id, amount);\n\n        require(\n            to.code.length == 0\n                ? to != address(0)\n                : ERC1155TokenReceiver(to).onERC1155Received(\n                    msg.sender,\n                    address(0),\n                    id,\n                    amount,\n                    data\n                ) == ERC1155TokenReceiver.onERC1155Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function _batchMint(\n        address to,\n        uint256[] memory ids,\n        uint256[] memory amounts,\n        bytes memory data\n    ) internal virtual {\n        uint256 idsLength = ids.length; // Saves MLOADs.\n\n        require(idsLength == amounts.length, \"LENGTH_MISMATCH\");\n\n        for (uint256 i = 0; i \u003c idsLength; ) {\n            balanceOf[to][ids[i]] += amounts[i];\n\n            // An array can\u0027t have a total length\n            // larger than the max uint256 value.\n            unchecked {\n                i++;\n            }\n        }\n\n        emit TransferBatch(msg.sender, address(0), to, ids, amounts);\n\n        require(\n            to.code.length == 0\n                ? to != address(0)\n                : ERC1155TokenReceiver(to).onERC1155BatchReceived(\n                    msg.sender,\n                    address(0),\n                    ids,\n                    amounts,\n                    data\n                ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function _batchBurn(\n        address from,\n        uint256[] memory ids,\n        uint256[] memory amounts\n    ) internal virtual {\n        uint256 idsLength = ids.length; // Saves MLOADs.\n\n        require(idsLength == amounts.length, \"LENGTH_MISMATCH\");\n\n        for (uint256 i = 0; i \u003c idsLength; ) {\n            balanceOf[from][ids[i]] -= amounts[i];\n\n            // An array can\u0027t have a total length\n            // larger than the max uint256 value.\n            unchecked {\n                i++;\n            }\n        }\n\n        emit TransferBatch(msg.sender, from, address(0), ids, amounts);\n    }\n\n    function _burn(\n        address from,\n        uint256 id,\n        uint256 amount\n    ) internal virtual {\n        balanceOf[from][id] -= amount;\n\n        emit TransferSingle(msg.sender, from, address(0), id, amount);\n    }\n}\n\n/// @notice A generic interface for a contract which properly accepts ERC1155 tokens.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC1155.sol)\ninterface ERC1155TokenReceiver {\n    function onERC1155Received(\n        address operator,\n        address from,\n        uint256 id,\n        uint256 amount,\n        bytes calldata data\n    ) external returns (bytes4);\n\n    function onERC1155BatchReceived(\n        address operator,\n        address from,\n        uint256[] calldata ids,\n        uint256[] calldata amounts,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n"},"ERC20.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity \u003e=0.8.0;\n\n/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)\n/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)\n/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.\nabstract contract ERC20 {\n    /*///////////////////////////////////////////////////////////////\n                                  EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\n\n    /*///////////////////////////////////////////////////////////////\n                             METADATA STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    string public name;\n\n    string public symbol;\n\n    uint8 public immutable decimals;\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC20 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 public totalSupply;\n\n    mapping(address =\u003e uint256) public balanceOf;\n\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\n\n    /*///////////////////////////////////////////////////////////////\n                             EIP-2612 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    bytes32 public constant PERMIT_TYPEHASH =\n        keccak256(\"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\");\n\n    uint256 internal immutable INITIAL_CHAIN_ID;\n\n    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;\n\n    mapping(address =\u003e uint256) public nonces;\n\n    /*///////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(\n        string memory _name,\n        string memory _symbol,\n        uint8 _decimals\n    ) {\n        name = _name;\n        symbol = _symbol;\n        decimals = _decimals;\n\n        INITIAL_CHAIN_ID = block.chainid;\n        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC20 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 amount) public virtual returns (bool) {\n        allowance[msg.sender][spender] = amount;\n\n        emit Approval(msg.sender, spender, amount);\n\n        return true;\n    }\n\n    function transfer(address to, uint256 amount) public virtual returns (bool) {\n        balanceOf[msg.sender] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can\u0027t exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(msg.sender, to, amount);\n\n        return true;\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) public virtual returns (bool) {\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\n\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\n\n        balanceOf[from] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can\u0027t exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(from, to, amount);\n\n        return true;\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              EIP-2612 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) public virtual {\n        require(deadline \u003e= block.timestamp, \"PERMIT_DEADLINE_EXPIRED\");\n\n        // Unchecked because the only math done is incrementing\n        // the owner\u0027s nonce which cannot realistically overflow.\n        unchecked {\n            bytes32 digest = keccak256(\n                abi.encodePacked(\n                    \"\\x19\\x01\",\n                    DOMAIN_SEPARATOR(),\n                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))\n                )\n            );\n\n            address recoveredAddress = ecrecover(digest, v, r, s);\n\n            require(recoveredAddress != address(0) \u0026\u0026 recoveredAddress == owner, \"INVALID_SIGNER\");\n\n            allowance[recoveredAddress][spender] = value;\n        }\n\n        emit Approval(owner, spender, value);\n    }\n\n    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {\n        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();\n    }\n\n    function computeDomainSeparator() internal view virtual returns (bytes32) {\n        return\n            keccak256(\n                abi.encode(\n                    keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"),\n                    keccak256(bytes(name)),\n                    keccak256(\"1\"),\n                    block.chainid,\n                    address(this)\n                )\n            );\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                       INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 amount) internal virtual {\n        totalSupply += amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can\u0027t exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(address(0), to, amount);\n    }\n\n    function _burn(address from, uint256 amount) internal virtual {\n        balanceOf[from] -= amount;\n\n        // Cannot underflow because a user\u0027s balance\n        // will never be larger than the total supply.\n        unchecked {\n            totalSupply -= amount;\n        }\n\n        emit Transfer(from, address(0), amount);\n    }\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"SafeTransferLib.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity \u003e=0.8.0;\n\nimport {ERC20} from \"./ERC20.sol\";\n\n/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)\n/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)\n/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.\n/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.\nlibrary SafeTransferLib {\n    /*///////////////////////////////////////////////////////////////\n                            ETH OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    function safeTransferETH(address to, uint256 amount) internal {\n        bool callStatus;\n\n        assembly {\n            // Transfer the ETH and store if it succeeded or not.\n            callStatus := call(gas(), to, amount, 0, 0, 0, 0)\n        }\n\n        require(callStatus, \"ETH_TRANSFER_FAILED\");\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                           ERC20 OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    function safeTransferFrom(\n        ERC20 token,\n        address from,\n        address to,\n        uint256 amount\n    ) internal {\n        bool callStatus;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata to memory piece by piece:\n            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.\n            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the \"from\" argument.\n            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 68), amount) // Finally append the \"amount\" argument. No mask as it\u0027s a full 32 byte value.\n\n            // Call the token and store if it succeeded or not.\n            // We use 100 because the calldata length is 4 + 32 * 3.\n            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)\n        }\n\n        require(didLastOptionalReturnCallSucceed(callStatus), \"TRANSFER_FROM_FAILED\");\n    }\n\n    function safeTransfer(\n        ERC20 token,\n        address to,\n        uint256 amount\n    ) internal {\n        bool callStatus;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata to memory piece by piece:\n            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.\n            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 36), amount) // Finally append the \"amount\" argument. No mask as it\u0027s a full 32 byte value.\n\n            // Call the token and store if it succeeded or not.\n            // We use 68 because the calldata length is 4 + 32 * 2.\n            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)\n        }\n\n        require(didLastOptionalReturnCallSucceed(callStatus), \"TRANSFER_FAILED\");\n    }\n\n    function safeApprove(\n        ERC20 token,\n        address to,\n        uint256 amount\n    ) internal {\n        bool callStatus;\n\n        assembly {\n            // Get a pointer to some free memory.\n            let freeMemoryPointer := mload(0x40)\n\n            // Write the abi-encoded calldata to memory piece by piece:\n            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.\n            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the \"to\" argument.\n            mstore(add(freeMemoryPointer, 36), amount) // Finally append the \"amount\" argument. No mask as it\u0027s a full 32 byte value.\n\n            // Call the token and store if it succeeded or not.\n            // We use 68 because the calldata length is 4 + 32 * 2.\n            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)\n        }\n\n        require(didLastOptionalReturnCallSucceed(callStatus), \"APPROVE_FAILED\");\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                         INTERNAL HELPER LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {\n        assembly {\n            // Get how many bytes the call returned.\n            let returnDataSize := returndatasize()\n\n            // If the call reverted:\n            if iszero(callStatus) {\n                // Copy the revert message into memory.\n                returndatacopy(0, 0, returnDataSize)\n\n                // Revert with the same message.\n                revert(0, returnDataSize)\n            }\n\n            switch returnDataSize\n            case 32 {\n                // Copy the return data into memory.\n                returndatacopy(0, 0, returnDataSize)\n\n                // Set success to whether it returned true.\n                success := iszero(iszero(mload(0)))\n            }\n            case 0 {\n                // There was no return data.\n                success := 1\n            }\n            default {\n                // It returned some malformed input.\n                success := 0\n            }\n        }\n    }\n}\n"}}