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
    "contracts/interfaces/Tether.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface Tether {\r\n    function approve(address spender, uint256 value) external;\r\n\r\n    function balanceOf(address user) external view returns (uint256);\r\n\r\n    function transfer(address to, uint256 value) external;\r\n}\r\n"
    },
    "contracts/interfaces/curve/ICurvePool.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface CurvePool {\r\n    function exchange_underlying(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx,\r\n        uint256 min_dy,\r\n        address receiver\r\n    ) external returns (uint256);\r\n\r\n    function exchange(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx,\r\n        uint256 min_dy,\r\n        address receiver\r\n    ) external returns (uint256);\r\n\r\n    function get_dy_underlying(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function get_dy(\r\n        int128 i,\r\n        int128 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function approve(address _spender, uint256 _value) external returns (bool);\r\n\r\n    function add_liquidity(uint256[2] memory amounts, uint256 _min_mint_amount) external;\r\n    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;\r\n    function add_liquidity(uint256[4] memory amounts, uint256 _min_mint_amount) external;\r\n\r\n    function remove_liquidity_one_coin(uint256 tokenAmount, int128 i, uint256 min_amount) external returns(uint256);\r\n    function remove_liquidity_one_coin(uint256 tokenAmount, uint256 i, uint256 min_amount) external returns(uint256);\r\n    function remove_liquidity_one_coin(uint256 tokenAmount, int128 i, uint256 min_amount, address receiver) external returns(uint256);\r\n}"
    },
    "contracts/interfaces/curve/ICurveThreeCryptoPool.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface CurveThreeCryptoPool {\r\n    function exchange(\r\n        uint256 i,\r\n        uint256 j,\r\n        uint256 dx,\r\n        uint256 min_dy\r\n    ) payable external;\r\n\r\n    function get_dy(\r\n        uint256 i,\r\n        uint256 j,\r\n        uint256 dx\r\n    ) external view returns (uint256);\r\n\r\n    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;\r\n}\r\n"
    },
    "contracts/interfaces/yearn/IYearnVault.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.6.12;\r\n\r\ninterface IYearnVault {\r\n    function withdraw() external returns (uint256);\r\n    function deposit(uint256 amount, address recipient) external returns (uint256);\r\n}"
    },
    "contracts/swappers/Leverage/YVCVXETHLevSwapper.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.4;\r\n\r\nimport \"@sushiswap/core/contracts/uniswapv2/interfaces/IUniswapV2Pair.sol\";\r\nimport \"../../interfaces/IBentoBoxV1.sol\";\r\nimport \"../../interfaces/curve/ICurvePool.sol\";\r\nimport \"../../interfaces/curve/ICurveThreeCryptoPool.sol\";\r\nimport \"../../interfaces/yearn/IYearnVault.sol\";\r\nimport \"../../interfaces/Tether.sol\";\r\nimport \"../../interfaces/ILevSwapperGeneric.sol\";\r\n\r\ncontract YVCVXETHLevSwapper is ILevSwapperGeneric {\r\n    IBentoBoxV1 public constant DEGENBOX = IBentoBoxV1(0xd96f48665a1410C0cd669A88898ecA36B9Fc2cce);\r\n    CurvePool public constant MIM3POOL = CurvePool(0x5a6A4D54456819380173272A5E8E9B9904BdF41B);\r\n    CurvePool public constant CVXETHPOOL = CurvePool(0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4);\r\n    IYearnVault public constant YVCVXETH = IYearnVault(0x1635b506a88fBF428465Ad65d00e8d6B6E5846C3);\r\n    Tether public constant USDT = Tether(0xdAC17F958D2ee523a2206206994597C13D831ec7);\r\n    IERC20 public constant MIM = IERC20(0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3);\r\n    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\r\n    IERC20 public constant CVXETH = IERC20(0x3A283D9c08E8b55966afb64C515f5143cf907611);\r\n    CurveThreeCryptoPool public constant THREECRYPTO = CurveThreeCryptoPool(0xD51a44d3FaE010294C616388b506AcdA1bfAAE46);\r\n\r\n    constructor() {\r\n        MIM.approve(address(MIM3POOL), type(uint256).max);\r\n        USDT.approve(address(THREECRYPTO), type(uint256).max);\r\n        WETH.approve(address(CVXETHPOOL), type(uint256).max);\r\n        CVXETH.approve(address(YVCVXETH), type(uint256).max);\r\n    }\r\n\r\n    /// @inheritdoc ILevSwapperGeneric\r\n    function swap(\r\n        address recipient,\r\n        uint256 shareToMin,\r\n        uint256 shareFrom\r\n    ) public override returns (uint256 extraShare, uint256 shareReturned) {\r\n        (uint256 mimAmount, ) = DEGENBOX.withdraw(MIM, address(this), address(this), 0, shareFrom);\r\n\r\n        // MIM -> USDT\r\n        uint256 usdtAmount = MIM3POOL.exchange_underlying(0, 3, mimAmount, 0, address(this));\r\n\r\n        // USDT -> WETH\r\n        THREECRYPTO.exchange(0, 2, usdtAmount, 0);\r\n\r\n        // WETH -> Curve CVXETH\r\n        uint256[2] memory amounts = [WETH.balanceOf(address(this)), 0];\r\n        CVXETHPOOL.add_liquidity(amounts, 0);\r\n\r\n        // Curve CVXETH -> Yearn CVXETH\r\n        uint256 yvCvxEthAmount = YVCVXETH.deposit(type(uint256).max, address(DEGENBOX));\r\n\r\n        (, shareReturned) = DEGENBOX.deposit(IERC20(address(YVCVXETH)), address(DEGENBOX), recipient, yvCvxEthAmount, 0);\r\n        extraShare = shareReturned - shareToMin;\r\n    }\r\n}\r\n"
    }
  }
}}