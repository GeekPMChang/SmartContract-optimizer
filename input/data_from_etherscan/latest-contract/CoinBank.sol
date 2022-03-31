{"CoinBank.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC20.sol\";\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a + b;\r\n        require(c \u003e= a);\r\n    }\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        require(b \u003e 0);\r\n        c = a / b;\r\n    }\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b);\r\n    }\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        require(b \u003c= a);\r\n        c = a - b;\r\n    }\r\n}\r\n\r\n//----------------------------------------------------------------------------------\r\n\r\ncontract CoinBank{\r\n    using SafeMath for uint256;\r\n\r\n    address payable public owner;\r\n    address coin;\r\n    uint256 priceForMCoins;\r\n    \r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor (address coinAddress) {\r\n        coin = coinAddress;\r\n        owner = payable(msg.sender);\r\n   }\r\n    \r\n    function buy1000000x(uint256 amount) public payable{\r\n        require(IERC20(coin).balanceOf(address(this)) \u003e= SafeMath.mul(amount,1000000));\r\n        require(msg.value \u003e= SafeMath.mul(amount, priceForMCoins));\r\n        require(priceForMCoins \u003e 0);\r\n        IERC20(coin).transfer(msg.sender, SafeMath.mul(amount,1000000));\r\n    }\r\n    \r\n    function mCoinPrice() public view returns (uint256 price){\r\n        return priceForMCoins;\r\n    }\r\n    \r\n    function payout() public {\r\n        require(msg.sender == owner);\r\n        owner.transfer(address(this).balance);\r\n    }\r\n    \r\n    function reclaimCoins() public {\r\n        require(msg.sender == owner);\r\n        IERC20(coin).transfer(msg.sender, totalSupply());\r\n    }\r\n    \r\n    function setPriceFor1M(uint256 price) public {\r\n        require(owner == msg.sender);\r\n        priceForMCoins = price;\r\n    }\r\n    \r\n    function totalSupply() public view returns (uint256 supply){\r\n        return IERC20(coin).balanceOf(address(this));\r\n    }\r\n    \r\n    function transferOwnership(address newOwner) public {    \r\n        require(owner == msg.sender, \"Only owner\");\r\n        require(newOwner != address(0), \"Zero address\");\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner.transfer(address(this).balance);\r\n        owner = payable(newOwner);\r\n    }\r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"}}