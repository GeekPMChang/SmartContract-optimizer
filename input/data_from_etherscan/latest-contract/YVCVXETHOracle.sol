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
    "contracts/interfaces/IOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface IOracle {\r\n    /// @notice Get the latest exchange rate.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return success if no valid (recent) rate is available, return false else true.\r\n    /// @return rate The rate of the requested asset / pair / pool.\r\n    function get(bytes calldata data) external returns (bool success, uint256 rate);\r\n\r\n    /// @notice Check the last exchange rate without any state changes.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return success if no valid (recent) rate is available, return false else true.\r\n    /// @return rate The rate of the requested asset / pair / pool.\r\n    function peek(bytes calldata data) external view returns (bool success, uint256 rate);\r\n\r\n    /// @notice Check the current spot exchange rate without any state changes. For oracles like TWAP this will be different from peek().\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return rate The rate of the requested asset / pair / pool.\r\n    function peekSpot(bytes calldata data) external view returns (uint256 rate);\r\n\r\n    /// @notice Returns a human readable (short) name about this oracle.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return (string) A human readable symbol name about this oracle.\r\n    function symbol(bytes calldata data) external view returns (string memory);\r\n\r\n    /// @notice Returns a human readable name about this oracle.\r\n    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.\r\n    /// For example:\r\n    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));\r\n    /// @return (string) A human readable name about this oracle.\r\n    function name(bytes calldata data) external view returns (string memory);\r\n}\r\n"
    },
    "contracts/oracles/YVCVXETHOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.4;\r\nimport \"../interfaces/IOracle.sol\";\r\n\r\n// Chainlink Aggregator\r\n\r\ninterface IAggregator {\r\n    function latestAnswer() external view returns (int256 answer);\r\n}\r\n\r\ninterface IYearnVault {\r\n    function pricePerShare() external view returns (uint256 price);\r\n}\r\n\r\ninterface ICurvePool {\r\n    function get_virtual_price() external view returns (uint256 price);\r\n    function lp_price() external view returns (uint256 price);\r\n}\r\n\r\ncontract YVCVXETHOracle is IOracle {\r\n    ICurvePool public constant CVXETH = ICurvePool(0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4);\r\n    IYearnVault public constant YVCVXETH = IYearnVault(0x1635b506a88fBF428465Ad65d00e8d6B6E5846C3);\r\n    IAggregator public constant ETH = IAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);\r\n\r\n    // Calculates the lastest exchange rate\r\n    // Uses both divide and multiply only for tokens not supported directly by Chainlink, for example MKR/USD\r\n    function _get() internal view returns (uint256) {\r\n        uint256 yVCurvePrice = CVXETH.lp_price() * uint256(ETH.latestAnswer()) * YVCVXETH.pricePerShare();\r\n\r\n        return 1e62 / yVCurvePrice;\r\n    }\r\n\r\n    // Get the latest exchange rate\r\n    /// @inheritdoc IOracle\r\n    function get(bytes calldata) public view override returns (bool, uint256) {\r\n        return (true, _get());\r\n    }\r\n\r\n    // Check the last exchange rate without any state changes\r\n    /// @inheritdoc IOracle\r\n    function peek(bytes calldata) public view override returns (bool, uint256) {\r\n        return (true, _get());\r\n    }\r\n\r\n    // Check the current spot exchange rate without any state changes\r\n    /// @inheritdoc IOracle\r\n    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {\r\n        (, rate) = peek(data);\r\n    }\r\n\r\n    /// @inheritdoc IOracle\r\n    function name(bytes calldata) public pure override returns (string memory) {\r\n        return \"Chainlink CVXETH\";\r\n    }\r\n\r\n    /// @inheritdoc IOracle\r\n    function symbol(bytes calldata) public pure override returns (string memory) {\r\n        return \"LINK/CVXETH\";\r\n    }\r\n}\r\n"
    }
  }
}}