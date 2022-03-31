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
      "enabled": true,
      "runs": 2000
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
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IAccessControl.sol\";\nimport \"../utils/Context.sol\";\nimport \"../utils/Strings.sol\";\nimport \"../utils/introspection/ERC165.sol\";\n\n/**\n * @dev Contract module that allows children to implement role-based access\n * control mechanisms. This is a lightweight version that doesn't allow enumerating role\n * members except through off-chain means by accessing the contract event logs. Some\n * applications may benefit from on-chain enumerability, for those cases see\n * {AccessControlEnumerable}.\n *\n * Roles are referred to by their `bytes32` identifier. These should be exposed\n * in the external API and be unique. The best way to achieve this is by\n * using `public constant` hash digests:\n *\n * ```\n * bytes32 public constant MY_ROLE = keccak256(\"MY_ROLE\");\n * ```\n *\n * Roles can be used to represent a set of permissions. To restrict access to a\n * function call, use {hasRole}:\n *\n * ```\n * function foo() public {\n *     require(hasRole(MY_ROLE, msg.sender));\n *     ...\n * }\n * ```\n *\n * Roles can be granted and revoked dynamically via the {grantRole} and\n * {revokeRole} functions. Each role has an associated admin role, and only\n * accounts that have a role's admin role can call {grantRole} and {revokeRole}.\n *\n * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means\n * that only accounts with this role will be able to grant or revoke other\n * roles. More complex role relationships can be created by using\n * {_setRoleAdmin}.\n *\n * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to\n * grant and revoke this role. Extra precautions should be taken to secure\n * accounts that have been granted it.\n */\nabstract contract AccessControl is Context, IAccessControl, ERC165 {\n    struct RoleData {\n        mapping(address => bool) members;\n        bytes32 adminRole;\n    }\n\n    mapping(bytes32 => RoleData) private _roles;\n\n    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;\n\n    /**\n     * @dev Modifier that checks that an account has a specific role. Reverts\n     * with a standardized message including the required role.\n     *\n     * The format of the revert reason is given by the following regular expression:\n     *\n     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/\n     *\n     * _Available since v4.1._\n     */\n    modifier onlyRole(bytes32 role) {\n        _checkRole(role, _msgSender());\n        _;\n    }\n\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);\n    }\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {\n        return _roles[role].members[account];\n    }\n\n    /**\n     * @dev Revert with a standard message if `account` is missing `role`.\n     *\n     * The format of the revert reason is given by the following regular expression:\n     *\n     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/\n     */\n    function _checkRole(bytes32 role, address account) internal view virtual {\n        if (!hasRole(role, account)) {\n            revert(\n                string(\n                    abi.encodePacked(\n                        \"AccessControl: account \",\n                        Strings.toHexString(uint160(account), 20),\n                        \" is missing role \",\n                        Strings.toHexString(uint256(role), 32)\n                    )\n                )\n            );\n        }\n    }\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {\n        return _roles[role].adminRole;\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been revoked `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) public virtual override {\n        require(account == _msgSender(), \"AccessControl: can only renounce roles for self\");\n\n        _revokeRole(role, account);\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event. Note that unlike {grantRole}, this function doesn't perform any\n     * checks on the calling account.\n     *\n     * [WARNING]\n     * ====\n     * This function should only be called from the constructor when setting\n     * up the initial roles for the system.\n     *\n     * Using this function in any other way is effectively circumventing the admin\n     * system imposed by {AccessControl}.\n     * ====\n     *\n     * NOTE: This function is deprecated in favor of {_grantRole}.\n     */\n    function _setupRole(bytes32 role, address account) internal virtual {\n        _grantRole(role, account);\n    }\n\n    /**\n     * @dev Sets `adminRole` as ``role``'s admin role.\n     *\n     * Emits a {RoleAdminChanged} event.\n     */\n    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {\n        bytes32 previousAdminRole = getRoleAdmin(role);\n        _roles[role].adminRole = adminRole;\n        emit RoleAdminChanged(role, previousAdminRole, adminRole);\n    }\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * Internal function without access restriction.\n     */\n    function _grantRole(bytes32 role, address account) internal virtual {\n        if (!hasRole(role, account)) {\n            _roles[role].members[account] = true;\n            emit RoleGranted(role, account, _msgSender());\n        }\n    }\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * Internal function without access restriction.\n     */\n    function _revokeRole(bytes32 role, address account) internal virtual {\n        if (hasRole(role, account)) {\n            _roles[role].members[account] = false;\n            emit RoleRevoked(role, account, _msgSender());\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/IAccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of AccessControl declared to support ERC165 detection.\n */\ninterface IAccessControl {\n    /**\n     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`\n     *\n     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite\n     * {RoleAdminChanged} not being emitted signaling this.\n     *\n     * _Available since v3.1._\n     */\n    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);\n\n    /**\n     * @dev Emitted when `account` is granted `role`.\n     *\n     * `sender` is the account that originated the contract call, an admin role\n     * bearer except when using {AccessControl-_setupRole}.\n     */\n    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Emitted when `account` is revoked `role`.\n     *\n     * `sender` is the account that originated the contract call:\n     *   - if using `revokeRole`, it is the admin role bearer\n     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)\n     */\n    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) external view returns (bool);\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {AccessControl-_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) external view returns (bytes32);\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been granted `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) external;\n}\n"
    },
    "@openzeppelin/contracts/security/Pausable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\nabstract contract Pausable is Context {\n    /**\n     * @dev Emitted when the pause is triggered by `account`.\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by `account`.\n     */\n    event Unpaused(address account);\n\n    bool private _paused;\n\n    /**\n     * @dev Initializes the contract in unpaused state.\n     */\n    constructor() {\n        _paused = false;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view virtual returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    modifier whenNotPaused() {\n        require(!paused(), \"Pausable: paused\");\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    modifier whenPaused() {\n        require(paused(), \"Pausable: not paused\");\n        _;\n    }\n\n    /**\n     * @dev Triggers stopped state.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    function _pause() internal virtual whenNotPaused {\n        _paused = true;\n        emit Paused(_msgSender());\n    }\n\n    /**\n     * @dev Returns to normal state.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    function _unpause() internal virtual whenPaused {\n        _paused = false;\n        emit Unpaused(_msgSender());\n    }\n}\n"
    },
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        // On the first call to nonReentrant, _notEntered will be true\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n\n        _;\n\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/IERC721.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../../utils/introspection/IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC721 compliant contract.\n */\ninterface IERC721 is IERC165 {\n    /**\n     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\n     */\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\n     */\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /**\n     * @dev Returns the number of tokens in ``owner``'s account.\n     */\n    function balanceOf(address owner) external view returns (uint256 balance);\n\n    /**\n     * @dev Returns the owner of the `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Transfers `tokenId` token from `from` to `to`.\n     *\n     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    /**\n     * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n     * The approval is cleared when the token is transferred.\n     *\n     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n     *\n     * Requirements:\n     *\n     * - The caller must own the token or be an approved operator.\n     * - `tokenId` must exist.\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address to, uint256 tokenId) external;\n\n    /**\n     * @dev Returns the account approved for `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function getApproved(uint256 tokenId) external view returns (address operator);\n\n    /**\n     * @dev Approve or remove `operator` as an operator for the caller.\n     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n     *\n     * Requirements:\n     *\n     * - The `operator` cannot be the caller.\n     *\n     * Emits an {ApprovalForAll} event.\n     */\n    function setApprovalForAll(address operator, bool _approved) external;\n\n    /**\n     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n     *\n     * See {setApprovalForAll}\n     */\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes calldata data\n    ) external;\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/ERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC165.sol\";\n\n/**\n * @dev Implementation of the {IERC165} interface.\n *\n * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check\n * for the additional interface id that will be supported. For example:\n *\n * ```solidity\n * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);\n * }\n * ```\n *\n * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.\n */\nabstract contract ERC165 is IERC165 {\n    /**\n     * @dev See {IERC165-supportsInterface}.\n     */\n    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {\n        return interfaceId == type(IERC165).interfaceId;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "contracts/TempMint.sol": {
      "content": "//*~~~> SPDX-License-Identifier: MIT \n/*~~~> PHUNKS\n    Thank you for your inspiration and phriendship meant.\n      Never stop phighting, never surrender, always stand up for what is right and make the best of all situations towards all people.\n      Phunks are phreedom phighters!\n        \"When the power of love overcomes the love of power the world will know peace.\" - Jimi Hendrix <3\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((((((((((((((((((((((@@@@@##############################%%%%%@@@@@((((((((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((((((((((((((((((((((@@@@@##############################%%%%%@@@@@((((((((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((@@@@@########################################%%%%%@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((@@@@@########################################%%%%%@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@###############@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@###############@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@@@@@##########@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@@@@@##########@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@/////////////////////////////////////////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@/////////////////////////////////////////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@#PHUNKYJON///////////////#PHUNKYJON//////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@#PHUNKYJON///////////////#PHUNKYJON//////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@/////@EYES////////////////////@EYES///////////////@@@@@((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@/////@EYES////////////////////@EYES///////////////EAR@@((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@//////////////////////////////////////////////////EAR@@((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@//////////////////////////////////////////////////EAR@@((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@/////////////////////////////////////////////@@@@@@@@@@((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@/////////////////////////////////////////////@@@@@@@@@@((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@//////////NOSE@NOSE@////////////////////#####@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((SMOKE((((((((((@@@@@//////////NOSE@NOSE@////////////////////#####@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((@@@@@#####//////////////////////////////##########@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((@@@@@#####//////////////////////////////##########@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((@SPLIFF@SPLIFF@SPLIFF@SPLIFF@@###################################@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((@SPLIFF@SPLIFF@SPLIFF@SPLIFF@@###################################@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((EMBER(((((,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@MOUTH&&&&&####################@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((EMBER(((((,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@MOUTH&&&&&####################@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((@SPLIFF@SPLIFF@SPLIFF@SPLIFF@@##############################/////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((@SPLIFF@SPLIFF@SPLIFF@SPLIFF@@##############################/////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((((((((((((((((((((((@@@@@##############################//////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%(((((((((((((((((((((((((((((((((((@@@@@##############################//////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@///////////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@///////////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((@@@@@///////////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((@@@@@///////////////@@@@@(((((((((((((((((((((((((%%%%%\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@@@@@///////////////@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@@@@@///////////////@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n <~~~*/\n\npragma solidity 0.8.7;\n\nimport \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport \"@openzeppelin/contracts/security/Pausable.sol\";\nimport \"@openzeppelin/contracts/token/ERC721/IERC721.sol\";\nimport \"@openzeppelin/contracts/access/AccessControl.sol\";\n\ninterface MarketNFT {\n  function safeMint(address to, uint _tokenId) external;\n}\ncontract TempMint is ReentrancyGuard, Pausable, AccessControl {\n  /*~~~>\n    State variables\n  <~~~*/\n  uint public nftsRedeemed;\n  uint public mintPrice;\n  address public nftAddress;\n\n  //*~~~> Marketplace NFT that can be used to claim rewards and act as a DAO\n  struct NFT {\n    uint tokenId;\n    address contractAddress;\n    address minter;\n  }\n\n  //*~~~> DEV_ROLE for designated accessibility\n  bytes32 public constant DEV_ROLE = keccak256(\"DEV_ROLE\");\n  modifier hasDevAdmin(){\n    require(hasRole(DEV_ROLE, msg.sender), \"DOES NOT HAVE DEV ROLE\");\n    _;\n  }\n\n  constructor(address deployer) {\n    _setupRole(DEFAULT_ADMIN_ROLE, deployer);\n    _setupRole(DEV_ROLE, deployer);\n    nftsRedeemed = 0;\n    mintPrice = 0;\n  }\n\n  //*~~~> Memory mappings\n  mapping (uint256 => NFT) private _idToNft;\n  \n  // Event declarations\n  event nftClaimed(uint nftId, address minter, address receiver);\n  event Received(address, uint);\n\n  /// @notice\n    /*~~~>\n      DEV_ROLE write function for setting the NFT contract address\n    <~~~*/\n  ///@dev \n  //*~~~> uint contractAddress: address of new NFT contract\n  /// @return Bool\n  function setNftAddress(address _contractAddress) external hasDevAdmin returns(bool){\n    nftAddress = _contractAddress;\n    return true;\n  }\n\n  /// @notice\n    /*~~~>\n      DEV_ROLE write function for setting the mint price\n    <~~~*/\n  ///@dev \n  //*~~~> uint mintPrice: price in wei\n  /// @return Bool\n  function setMintPrice(uint _mintPrice) external hasDevAdmin returns(bool){\n    mintPrice = _mintPrice;\n    return true;\n  }\n\n  /// @notice\n    /*~~~>\n      Public write function for minting new NFTs incrementally\n    <~~~*/\n  ///@dev \n  //*~~~> uint howMany: howMany to mint\n  //*~~~> address[] calldata toWhom: who receives the NFT minted\n  /// @return Bool\n  function redeemForNft(uint howMany, address[] calldata toWhom) external payable whenNotPaused returns(bool){\n    require(msg.value >= mintPrice * howMany);\n    uint id = nftsRedeemed;\n    for(uint i = 0; i < howMany; i+=1){\n      MarketNFT(nftAddress).safeMint(toWhom[i], id);\n      _idToNft[id] = NFT(id, nftAddress, toWhom[i]);\n      emit nftClaimed(id, msg.sender, toWhom[i]);\n      id++;\n    }\n    nftsRedeemed=id;\n    return true;\n  }\n\n  /// @notice\n  /*~~~>\n    Public read function for retrieving internal memory items of NFTs minted\n  <~~~*/\n  /// @return NFT[] memory array\n  function fetchNFTsCreated() external view returns (NFT[] memory) {\n    NFT[] memory nfts = new NFT[](nftsRedeemed);\n    uint currentIndex;\n    for (uint i = 0; i < nftsRedeemed; i++) {\n      NFT storage currentItem = _idToNft[i];\n      nfts[currentIndex] = currentItem;\n      currentIndex++;\n    }\n    return nfts;\n  }\n\n  /// @notice\n  /*~~~>\n    Function for retrieving uint count of NFTs minted\n  <~~~*/\n  /// @return uint\n  function fetchNFTsCreatedCount() external view returns (uint) {\n    return nftsRedeemed;\n  }\n\n  function fetchMintPrice() external view returns (uint) {\n    return mintPrice;\n  }\n\n  ///@notice DEV operations for emergency functions\n  function pause() external hasDevAdmin {\n      _pause();\n  }\n  function unpause() external hasDevAdmin {\n      _unpause();\n  }\n\n  //*~~~> Fallback functions\n  function onERC1155Received(address, address, uint256, uint256, bytes memory) external virtual returns (bytes4) {\n      return this.onERC1155Received.selector;\n    }\n  function onERC721Received(\n      address, \n      address, \n      uint256, \n      bytes calldata\n    ) external pure returns(bytes4) {\n    return bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"));\n  }\n  \n  ///@notice\n  //*~~~> DEV_ROLE withdraw function for ETH sent\n  function withdrawAmountFromContract(address receiver) hasDevAdmin external {\n      payable(receiver).transfer(address(this).balance);\n   }\n}"
    }
  }
}}