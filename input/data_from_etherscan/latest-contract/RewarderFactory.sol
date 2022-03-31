{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 800
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
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and make it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "contracts/Rewarder.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.0;\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport \"./interfaces/IRewarder.sol\";\nimport \"./libraries/TransferHelper.sol\";\n\ncontract Rewarder is IRewarder, ReentrancyGuard {\n    address public immutable override currency;\n    address public immutable pool;\n    address public operator;\n\n    event LogRewarderWithdraw(address indexed _rewarder, address _currency, address indexed _to, uint256 _amount);\n    event LogTransferOwnerShip(address indexed _rewarder, address indexed _oldOperator, address indexed _newOperator);\n\n    constructor(\n        address _operator,\n        address _currency,\n        address _pool\n    ) {\n        require(_operator != address(0), \"UnoRe: zero operator address\");\n        require(_pool != address(0), \"UnoRe: zero pool address\");\n        currency = _currency;\n        pool = _pool;\n        operator = _operator;\n    }\n\n    receive() external payable {}\n\n    function onReward(address _to, uint256 _amount) external payable override onlyPOOL returns (uint256) {\n        require(_to != address(0), \"UnoRe: zero address reward\");\n        if (currency == address(0)) {\n            require(address(this).balance >= _amount, \"UnoRe: insufficient reward balance\");\n            TransferHelper.safeTransferETH(_to, _amount);\n            return _amount;\n        } else {\n            require(IERC20(currency).balanceOf(address(this)) >= _amount, \"UnoRe: insufficient reward balance\");\n            TransferHelper.safeTransfer(currency, _to, _amount);\n            return _amount;\n        }\n    }\n\n    function withdraw(address _to, uint256 _amount) external onlyOperator {\n        require(_to != address(0), \"UnoRe: zero address reward\");\n        if (currency == address(0)) {\n            if (address(this).balance >= _amount) {\n                TransferHelper.safeTransferETH(_to, _amount);\n                emit LogRewarderWithdraw(address(this), currency, _to, _amount);\n            } else {\n                if (address(this).balance > 0) {\n                    uint256 rewardAmount = address(this).balance;\n                    TransferHelper.safeTransferETH(_to, address(this).balance);\n                    emit LogRewarderWithdraw(address(this), currency, _to, rewardAmount);\n                }\n            }\n        } else {\n            if (IERC20(currency).balanceOf(address(this)) >= _amount) {\n                TransferHelper.safeTransfer(currency, _to, _amount);\n                emit LogRewarderWithdraw(address(this), currency, _to, _amount);\n            } else {\n                if (IERC20(currency).balanceOf(address(this)) > 0) {\n                    uint256 rewardAmount = IERC20(currency).balanceOf(address(this));\n                    TransferHelper.safeTransfer(currency, _to, IERC20(currency).balanceOf(address(this)));\n                    emit LogRewarderWithdraw(address(this), currency, _to, rewardAmount);\n                }\n            }\n        }\n    }\n\n    function transferOwnership(address _to) external onlyOperator {\n        require(_to != address(0), \"UnoRe: zero address reward\");\n        address oldOperator = operator;\n        operator = _to;\n        emit LogTransferOwnerShip(address(this), oldOperator, _to);\n    }\n\n    modifier onlyPOOL() {\n        require(msg.sender == pool, \"Only SSRP or SSIP contract can call this function.\");\n        _;\n    }\n\n    modifier onlyOperator() {\n        require(msg.sender == operator, \"Only operator call this function.\");\n        _;\n    }\n}\n"
    },
    "contracts/factories/RewarderFactory.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity 0.8.0;\n\nimport \"../Rewarder.sol\";\nimport \"../interfaces/IRewarderFactory.sol\";\n\ncontract RewarderFactory is IRewarderFactory {\n    constructor() {}\n\n    function newRewarder(\n        address _operator,\n        address _currency,\n        address _pool\n    ) external override returns (address) {\n        Rewarder _rewarder = new Rewarder(_operator, _currency, _pool);\n        address _rewarderAddr = address(_rewarder);\n\n        return _rewarderAddr;\n    }\n}\n"
    },
    "contracts/interfaces/IRewarder.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.0;\n\ninterface IRewarder {\n    function currency() external view returns (address);\n\n    function onReward(address to, uint256 unoAmount) external payable returns (uint256);\n}\n"
    },
    "contracts/interfaces/IRewarderFactory.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity 0.8.0;\n\ninterface IRewarderFactory {\n    function newRewarder(\n        address _operator,\n        address _currency,\n        address _pool\n    ) external returns (address);\n}\n"
    },
    "contracts/libraries/TransferHelper.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.8.0;\n\n// from Uniswap TransferHelper library\nlibrary TransferHelper {\n    function safeApprove(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes('approve(address,uint256)')));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), \"TransferHelper::safeApprove: approve failed\");\n    }\n\n    function safeTransfer(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes('transfer(address,uint256)')));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), \"TransferHelper::safeTransfer: transfer failed\");\n    }\n\n    function safeTransferFrom(\n        address token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), \"TransferHelper::transferFrom: transferFrom failed\");\n    }\n\n    function safeTransferETH(address to, uint256 value) internal {\n        (bool success, ) = to.call{value: value}(new bytes(0));\n        require(success, \"TransferHelper::safeTransferETH: ETH transfer failed\");\n    }\n}\n"
    }
  }
}}