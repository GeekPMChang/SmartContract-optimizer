{"DynamicBulkTransfer.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.5;\n\nimport \"./TransferHelper.sol\";\nimport \"./Ownable.sol\";\n\ninterface Token {\n    function balanceOf(address who) external view returns (uint256);\n\n    function allowance(address owner, address spender)\n        external\n        view\n        returns (uint256);\n}\n\ncontract DynamicBulkTransfer is Ownable {\n    function makeTransfer(\n        address payable[] memory addressArray,\n        uint256[] memory amountArray,\n        address contactAddress\n    ) external {\n        require(\n            addressArray.length == amountArray.length,\n            \"Arrays must be of same size.\"\n        );\n        Token tokenInstance = Token(contactAddress);\n        for (uint256 i = 0; i \u003c addressArray.length; i++) {\n            require(\n                tokenInstance.allowance(msg.sender, address(this)) \u003e=\n                    amountArray[i],\n                \"Insufficient allowance.\"\n            );\n            require(\n                tokenInstance.balanceOf(msg.sender) \u003e= amountArray[i],\n                \"Owner has insufficient token balance.\"\n            );\n            TransferHelper.safeTransferFrom(\n                contactAddress,\n                msg.sender,\n                addressArray[i],\n                amountArray[i] \n            );\n        }\n    }\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.5;\n\ncontract Ownable {\n    address public owner;\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    /**\n     * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n     * account.\n     */\n    constructor() {\n        _setOwner(msg.sender);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\n     * @param newOwner The address to transfer ownership to.\n     */\n    function transferOwnership(address newOwner) public onlyOwner {\n        require(newOwner != address(0));\n        emit OwnershipTransferred(owner, newOwner);\n        owner = newOwner;\n    }\n\n    function _setOwner(address newOwner) internal {\n        owner = newOwner;\n    }\n}\n"},"TransferHelper.sol":{"content":"// SPDX-License-Identifier: GPL-3.0-or-later\n\npragma solidity \u003e=0.6.0;\n\n// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false\nlibrary TransferHelper {\n    function safeApprove(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes(\u0027approve(address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(\n            abi.encodeWithSelector(0x095ea7b3, to, value)\n        );\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper::safeApprove: approve failed\"\n        );\n    }\n\n    function safeTransfer(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes(\u0027transfer(address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(\n            abi.encodeWithSelector(0xa9059cbb, to, value)\n        );\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper::safeTransfer: transfer failed\"\n        );\n    }\n\n    function safeTransferFrom(\n        address token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes(\u0027transferFrom(address,address,uint256)\u0027)));\n        (bool success, bytes memory data) = token.call(\n            abi.encodeWithSelector(0x23b872dd, from, to, value)\n        );\n        require(\n            success \u0026\u0026 (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper::transferFrom: transferFrom failed\"\n        );\n    }\n\n    function safeTransferETH(address to, uint256 value) internal {\n        (bool success, ) = to.call{value: value}(new bytes(0));\n        require(\n            success,\n            \"TransferHelper::safeTransferETH: ETH transfer failed\"\n        );\n    }\n}\n"}}