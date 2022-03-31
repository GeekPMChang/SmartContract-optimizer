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
    "@sushiswap/core/contracts/uniswapv2/interfaces/IUniswapV2Pair.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity >=0.5.0;\n\ninterface IUniswapV2Pair {\n    event Approval(address indexed owner, address indexed spender, uint value);\n    event Transfer(address indexed from, address indexed to, uint value);\n\n    function name() external pure returns (string memory);\n    function symbol() external pure returns (string memory);\n    function decimals() external pure returns (uint8);\n    function totalSupply() external view returns (uint);\n    function balanceOf(address owner) external view returns (uint);\n    function allowance(address owner, address spender) external view returns (uint);\n\n    function approve(address spender, uint value) external returns (bool);\n    function transfer(address to, uint value) external returns (bool);\n    function transferFrom(address from, address to, uint value) external returns (bool);\n\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\n    function PERMIT_TYPEHASH() external pure returns (bytes32);\n    function nonces(address owner) external view returns (uint);\n\n    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;\n\n    event Mint(address indexed sender, uint amount0, uint amount1);\n    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);\n    event Swap(\n        address indexed sender,\n        uint amount0In,\n        uint amount1In,\n        uint amount0Out,\n        uint amount1Out,\n        address indexed to\n    );\n    event Sync(uint112 reserve0, uint112 reserve1);\n\n    function MINIMUM_LIQUIDITY() external pure returns (uint);\n    function factory() external view returns (address);\n    function token0() external view returns (address);\n    function token1() external view returns (address);\n    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);\n    function price0CumulativeLast() external view returns (uint);\n    function price1CumulativeLast() external view returns (uint);\n    function kLast() external view returns (uint);\n\n    function mint(address to) external returns (uint liquidity);\n    function burn(address to) external returns (uint amount0, uint amount1);\n    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;\n    function skim(address to) external;\n    function sync() external;\n\n    function initialize(address, address) external;\n}"
    },
    "contracts/interfaces/IBentoBoxV1.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\nimport \"./IERC20.sol\";\r\n\r\ninterface IBentoBoxV1 {\r\n    function withdraw(\r\n        IERC20 token,\r\n        address from,\r\n        address to,\r\n        uint256 amount,\r\n        uint256 share\r\n    ) external returns (uint256, uint256);\r\n\r\n    function deposit(\r\n        IERC20 token,\r\n        address from,\r\n        address to,\r\n        uint256 amount,\r\n        uint256 share\r\n    ) external returns (uint256, uint256);\r\n}\r\n"
    },
    "contracts/interfaces/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    /// @notice EIP 2612\r\n    function permit(\r\n        address owner,\r\n        address spender,\r\n        uint256 value,\r\n        uint256 deadline,\r\n        uint8 v,\r\n        bytes32 r,\r\n        bytes32 s\r\n    ) external;\r\n}\r\n"
    },
    "contracts/interfaces/ILevSwapperGeneric.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface ILevSwapperGeneric {\r\n    /// @notice Swaps to a flexible amount, from an exact input amount\r\n    function swap(\r\n        address recipient,\r\n        uint256 shareToMin,\r\n        uint256 shareFrom\r\n    ) external returns (uint256 extraShare, uint256 shareReturned);\r\n}\r\n"
    },
    "contracts/interfaces/yearn/IYearnVault.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface IYearnVault {\r\n    function withdraw() external returns (uint256);\r\n    function deposit(uint256 amount, address recipient) external returns (uint256);\r\n}"
    },
    "contracts/swappers/Leverage/YVMIM3CrvLevSwapper.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.4;\r\n\r\nimport \"@sushiswap/core/contracts/uniswapv2/interfaces/IUniswapV2Pair.sol\";\r\nimport \"../../interfaces/IBentoBoxV1.sol\";\r\nimport \"../../interfaces/yearn/IYearnVault.sol\";\r\nimport \"../../interfaces/ILevSwapperGeneric.sol\";\r\n\r\ninterface CurvePool {\r\n    function add_liquidity(\r\n        address pool,\r\n        uint256[4] memory amounts,\r\n        uint256 _min_mint_amount\r\n    ) external returns (uint256);\r\n}\r\n\r\ncontract YVMIM3CRVLevSwapper is ILevSwapperGeneric {\r\n    IBentoBoxV1 public constant DEGENBOX = IBentoBoxV1(0xd96f48665a1410C0cd669A88898ecA36B9Fc2cce);\r\n    CurvePool public constant THREEPOOL = CurvePool(0xA79828DF1850E8a3A3064576f380D90aECDD3359);\r\n    IERC20 public constant MIM3CRV = IERC20(0x5a6A4D54456819380173272A5E8E9B9904BdF41B);\r\n    IYearnVault public constant YVMIM3CRV = IYearnVault(0x2DfB14E32e2F8156ec15a2c21c3A6c053af52Be8);\r\n    IERC20 public constant MIM = IERC20(0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3);\r\n\r\n    constructor() {\r\n        MIM.approve(address(THREEPOOL), type(uint256).max);\r\n        MIM3CRV.approve(address(YVMIM3CRV), type(uint256).max);\r\n    }\r\n\r\n    /// @inheritdoc ILevSwapperGeneric\r\n    function swap(\r\n        address recipient,\r\n        uint256 shareToMin,\r\n        uint256 shareFrom\r\n    ) public override returns (uint256 extraShare, uint256 shareReturned) {\r\n        (uint256 mimAmount, ) = DEGENBOX.withdraw(MIM, address(this), address(this), 0, shareFrom);\r\n\r\n        // MIM -> MIM3CRV\r\n        // MIM, DAI, USDC, USDT\r\n        uint256[4] memory amounts = [mimAmount, 0, 0, 0];\r\n        uint256 mim3CrvAmount = THREEPOOL.add_liquidity(address(MIM3CRV), amounts, 0);\r\n\r\n        // MIM3CRV -> YVMIM3CRV\r\n        uint256 yvMim3CrvAmount = YVMIM3CRV.deposit(mim3CrvAmount, address(DEGENBOX));\r\n\r\n        (, shareReturned) = DEGENBOX.deposit(IERC20(address(YVMIM3CRV)), address(DEGENBOX), recipient, yvMim3CrvAmount, 0);\r\n        extraShare = shareReturned - shareToMin;\r\n    }\r\n}\r\n"
    }
  }
}}