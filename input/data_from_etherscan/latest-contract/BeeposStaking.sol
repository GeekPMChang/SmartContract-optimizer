{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}"},"EnumerableSet.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Library for managing\r\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\r\n * types.\r\n *\r\n * Sets have the following properties:\r\n *\r\n * - Elements are added, removed, and checked for existence in constant time\r\n * (O(1)).\r\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\r\n *\r\n * ```\r\n * contract Example {\r\n *     // Add the library methods\r\n *     using EnumerableSet for EnumerableSet.AddressSet;\r\n *\r\n *     // Declare a set state variable\r\n *     EnumerableSet.AddressSet private mySet;\r\n * }\r\n * ```\r\n *\r\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\r\n * and `uint256` (`UintSet`) are supported.\r\n */\r\nlibrary EnumerableSet {\r\n    // To implement this library for multiple types with as little code\r\n    // repetition as possible, we write it in terms of a generic Set type with\r\n    // bytes32 values.\r\n    // The Set implementation uses private functions, and user-facing\r\n    // implementations (such as AddressSet) are just wrappers around the\r\n    // underlying Set.\r\n    // This means that we can only create new EnumerableSets for types that fit\r\n    // in bytes32.\r\n\r\n    struct Set {\r\n        // Storage of set values\r\n        bytes32[] _values;\r\n\r\n        // Position of the value in the `values` array, plus 1 because index 0\r\n        // means a value is not in the set.\r\n        mapping (bytes32 =\u003e uint256) _indexes;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function _add(Set storage set, bytes32 value) private returns (bool) {\r\n        if (!_contains(set, value)) {\r\n            set._values.push(value);\r\n            // The value is stored at length-1, but we add 1 to all indexes\r\n            // and use 0 as a sentinel value\r\n            set._indexes[value] = set._values.length;\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\r\n        // We read and store the value\u0027s index to prevent multiple reads from the same storage slot\r\n        uint256 valueIndex = set._indexes[value];\r\n\r\n        if (valueIndex != 0) { // Equivalent to contains(set, value)\r\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\r\n            // the array, and then remove the last element (sometimes called as \u0027swap and pop\u0027).\r\n            // This modifies the order of the array, as noted in {at}.\r\n\r\n            uint256 toDeleteIndex = valueIndex - 1;\r\n            uint256 lastIndex = set._values.length - 1;\r\n\r\n            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs\r\n            // so rarely, we still do the swap anyway to avoid the gas cost of adding an \u0027if\u0027 statement.\r\n\r\n            bytes32 lastvalue = set._values[lastIndex];\r\n\r\n            // Move the last value to the index where the value to delete is\r\n            set._values[toDeleteIndex] = lastvalue;\r\n            // Update the index for the moved value\r\n            set._indexes[lastvalue] = valueIndex; // Replace lastvalue\u0027s index to valueIndex\r\n\r\n            // Delete the slot where the moved value was stored\r\n            set._values.pop();\r\n\r\n            // Delete the index for the deleted slot\r\n            delete set._indexes[value];\r\n\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\r\n        return set._indexes[value] != 0;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values on the set. O(1).\r\n     */\r\n    function _length(Set storage set) private view returns (uint256) {\r\n        return set._values.length;\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\r\n        require(set._values.length \u003e index, \"EnumerableSet: index out of bounds\");\r\n        return set._values[index];\r\n    }\r\n\r\n    // Bytes32Set\r\n\r\n    struct Bytes32Set {\r\n        Set _inner;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\r\n        return _add(set._inner, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\r\n        return _remove(set._inner, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\r\n        return _contains(set._inner, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values in the set. O(1).\r\n     */\r\n    function length(Bytes32Set storage set) internal view returns (uint256) {\r\n        return _length(set._inner);\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\r\n        return _at(set._inner, index);\r\n    }\r\n\r\n    // AddressSet\r\n\r\n    struct AddressSet {\r\n        Set _inner;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function add(AddressSet storage set, address value) internal returns (bool) {\r\n        return _add(set._inner, bytes32(uint256(uint160(value))));\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function remove(AddressSet storage set, address value) internal returns (bool) {\r\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\r\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values in the set. O(1).\r\n     */\r\n    function length(AddressSet storage set) internal view returns (uint256) {\r\n        return _length(set._inner);\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\r\n        return address(uint160(uint256(_at(set._inner, index))));\r\n    }\r\n\r\n\r\n    // UintSet\r\n\r\n    struct UintSet {\r\n        Set _inner;\r\n    }\r\n\r\n    /**\r\n     * @dev Add a value to a set. O(1).\r\n     *\r\n     * Returns true if the value was added to the set, that is if it was not\r\n     * already present.\r\n     */\r\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\r\n        return _add(set._inner, bytes32(value));\r\n    }\r\n\r\n    /**\r\n     * @dev Removes a value from a set. O(1).\r\n     *\r\n     * Returns true if the value was removed from the set, that is if it was\r\n     * present.\r\n     */\r\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\r\n        return _remove(set._inner, bytes32(value));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the value is in the set. O(1).\r\n     */\r\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\r\n        return _contains(set._inner, bytes32(value));\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of values on the set. O(1).\r\n     */\r\n    function length(UintSet storage set) internal view returns (uint256) {\r\n        return _length(set._inner);\r\n    }\r\n\r\n   /**\r\n    * @dev Returns the value stored at position `index` in the set. O(1).\r\n    *\r\n    * Note that there are no guarantees on the ordering of values inside the\r\n    * array, and it may change when more values are added or removed.\r\n    *\r\n    * Requirements:\r\n    *\r\n    * - `index` must be strictly less than {length}.\r\n    */\r\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\r\n        return uint256(_at(set._inner, index));\r\n    }\r\n}"},"ERC721Holder.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC721Receiver.sol\";\r\n\r\n  /**\r\n   * @dev Implementation of the {IERC721Receiver} interface.\r\n   *\r\n   * Accepts all token transfers.\r\n   * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.\r\n   */\r\ncontract ERC721Holder is IERC721Receiver {\r\n\r\n    /**\r\n     * @dev See {IERC721Receiver-onERC721Received}.\r\n     *\r\n     * Always returns `IERC721Receiver.onERC721Received.selector`.\r\n     */\r\n    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {\r\n        return this.onERC721Received.selector;\r\n    }\r\n}"},"IERC165.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Interface of the ERC165 standard, as defined in the\r\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\r\n *\r\n * Implementers can declare support of contract interfaces, which can then be\r\n * queried by others ({ERC165Checker}).\r\n *\r\n * For an implementation, see {ERC165}.\r\n */\r\ninterface IERC165 {\r\n    /**\r\n     * @dev Returns true if this contract implements the interface defined by\r\n     * `interfaceId`. See the corresponding\r\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\r\n     * to learn more about how these ids are created.\r\n     *\r\n     * This function call must use less than 30 000 gas.\r\n     */\r\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"IERC721.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC165.sol\";\r\n\r\n/**\r\n * @dev Required interface of an ERC721 compliant contract.\r\n */\r\ninterface IERC721 is IERC165 {\r\n    /**\r\n     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\r\n\r\n    /**\r\n     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\r\n     */\r\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\r\n\r\n    /**\r\n     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\r\n     */\r\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\r\n\r\n    /**\r\n     * @dev Returns the number of tokens in ``owner``\u0027s account.\r\n     */\r\n    function balanceOf(address owner) external view returns (uint256 balance);\r\n\r\n    /**\r\n     * @dev Returns the owner of the `tokenId` token.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `tokenId` must exist.\r\n     */\r\n    function ownerOf(uint256 tokenId) external view returns (address owner);\r\n\r\n    /**\r\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\r\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `from` cannot be the zero address.\r\n     * - `to` cannot be the zero address.\r\n     * - `tokenId` token must exist and be owned by `from`.\r\n     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\r\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function safeTransferFrom(address from, address to, uint256 tokenId) external;\r\n\r\n    /**\r\n     * @dev Transfers `tokenId` token from `from` to `to`.\r\n     *\r\n     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `from` cannot be the zero address.\r\n     * - `to` cannot be the zero address.\r\n     * - `tokenId` token must be owned by `from`.\r\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address from, address to, uint256 tokenId) external;\r\n\r\n    /**\r\n     * @dev Gives permission to `to` to transfer `tokenId` token to another account.\r\n     * The approval is cleared when the token is transferred.\r\n     *\r\n     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The caller must own the token or be an approved operator.\r\n     * - `tokenId` must exist.\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address to, uint256 tokenId) external;\r\n\r\n    /**\r\n     * @dev Returns the account approved for `tokenId` token.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `tokenId` must exist.\r\n     */\r\n    function getApproved(uint256 tokenId) external view returns (address operator);\r\n\r\n    /**\r\n     * @dev Approve or remove `operator` as an operator for the caller.\r\n     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The `operator` cannot be the caller.\r\n     *\r\n     * Emits an {ApprovalForAll} event.\r\n     */\r\n    function setApprovalForAll(address operator, bool _approved) external;\r\n\r\n    /**\r\n     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\r\n     *\r\n     * See {setApprovalForAll}\r\n     */\r\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\r\n\r\n    /**\r\n      * @dev Safely transfers `tokenId` token from `from` to `to`.\r\n      *\r\n      * Requirements:\r\n      *\r\n      * - `from` cannot be the zero address.\r\n      * - `to` cannot be the zero address.\r\n      * - `tokenId` token must exist and be owned by `from`.\r\n      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\r\n      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\r\n      *\r\n      * Emits a {Transfer} event.\r\n      */\r\n    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;\r\n}"},"IERC721Receiver.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @title ERC721 token receiver interface\r\n * @dev Interface for any contract that wants to support safeTransfers\r\n * from ERC721 asset contracts.\r\n */\r\ninterface IERC721Receiver {\r\n    /**\r\n     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}\r\n     * by `operator` from `from`, this function is called.\r\n     *\r\n     * It must return its Solidity selector to confirm the token transfer.\r\n     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.\r\n     *\r\n     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.\r\n     */\r\n    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);\r\n}"},"Math.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Standard math utilities missing in the Solidity language.\r\n */\r\nlibrary Math {\r\n    /**\r\n     * @dev Returns the largest of two numbers.\r\n     */\r\n    function max(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003e= b ? a : b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the smallest of two numbers.\r\n     */\r\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003c b ? a : b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the average of two numbers. The result is rounded towards\r\n     * zero.\r\n     */\r\n    function average(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // (a + b) / 2 can overflow, so we distribute\r\n        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);\r\n    }\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Context.sol\";\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}"},"Pausable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which allows children to implement an emergency stop\r\n * mechanism that can be triggered by an authorized account.\r\n *\r\n * This module is used through inheritance. It will make available the\r\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\r\n * the functions of your contract. Note that they will not be pausable by\r\n * simply including this module, only once the modifiers are put in place.\r\n */\r\nabstract contract Pausable is Context {\r\n    /**\r\n     * @dev Emitted when the pause is triggered by `account`.\r\n     */\r\n    event Paused(address account);\r\n\r\n    /**\r\n     * @dev Emitted when the pause is lifted by `account`.\r\n     */\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    /**\r\n     * @dev Initializes the contract in unpaused state.\r\n     */\r\n    constructor () {\r\n        _paused = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the contract is paused, and false otherwise.\r\n     */\r\n    function paused() public view virtual returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The contract must not be paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!paused(), \"Pausable: paused\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The contract must be paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(paused(), \"Pausable: not paused\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Triggers stopped state.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The contract must not be paused.\r\n     */\r\n    function _pause() internal virtual whenNotPaused {\r\n        _paused = true;\r\n        emit Paused(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Returns to normal state.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The contract must be paused.\r\n     */\r\n    function _unpause() internal virtual whenPaused {\r\n        _paused = false;\r\n        emit Unpaused(_msgSender());\r\n    }\r\n}"},"Staking.sol":{"content":"// SPDX-License-Identifier: Unlicensed\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Ownable.sol\";\r\nimport \"./Pausable.sol\";\r\nimport \"./IERC20.sol\";\r\nimport \"./IERC721.sol\";\r\nimport \"./ERC721Holder.sol\";\r\nimport \"./Math.sol\";\r\nimport \"./EnumerableSet.sol\";\r\n\r\ncontract BeeposStaking is Ownable, ERC721Holder, Pausable {\r\n\r\n    using EnumerableSet for EnumerableSet.UintSet;\r\n    IERC721 public nftContractInstance;\r\n    IERC20 public tokenContractInstance;\r\n\r\n    // Number of tokens per block. There are approx 6k blocks per day and 10 tokens are represented by 10**18 (after considering decimals).\r\n    uint256 public rate;\r\n\t\r\n    // Mapping of address to token numbers deposited\r\n    mapping(address =\u003e EnumerableSet.UintSet) private _deposits;\r\n\r\n    // Mapping of address -\u003e token -\u003e block number\r\n    mapping(address =\u003e mapping(uint256 =\u003e uint256)) public _depositBlocks;\r\n\r\n    constructor(address nftContractAddress, uint256 initialRate, address tokenAddress) {\r\n        nftContractInstance = IERC721(nftContractAddress);\r\n        rate = initialRate;\r\n        tokenContractInstance = IERC20(tokenAddress);\r\n    }\r\n\t\r\n    function setAddresses(address nftContractAddress, address tokenAddress) public onlyOwner {\r\n        nftContractInstance = IERC721(nftContractAddress);\r\n        tokenContractInstance = IERC20(tokenAddress);\r\n    }\r\n\r\n    function setRate(uint256 newRate) public onlyOwner {\r\n        rate = newRate;\r\n    }\r\n\t\r\n    function pause() public onlyOwner {\r\n        _pause();\r\n    }\r\n\r\n    function unpause() public onlyOwner {\r\n        _unpause();\r\n    }\r\n\r\n    function depositsOf(address owner) external view returns (uint256[] memory) {\r\n        EnumerableSet.UintSet storage depositSet = _deposits[owner];\r\n        uint256[] memory tokenIds = new uint256[](depositSet.length());\r\n\r\n        for (uint256 i; i \u003c depositSet.length(); i++) {\r\n            tokenIds[i] = depositSet.at(i);\r\n        }\r\n        return tokenIds;\r\n    }\r\n\r\n    function hasDeposits(address owner, uint256[] memory tokenIds) external view returns (bool) {\r\n        EnumerableSet.UintSet storage depositSet = _deposits[owner];\r\n        for (uint256 i = 0; i \u003c tokenIds.length; i++) {\r\n            if (! depositSet.contains(tokenIds[i])) {\r\n                return false;\r\n            }\r\n        }\r\n        return true;\r\n    }\r\n\r\n    function hasDepositsOrOwns(address owner, uint256[] memory tokenIds) external view returns (bool) {\r\n        EnumerableSet.UintSet storage depositSet = _deposits[owner];\r\n        for (uint256 i = 0; i \u003c tokenIds.length; i++) {\r\n            if (! depositSet.contains(tokenIds[i]) \u0026\u0026 nftContractInstance.ownerOf(tokenIds[i]) != owner) {\r\n                return false;\r\n            }\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    function calculateRewards(address owner, uint256[] memory tokenIds) external view returns (uint256) {\r\n        uint256 reward = 0;\r\n        for (uint256 i; i \u003c tokenIds.length; i++) {\r\n            reward += calculateReward(owner, tokenIds[i]);\r\n        }\r\n        return reward;\r\n    }\r\n\r\n    function calculateReward(address owner, uint256 tokenId) public view returns (uint256) {\r\n        require(block.number \u003e= _depositBlocks[owner][tokenId], \"Invalid block numbers\");\r\n        return rate * (_deposits[owner].contains(tokenId) ? 1 : 0) * (block.number - _depositBlocks[owner][tokenId]);\r\n    }\r\n\t\r\n    function claimRewards(uint256[] calldata tokenIds) public whenNotPaused {\r\n        uint256 reward = 0;\r\n        uint256 currentBlock = block.number;\r\n        for (uint256 i; i \u003c tokenIds.length; i++) {\r\n            reward += calculateReward(msg.sender, tokenIds[i]);\r\n            _depositBlocks[msg.sender][tokenIds[i]] = currentBlock;\r\n        }\r\n        if (reward \u003e 0) \r\n\t\t{\r\n            tokenContractInstance.transfer(msg.sender, reward);\r\n        }\r\n    }\r\n\r\n    function deposit(uint256[] calldata tokenIds) external whenNotPaused {\r\n        require(msg.sender != address(nftContractInstance), \"Invalid address\");\r\n        uint256 currentBlock = block.number;\r\n        for (uint256 i = 0; i \u003c tokenIds.length; i++) {\r\n            nftContractInstance.safeTransferFrom(msg.sender, address(this), tokenIds[i], \"\");\r\n            _deposits[msg.sender].add(tokenIds[i]);\r\n            _depositBlocks[msg.sender][tokenIds[i]] = currentBlock;\r\n        }\r\n    }\r\n\t\r\n    function withdraw(uint256[] calldata tokenIds) external whenNotPaused {\r\n        claimRewards(tokenIds);\r\n        for (uint256 i; i \u003c tokenIds.length; i++) {\r\n            require(_deposits[msg.sender].contains(tokenIds[i]), \"This token has not been deposited\");\r\n            _deposits[msg.sender].remove(tokenIds[i]);\r\n            nftContractInstance.safeTransferFrom(address(this), msg.sender, tokenIds[i], \"\");\r\n        }\r\n    }\r\n\t\r\n    function withdrawTokens(uint256 tokenAmount) external onlyOwner {\r\n        tokenContractInstance.transfer(msg.sender, tokenAmount);\r\n    }\r\n}"}}