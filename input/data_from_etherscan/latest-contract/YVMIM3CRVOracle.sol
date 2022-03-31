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
    "contracts/oracles/YVMim3CrvOracle.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.4;\r\nimport \"../interfaces/IOracle.sol\";\r\n\r\n// Chainlink Aggregator\r\n\r\ninterface IAggregator {\r\n    function latestAnswer() external view returns (int256 answer);\r\n}\r\n\r\ninterface IYearnVault {\r\n    function pricePerShare() external view returns (uint256 price);\r\n}\r\n\r\ninterface ICurvePool {\r\n    function get_virtual_price() external view returns (uint256 price);\r\n}\r\n\r\ncontract YVMIM3CRVOracle is IOracle {\r\n    ICurvePool public constant MIM3CRV = ICurvePool(0x5a6A4D54456819380173272A5E8E9B9904BdF41B);\r\n    IYearnVault public constant YVMIM3CRV = IYearnVault(0x2DfB14E32e2F8156ec15a2c21c3A6c053af52Be8);\r\n    IAggregator public constant MIM = IAggregator(0x7A364e8770418566e3eb2001A96116E6138Eb32F);\r\n    IAggregator constant public DAI = IAggregator(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);\r\n    IAggregator constant public USDC = IAggregator(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);\r\n    IAggregator constant public USDT = IAggregator(0x3E7d1eAB13ad0104d2750B8863b489D65364e32D);\r\n    \r\n    /**\r\n     * @dev Returns the smallest of two numbers.\r\n     */\r\n    // FROM: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/6d97f0919547df11be9443b54af2d90631eaa733/contracts/utils/math/Math.sol\r\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a < b ? a : b;\r\n    }\r\n\r\n    // Calculates the lastest exchange rate\r\n    // Uses both divide and multiply only for tokens not supported directly by Chainlink, for example MKR/USD\r\n    function _get() internal view returns (uint256) {\r\n        uint256 minStable = min(\r\n            uint256(DAI.latestAnswer()),\r\n            min(uint256(USDC.latestAnswer()), min(uint256(USDT.latestAnswer()), uint256(MIM.latestAnswer())))\r\n        );\r\n\r\n        uint256 yVCurvePrice = MIM3CRV.get_virtual_price() * minStable * YVMIM3CRV.pricePerShare();\r\n\r\n        return 1e62 / yVCurvePrice;\r\n    }\r\n\r\n    // Get the latest exchange rate\r\n    /// @inheritdoc IOracle\r\n    function get(bytes calldata) public view override returns (bool, uint256) {\r\n        return (true, _get());\r\n    }\r\n\r\n    // Check the last exchange rate without any state changes\r\n    /// @inheritdoc IOracle\r\n    function peek(bytes calldata) public view override returns (bool, uint256) {\r\n        return (true, _get());\r\n    }\r\n\r\n    // Check the current spot exchange rate without any state changes\r\n    /// @inheritdoc IOracle\r\n    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {\r\n        (, rate) = peek(data);\r\n    }\r\n\r\n    /// @inheritdoc IOracle\r\n    function name(bytes calldata) public pure override returns (string memory) {\r\n        return \"Chainlink MIM3CRV\";\r\n    }\r\n\r\n    /// @inheritdoc IOracle\r\n    function symbol(bytes calldata) public pure override returns (string memory) {\r\n        return \"LINK/MIM3CRV\";\r\n    }\r\n}\r\n"
    }
  }
}}