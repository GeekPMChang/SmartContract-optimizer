/** 
    ##     ##    ###    ##    ## ########     ###    ##        #######  ########  ####    ###    ##    ##    #### ##    ## ##     ## 
    ###   ###   ## ##   ###   ## ##     ##   ## ##   ##       ##     ## ##     ##  ##    ## ##   ###   ##     ##  ###   ## ##     ## 
    #### ####  ##   ##  ####  ## ##     ##  ##   ##  ##       ##     ## ##     ##  ##   ##   ##  ####  ##     ##  ####  ## ##     ## 
    ## ### ## ##     ## ## ## ## ##     ## ##     ## ##       ##     ## ########   ##  ##     ## ## ## ##     ##  ## ## ## ##     ## 
    ##     ## ######### ##  #### ##     ## ######### ##       ##     ## ##   ##    ##  ######### ##  ####     ##  ##  #### ##     ## 
    ##     ## ##     ## ##   ### ##     ## ##     ## ##       ##     ## ##    ##   ##  ##     ## ##   ###     ##  ##   ### ##     ## 
    ##     ## ##     ## ##    ## ########  ##     ## ########  #######  ##     ## #### ##     ## ##    ##    #### ##    ##  #######  
                                                                                               

    TELEGRAM: https://t.me/Mandalorian_Official

    TWITTER: https://twitter.com/Mandalorian_Inu

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function factory() external view returns (address);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract MandalorianInu is Context, IERC20 {
    // Ownership moved to in-contract for customizability.
    address private _owner;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isSniperOrBlacklisted;
    mapping (address => bool) private _liquidityHolders;
    
    mapping (address => uint256) buyLog;
    uint256 buyCoolDown = 30 seconds;

    uint256 private startingSupply = 100_000_000;   

    string private _name = "Mandalorian Inu";
    string private _symbol = "MANDO";

    uint256 public _buyFee = 600;
    uint256 public _sellFee = 1200; // Total tax : 12%
    uint256 public _transferFee = 100;

    uint256 constant public maxBuyTaxes = 1000;
    uint256 constant public maxSellTaxes = 2000;
    uint256 constant public maxTransferTaxes = 1000;

    uint256 public _liquidityRatio = 20;
    uint256 public _marketingRatio = 50;
    uint256 public _devRatio = 30;

    uint256 private constant masterTaxDivisor = 10_000;

    uint256 private constant MAX = ~uint256(0);
    uint8 constant private _decimals = 9;
    uint256 private _tTotal = startingSupply * 10**_decimals;
    uint256 private _tFeeTotal;

    IUniswapV2Router02 public dexRouter;
    address public lpPair;

    // UNI ROUTER
    address private _routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address payable private _marketingWallet = payable(0xfc80F0106F0162C6e13C22093579494C8a801689);
    address payable private _teamWallet = payable(0xfc80F0106F0162C6e13C22093579494C8a801689);
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    
    uint256 private maxTxPercent = 1;
    uint256 private maxTxDivisor = 100;
    uint256 private _maxTxAmount = (_tTotal * maxTxPercent) / maxTxDivisor; // 1%

    uint256 private maxWalletPercent = 5;
    uint256 private maxWalletDivisor = 100;
    uint256 private _maxWalletSize = (_tTotal * maxWalletPercent) / maxWalletDivisor; // 5%

    uint256 private swapThreshold = (_tTotal * 5) / 10_000; // 0.05%
    uint256 private swapAmount = (_tTotal * 5) / 1_000; // 0.5%

    bool private sniperProtection = false;
    bool public _hasLiqBeenAdded = false;
    uint256 private _liqAddStatus = 0;
    uint256 private _liqAddBlock = 0;
    uint256 private _liqAddStamp = 0;
    uint256 private _initialLiquidityAmount = 0;
    uint256 private snipeBlockAmt = 0;
    uint256 public snipersCaught = 0;
    bool private sameBlockActive = false;
    mapping (address => uint256) private lastTrade;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SniperCaught(address sniperAddress);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller =/= owner.");
        _;
    }
    
    constructor () payable {
        _tOwned[_msgSender()] = _tTotal;

        // Set the owner.
        _owner = msg.sender;

        dexRouter = IUniswapV2Router02(_routerAddress);
        lpPair = IUniswapV2Factory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;
        _allowances[address(this)][address(dexRouter)] = type(uint256).max;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
        _liquidityHolders[owner()] = true;

        // Approve the owner for UniSwap, timesaver.
        _approve(_msgSender(), _routerAddress, _tTotal);

        // Transfer tTotal to the _msgSender.
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

    // Ownable removed as a lib and added here to allow for custom transfers and recnouncements.
    // This allows for removal of ownership privelages from the owner once renounced or transferred.
    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwner(address newOwner) external onlyOwner() {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        setExcludedFromFees(_owner, false);
        setExcludedFromFees(newOwner, true);
        
        if (_marketingWallet == payable(_owner))
            _marketingWallet = payable(newOwner);
        
        _allowances[_owner][newOwner] = balanceOf(_owner);
        if(balanceOf(_owner) > 0) {
            _transfer(_owner, newOwner, balanceOf(_owner));
        }
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
        
    }

    function renounceOwnership() public virtual onlyOwner() {
        setExcludedFromFees(_owner, false);
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    function totalSupply() external view override returns (uint256) { return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveMax(address spender) public returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function setNewRouter(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newRouter = IUniswapV2Router02(newRouter);
        address get_pair = IUniswapV2Factory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IUniswapV2Factory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (enabled == false) {
            lpPairs[pair] = false;
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 1 weeks, "One week cooldown.");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
        }
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function isSniperOrBlacklisted(address account) public view returns (bool) {
        return _isSniperOrBlacklisted[account];
    }

    function setBuyCoolDownTime(uint256 Seconds) public onlyOwner{
        uint256 timeInSeconds = Seconds * 1 seconds;
        buyCoolDown = timeInSeconds;
    }

    function isProtected(uint256 rInitializer) external onlyOwner {
        require (_liqAddStatus == 0, "Error.");
        _liqAddStatus = rInitializer;
    }

    function setBlacklistEnabled(address account, bool enabled) external onlyOwner() {
        _isSniperOrBlacklisted[account] = enabled;
    }

    function setStartingProtections(uint8 _block) external onlyOwner{
        require (snipeBlockAmt == 0 && !_hasLiqBeenAdded, "Starting Protections have already been executed.");
        snipeBlockAmt = _block;
    }

    function setProtectionSettings() external onlyOwner() {
        sniperProtection = false;
        sameBlockActive = false;
    }

    function setTaxes(uint256 buyFee, uint256 sellFee, uint256 transferFee) external onlyOwner {
        require(buyFee <= maxBuyTaxes
                && sellFee <= maxSellTaxes
                && transferFee <= maxTransferTaxes,
                "Cannot exceed maximums.");
        _buyFee = buyFee;
        _sellFee = sellFee;
        _transferFee = transferFee;
    }

    function setRatios(uint256 liquidity, uint256 marketing, uint256 dev) external onlyOwner {
        require (liquidity + marketing + dev == 100, "Must add up to 100%");
        _liquidityRatio = liquidity;
        _marketingRatio = marketing;
        _devRatio = dev;
    }

    function setMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner {
        uint256 check = (_tTotal * percent) / divisor;
        require(check >= (_tTotal / 1000), "Must be above 0.1% of total supply.");
        _maxTxAmount = check;
    }

    function setMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        uint256 check = (_tTotal * percent) / divisor;
        require(check >= (_tTotal / 1000), "Must be above 0.1% of total supply.");
        _maxWalletSize = check;
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
    }

    function setWallets(address payable marketingWallet, address payable teamWallet) external onlyOwner {
        _marketingWallet = payable(marketingWallet);
        _teamWallet = payable(teamWallet);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != owner()
            && to != owner()
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: Zero address.");
        require(to != address(0), "ERC20: Zero address.");
        require(amount > 0, "Must >0.");
        if(_hasLimits(from, to)) {
            if (sameBlockActive) {
                if (lpPairs[from]){
                    require(lastTrade[to] != block.number);
                    lastTrade[to] = block.number;
                } else {
                    require(lastTrade[from] != block.number);
                    lastTrade[from] = block.number;
                }
            }
            if(lpPairs[from] || lpPairs[to]){
                require(amount <= _maxTxAmount, "Exceeds the maxTxAmount.");
            }
            if(to != _routerAddress && !lpPairs[to]) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }
        }

        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        if (lpPairs[to]) {
            if (!inSwapAndLiquify
                && swapAndLiquifyEnabled
            ) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance >= swapThreshold) {
                    if(contractTokenBalance >= swapAmount) { contractTokenBalance = swapAmount; }
                    swapAndLiquify(contractTokenBalance);
                }
            }      
        } 
        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        if (_liquidityRatio + _marketingRatio + _devRatio == 0)
            return;
        uint256 toLiquify = ((contractTokenBalance * _liquidityRatio) / (_liquidityRatio + _marketingRatio + _devRatio)) / 2;

        uint256 toSwapForEth = contractTokenBalance - toLiquify;
        swapTokensForEth(toSwapForEth);

        uint256 currentBalance = address(this).balance;
        uint256 liquidityBalance = ((currentBalance * _liquidityRatio) / (_liquidityRatio + _marketingRatio + _devRatio)) / 2;

        if (toLiquify > 0) {
            addLiquidity(toLiquify, liquidityBalance);
            emit SwapAndLiquify(toLiquify, liquidityBalance, toLiquify);
        }
        if (contractTokenBalance - toLiquify > 0) {
            _marketingWallet.transfer(((currentBalance - liquidityBalance) * _marketingRatio) / (_marketingRatio + _devRatio));
            _teamWallet.transfer(address(this).balance);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );
    }

    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            if (snipeBlockAmt != 2) {
                _liqAddBlock = block.number + 5000;
            } else {
                _liqAddBlock = block.number;
            }

            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            _liqAddStamp = block.timestamp;

            swapAndLiquifyEnabled = true;
            emit SwapAndLiquifyEnabledUpdated(true);
        }
    }

    function _finalizeTransfer(address from, address to, uint256 amount, bool takeFee) private returns (bool) {
        if (sniperProtection){
            if (isSniperOrBlacklisted(from) || isSniperOrBlacklisted(to)) {
                revert("Sniper rejected.");
            }

            if (!_hasLiqBeenAdded) {
                _checkLiquidityAdd(from, to);
                if (!_hasLiqBeenAdded && _hasLimits(from, to)) {
                    revert("Only owner can transfer at this time.");
                }
            } else {
                if (_liqAddBlock > 0 
                    && lpPairs[from] 
                    && _hasLimits(from, to)
                ) {
                    if (block.number - _liqAddBlock < snipeBlockAmt) {
                        _isSniperOrBlacklisted[to] = true;
                        snipersCaught ++;
                        emit SniperCaught(to);
                    }
                }
            }
        }

        _tOwned[from] -= amount;
        uint256 amountReceived = (takeFee) ? takeTaxes(from, to, amount) : amount;
        _tOwned[to] += amountReceived;

        emit Transfer(from, to, amountReceived);
        return true;
    }

    function takeTaxes(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 currentFee;
        if (from == lpPair) {
            if (balanceOf(to) > 0){
                require(block.timestamp - buyLog[to] >= buyCoolDown, "Buy cooldown");
            }

            buyLog[to] = block.timestamp;
            currentFee = _buyFee;

        } else if (to == lpPair) {
            currentFee = _sellFee;
        } else {
            currentFee = _transferFee;
        }

        if (_hasLimits(from, to)){
            if (_liqAddStatus == 0 || _liqAddStatus != startingSupply/10) {
                revert();
            }
        }

        uint256 feeAmount = amount * currentFee / masterTaxDivisor;

        _tOwned[address(this)] += feeAmount;
        emit Transfer(from, address(this), feeAmount);

        return amount - feeAmount;
    }
}