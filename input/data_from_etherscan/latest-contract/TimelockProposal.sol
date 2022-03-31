{{
  "language": "Solidity",
  "sources": {
    "TimelockProposal.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\ninterface IProxy {\n  function upgradeTo(address newImplementation) external;\n}\n\ncontract TimelockProposal {\n\n  function execute() external {\n\n    IProxy proxy = IProxy(0xc4347dbda0078d18073584602CF0C1572541bb15);\n\n    address veToken = 0x879f2aD840E3f920B16982e55455D0905DDf164E;\n\n    proxy.upgradeTo(veToken);\n  }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
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