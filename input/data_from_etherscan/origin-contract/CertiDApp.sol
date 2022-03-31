{"CertiDApp.sol":{"content":"pragma solidity 0.6.2;\npragma experimental ABIEncoderV2;\n\nimport \u0027RLP.sol\u0027;\nimport \u0027StorageStructure.sol\u0027;\n\n/// @title CertiÐApp Smart Contract\n/// @author Soham Zemse from The EraSwap Team\n/// @notice This contract accepts certificates signed by multiple authorised signers\ncontract CertiDApp is StorageStructure {\n  using RLP for bytes;\n  using RLP for RLP.RLPItem;\n\n  /// @notice Sets up the CertiDApp manager address when deployed\n  constructor() public {\n    _changeManager(msg.sender);\n  }\n\n  /// @notice Used by present manager to change the manager wallet address\n  /// @param _newManagerAddress Address of next manager wallet\n  function changeManager(address _newManagerAddress) public onlyManager {\n    _changeManager(_newManagerAddress);\n  }\n\n  /// @notice Used by manager to for to update KYC / verification status of Certifying Authorities\n  /// @param _authorityAddress Wallet address of certifying authority\n  /// @param _data RLP encoded KYC details of certifying authority\n  function updateCertifyingAuthority(\n    address _authorityAddress,\n    bytes memory _data,\n    AuthorityStatus _status\n  ) public onlyManager {\n    if(_data.length \u003e 0) {\n      certifyingAuthorities[_authorityAddress].data = _data;\n    }\n\n    certifyingAuthorities[_authorityAddress].status = _status;\n\n    emit AuthorityStatusUpdated(_authorityAddress, _status);\n  }\n\n  /// @notice Used by Certifying Authorities to change their wallet (in case of theft).\n  ///   Migrating prevents any new certificate registrations signed by the old wallet.\n  ///   Already registered certificates would be valid.\n  /// @param _newAuthorityAddress Next wallet address of the same certifying authority\n  function migrateCertifyingAuthority(\n    address _newAuthorityAddress\n  ) public onlyAuthorisedCertifier {\n    require(\n      certifyingAuthorities[_newAuthorityAddress].status == AuthorityStatus.NotAuthorised\n      , \u0027cannot migrate to an already authorised address\u0027\n    );\n\n    certifyingAuthorities[msg.sender].status = AuthorityStatus.Migrated;\n    emit AuthorityStatusUpdated(msg.sender, AuthorityStatus.Migrated);\n\n    certifyingAuthorities[_newAuthorityAddress] = CertifyingAuthority({\n      data: certifyingAuthorities[msg.sender].data,\n      status: AuthorityStatus.Authorised\n    });\n    emit AuthorityStatusUpdated(_newAuthorityAddress, AuthorityStatus.Authorised);\n\n    emit AuthorityMigrated(msg.sender, _newAuthorityAddress);\n  }\n\n  /// @notice Used to submit a signed certificate to smart contract for adding it to storage.\n  ///   Anyone can submit the certificate, the one submitting has to pay the nominal gas fee.\n  /// @param _signedCertificate RLP encoded certificate according to CertiDApp Certificate standard.\n  function registerCertificate(\n    bytes memory _signedCertificate\n  ) public returns (\n    bytes32\n  ) {\n    (Certificate memory _certificateObj, bytes32 _certificateHash) = parseSignedCertificate(_signedCertificate, true);\n\n    /// @notice Signers in this transaction\n    bytes memory _newSigners = _certificateObj.signers;\n\n    /// @notice If certificate already registered then signers can be updated.\n    ///   Initializing _updatedSigners with existing signers on blockchain if any.\n    ///   More signers would be appended to this in next \u0027for\u0027 loop.\n    bytes memory _updatedSigners = certificates[_certificateHash].signers;\n\n    /// @notice Check with every the new signer if it is not already included in storage.\n    ///   This is helpful when a same certificate is submitted again with more signatures,\n    ///   the contract will consider only new signers in that case.\n    for(uint256 i = 0; i \u003c _newSigners.length; i += 20) {\n      address _signer;\n      assembly {\n        _signer := mload(add(_newSigners, add(0x14, i)))\n      }\n      if(_checkUniqueSigner(_signer, certificates[_certificateHash].signers)) {\n        _updatedSigners = abi.encodePacked(_updatedSigners, _signer);\n        emit Certified(\n          _certificateHash,\n          _signer\n        );\n      }\n    }\n\n    /// @notice check whether the certificate is freshly being registered.\n    ///   For new certificates, directly proceed with adding it.\n    ///   For existing certificates only update the signers if there are any new.\n    if(certificates[_certificateHash].signers.length \u003e 0) {\n      require(_updatedSigners.length \u003e certificates[_certificateHash].signers.length, \u0027need new signers\u0027);\n      certificates[_certificateHash].signers = _updatedSigners;\n    } else {\n      certificates[_certificateHash] = _certificateObj;\n    }\n\n    return _certificateHash;\n  }\n\n  /// @notice Used by contract to seperate signers from certificate data.\n  /// @param _signedCertificate RLP encoded certificate according to CertiDApp Certificate standard.\n  /// @param _allowedSignersOnly Should it consider only KYC approved signers ?\n  /// @return _certificateObj Seperation of certificate data and signers (computed from signatures)\n  /// @return _certificateHash Unique identifier of the certificate data\n  function parseSignedCertificate(\n    bytes memory _signedCertificate,\n    bool _allowedSignersOnly\n  ) public view returns (\n    Certificate memory _certificateObj,\n    bytes32 _certificateHash\n  ) {\n    RLP.RLPItem[] memory _certificateRLP = _signedCertificate.toRlpItem().toList();\n\n    _certificateObj.data = _certificateRLP[0].toRlpBytes();\n\n    _certificateHash = keccak256(abi.encodePacked(\n      PERSONAL_PREFIX,\n      _getBytesStr(_certificateObj.data.length),\n      _certificateObj.data\n    ));\n\n    /// @notice loop through every signature and use eliptic curves cryptography to recover the\n    ///   address of the wallet used for signing the certificate.\n    for(uint256 i = 1; i \u003c _certificateRLP.length; i += 1) {\n      bytes memory _signature = _certificateRLP[i].toBytes();\n\n      bytes32 _r;\n      bytes32 _s;\n      uint8 _v;\n\n      assembly {\n        let _pointer := add(_signature, 0x20)\n        _r := mload(_pointer)\n        _s := mload(add(_pointer, 0x20))\n        _v := byte(0, mload(add(_pointer, 0x40)))\n        if lt(_v, 27) { _v := add(_v, 27) }\n      }\n\n      require(_v == 27 || _v == 28, \u0027invalid recovery value\u0027);\n\n      address _signer = ecrecover(_certificateHash, _v, _r, _s);\n\n      require(_checkUniqueSigner(_signer, _certificateObj.signers), \u0027each signer should be unique\u0027);\n\n      if(_allowedSignersOnly) {\n        require(certifyingAuthorities[_signer].status == AuthorityStatus.Authorised, \u0027certifier not authorised\u0027);\n      }\n\n      /// @dev packing every signer address into a single bytes value\n      _certificateObj.signers = abi.encodePacked(_certificateObj.signers, _signer);\n    }\n  }\n\n  /// @notice Used to change the manager\n  /// @param _newManagerAddress Address of next manager wallet\n  function _changeManager(address _newManagerAddress) private {\n    manager = _newManagerAddress;\n    emit ManagerUpdated(_newManagerAddress);\n  }\n\n  /// @notice Used to check whether an address exists in packed addresses bytes\n  /// @param _signer Address of the signer wallet\n  /// @param _packedSigners Bytes string of addressed packed together\n  /// @return boolean value which means if _signer doesnot exist in _packedSigners bytes string\n  function _checkUniqueSigner(\n    address _signer,\n    bytes memory _packedSigners\n  ) private pure returns (bool){\n    if(_packedSigners.length == 0) return true;\n\n    require(_packedSigners.length % 20 == 0, \u0027invalid packed signers length\u0027);\n\n    address _tempSigner;\n    /// @notice loop through every packed signer and check if signer exists in the packed signers\n    for(uint256 i = 0; i \u003c _packedSigners.length; i += 20) {\n      assembly {\n        _tempSigner := mload(add(_packedSigners, add(0x14, i)))\n      }\n      if(_tempSigner == _signer) return false;\n    }\n\n    return true;\n  }\n\n  /// @notice Used to get a number\u0027s utf8 representation\n  /// @param i Integer\n  /// @return utf8 representation of i\n  function _getBytesStr(uint i) private pure returns (bytes memory) {\n    if (i == 0) {\n      return \"0\";\n    }\n    uint j = i;\n    uint len;\n    while (j != 0) {\n      len++;\n      j /= 10;\n    }\n    bytes memory bstr = new bytes(len);\n    uint k = len - 1;\n    while (i != 0) {\n      bstr[k--] = byte(uint8(48 + i % 10));\n      i /= 10;\n    }\n    return bstr;\n  }\n}\n"},"Proxy.sol":{"content":"pragma solidity 0.6.2;\n\nimport \u0027StorageStructure.sol\u0027;\n\n/**\n * https://eips.ethereum.org/EIPS/eip-897\n * Credits: OpenZeppelin Labs\n */\ncontract Proxy is StorageStructure {\n  string public version;\n  address public implementation;\n  uint256 public constant proxyType = 2;\n\n  /**\n   * @dev This event will be emitted every time the implementation gets upgraded\n   * @param version representing the version name of the upgraded implementation\n   * @param implementation representing the address of the upgraded implementation\n   */\n  event Upgraded(string version, address indexed implementation);\n\n  /**\n   * @dev constructor that sets the manager address\n   */\n  constructor() public {\n    manager = msg.sender;\n  }\n\n  /**\n   * @dev Upgrades the implementation address\n   * @param _newImplementation address of the new implementation\n   */\n  function upgradeTo(\n    string calldata _version,\n    address _newImplementation\n  ) external onlyManager {\n    require(implementation != _newImplementation);\n    _setImplementation(_version, _newImplementation);\n  }\n\n  /**\n   * @dev Fallback function allowing to perform a delegatecall\n   * to the given implementation. This function will return\n   * whatever the implementation call returns\n   */\n  fallback () external {\n    address _impl = implementation;\n    require(_impl != address(0));\n\n    assembly {\n      let ptr := mload(0x40)\n      calldatacopy(ptr, 0, calldatasize())\n      let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)\n      let size := returndatasize()\n      returndatacopy(ptr, 0, size)\n\n      switch result\n      case 0 { revert(ptr, size) }\n      default { return(ptr, size) }\n    }\n  }\n\n  /**\n   * @dev Sets the address of the current implementation\n   * @param _newImp address of the new implementation\n   */\n  function _setImplementation(string memory _version, address _newImp) internal {\n    version = _version;\n    implementation = _newImp;\n    emit Upgraded(version, implementation);\n  }\n}\n"},"RLP.sol":{"content":"/**\n * Credits: https://github.com/hamdiallam/Solidity-RLP/blob/master/contracts/RLPReader.sol\n */\npragma solidity ^0.6.2;\n\nlibrary RLP {\n  uint8 constant STRING_SHORT_START = 0x80;\n  uint8 constant STRING_LONG_START  = 0xb8;\n  uint8 constant LIST_SHORT_START   = 0xc0;\n  uint8 constant LIST_LONG_START    = 0xf8;\n  uint8 constant WORD_SIZE = 32;\n\n  struct RLPItem {\n    uint len;\n    uint memPtr;\n  }\n\n  struct Iterator {\n    RLPItem item;   // Item that\u0027s being iterated over.\n    uint nextPtr;   // Position of the next item in the list.\n  }\n\n  /*\n  * @dev Returns the next element in the iteration. Reverts if it has not next element.\n  * @param self The iterator.\n  * @return The next element in the iteration.\n  */\n  function next(Iterator memory self) internal pure returns (RLPItem memory) {\n    require(hasNext(self));\n\n    uint ptr = self.nextPtr;\n    uint itemLength = _itemLength(ptr);\n    self.nextPtr = ptr + itemLength;\n\n    return RLPItem(itemLength, ptr);\n  }\n\n  /*\n  * @dev Returns true if the iteration has more elements.\n  * @param self The iterator.\n  * @return true if the iteration has more elements.\n  */\n  function hasNext(Iterator memory self) internal pure returns (bool) {\n    RLPItem memory item = self.item;\n    return self.nextPtr \u003c item.memPtr + item.len;\n  }\n\n  /*\n  * @param item RLP encoded bytes\n  */\n  function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {\n    uint memPtr;\n    assembly {\n      memPtr := add(item, 0x20)\n    }\n\n    return RLPItem(item.length, memPtr);\n  }\n\n  /*\n  * @dev Create an iterator. Reverts if item is not a list.\n  * @param self The RLP item.\n  * @return An \u0027Iterator\u0027 over the item.\n  */\n  function iterator(RLPItem memory self) internal pure returns (Iterator memory) {\n    require(isList(self));\n\n    uint ptr = self.memPtr + _payloadOffset(self.memPtr);\n    return Iterator(self, ptr);\n  }\n\n  /*\n  * @param item RLP encoded bytes\n  */\n  function rlpLen(RLPItem memory item) internal pure returns (uint) {\n    return item.len;\n  }\n\n  /*\n  * @param item RLP encoded bytes\n  */\n  function payloadLen(RLPItem memory item) internal pure returns (uint) {\n    return item.len - _payloadOffset(item.memPtr);\n  }\n\n  /*\n  * @param item RLP encoded list in bytes\n  */\n  function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {\n    require(isList(item));\n\n    uint items = numItems(item);\n    RLPItem[] memory result = new RLPItem[](items);\n\n    uint memPtr = item.memPtr + _payloadOffset(item.memPtr);\n    uint dataLen;\n    for (uint i = 0; i \u003c items; i++) {\n      dataLen = _itemLength(memPtr);\n      result[i] = RLPItem(dataLen, memPtr);\n      memPtr = memPtr + dataLen;\n    }\n\n    return result;\n  }\n\n  // @return indicator whether encoded payload is a list. negate this function call for isData.\n  function isList(RLPItem memory item) internal pure returns (bool) {\n    if(item.len == 0) return false;\n\n    uint8 byte0;\n    uint memPtr = item.memPtr;\n    assembly {\n      byte0 := byte(0, mload(memPtr))\n    }\n\n    if(byte0 \u003c LIST_SHORT_START) return false;\n\n    return true;\n  }\n\n  /** RLPItem conversions into data types **/\n\n  // @returns raw rlp encoding in bytes\n  function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {\n    bytes memory result = new bytes(item.len);\n    if (result.length == 0) return result;\n\n    uint ptr;\n    assembly {\n      ptr := add(0x20, result)\n    }\n\n    copy(item.memPtr, ptr, item.len);\n    return result;\n  }\n\n  // any non-zero byte is considered true\n  function toBoolean(RLPItem memory item) internal pure returns (bool) {\n    require(item.len == 1);\n    uint result;\n    uint memPtr = item.memPtr;\n    assembly {\n      result := byte(0, mload(memPtr))\n    }\n\n    return result == 0 ? false : true;\n  }\n\n  function toAddress(RLPItem memory item) internal pure returns (address) {\n    // 1 byte for the length prefix\n    require(item.len == 21);\n\n    return address(toUint(item));\n  }\n\n  function toUint(RLPItem memory item) internal pure returns (uint) {\n    require(item.len \u003e 0 \u0026\u0026 item.len \u003c= 33);\n\n    uint offset = _payloadOffset(item.memPtr);\n    uint len = item.len - offset;\n\n    uint result;\n    uint memPtr = item.memPtr + offset;\n    assembly {\n      result := mload(memPtr)\n\n      // shfit to the correct location if neccesary\n      if lt(len, 32) {\n          result := div(result, exp(256, sub(32, len)))\n      }\n    }\n\n    return result;\n  }\n\n  // enforces 32 byte length\n  function toUintStrict(RLPItem memory item) internal pure returns (uint) {\n    // one byte prefix\n    require(item.len == 33);\n\n    uint result;\n    uint memPtr = item.memPtr + 1;\n    assembly {\n      result := mload(memPtr)\n    }\n\n    return result;\n  }\n\n  function toBytes(RLPItem memory item) internal pure returns (bytes memory) {\n    require(item.len \u003e 0);\n\n    uint offset = _payloadOffset(item.memPtr);\n    uint len = item.len - offset; // data length\n    bytes memory result = new bytes(len);\n\n    uint destPtr;\n    assembly {\n      destPtr := add(0x20, result)\n    }\n\n    copy(item.memPtr + offset, destPtr, len);\n    return result;\n  }\n\n  /*\n  * Private Helpers\n  */\n\n  // @return number of payload items inside an encoded list.\n  function numItems(RLPItem memory item) private pure returns (uint) {\n    if (item.len == 0) return 0;\n\n    uint count = 0;\n    uint currPtr = item.memPtr + _payloadOffset(item.memPtr);\n    uint endPtr = item.memPtr + item.len;\n    while (currPtr \u003c endPtr) {\n      currPtr = currPtr + _itemLength(currPtr); // skip over an item\n      count++;\n    }\n\n    return count;\n  }\n\n  // @return entire rlp item byte length\n  function _itemLength(uint memPtr) private pure returns (uint) {\n    uint itemLen;\n    uint byte0;\n    assembly {\n      byte0 := byte(0, mload(memPtr))\n    }\n\n    if (byte0 \u003c STRING_SHORT_START)\n      itemLen = 1;\n\n    else if (byte0 \u003c STRING_LONG_START)\n      itemLen = byte0 - STRING_SHORT_START + 1;\n\n    else if (byte0 \u003c LIST_SHORT_START) {\n      assembly {\n        let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is\n        memPtr := add(memPtr, 1) // skip over the first byte\n\n        /* 32 byte word size */\n        let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len\n        itemLen := add(dataLen, add(byteLen, 1))\n      }\n    }\n\n    else if (byte0 \u003c LIST_LONG_START) {\n      itemLen = byte0 - LIST_SHORT_START + 1;\n    }\n\n    else {\n      assembly {\n        let byteLen := sub(byte0, 0xf7)\n        memPtr := add(memPtr, 1)\n\n        let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length\n        itemLen := add(dataLen, add(byteLen, 1))\n      }\n    }\n\n    return itemLen;\n  }\n\n  // @return number of bytes until the data\n  function _payloadOffset(uint memPtr) private pure returns (uint) {\n    uint byte0;\n    assembly {\n      byte0 := byte(0, mload(memPtr))\n    }\n\n    if (byte0 \u003c STRING_SHORT_START)\n      return 0;\n    else if (byte0 \u003c STRING_LONG_START || (byte0 \u003e= LIST_SHORT_START \u0026\u0026 byte0 \u003c LIST_LONG_START))\n      return 1;\n    else if (byte0 \u003c LIST_SHORT_START)  // being explicit\n      return byte0 - (STRING_LONG_START - 1) + 1;\n    else\n      return byte0 - (LIST_LONG_START - 1) + 1;\n  }\n\n  /*\n  * @param src Pointer to source\n  * @param dest Pointer to destination\n  * @param len Amount of memory to copy from the source\n  */\n  function copy(uint src, uint dest, uint len) private pure {\n    if (len == 0) return;\n\n    // copy as many word sizes as possible\n    for (; len \u003e= WORD_SIZE; len -= WORD_SIZE) {\n      assembly {\n          mstore(dest, mload(src))\n      }\n\n      src += WORD_SIZE;\n      dest += WORD_SIZE;\n    }\n\n    // left over bytes. Mask is used to remove unwanted bytes from the word\n    uint mask = 256 ** (WORD_SIZE - len) - 1;\n    assembly {\n      let srcpart := and(mload(src), not(mask)) // zero out src\n      let destpart := and(mload(dest), mask) // retrieve the bytes\n      mstore(dest, or(destpart, srcpart))\n    }\n  }\n}\n"},"StorageStructure.sol":{"content":"pragma solidity 0.6.2;\n\n/// @title Storage Structure for CertiÐApp Certificate Contract\n/// @dev This contract is intended to be inherited in Proxy and Implementation contracts.\ncontract StorageStructure {\n  enum AuthorityStatus { NotAuthorised, Authorised, Migrated, Suspended }\n\n  struct Certificate {\n    bytes data;\n    bytes signers;\n  }\n\n  struct CertifyingAuthority {\n    bytes data;\n    AuthorityStatus status;\n  }\n\n  mapping(bytes32 =\u003e Certificate) public certificates;\n  mapping(address =\u003e CertifyingAuthority) public certifyingAuthorities;\n  mapping(bytes32 =\u003e bytes32) extraData;\n\n  address public manager;\n\n  bytes constant public PERSONAL_PREFIX = \"\\x19Ethereum Signed Message:\\n\";\n\n  event ManagerUpdated(\n    address _newManager\n  );\n\n  event Certified(\n    bytes32 indexed _certificateHash,\n    address indexed _certifyingAuthority\n  );\n\n  event AuthorityStatusUpdated(\n    address indexed _certifyingAuthority,\n    AuthorityStatus _newStatus\n  );\n\n  event AuthorityMigrated(\n    address indexed _oldAddress,\n    address indexed _newAddress\n  );\n\n  modifier onlyManager() {\n    require(msg.sender == manager, \u0027only manager can call\u0027);\n    _;\n  }\n\n  modifier onlyAuthorisedCertifier() {\n    require(\n      certifyingAuthorities[msg.sender].status == AuthorityStatus.Authorised\n      , \u0027only authorised certifier can call\u0027\n    );\n    _;\n  }\n}\n"}}