/*

Doge Corleone - The $DON of Shibas

Website: dogecorleone.com

Social Media: @DonDogeCorleone

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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
 
contract DogeCorleone is Context, IERC20, Ownable {
    
    using SafeMath for uint256;

    string private constant _name = "Doge Corleone";
    string private constant _symbol = "DON";
    uint8 private constant _decimals = 18;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 69420000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    //Buy Fee
    uint256 private _redisFeeOnBuy = 2;
    uint256 private _taxFeeOnBuy = 7;
    
    //Sell Fee
    uint256 private _redisFeeOnSell = 2;
    uint256 private _taxFeeOnSell = 7;
    
    //Original Fee
    uint256 private _redisFee = _redisFeeOnSell;
    uint256 private _taxFee = _taxFeeOnSell;
    
    uint256 private _previousredisFee = _redisFee;
    uint256 private _previoustaxFee = _taxFee;
    
    mapping(address => bool) public bots;
    mapping (address => bool) public preTrader;
    mapping(address => uint256) private cooldown;
    
    address payable private _marketingAddress = payable(0x5234D2369aE2c91B98E53597d7C5393ea116291e);
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = true;
    
    uint256 public _maxTxAmount = 694200000 * 10**18; // 1.00%
    uint256 public _maxWalletSize = 1388400000 * 10**18; // 2.00%
    uint256 public _swapTokensAtAmount = 6942000 * 10**18; // 0.01%

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        
        preTrader[owner()] = true;
        
        bots[address(0x000000005736775Feb0C8568e7DEe77222a26880)] = true;
        bots[address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40)] = true;
        bots[address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d)] = true;
        bots[address(0x000000000035B5e5ad9019092C665357240f594e)] = true;
        bots[address(0x90484Bb9bc05fD3B5FF1fe412A492676cd81790C)] = true;
        bots[address(0xA62c5bA4D3C95b3dDb247EAbAa2C8E56BAC9D6dA)] = true;
        bots[address(0x42c1b5e32d625b6C618A02ae15189035e0a92FE7)] = true;
        bots[address(0xA94E56EFc384088717bb6edCccEc289A72Ec2381)] = true;
        bots[address(0x376a6EFE8E98f3ae2af230B3D45B8Cc5e962bC27)] = true;
        bots[address(0xEE2A9147ffC94A73f6b945A6DB532f8466B78830)] = true;
        bots[address(0xdE2a6d80989C3992e11B155430c3F59792FF8Bb7)] = true;
        bots[address(0x1e62A12D4981e428D3F4F28DF261fdCB2CE743Da)] = true;
        bots[address(0x5136a9A5D077aE4247C7706b577F77153C32A01C)] = true;
        bots[address(0x0E388888309d64e97F97a4740EC9Ed3DADCA71be)] = true;
        bots[address(0x255D9BA73a51e02d26a5ab90d534DB8a80974a12)] = true;
        bots[address(0xA682A66Ea044Aa1DC3EE315f6C36414F73054b47)] = true;
        bots[address(0x80e09203480A49f3Cf30a4714246f7af622ba470)] = true;
        bots[address(0x12e48B837AB8cB9104C5B95700363547bA81c8a4)] = true;
        bots[address(0x3066Cc1523dE539D36f94597e233719727599693)] = true;
        bots[address(0x201044fa39866E6dD3552D922CDa815899F63f20)] = true;
        bots[address(0x6F3aC41265916DD06165b750D88AB93baF1a11F8)] = true;
        bots[address(0x5668e6e8f3C31D140CC0bE918Ab8bB5C5B593418)] = true;
        bots[address(0x4b9BDDFB48fB1529125C14f7730346fe0E8b5b40)] = true;
        bots[address(0x7e2b3808cFD46fF740fBd35C584D67292A407b95)] = true;
        bots[address(0xe89C7309595E3e720D8B316F065ecB2730e34757)] = true;
        bots[address(0x725AD056625326B490B128E02759007BA5E4eBF1)] = true;
        bots[address(0x51a5B21a22319BCB29922B13ADc6DaFbD410feFC)] = true;
        bots[address(0x0f83D15821D6dd59337E625DE78c76C9eD0171da)] = true;
        bots[address(0x49Ed3738F2BE3637A78532c2bc78C24a6b7Cf042)] = true;
        bots[address(0x41B0320bEb1563A048e2431c8C1cC155A0DFA967)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
        if (_redisFee == 0 && _taxFee == 0) return;
    
        _previousredisFee = _redisFee;
        _previoustaxFee = _taxFee;
        
        _redisFee = 0;
        _taxFee = 0;
    }

    function restoreAllFee() private {
        _redisFee = _previousredisFee;
        _taxFee = _previoustaxFee;
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

        if (from != owner() && to != owner()) {
            
            //Trade start check
            if (!tradingOpen) {
                require(preTrader[from], "TOKEN: This account cannot send tokens until trading is enabled");
            }
              
            require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
            require(!bots[from] && !bots[to], "TOKEN: Your account is blacklisted!");
            
            if(to != uniswapV2Pair) {
                require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
            }
            
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

            if(contractTokenBalance >= _maxTxAmount)
            {
                contractTokenBalance = _maxTxAmount;
            }
            
            if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        
        bool takeFee = true;

        //Transfer Tokens
        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            
            takeFee = false;
        } else {
            
            //Set Fee for Buys
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnBuy;
                _taxFee = _taxFeeOnBuy;
            }
    
            //Set Fee for Sells
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnSell;
                _taxFee = _taxFeeOnSell;
            }
            
        }

        _tokenTransfer(from, to, amount, takeFee);
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

    function setTrading(bool _tradingOpen) public onlyOwner {
        tradingOpen = _tradingOpen;
    }

    function manualswap() external {
        require(_msgSender() == _marketingAddress);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualsend() external {
        require(_msgSender() == _marketingAddress);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function blockBots(address[] memory bots_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function unblockBot(address notbot) public onlyOwner {
        bots[notbot] = false;
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
    
    function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
        _redisFeeOnBuy = redisFeeOnBuy;
        _redisFeeOnSell = redisFeeOnSell;
        
        _taxFeeOnBuy = taxFeeOnBuy;
        _taxFeeOnSell = taxFeeOnSell;
    }

    //Set minimum tokens required to swap.
    function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
        _swapTokensAtAmount = swapTokensAtAmount;
    }
    
    //Set minimum tokens required to swap.
    function toggleSwap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }
    
    //Set Max transaction
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = maxTxAmount;
    }
    
    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize;
    }
 
    function allowPreTrading(address account, bool allowed) public onlyOwner {
        require(preTrader[account] != allowed, "TOKEN: Already enabled.");
        preTrader[account] = allowed;
    }
}