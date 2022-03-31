// SPDX-License-Identifier: Unlicensed

/*
https://t.me/apecap
https://t.me/apecap
https://t.me/apecap

Ape capital 

Ape capital not only provide a direct indication on what project is worth to invest, but also play the role as the liquidity provider to all qualified new coming crypto IDO projects

Our mission is to create a rug-free and profitable environment for all of our token holders by offering a decentralised governance. Token holders earn the final decision on which project to fund through the DAO election, making sure the liquidity pool is used in the right way. 

Ape capital has 4 traits:

1) Decentralized Governance,
2) Decentralized Liquidity Pool
3) Decentralized Passive Income
4) Decentralized Investment suggestion

Decentralised Governance

The function of decentralised governance is to demonstrate a collective decision by our token holders, rules and requirements on selecting which new IDO to be funded will be formulated collectively.

Decentralised Liquidity Pool

The liquidity pool of approved projects will be provided by our DAO. It escalated the liquidity pool to a decentralised level. Our DAO will lock the Liquid Pool once the Ape capital Asset Management analytical Team confirms that the project is committed. If the DAO agrees, we could consider investing on that designed project as well.

Decentralised Passive Income

All liquidity pool providers would earn a passive income when people trade the token by the pool. It is simple for Ape capital to gain the passive income and share the income to all our holders with staking.

Decentralized Investment suggestion

Ape capital enables every token holder to access the most updated crypto investment report by our finest strategists. Ape capital Asset Management analytical Team deals with the most challenging work related to due diligence making sure every project we invest is rug-free

Therefore, the approved decentralized liquidity pool project could be your investment choice. The selection will be a decentralized investment suggestion. We strive our best to eliminate the possibility of “rug-pull” and to make sure every choice of our investment is the right choice.


*/

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract APECAP is Context, IERC20, Ownable {
    
    using SafeMath for uint256;

    string private constant _name = "APE CAPITAL";
    string private constant _symbol = "APECAP";
    uint8 private constant _decimals = 9;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping (address => uint256) private _buyMap;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1e9 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    mapping(address => bool) private _isSniper;
    uint256 public launchTime;

    uint256 private _redisFeeJeets = 0;
    uint256 private _taxFeeJeets = 15;

    uint256 private _totalRefOnBuy = 0;
    uint256 private _totalTaxOnSell = 10;
    
    uint256 private _totalRefOnSell = 0;
    uint256 private _totalSellTax = 15;
    
    uint256 private _redisFee = _totalRefOnSell;
    uint256 private _taxFee = _totalSellTax;
    uint256 private _burnFee = 0;
    
    uint256 private _previousredisFee = _redisFee;
    uint256 private _previoustaxFee = _taxFee;
    uint256 private _previousburnFee = _burnFee;
    
    address payable private _marketingAddress = payable(0xD1e7DAdaAbd0BD853A260c62898cD0B73E469F12);
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public timeJeets = 5 minutes;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = true;
    bool private isMaxBuyActivated = true;
    
    uint256 public _maxTxAmount = 2e7 * 10**9; 
    uint256 public _maxWalletSize = 2e7 * 10**9;
    uint256 public _swapTokensAtAmount = 1000 * 10**9;
    uint256 public _minimumBuyAmount = 2e7 * 10**9 ;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        
        _rOwned[_msgSender()] = _rTotal;
        
       
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _isExcludedFromFee[deadAddress] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function createNewPair() external onlyOwner{
        require(!tradingOpen);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function tokenFromReflection(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function removeAllFee() private {
        if (_redisFee == 0 && _taxFee == 0 && _burnFee == 0) return;
    
        _previousredisFee = _redisFee;
        _previoustaxFee = _taxFee;
        _previousburnFee = _burnFee;
        
        _redisFee = 0;
        _taxFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _redisFee = _previousredisFee;
        _taxFee = _previoustaxFee;
        _burnFee = _previousburnFee;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isSniper[to], 'Stop sniping!');
        require(!_isSniper[from], 'Stop sniping!');
        require(!_isSniper[_msgSender()], 'Stop sniping!');

        if (from != owner() && to != owner()) {
            
            if (!tradingOpen) {
                revert("Trading not yet enabled!");
            }
            
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                if (to != address(this) && from != address(this) && to != _marketingAddress && from != _marketingAddress) {
                    require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
                }
            }

            if (to != uniswapV2Pair && to != _marketingAddress && to != address(this) && to != deadAddress) {
                require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
                if (isMaxBuyActivated) {
                    if (block.timestamp <= launchTime + 20 minutes) {
                        require(amount <= _minimumBuyAmount, "Amount too much");
                    }
                }
            }
            
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance > _swapTokensAtAmount;
            
            if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                uint256 burntAmount = 0;
                if (_burnFee > 0) {
                    burntAmount = contractTokenBalance.mul(_burnFee).div(10**2);
                    burnTokens(burntAmount);
                }
                swapTokensForEth(contractTokenBalance - burntAmount);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        
        bool takeFee = true;

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            takeFee = false;
        } else {
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                    _buyMap[to] = block.timestamp;
                    _redisFee = _totalRefOnBuy;
                    _taxFee = _totalTaxOnSell;
                    if (block.timestamp == launchTime) {
                        _isSniper[to] = true;
                    }
            }
    
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                if (_buyMap[from] != 0 && (_buyMap[from] + timeJeets >= block.timestamp)) {
                    _redisFee = _redisFeeJeets;
                    _taxFee = _taxFeeJeets;
                } else {
                    _redisFee = _totalRefOnSell;
                    _taxFee = _totalSellTax;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function burnTokens(uint256 burntAmount) private {
        _transfer(address(this), deadAddress, burntAmount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _marketingAddress.transfer(amount);
    }

    function setTrading() public onlyOwner {
        require(!tradingOpen);
        tradingOpen = true;
        launchTime = block.timestamp;
    }

    function setMarketingWallet(address marketingAddress) external {
        require(_msgSender() == _marketingAddress);
        _marketingAddress = payable(marketingAddress);
        _isExcludedFromFee[_marketingAddress] = true;
    }

    function setIsMaxBuyActivated(bool _isMaxBuyActivated) public onlyOwner {
        isMaxBuyActivated = _isMaxBuyActivated;
    }

    function manualswap(uint256 amount) external {
        require(_msgSender() == _marketingAddress);
        require(amount <= balanceOf(address(this)) && amount > 0, "Wrong amount");
        swapTokensForEth(amount);
    }

    function addSniper(address sniper) external onlyOwner {
        _isSniper[sniper] = true;
    }

    function removeSniper(address sniper) external onlyOwner {
        if (_isSniper[sniper]) {
            _isSniper[sniper] = false;
        }
    }

    function isSniper(address sniper) external view returns (bool){
        return _isSniper[sniper];
    }

    function manualsend() external {
        require(_msgSender() == _marketingAddress);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    receive() external payable {}

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
            _getTValues(tAmount, _redisFee, _taxFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tFee, tTeam, currentRate);
        
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getTValues(
        uint256 tAmount,
        uint256 redisFee,
        uint256 taxFee
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(redisFee).div(100);
        uint256 tTeam = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);

        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);

        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();

        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
    
        return (rSupply, tSupply);
    }

    function toggleSwap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }
    
    function setMaxTxnAmount(uint256 maxTxAmount) external onlyOwner {
        require(maxTxAmount >= 5e9 * 10**9, "Maximum transaction amount must be greater than 0.5%");
        _maxTxAmount = maxTxAmount;
    }
    
    function setMaxWalletSize(uint256 maxWalletSize) external onlyOwner {
        require(maxWalletSize >= _maxWalletSize);
        _maxWalletSize = maxWalletSize;
    }

    function setTaxFee(uint256 amountBuy, uint256 amountSell) external onlyOwner {
        require( amountBuy <= 13);
        require( amountSell <= 15);
        _totalTaxOnSell = amountBuy;
        _totalSellTax = amountSell;
    }

    function setRefFee(uint256 amountRefBuy, uint256 amountRefSell) external onlyOwner {
        _totalRefOnBuy = amountRefBuy;
        _totalRefOnSell = amountRefSell;
    }

    function setBurnFee(uint256 amount) external onlyOwner {
        require(amount >= 0 && amount <= 1);
        _burnFee = amount;
    }

    function setJeetsFee(uint256 amountRedisJeets, uint256 amountTaxJeets) external onlyOwner {
        require(amountRedisJeets >= 0 && amountRedisJeets <= 1);
        require(amountTaxJeets >= 0 && amountTaxJeets <= 19);
        _redisFeeJeets = amountRedisJeets;
        _taxFeeJeets = amountTaxJeets;
    }

    function setTimeJeets(uint256 hoursTime) external onlyOwner {
        require(hoursTime >= 0 && hoursTime <= 4);
        timeJeets = hoursTime * 1 hours;
    }

}