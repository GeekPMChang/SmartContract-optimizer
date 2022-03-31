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
    "@boringcrypto/boring-solidity/contracts/BoringOwnable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.6.12;\n\n// Audit on 5-Jan-2021 by Keno and BoringCrypto\n// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol\n// Edited by BoringCrypto\n\ncontract BoringOwnableData {\n    address public owner;\n    address public pendingOwner;\n}\n\ncontract BoringOwnable is BoringOwnableData {\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /// @notice `owner` defaults to msg.sender on construction.\n    constructor() public {\n        owner = msg.sender;\n        emit OwnershipTransferred(address(0), msg.sender);\n    }\n\n    /// @notice Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.\n    /// Can only be invoked by the current `owner`.\n    /// @param newOwner Address of the new owner.\n    /// @param direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.\n    /// @param renounce Allows the `newOwner` to be `address(0)` if `direct` and `renounce` is True. Has no effect otherwise.\n    function transferOwnership(\n        address newOwner,\n        bool direct,\n        bool renounce\n    ) public onlyOwner {\n        if (direct) {\n            // Checks\n            require(newOwner != address(0) || renounce, \"Ownable: zero address\");\n\n            // Effects\n            emit OwnershipTransferred(owner, newOwner);\n            owner = newOwner;\n            pendingOwner = address(0);\n        } else {\n            // Effects\n            pendingOwner = newOwner;\n        }\n    }\n\n    /// @notice Needs to be called by `pendingOwner` to claim ownership.\n    function claimOwnership() public {\n        address _pendingOwner = pendingOwner;\n\n        // Checks\n        require(msg.sender == _pendingOwner, \"Ownable: caller != pending owner\");\n\n        // Effects\n        emit OwnershipTransferred(owner, _pendingOwner);\n        owner = _pendingOwner;\n        pendingOwner = address(0);\n    }\n\n    /// @notice Only allows the `owner` to execute the function.\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Ownable: caller is not the owner\");\n        _;\n    }\n}\n"
    },
    "@boringcrypto/boring-solidity/contracts/interfaces/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.6.12;\n\ninterface IERC20 {\n    function totalSupply() external view returns (uint256);\n\n    function balanceOf(address account) external view returns (uint256);\n\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /// @notice EIP 2612\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) external;\n}\n"
    },
    "contracts/interfaces/IOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface IOracle {\r\n    /// @notice Get the latest exchange rate.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return success if no valid (recent) rate is available, return false else true.\r\n    /// @return rate The rate of the requested asset / pair / pool.\r\n    function get(bytes calldata data) external returns (bool success, uint256 rate);\r\n\r\n    /// @notice Check the last exchange rate without any state changes.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return success if no valid (recent) rate is available, return false else true.\r\n    /// @return rate The rate of the requested asset / pair / pool.\r\n    function peek(bytes calldata data) external view returns (bool success, uint256 rate);\r\n\r\n    /// @notice Check the current spot exchange rate without any state changes. For oracles like TWAP this will be different from peek().\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return rate The rate of the requested asset / pair / pool.\r\n    function peekSpot(bytes calldata data) external view returns (uint256 rate);\r\n\r\n    /// @notice Returns a human readable (short) name about this oracle.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return (string) A human readable symbol name about this oracle.\r\n    function symbol(bytes calldata data) external view returns (string memory);\r\n\r\n    /// @notice Returns a human readable name about this oracle.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return (string) A human readable name about this oracle.\r\n    function name(bytes calldata data) external view returns (string memory);\r\n}\r\n"
    },
    "contracts/oracles/ProxyOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\nimport \"../interfaces/IOracle.sol\";\r\nimport \"@boringcrypto/boring-solidity/contracts/interfaces/IERC20.sol\";\r\nimport \"@boringcrypto/boring-solidity/contracts/BoringOwnable.sol\";\r\n\r\n/// @title ProxyOracle\r\n/// @author 0xMerlin\r\n/// @notice Oracle used for getting the price of an oracle implementation\r\ncontract ProxyOracle is IOracle, BoringOwnable {\r\n    IOracle public oracleImplementation;\r\n\r\n    event LogOracleImplementationChange(IOracle indexed oldOracle, IOracle indexed newOracle);\r\n\r\n    constructor() public {}\r\n\r\n    function changeOracleImplementation(IOracle newOracle) external onlyOwner {\r\n        IOracle oldOracle = oracleImplementation;\r\n        oracleImplementation = newOracle;\r\n        emit LogOracleImplementationChange(oldOracle, newOracle);\r\n    }\r\n\r\n    // Get the latest exchange rate\r\n    /// @inheritdoc IOracle\r\n    function get(bytes calldata data) public override returns (bool, uint256) {\r\n        return oracleImplementation.get(data);\r\n    }\r\n\r\n    // Check the last exchange rate without any state changes\r\n    /// @inheritdoc IOracle\r\n    function peek(bytes calldata data) public view override returns (bool, uint256) {\r\n        return oracleImplementation.peek(data);\r\n    }\r\n\r\n    // Check the current spot exchange rate without any state changes\r\n    /// @inheritdoc IOracle\r\n    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {\r\n        return oracleImplementation.peekSpot(data);\r\n    }\r\n\r\n    /// @inheritdoc IOracle\r\n    function name(bytes calldata) public view override returns (string memory) {\r\n        return \"Proxy Oracle\";\r\n    }\r\n\r\n    /// @inheritdoc IOracle\r\n    function symbol(bytes calldata) public view override returns (string memory) {\r\n        return \"Proxy\";\r\n    }\r\n}\r\n"
    }
  }
}}