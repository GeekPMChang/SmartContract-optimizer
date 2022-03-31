{{
  "language": "Solidity",
  "sources": {
    "ChainlinkAdapter.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\npragma solidity =0.8.11;\n\nimport \"AggregatorV2V3Interface.sol\";\n\ncontract ChainlinkAdapter is AggregatorV2V3Interface {\n    uint8 public override constant decimals = 18;\n    uint256 public override constant version = 1;\n    int256 public constant rateDecimals = 10**18;\n\n    string public override description;\n    AggregatorV2V3Interface public immutable baseToUSDOracle;\n    int256 public immutable baseToUSDDecimals;\n    AggregatorV2V3Interface public immutable quoteToUSDOracle;\n    int256 public immutable quoteToUSDDecimals;\n\n    constructor (\n        AggregatorV2V3Interface baseToUSDOracle_,\n        AggregatorV2V3Interface quoteToUSDOracle_,\n        string memory description_\n    ) {\n        description = description_;\n        baseToUSDOracle = baseToUSDOracle_;\n        quoteToUSDOracle = quoteToUSDOracle_;\n        baseToUSDDecimals = int256(10**baseToUSDOracle_.decimals());\n        quoteToUSDDecimals = int256(10**quoteToUSDOracle_.decimals());\n    }\n\n    function _calculateBaseToQuote() internal view returns (\n        uint80 roundId,\n        int256 answer,\n        uint256 startedAt,\n        uint256 updatedAt,\n        uint80 answeredInRound\n    ) {\n        int256 baseToUSD;\n        (\n            roundId,\n            baseToUSD,\n            startedAt,\n            updatedAt,\n            answeredInRound\n        ) = baseToUSDOracle.latestRoundData();\n        require(baseToUSD > 0, \"Chainlink Rate Error\");\n        (\n            /* roundId */,\n            int256 quoteToUSD,\n            /* uint256 startedAt */,\n            /* updatedAt */,\n            /* answeredInRound */\n        ) = quoteToUSDOracle.latestRoundData();\n        require(quoteToUSD > 0, \"Chainlink Rate Error\");\n\n        // To convert from USDC/USD (base) and ETH/USD (quote) to USDC/ETH we do:\n        // (USDC/USD * quoteDecimals * 1e18) / (ETH/USD * baseDecimals)\n        answer = (baseToUSD * quoteToUSDDecimals * rateDecimals) / (quoteToUSD * baseToUSDDecimals);\n    }\n\n    function latestRoundData() external view override returns (\n        uint80 roundId,\n        int256 answer,\n        uint256 startedAt,\n        uint256 updatedAt,\n        uint80 answeredInRound\n    ) {\n        return _calculateBaseToQuote();\n    }\n\n    function latestAnswer() external view override returns (int256 answer) {\n        (/* */, answer, /* */, /* */, /* */) = _calculateBaseToQuote();\n    }\n\n    function latestTimestamp() external view override returns (uint256 updatedAt) {\n        (/* */, /* */, /* */, updatedAt, /* */) = _calculateBaseToQuote();\n    }\n\n    function latestRound() external view override returns (uint256 roundId) {\n        (roundId, /* */, /* */, /* */, /* */) = _calculateBaseToQuote();\n    }\n\n    function getRoundData(uint80 _roundId) external view override returns (\n        uint80 roundId,\n        int256 answer,\n        uint256 startedAt,\n        uint256 updatedAt,\n        uint80 answeredInRound\n    ) {\n        revert();\n    }\n\n    function getAnswer(uint256 roundId) external view override returns (int256) { revert(); }\n    function getTimestamp(uint256 roundId) external view override returns (uint256) { revert(); }\n}\n"
    },
    "AggregatorV2V3Interface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.6.0;\n\nimport \"AggregatorInterface.sol\";\nimport \"AggregatorV3Interface.sol\";\n\ninterface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface\n{\n}"
    },
    "AggregatorInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.6.0;\n\ninterface AggregatorInterface {\n  function latestAnswer() external view returns (int256);\n  function latestTimestamp() external view returns (uint256);\n  function latestRound() external view returns (uint256);\n  function getAnswer(uint256 roundId) external view returns (int256);\n  function getTimestamp(uint256 roundId) external view returns (uint256);\n\n  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);\n  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);\n}\n"
    },
    "AggregatorV3Interface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.6.0;\n\ninterface AggregatorV3Interface {\n\n  function decimals() external view returns (uint8);\n  function description() external view returns (string memory);\n  function version() external view returns (uint256);\n\n  // getRoundData and latestRoundData should both raise \"No data present\"\n  // if they do not have data to report, instead of returning unset values\n  // which could be misinterpreted as actual reported values.\n  function getRoundData(uint80 _roundId)\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n  function latestRoundData()\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n}"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "ChainlinkAdapter.sol": {}
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