{{
  "language": "Solidity",
  "sources": {
    "Distributor.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.10;\n\nimport {Ownable} from \"Ownable.sol\";\nimport {IERC20} from \"IERC20.sol\";\n\n/// @title Distributor\n/// @author dantop114\n/// @notice Distribution contract that handles IDLE distribution for Idle Liquidity Gauges.\ncontract Distributor is Ownable {\n\n    /*///////////////////////////////////////////////////////////////\n                        IMMUTABLES AND CONSTANTS\n    ///////////////////////////////////////////////////////////////*/\n\n    /// @notice The treasury address (used in case of emergency withdraw).\n    address immutable treasury;\n\n    /// @notice The IDLE token (the token to distribute).\n    IERC20 immutable idle;\n\n    /// @notice One week in seconds.\n    uint256 public constant ONE_WEEK = 86400 * 7;\n\n    /// @notice Initial distribution rate (as per IIP-*).\n    /// @dev 178_200 IDLEs in 6 months.\n    uint256 public constant INITIAL_RATE = (178_200 * 10 ** 18) / (26 * ONE_WEEK);\n\n    /// @notice Distribution epoch duration.\n    /// @dev 6 months epoch duration.\n    uint256 public constant EPOCH_DURATION = ONE_WEEK;\n\n    /// @notice Initial distribution epoch delay.\n    /// @dev This needs to be updated when deploying if 1 day is not enough.\n    uint256 public constant INITIAL_DISTRIBUTION_DELAY = 86400;\n\n    /*///////////////////////////////////////////////////////////////\n                                STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    /// @notice Distributed IDLEs so far.\n    uint256 public distributed;\n\n    /// @notice Running distribution epoch rate.\n    uint256 public rate;\n\n    /// @notice Running distribution epoch starting epoch time\n    uint256 public startEpochTime = block.timestamp + INITIAL_DISTRIBUTION_DELAY - EPOCH_DURATION;\n\n    /// @notice Total distributed IDLEs when current epoch starts\n    uint256 public epochStartingDistributed;\n\n    /// @notice Distribution rate pending for upcoming epoch\n    uint256 public pendingRate = INITIAL_RATE;\n\n    /// @notice The DistributorProxy contract\n    address public distributorProxy;\n\n    /*///////////////////////////////////////////////////////////////\n                                EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    /// @notice Event emitted when distributor proxy is updated.\n    event UpdateDistributorProxy(address oldProxy, address newProxy);\n\n    /// @notice Event emitted when distribution parameters are updated for upcoming distribution epoch.\n    event UpdatePendingRate(uint256 rate);\n\n    /// @notice Event emitted when distribution parameters are updated.\n    event UpdateDistributionParameters(uint256 time, uint256 rate);\n\n    /*///////////////////////////////////////////////////////////////\n                            CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    /// @dev The constructor.\n    /// @param _idle The IDLE token address.\n    /// @param _treasury The emergency withdrawal address.\n    constructor(IERC20 _idle, address _treasury) {\n        idle = _idle;\n        treasury = _treasury;\n    }\n\n    /// @notice Update the DistributorProxy contract\n    /// @dev Only owner can call this method\n    /// @param proxy New DistributorProxy contract\n    function setDistributorProxy(address proxy) external onlyOwner {\n        address distributorProxy_ = distributorProxy;\n        distributorProxy = proxy;\n\n        emit UpdateDistributorProxy(distributorProxy_, proxy);\n    }\n\n    /// @notice Update rate for next epoch\n    /// @dev Only owner can call this method\n    /// @param newRate Rate for upcoming epoch\n    function setPendingRate(uint256 newRate) external onlyOwner {\n        pendingRate = newRate;\n        emit UpdatePendingRate(newRate);\n    }\n\n    /// @dev Updates internal state to match current epoch distribution parameters.\n    function _updateDistributionParameters() internal {\n        startEpochTime += EPOCH_DURATION; // set start epoch timestamp\n        epochStartingDistributed += (rate * EPOCH_DURATION); // set initial distributed floor\n        rate = pendingRate; // set new rate\n\n        emit UpdateDistributionParameters(startEpochTime, rate);\n    }\n\n    /// @notice Updates distribution rate and start timestamp of the epoch.\n    /// @dev Callable by anyone if pending epoch should start.\n    function updateDistributionParameters() external {\n        require(block.timestamp >= startEpochTime + EPOCH_DURATION, \"epoch still running\");\n        _updateDistributionParameters();\n    }\n\n    /// @notice Get timestamp of the current distribution epoch start.\n    /// @return _startEpochTime Timestamp of the current epoch start.\n    function startEpochTimeWrite() external returns (uint256 _startEpochTime) {\n        _startEpochTime = startEpochTime;\n\n        if (block.timestamp >= _startEpochTime + EPOCH_DURATION) {\n            _updateDistributionParameters();\n            _startEpochTime = startEpochTime;\n        }\n    }\n\n    /// @notice Get timestamp of the next distribution epoch start.\n    /// @return _futureEpochTime Timestamp of the next epoch start.\n    function futureEpochTimeWrite() external returns (uint256 _futureEpochTime) {\n        _futureEpochTime = startEpochTime + EPOCH_DURATION;\n\n        if (block.timestamp >= _futureEpochTime) {\n            _updateDistributionParameters();\n            _futureEpochTime = startEpochTime + EPOCH_DURATION;\n        }\n    }\n\n    /// @dev Returns max available IDLEs to distribute.\n    /// @dev This will revert until initial distribution begins.\n    function _availableToDistribute() internal view returns (uint256) {\n        return epochStartingDistributed + (block.timestamp - startEpochTime) * rate;\n    }\n\n    /// @notice Returns max available IDLEs for current distribution epoch.\n    /// @return Available IDLEs to distribute.\n    function availableToDistribute() external view returns (uint256) {\n        return _availableToDistribute();\n    }\n\n    /// @notice Distribute `amount` IDLE to address `to`.\n    /// @param to The account that will receive IDLEs.\n    /// @param amount The amount of IDLEs to distribute.\n    function distribute(address to, uint256 amount) external returns(bool) {\n        require(msg.sender == distributorProxy, \"not proxy\");\n        require(to != address(0), \"address zero\");\n\n        if (block.timestamp >= startEpochTime + EPOCH_DURATION) {\n            _updateDistributionParameters();\n        }\n\n        uint256 _distributed = distributed + amount;\n        require(_distributed <= _availableToDistribute(), \"amount too high\");\n\n        distributed = _distributed;\n        return idle.transfer(to, amount);\n    }\n\n    /// @notice Emergency method to withdraw funds.\n    /// @param amount The amount of IDLEs to withdraw from contract.\n    function emergencyWithdraw(uint256 amount) external onlyOwner {\n        idle.transfer(treasury, amount);\n    }\n}\n"
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 1000
    },
    "libraries": {
      "Distributor.sol": {}
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