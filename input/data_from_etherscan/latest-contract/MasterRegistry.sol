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
      "runs": 10000
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
    "@openzeppelin/contracts/access/AccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"../utils/EnumerableSet.sol\";\nimport \"../utils/Address.sol\";\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module that allows children to implement role-based access\n * control mechanisms.\n *\n * Roles are referred to by their `bytes32` identifier. These should be exposed\n * in the external API and be unique. The best way to achieve this is by\n * using `public constant` hash digests:\n *\n * ```\n * bytes32 public constant MY_ROLE = keccak256(\"MY_ROLE\");\n * ```\n *\n * Roles can be used to represent a set of permissions. To restrict access to a\n * function call, use {hasRole}:\n *\n * ```\n * function foo() public {\n *     require(hasRole(MY_ROLE, msg.sender));\n *     ...\n * }\n * ```\n *\n * Roles can be granted and revoked dynamically via the {grantRole} and\n * {revokeRole} functions. Each role has an associated admin role, and only\n * accounts that have a role's admin role can call {grantRole} and {revokeRole}.\n *\n * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means\n * that only accounts with this role will be able to grant or revoke other\n * roles. More complex role relationships can be created by using\n * {_setRoleAdmin}.\n *\n * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to\n * grant and revoke this role. Extra precautions should be taken to secure\n * accounts that have been granted it.\n */\nabstract contract AccessControl is Context {\n    using EnumerableSet for EnumerableSet.AddressSet;\n    using Address for address;\n\n    struct RoleData {\n        EnumerableSet.AddressSet members;\n        bytes32 adminRole;\n    }\n\n    mapping (bytes32 => RoleData) private _roles;\n\n    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;\n\n    /**\n     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`\n     *\n     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite\n     * {RoleAdminChanged} not being emitted signaling this.\n     *\n     * _Available since v3.1._\n     */\n    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);\n\n    /**\n     * @dev Emitted when `account` is granted `role`.\n     *\n     * `sender` is the account that originated the contract call, an admin role\n     * bearer except when using {_setupRole}.\n     */\n    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Emitted when `account` is revoked `role`.\n     *\n     * `sender` is the account that originated the contract call:\n     *   - if using `revokeRole`, it is the admin role bearer\n     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)\n     */\n    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) public view returns (bool) {\n        return _roles[role].members.contains(account);\n    }\n\n    /**\n     * @dev Returns the number of accounts that have `role`. Can be used\n     * together with {getRoleMember} to enumerate all bearers of a role.\n     */\n    function getRoleMemberCount(bytes32 role) public view returns (uint256) {\n        return _roles[role].members.length();\n    }\n\n    /**\n     * @dev Returns one of the accounts that have `role`. `index` must be a\n     * value between 0 and {getRoleMemberCount}, non-inclusive.\n     *\n     * Role bearers are not sorted in any particular way, and their ordering may\n     * change at any point.\n     *\n     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure\n     * you perform all queries on the same block. See the following\n     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]\n     * for more information.\n     */\n    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {\n        return _roles[role].members.at(index);\n    }\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) public view returns (bytes32) {\n        return _roles[role].adminRole;\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) public virtual {\n        require(hasRole(_roles[role].adminRole, _msgSender()), \"AccessControl: sender must be an admin to grant\");\n\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) public virtual {\n        require(hasRole(_roles[role].adminRole, _msgSender()), \"AccessControl: sender must be an admin to revoke\");\n\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been granted `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) public virtual {\n        require(account == _msgSender(), \"AccessControl: can only renounce roles for self\");\n\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event. Note that unlike {grantRole}, this function doesn't perform any\n     * checks on the calling account.\n     *\n     * [WARNING]\n     * ====\n     * This function should only be called from the constructor when setting\n     * up the initial roles for the system.\n     *\n     * Using this function in any other way is effectively circumventing the admin\n     * system imposed by {AccessControl}.\n     * ====\n     */\n    function _setupRole(bytes32 role, address account) internal virtual {\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Sets `adminRole` as ``role``'s admin role.\n     *\n     * Emits a {RoleAdminChanged} event.\n     */\n    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {\n        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);\n        _roles[role].adminRole = adminRole;\n    }\n\n    function _grantRole(bytes32 role, address account) private {\n        if (_roles[role].members.add(account)) {\n            emit RoleGranted(role, account, _msgSender());\n        }\n    }\n\n    function _revokeRole(bytes32 role, address account) private {\n        if (_roles[role].members.remove(account)) {\n            emit RoleRevoked(role, account, _msgSender());\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.2 <0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { size := extcodesize(account) }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\n        (bool success, ) = recipient.call{ value: amount }(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain`call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n      return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.call{ value: value }(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                // solhint-disable-next-line no-inline-assembly\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Library for managing\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\n * types.\n *\n * Sets have the following properties:\n *\n * - Elements are added, removed, and checked for existence in constant time\n * (O(1)).\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\n *\n * ```\n * contract Example {\n *     // Add the library methods\n *     using EnumerableSet for EnumerableSet.AddressSet;\n *\n *     // Declare a set state variable\n *     EnumerableSet.AddressSet private mySet;\n * }\n * ```\n *\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\n * and `uint256` (`UintSet`) are supported.\n */\nlibrary EnumerableSet {\n    // To implement this library for multiple types with as little code\n    // repetition as possible, we write it in terms of a generic Set type with\n    // bytes32 values.\n    // The Set implementation uses private functions, and user-facing\n    // implementations (such as AddressSet) are just wrappers around the\n    // underlying Set.\n    // This means that we can only create new EnumerableSets for types that fit\n    // in bytes32.\n\n    struct Set {\n        // Storage of set values\n        bytes32[] _values;\n\n        // Position of the value in the `values` array, plus 1 because index 0\n        // means a value is not in the set.\n        mapping (bytes32 => uint256) _indexes;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function _add(Set storage set, bytes32 value) private returns (bool) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            // The value is stored at length-1, but we add 1 to all indexes\n            // and use 0 as a sentinel value\n            set._indexes[value] = set._values.length;\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\n        // We read and store the value's index to prevent multiple reads from the same storage slot\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) { // Equivalent to contains(set, value)\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\n            // the array, and then remove the last element (sometimes called as 'swap and pop').\n            // This modifies the order of the array, as noted in {at}.\n\n            uint256 toDeleteIndex = valueIndex - 1;\n            uint256 lastIndex = set._values.length - 1;\n\n            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs\n            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.\n\n            bytes32 lastvalue = set._values[lastIndex];\n\n            // Move the last value to the index where the value to delete is\n            set._values[toDeleteIndex] = lastvalue;\n            // Update the index for the moved value\n            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based\n\n            // Delete the slot where the moved value was stored\n            set._values.pop();\n\n            // Delete the index for the deleted slot\n            delete set._indexes[value];\n\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\n        require(set._values.length > index, \"EnumerableSet: index out of bounds\");\n        return set._values[index];\n    }\n\n    // Bytes32Set\n\n    struct Bytes32Set {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _add(set._inner, value);\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _remove(set._inner, value);\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\n        return _contains(set._inner, value);\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(Bytes32Set storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\n        return _at(set._inner, index);\n    }\n\n    // AddressSet\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(AddressSet storage set, address value) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(AddressSet storage set, address value) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\n        return address(uint160(uint256(_at(set._inner, index))));\n    }\n\n\n    // UintSet\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n}\n"
    },
    "contracts/helper/BaseBoringBatchable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\n// solhint-disable avoid-low-level-calls\n// solhint-disable no-inline-assembly\n\n// Audit on 5-Jan-2021 by Keno and BoringCrypto\n// WARNING!!!\n// Combining BoringBatchable with msg.value can cause double spending issues\n// https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong/\n\ncontract BaseBoringBatchable {\n    /// @dev Helper function to extract a useful revert message from a failed call.\n    /// If the returned data is malformed or not correctly abi encoded then this call can fail itself.\n    function _getRevertMsg(bytes memory _returnData)\n        internal\n        pure\n        returns (string memory)\n    {\n        // If the _res length is less than 68, then the transaction failed silently (without a revert message)\n        if (_returnData.length < 68) return \"Transaction reverted silently\";\n\n        assembly {\n            // Slice the sighash.\n            _returnData := add(_returnData, 0x04)\n        }\n        return abi.decode(_returnData, (string)); // All that remains is the revert string\n    }\n\n    /// @notice Allows batched call to self (this contract).\n    /// @param calls An array of inputs for each call.\n    /// @param revertOnFail If True then reverts after a failed call and stops doing further calls.\n    // F1: External is ok here because this is the batch function, adding it to a batch makes no sense\n    // F2: Calls in the batch may be payable, delegatecall operates in the same context, so each call in the batch has access to msg.value\n    // C3: The length of the loop is fully under user control, so can't be exploited\n    // C7: Delegatecall is only used on the same contract, so it's safe\n    function batch(bytes[] calldata calls, bool revertOnFail) external payable {\n        for (uint256 i = 0; i < calls.length; i++) {\n            (bool success, bytes memory result) = address(this).delegatecall(\n                calls[i]\n            );\n            if (!success && revertOnFail) {\n                revert(_getRevertMsg(result));\n            }\n        }\n    }\n}\n"
    },
    "contracts/interfaces/IMasterRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.6.0;\npragma experimental ABIEncoderV2;\n\ninterface IMasterRegistry {\n    /* Structs */\n\n    struct ReverseRegistryData {\n        bytes32 name;\n        uint256 version;\n    }\n\n    /* Functions */\n\n    /**\n     * @notice Add a new registry entry to the master list.\n     * @param registryName name for the registry\n     * @param registryAddress address of the new registry\n     */\n    function addRegistry(bytes32 registryName, address registryAddress)\n        external\n        payable;\n\n    /**\n     * @notice Resolves a name to the latest registry address. Reverts if no match is found.\n     * @param name name for the registry\n     * @return address address of the latest registry with the matching name\n     */\n    function resolveNameToLatestAddress(bytes32 name)\n        external\n        view\n        returns (address);\n\n    /**\n     * @notice Resolves a name and version to an address. Reverts if there is no registry with given name and version.\n     * @param name address of the registry you want to resolve to\n     * @param version version of the registry you want to resolve to\n     */\n    function resolveNameAndVersionToAddress(bytes32 name, uint256 version)\n        external\n        view\n        returns (address);\n\n    /**\n     * @notice Resolves a name to an array of all addresses. Reverts if no match is found.\n     * @param name name for the registry\n     * @return address address of the latest registry with the matching name\n     */\n    function resolveNameToAllAddresses(bytes32 name)\n        external\n        view\n        returns (address[] memory);\n\n    /**\n     * @notice Resolves an address to registry entry data.\n     * @param registryAddress address of a registry you want to resolve\n     * @return name name of the resolved registry\n     * @return version version of the resolved registry\n     * @return isLatest boolean flag of whether the given address is the latest version of the given registries with\n     * matching name\n     */\n    function resolveAddressToRegistryData(address registryAddress)\n        external\n        view\n        returns (\n            bytes32 name,\n            uint256 version,\n            bool isLatest\n        );\n}\n"
    },
    "contracts/registries/MasterRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"@openzeppelin/contracts/access/AccessControl.sol\";\nimport \"../helper/BaseBoringBatchable.sol\";\nimport \"../interfaces/IMasterRegistry.sol\";\n\n/**\n * @title MasterRegistry\n * @notice This contract holds list of other registries or contracts and its historical versions.\n */\ncontract MasterRegistry is AccessControl, IMasterRegistry, BaseBoringBatchable {\n    /// @notice Role responsible for adding registries.\n    bytes32 public constant SADDLE_MANAGER_ROLE =\n        keccak256(\"SADDLE_MANAGER_ROLE\");\n\n    mapping(bytes32 => address[]) private registryMap;\n    mapping(address => ReverseRegistryData) private reverseRegistry;\n\n    /**\n     * @notice Add a new registry entry to the master list.\n     * @param name address of the added pool\n     * @param registryAddress address of the registry\n     * @param version version of the registry\n     */\n    event AddRegistry(\n        bytes32 indexed name,\n        address registryAddress,\n        uint256 version\n    );\n\n    constructor(address admin) public {\n        _setupRole(DEFAULT_ADMIN_ROLE, admin);\n        _setupRole(SADDLE_MANAGER_ROLE, msg.sender);\n    }\n\n    /// @inheritdoc IMasterRegistry\n    function addRegistry(bytes32 registryName, address registryAddress)\n        external\n        payable\n        override\n    {\n        require(\n            hasRole(SADDLE_MANAGER_ROLE, msg.sender),\n            \"MR: msg.sender is not allowed\"\n        );\n        require(registryName != 0, \"MR: name cannot be empty\");\n        require(registryAddress != address(0), \"MR: address cannot be empty\");\n\n        address[] storage registry = registryMap[registryName];\n        uint256 version = registry.length;\n        registry.push(registryAddress);\n        require(\n            reverseRegistry[registryAddress].name == 0,\n            \"MR: duplicate registry address\"\n        );\n        reverseRegistry[registryAddress] = ReverseRegistryData(\n            registryName,\n            version\n        );\n\n        emit AddRegistry(registryName, registryAddress, version);\n    }\n\n    /// @inheritdoc IMasterRegistry\n    function resolveNameToLatestAddress(bytes32 name)\n        external\n        view\n        override\n        returns (address)\n    {\n        address[] storage registry = registryMap[name];\n        uint256 length = registry.length;\n        require(length > 0, \"MR: no match found for name\");\n        return registry[length - 1];\n    }\n\n    /// @inheritdoc IMasterRegistry\n    function resolveNameAndVersionToAddress(bytes32 name, uint256 version)\n        external\n        view\n        override\n        returns (address)\n    {\n        address[] storage registry = registryMap[name];\n        require(\n            version < registry.length,\n            \"MR: no match found for name and version\"\n        );\n        return registry[version];\n    }\n\n    /// @inheritdoc IMasterRegistry\n    function resolveNameToAllAddresses(bytes32 name)\n        external\n        view\n        override\n        returns (address[] memory)\n    {\n        address[] storage registry = registryMap[name];\n        require(registry.length > 0, \"MR: no match found for name\");\n        return registry;\n    }\n\n    /// @inheritdoc IMasterRegistry\n    function resolveAddressToRegistryData(address registryAddress)\n        external\n        view\n        override\n        returns (\n            bytes32 name,\n            uint256 version,\n            bool isLatest\n        )\n    {\n        ReverseRegistryData memory data = reverseRegistry[registryAddress];\n        require(data.name != 0, \"MR: no match found for address\");\n        name = data.name;\n        version = data.version;\n        uint256 length = registryMap[name].length;\n        require(length > 0, \"MR: no version found for address\");\n        isLatest = version == length - 1;\n    }\n}\n"
    }
  }
}}