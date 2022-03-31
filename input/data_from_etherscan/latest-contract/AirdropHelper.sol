{"AirdropHelper.sol":{"content":"pragma solidity 0.8.10;\n\nimport \"./ERC721.sol\";\n\ncontract AirdropHelper{\n    address constant Owner = 0x5F13c058a660631558De911acd1b3B216B7f7f2A;\n    ERC721 constant Pixelmon = ERC721(0x32973908FaeE0Bf825A343000fE412ebE56F802A);\n\n    constructor() {}\n\n    function bulkTransfer(address[] calldata receivers, uint[] calldata tokenIds) public {\n        require(msg.sender == Owner);\n        require(receivers.length == tokenIds.length);\n        for (uint256 i = 0; i \u003c tokenIds.length; i++) {\n            Pixelmon.transferFrom(Owner, receivers[i], tokenIds[i]); \n        }\n    }\n}"},"ERC721.sol":{"content":"// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity \u003e=0.8.0;\n\n/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.\n/// @author Solmate (https://github.com/distractedm1nd/solmate/blob/main/src/tokens/ERC721.sol)\n/// @dev Note that balanceOf does not revert if passed the zero address, in defiance of the ERC.\nabstract contract ERC721 {\n    /*///////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 indexed id);\n\n    event Approval(address indexed owner, address indexed spender, uint256 indexed id);\n\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /*///////////////////////////////////////////////////////////////\n                          METADATA STORAGE/LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    string public name;\n\n    string public symbol;\n\n    function tokenURI(uint256 id) public view virtual returns (string memory);\n\n    /*///////////////////////////////////////////////////////////////\n                            ERC721 STORAGE                        \n    //////////////////////////////////////////////////////////////*/\n\n    uint256 public totalSupply;\n\n    mapping(address =\u003e uint256) public balanceOf;\n\n    mapping(uint256 =\u003e address) public ownerOf;\n\n    mapping(uint256 =\u003e address) public getApproved;\n\n    mapping(address =\u003e mapping(address =\u003e bool)) public isApprovedForAll;\n\n    /*///////////////////////////////////////////////////////////////\n                              CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(string memory _name, string memory _symbol) {\n        name = _name;\n        symbol = _symbol;\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC721 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 id) public virtual {\n        address owner = ownerOf[id];\n\n        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], \"NOT_AUTHORIZED\");\n\n        getApproved[id] = spender;\n\n        emit Approval(owner, spender, id);\n    }\n\n    function setApprovalForAll(address operator, bool approved) public virtual {\n        isApprovedForAll[msg.sender][operator] = approved;\n\n        emit ApprovalForAll(msg.sender, operator, approved);\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 id\n    ) public virtual {\n        require(from == ownerOf[id], \"WRONG_FROM\");\n\n        require(to != address(0), \"INVALID_RECIPIENT\");\n\n        require(\n            msg.sender == from || msg.sender == getApproved[id] || isApprovedForAll[from][msg.sender],\n            \"NOT_AUTHORIZED\"\n        );\n\n        // Underflow of the sender\u0027s balance is impossible because we check for\n        // ownership above and the recipient\u0027s balance can\u0027t realistically overflow.\n        unchecked {\n            balanceOf[from]--;\n\n            balanceOf[to]++;\n        }\n\n        ownerOf[id] = to;\n\n        delete getApproved[id];\n\n        emit Transfer(from, to, id);\n    }\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id\n    ) public virtual {\n        transferFrom(from, to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, \"\") ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        bytes memory data\n    ) public virtual {\n        transferFrom(from, to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                              ERC165 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {\n        return\n            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165\n            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721\n            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                       INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 id) internal virtual {\n        require(to != address(0), \"INVALID_RECIPIENT\");\n\n        require(ownerOf[id] == address(0), \"ALREADY_MINTED\");\n\n        // Counter overflow is incredibly unrealistic.\n        unchecked {\n            totalSupply++;\n\n            balanceOf[to]++;\n        }\n\n        ownerOf[id] = to;\n\n        emit Transfer(address(0), to, id);\n    }\n\n    function _burn(uint256 id) internal virtual {\n        address owner = ownerOf[id];\n\n        require(ownerOf[id] != address(0), \"NOT_MINTED\");\n\n        // Ownership check above ensures no underflow.\n        unchecked {\n            totalSupply--;\n\n            balanceOf[owner]--;\n        }\n\n        delete ownerOf[id];\n\n        delete getApproved[id];\n\n        emit Transfer(owner, address(0), id);\n    }\n\n    /*///////////////////////////////////////////////////////////////\n                       INTERNAL SAFE MINT LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _safeMint(address to, uint256 id) internal virtual {\n        _mint(to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, \"\") ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n\n    function _safeMint(\n        address to,\n        uint256 id,\n        bytes memory data\n    ) internal virtual {\n        _mint(to, id);\n\n        require(\n            to.code.length == 0 ||\n                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==\n                ERC721TokenReceiver.onERC721Received.selector,\n            \"UNSAFE_RECIPIENT\"\n        );\n    }\n}\n\n/// @notice A generic interface for a contract which properly accepts ERC721 tokens.\n/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)\ninterface ERC721TokenReceiver {\n    function onERC721Received(\n        address operator,\n        address from,\n        uint256 id,\n        bytes calldata data\n    ) external returns (bytes4);\n}"}}