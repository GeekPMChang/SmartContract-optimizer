/*SPDX-License-Identifier: UNLICENSED

"Remember all the pain he's caused, the people he's hurt... NOW MAKE THAT YOUR POWER!!!"
— Goku encouraging Gohan to defeat Cell

https://t.me/apegoku

*/

pragma solidity ^0.8.10;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}  

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

contract APEGOKU is Context, IERC20, Ownable {
    mapping (address => uint) private _owned;
    mapping (address => mapping (address => uint)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isSniper;
    uint private constant _totalSupply = 1e12 * 10**9;

    string public constant name = unicode"APE Goku";
    string public constant symbol = unicode"APEGOKU";
    uint8 public constant decimals = 9;

    IUniswapV2Router02 private uniswapV2Router;

    address payable public _CollectionAdd;
    address public uniswapV2Pair;
    uint public _buyFee = 11;
    uint public _sellFee = 14;
    uint private _feeRate = 15;
    uint public _maxHeldTokens;

    uint public _launchedAt;
    bool private _tradingStart;
    bool private _inSwap = false;
    bool public _useImpactFeeSetter = false;

    struct User {
        uint buy;
        bool exists;
    }

    event FeeMultiplierUpdated(uint _multiplier);
    event ImpactFeeSetterUpdated(bool _usefeesetter);
    event FeeRateUpdated(uint _rate);
    event FeesUpdated(uint _buy, uint _sell);
    event TaxAddUpdated(address _taxwallet);
    
    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }
    constructor (address payable TaxAdd) {
        _CollectionAdd = TaxAdd;
        _owned[address(this)] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[TaxAdd] = true;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function balanceOf(address account) public view override returns (uint) {
        return _owned[account];
    }
    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function totalSupply() public pure override returns (uint) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
       
        _transfer(sender, recipient, amount);
        uint allowedAmount = _allowances[sender][_msgSender()] - amount;
        _approve(sender, _msgSender(), allowedAmount);
        return true;
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint amount) private {
        require(!_isSniper[from]);
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
        bool isBuy = false;
        if(from != owner() && to != owner()) {
            if(from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(_tradingStart);
                if((_launchedAt + (5 minutes)) > block.timestamp) {
                    require((amount + balanceOf(address(to))) <= _maxHeldTokens); 
                }
                isBuy = true;
            }
            if(!_inSwap && _tradingStart && from != uniswapV2Pair) {
                uint contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance > 0) {
                    if(_useImpactFeeSetter) {
                        if(contractTokenBalance > (balanceOf(uniswapV2Pair) * _feeRate) / 100) {
                            contractTokenBalance = (balanceOf(uniswapV2Pair) * _feeRate) / 100;
                        }
                    }
                    swapTokensForEth(contractTokenBalance);
                }
                uint contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                isBuy = false;
            }
        }
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        _tokenTransfer(from,to,amount,takeFee,isBuy);
    }

    function swapTokensForEth(uint tokenAmount) private lockTheSwap {
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
        
    function sendETHToFee(uint amount) private {
        _CollectionAdd.transfer(amount);
    }
    
    function _tokenTransfer(address sender, address recipient, uint amount, bool takefee, bool buy) private {
        (uint fee) = _getFee(takefee, buy);
        _transferStandard(sender, recipient, amount, fee);
    }

    function _getFee(bool takefee, bool buy) private view returns (uint) {
        uint fee = 0;
        if(takefee) {
            if(buy) {
                fee = _buyFee;
            } else {
                fee = _sellFee;
            }
        }
        return fee;
    }

    function _transferStandard(address sender, address recipient, uint amount, uint fee) private {
        (uint transferAmount, uint team) = _getValues(amount, fee);
        _owned[sender] = _owned[sender] - amount;
        _owned[recipient] = _owned[recipient] + transferAmount; 
        _takeTeam(team);
        emit Transfer(sender, recipient, transferAmount);
    }

    function _getValues(uint amount, uint teamFee) private pure returns (uint, uint) {
        uint team = (amount * teamFee) / 100;
        uint transferAmount = amount - team;
        return (transferAmount, team);
    }

    function _takeTeam(uint team) private {
        _owned[address(this)] = _owned[address(this)] + team;
    }

    receive() external payable {}

    function initContract() external onlyOwner() {
        require(!_tradingStart);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function startTrading() external onlyOwner() {
        require(!_tradingStart);
        _tradingStart = true;
        _launchedAt = block.timestamp;
        _maxHeldTokens = 20000000000 * 10**9; 
    }

    function manualswap() external {
        uint contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    function manualsend() external {
        uint contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function setFeeRate(uint rate) external onlyOwner() {
        require(_msgSender() == _CollectionAdd);
        _feeRate = rate;
        emit FeeRateUpdated(_feeRate);
    }

    function setFees(uint buy, uint sell) external onlyOwner() {
        require(buy < 14 && sell < 14);
        _buyFee = buy;
        _sellFee = sell;
        emit FeesUpdated(_buyFee, _sellFee);
    }

    function updateTaxAdd(address newAddress) external {
        require(_msgSender() == _CollectionAdd);
        _CollectionAdd = payable(newAddress);
        emit TaxAddUpdated(_CollectionAdd);
    }

    function thisBalance() external view returns (uint) {
        return balanceOf(address(this));
    }

    function amountInPool() external view returns (uint) {
        return balanceOf(uniswapV2Pair);
    }
    

}