{{
  "language": "Solidity",
  "sources": {
    "./contracts/governance/GRODistributer.sol": {
      "content": "// SPDX-License-Identifier: AGPLv3\npragma solidity 0.8.4;\n\ninterface IToken {\n    function mint(address _receiver, uint256 _amount) external;\n    function burn(address _receiver, uint256 _amount) external;\n}\n\n/// @notice Contract that defines GRO DAOs' tokenomics - Contracts set below\n///     are allowed to mint tokens based on predefined quotas. This contract is\n///     intrinsically tied to the GRO Dao token, and is the only contract that is\n///     allowed to mint and burn tokens.\ncontract GRODistributer {\n    // Limits for token minting\n    uint256 public constant DEFAULT_FACTOR = 1E18;\n    // Amount dedicated to the dao (13M - 5M)\n    uint256 public constant DAO_QUOTA = 8_000_000 * DEFAULT_FACTOR;\n    // Amount dedicated to the investor group\n    uint256 public constant INVESTOR_QUOTA = 19_490_577 * DEFAULT_FACTOR;\n    // Amount dedicated to the team\n    uint256 public constant TEAM_QUOTA = 22_509_423 * DEFAULT_FACTOR;\n    // Amount dedicated to the community\n    uint256 public constant COMMUNITY_QUOTA = 45_000_000 * DEFAULT_FACTOR;\n\n    IToken public immutable govToken;\n    // contracts that are allowed to mint\n    address public immutable DAO_VESTER;\n    address public immutable INVESTOR_VESTER;\n    address public immutable TEAM_VESTER;\n    address public immutable COMMUNITY_VESTER;\n    // contract that is allowed to burn\n    address public immutable BURNER;\n\n    // pool with minting limits for above contracts\n    mapping(address => uint256) public mintingPools;\n\n    constructor(address token, address[4] memory vesters, address burner) {\n        // set token\n        govToken = IToken(token);\n        \n        // set vesters\n        DAO_VESTER = vesters[0];\n        INVESTOR_VESTER = vesters[1];\n        TEAM_VESTER = vesters[2];\n        COMMUNITY_VESTER = vesters[3];\n        BURNER = burner;\n        \n        // set quotas for each vester\n        mintingPools[vesters[0]] = DAO_QUOTA;\n        mintingPools[vesters[1]] = INVESTOR_QUOTA;\n        mintingPools[vesters[2]] = TEAM_QUOTA;\n        mintingPools[vesters[3]] = COMMUNITY_QUOTA;\n    }\n\n    /// @notice mint tokens - Reduces total allowance for minting pool\n    /// @param account account to mint for\n    /// @param amount amount to mint\n    function mint(address account, uint256 amount) external {\n        require(\n            msg.sender == INVESTOR_VESTER ||\n            msg.sender == TEAM_VESTER ||\n            msg.sender == COMMUNITY_VESTER,\n            'mint: msg.sender != vester'\n        );\n        uint256 available = mintingPools[msg.sender];\n        mintingPools[msg.sender] = available - amount;\n        govToken.mint(account, amount);\n    }\n\n    /// @notice mintDao seperate minting function for dao vester - can mint from both\n    ///      community and dao quota\n    /// @param account account to mint for\n    /// @param amount amount to mint\n    /// @param community If the vest comes from the community or dao quota\n    function mintDao(\n        address account,\n        uint256 amount,\n        bool community\n    ) external {\n        require(msg.sender == DAO_VESTER, \"mintDao: msg.sender != DAO_VESTER\");\n        address poolId = msg.sender;\n        if (community) {\n            poolId = COMMUNITY_VESTER;\n        }\n        uint256 available = mintingPools[poolId];\n        mintingPools[poolId] = available - amount;\n        govToken.mint(account, amount);\n    }\n\n    /// @notice burn tokens - adds allowance to community pool\n    /// @param amount amount to burn\n    /// @dev Burned tokens should get add to users vesting position and\n    ///  add to the community quota.\n    function burn(uint256 amount) external {\n        require(msg.sender == BURNER, \"burn: msg.sender != BURNER\");\n        govToken.burn(msg.sender, amount);\n        mintingPools[COMMUNITY_VESTER] = mintingPools[COMMUNITY_VESTER] + amount;\n    }\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}