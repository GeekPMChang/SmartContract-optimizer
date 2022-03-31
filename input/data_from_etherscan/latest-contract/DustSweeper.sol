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
    "@chainlink/contracts/src/v0.8/Denominations.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nlibrary Denominations {\n  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n  address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;\n\n  // Fiat currencies follow https://en.wikipedia.org/wiki/ISO_4217\n  address public constant USD = address(840);\n  address public constant GBP = address(826);\n  address public constant EUR = address(978);\n  address public constant JPY = address(392);\n  address public constant KRW = address(410);\n  address public constant CNY = address(156);\n  address public constant AUD = address(36);\n  address public constant CAD = address(124);\n  address public constant CHF = address(756);\n  address public constant ARS = address(32);\n  address public constant PHP = address(608);\n  address public constant NZD = address(554);\n  address public constant SGD = address(702);\n  address public constant NGN = address(566);\n  address public constant ZAR = address(710);\n  address public constant RUB = address(643);\n  address public constant INR = address(356);\n  address public constant BRL = address(986);\n}\n"
    },
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface AggregatorInterface {\n  function latestAnswer() external view returns (int256);\n\n  function latestTimestamp() external view returns (uint256);\n\n  function latestRound() external view returns (uint256);\n\n  function getAnswer(uint256 roundId) external view returns (int256);\n\n  function getTimestamp(uint256 roundId) external view returns (uint256);\n\n  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);\n\n  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);\n}\n"
    },
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./AggregatorInterface.sol\";\nimport \"./AggregatorV3Interface.sol\";\n\ninterface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}\n"
    },
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface AggregatorV3Interface {\n  function decimals() external view returns (uint8);\n\n  function description() external view returns (string memory);\n\n  function version() external view returns (uint256);\n\n  // getRoundData and latestRoundData should both raise \"No data present\"\n  // if they do not have data to report, instead of returning unset values\n  // which could be misinterpreted as actual reported values.\n  function getRoundData(uint80 _roundId)\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n  function latestRoundData()\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n}\n"
    },
    "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\npragma abicoder v2;\n\nimport \"./AggregatorV2V3Interface.sol\";\n\ninterface FeedRegistryInterface {\n  struct Phase {\n    uint16 phaseId;\n    uint80 startingAggregatorRoundId;\n    uint80 endingAggregatorRoundId;\n  }\n\n  event FeedProposed(\n    address indexed asset,\n    address indexed denomination,\n    address indexed proposedAggregator,\n    address currentAggregator,\n    address sender\n  );\n  event FeedConfirmed(\n    address indexed asset,\n    address indexed denomination,\n    address indexed latestAggregator,\n    address previousAggregator,\n    uint16 nextPhaseId,\n    address sender\n  );\n\n  // V3 AggregatorV3Interface\n\n  function decimals(address base, address quote) external view returns (uint8);\n\n  function description(address base, address quote) external view returns (string memory);\n\n  function version(address base, address quote) external view returns (uint256);\n\n  function latestRoundData(address base, address quote)\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n  function getRoundData(\n    address base,\n    address quote,\n    uint80 _roundId\n  )\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n  // V2 AggregatorInterface\n\n  function latestAnswer(address base, address quote) external view returns (int256 answer);\n\n  function latestTimestamp(address base, address quote) external view returns (uint256 timestamp);\n\n  function latestRound(address base, address quote) external view returns (uint256 roundId);\n\n  function getAnswer(\n    address base,\n    address quote,\n    uint256 roundId\n  ) external view returns (int256 answer);\n\n  function getTimestamp(\n    address base,\n    address quote,\n    uint256 roundId\n  ) external view returns (uint256 timestamp);\n\n  // Registry getters\n\n  function getFeed(address base, address quote) external view returns (AggregatorV2V3Interface aggregator);\n\n  function getPhaseFeed(\n    address base,\n    address quote,\n    uint16 phaseId\n  ) external view returns (AggregatorV2V3Interface aggregator);\n\n  function isFeedEnabled(address aggregator) external view returns (bool);\n\n  function getPhase(\n    address base,\n    address quote,\n    uint16 phaseId\n  ) external view returns (Phase memory phase);\n\n  // Round helpers\n\n  function getRoundFeed(\n    address base,\n    address quote,\n    uint80 roundId\n  ) external view returns (AggregatorV2V3Interface aggregator);\n\n  function getPhaseRange(\n    address base,\n    address quote,\n    uint16 phaseId\n  ) external view returns (uint80 startingRoundId, uint80 endingRoundId);\n\n  function getPreviousRoundId(\n    address base,\n    address quote,\n    uint80 roundId\n  ) external view returns (uint80 previousRoundId);\n\n  function getNextRoundId(\n    address base,\n    address quote,\n    uint80 roundId\n  ) external view returns (uint80 nextRoundId);\n\n  // Feed management\n\n  function proposeFeed(\n    address base,\n    address quote,\n    address aggregator\n  ) external;\n\n  function confirmFeed(\n    address base,\n    address quote,\n    address aggregator\n  ) external;\n\n  // Proposed aggregator\n\n  function getProposedFeed(address base, address quote)\n    external\n    view\n    returns (AggregatorV2V3Interface proposedAggregator);\n\n  function proposedGetRoundData(\n    address base,\n    address quote,\n    uint80 roundId\n  )\n    external\n    view\n    returns (\n      uint80 id,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n  function proposedLatestRoundData(address base, address quote)\n    external\n    view\n    returns (\n      uint80 id,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n  // Phases\n  function getCurrentPhaseId(address base, address quote) external view returns (uint16 currentPhaseId);\n}\n"
    },
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/DustSweeper.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n// OpenZeppelin\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\nimport \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport \"@openzeppelin/contracts/utils/Address.sol\";\n// Chainlink\nimport \"@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol\";\nimport \"@chainlink/contracts/src/v0.8/Denominations.sol\";\n\ncontract DustSweeper is Ownable, ReentrancyGuard {\n  using SafeERC20 for IERC20;\n\n  uint256 private takerDiscountPercent;\n  uint256 private protocolFeePercent;\n  address private protocolWallet;\n\n  struct TokenData {\n    address tokenAddress;\n    uint256 tokenPrice;\n  }\n  mapping(address => uint8) private tokenDecimals;\n\n  // ChainLink\n  address private chainLinkRegistry;\n  address private quoteETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n\n  constructor(\n    address _chainLinkRegistry,\n    address _protocolWallet,\n    uint256 _takerDiscountPercent,\n    uint256 _protocolFeePercent\n  ) {\n    chainLinkRegistry = _chainLinkRegistry;\n    protocolWallet = _protocolWallet;\n    takerDiscountPercent = _takerDiscountPercent;\n    protocolFeePercent = _protocolFeePercent;\n  }\n\n  function sweepDust(\n    address[] calldata makers,\n    address[] calldata tokenAddresses\n  ) external payable nonReentrant {\n    // Make sure order data is valid\n    require(makers.length > 0 && makers.length == tokenAddresses.length, \"Passed order data in invalid format\");\n    // Track how much ETH was sent so we can return any overage\n    uint256 ethSent = msg.value;\n    uint256 totalNativeAmount = 0;\n    TokenData memory lastToken;\n    for (uint256 i = 0; i < makers.length; i++) {\n      // Fetch/cache tokenDecimals\n      if (tokenDecimals[tokenAddresses[i]] == 0) {\n        bytes memory decData = Address.functionStaticCall(tokenAddresses[i], abi.encodeWithSignature(\"decimals()\"));\n        tokenDecimals[tokenAddresses[i]] = abi.decode(decData, (uint8));\n      }\n      require(tokenDecimals[tokenAddresses[i]] > 0, \"Failed to fetch token decimals\");\n\n      // Fetch/cache tokenPrice\n      if (i == 0 || lastToken.tokenPrice == 0 || lastToken.tokenAddress != tokenAddresses[i]) {\n        // Need to fetch tokenPrice\n        lastToken = TokenData(tokenAddresses[i], uint256(getPrice(tokenAddresses[i], quoteETH)));\n      }\n      require(lastToken.tokenPrice > 0, \"Failed to fetch token price!\");\n\n      // Amount of Tokens to transfer\n      uint256 allowance = IERC20(tokenAddresses[i]).allowance(makers[i], address(this));\n      require(allowance > 0, \"Allowance for specified token is 0\");\n\n      // Equivalent amount of Native Tokens\n      uint256 nativeAmt = allowance * lastToken.tokenPrice / 10**tokenDecimals[tokenAddresses[i]];\n      totalNativeAmount += nativeAmt;\n\n      // Amount of Native Tokens to transfer\n      uint256 distribution = nativeAmt * (10**4 - takerDiscountPercent) / 10**4;\n      // Subtract distribution amount from ethSent amount\n      ethSent -= distribution;\n\n      // Taker sends Native Token to Maker\n      Address.sendValue(payable(makers[i]), distribution);\n\n      // DustSweeper sends Maker's tokens to Taker\n      IERC20(tokenAddresses[i]).safeTransferFrom(makers[i], msg.sender, allowance);\n    }\n\n    // Taker pays protocolFee % for the total amount to avoid multiple transfers\n    uint256 protocolNative = totalNativeAmount * protocolFeePercent / 10**4;\n    // Subtract protocolFee from ethSent\n    ethSent -= protocolNative;\n    // Send to protocol wallet\n    Address.sendValue(payable(protocolWallet), protocolNative);\n\n    // Pay any overage back to msg.sender as long as overage > gas cost\n    if (ethSent > 10000) {\n      Address.sendValue(payable(msg.sender), ethSent);\n    }\n  }\n\n  /**\n * Returns the latest price from Chainlink\n */\n  function getPrice(address base, address quote) public view returns(int256) {\n    (,int256 price,,,) = FeedRegistryInterface(chainLinkRegistry).latestRoundData(base, quote);\n    return price;\n  }\n\n  // onlyOwner protected Setters/Getters\n  function getTakerDiscountPercent() view external returns(uint256) {\n    return takerDiscountPercent;\n  }\n\n  function setTakerDiscountPercent(uint256 _takerDiscountPercent) external onlyOwner {\n    if (_takerDiscountPercent <= 5000) { // 50%\n      takerDiscountPercent = _takerDiscountPercent;\n    }\n  }\n\n  function getProtocolFeePercent() view external returns(uint256) {\n    return protocolFeePercent;\n  }\n\n  function setProtocolFeePercent(uint256 _protocolFeePercent) external onlyOwner {\n    if (_protocolFeePercent <= 1000) { // 10%\n      protocolFeePercent = _protocolFeePercent;\n    }\n  }\n\n  function getChainLinkRegistry() view external returns(address) {\n    return chainLinkRegistry;\n  }\n\n  function setChainLinkRegistry(address _chainLinkRegistry) external onlyOwner {\n    chainLinkRegistry = _chainLinkRegistry;\n  }\n\n  function getProtocolWallet() view external returns(address) {\n    return protocolWallet;\n  }\n\n  function setProtocolWallet(address _protocolWallet) external onlyOwner {\n    protocolWallet = _protocolWallet;\n  }\n\n  // Payment methods\n  receive() external payable {}\n  fallback() external payable {}\n\n  function removeBalance(address tokenAddress) external onlyOwner {\n    if (tokenAddress == address(0)) {\n      Address.sendValue(payable(msg.sender), address(this).balance);\n    } else {\n      uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));\n      if (tokenBalance > 0) {\n        IERC20(tokenAddress).safeTransfer(msg.sender, tokenBalance);\n      }\n    }\n  }\n\n}\n"
    }
  }
}}