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
      "runs": 1000
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
    "contracts/lib/Damage.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nlibrary Damage {\n    struct DamageComponent {\n        uint32 m;\n        uint32 d;\n    }\n\n    uint256 public constant PRECISION = 10;\n\n    function computeDamage(DamageComponent memory dmg)\n        public\n        pure\n        returns (uint256)\n    {\n        return (dmg.m * dmg.d) / PRECISION;\n    }\n\n    // This function assumes a hero is equipped after state change\n    function getDamageUpdate(\n        Damage.DamageComponent calldata dmg,\n        Damage.DamageComponent[] calldata removed,\n        Damage.DamageComponent[] calldata added\n    ) public pure returns (Damage.DamageComponent memory) {\n        Damage.DamageComponent memory updatedDmg = Damage.DamageComponent(\n            dmg.m,\n            dmg.d\n        );\n\n        for (uint256 i = 0; i < removed.length; i++) {\n            updatedDmg.m -= removed[i].m;\n            updatedDmg.d -= removed[i].d;\n        }\n\n        for (uint256 i = 0; i < added.length; i++) {\n            updatedDmg.m += added[i].m;\n            updatedDmg.d += added[i].d;\n        }\n\n        return updatedDmg;\n    }\n\n    // This function assumes a hero is equipped after state change\n    function getDamageUpdate(\n        Damage.DamageComponent calldata dmg,\n        Damage.DamageComponent calldata removed,\n        Damage.DamageComponent calldata added\n    ) public pure returns (Damage.DamageComponent memory) {\n        Damage.DamageComponent memory updatedDmg = Damage.DamageComponent(\n            dmg.m,\n            dmg.d\n        );\n\n        updatedDmg.m -= removed.m;\n        updatedDmg.d -= removed.d;\n\n        updatedDmg.m += added.m;\n        updatedDmg.d += added.d;\n\n        return updatedDmg;\n    }\n}\n"
    }
  }
}}