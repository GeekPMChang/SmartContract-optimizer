{"Gate.sol":{"content":"pragma solidity 0.4.25;\n\nimport \"./SafeMath.sol\";\nimport \"./ISettings.sol\";\nimport \"./IToken.sol\";\nimport \"./IOracle.sol\";\nimport \"./ITBoxManager.sol\";\n\n\n/// @title Gate\ncontract Gate {\n    using SafeMath for uint256;\n\n    /// @notice The address of the admin account.\n    address public admin;\n\n    // Fee percentage for TMV exchange\n    uint256 public feePercentTMV;\n\n    // Fee percentage for ETH exchange\n    uint256 public feePercentETH;\n\n    // Minimum amount to create order in TMV (18 decimals)\n    uint256 public minOrder;\n\n    // The address to transfer tokens\n    address public timviWallet;\n\n    ISettings public settings;\n\n    /// @dev An array containing the Order struct for all Orders in existence. The ID\n    ///  of each Order is actually an index into this array.\n    Order[] public orders;\n\n    /// @dev The Order struct. Every Order is represented by a copy\n    ///  of this structure.\n    struct Order {\n        address owner;\n        uint256 amount;\n    }\n\n    /// @dev The OrderCreated event is fired whenever a new Order comes into existence.\n    event OrderCreated(uint256 id, address owner, uint256 tmv);\n\n    /// @dev The OrderCancelled event is fired whenever an Order is cancelled.\n    event OrderCancelled(uint256 id, address owner, uint256 tmv);\n\n    /// @dev The OrderFilled event is fired whenever an Order is filled.\n    event OrderFilled(uint256 id, address owner, uint256 tmvTotal, uint256 tmvExecution, uint256 ethTotal, uint256 ethExecution);\n\n    /// @dev The OrderFilledPool event is fired whenever an Order is filled.\n    event OrderFilledPool(uint256 id, address owner, uint256 tmv, uint256 eth);\n\n    /// @dev The Converted event is fired whenever an exchange is processed immediately.\n    event Converted(address owner, uint256 tmv, uint256 eth);\n\n    /// @dev The Funded event is fired whenever the contract is funded.\n    event Funded(uint256 eth);\n\n    /// @dev The AdminChanged event is fired whenever the admin is changed.\n    event AdminChanged(address admin);\n\n    event GateTmvFeeUpdated(uint256 value);\n    event GateEthFeeUpdated(uint256 value);\n    event GateMinOrderUpdated(uint256 value);\n    event TimviWalletChanged(address wallet);\n    event GateFundsWithdrawn(uint256 value);\n\n    /// @dev Access modifier for admin-only functionality.\n    modifier onlyAdmin() {\n        require(admin == msg.sender, \"You have no access\");\n        _;\n    }\n\n    /// @dev Defends against front-running attacks.\n    modifier validTx() {\n        require(tx.gasprice \u003c= settings.gasPriceLimit(), \"Gas price is greater than allowed\");\n        _;\n    }\n\n    /// @notice ISettings address can\u0027t be changed later.\n    /// @dev The contract constructor sets the original `admin` of the contract to the sender\n    //   account and sets the settings contract with provided address.\n    /// @param _settings The address of the settings contract.\n    constructor(ISettings _settings) public {\n        admin = msg.sender;\n        timviWallet = msg.sender;\n        settings = ISettings(_settings);\n\n        feePercentTMV = 500; // 0.5%\n        feePercentETH = 500; // 0.5%\n        minOrder = 10 ** 18; // 1 TMV by default\n\n        emit GateTmvFeeUpdated(feePercentTMV);\n        emit GateEthFeeUpdated(feePercentETH);\n        emit GateMinOrderUpdated(minOrder);\n        emit TimviWalletChanged(timviWallet);\n        emit AdminChanged(admin);\n    }\n\n    function fundAdmin() external payable {\n        emit Funded(msg.value);\n    }\n\n    /// @dev Withdraws ETH.\n    function withdraw(address _beneficiary, uint256 _amount) external onlyAdmin {\n        require(_beneficiary != address(0), \"Zero address, be careful\");\n        require(address(this).balance \u003e= _amount, \"Insufficient funds\");\n        _beneficiary.transfer(_amount);\n        emit GateFundsWithdrawn(_amount);\n    }\n\n    /// @dev Sets feePercentTMV.\n    function setTmvFee(uint256 _value) external onlyAdmin {\n        require(_value \u003c= 10000, \"Too much\");\n        feePercentTMV = _value;\n        emit GateTmvFeeUpdated(_value);\n    }\n\n    /// @dev Sets feePercentETH.\n    function setEthFee(uint256 _value) external onlyAdmin {\n        require(_value \u003c= 10000, \"Too much\");\n        feePercentETH = _value;\n        emit GateEthFeeUpdated(_value);\n    }\n\n    /// @dev Sets minimum order amount.\n    function setMinOrder(uint256 _value) external onlyAdmin {\n        // The \"ether\" word just multiplies given value by 10 ** 18\n        require(_value \u003c= 100 ether, \"Too much\");\n\n        minOrder = _value;\n        emit GateMinOrderUpdated(_value);\n    }\n\n    /// @dev Sets timvi wallet address.\n    function setTimviWallet(address _wallet) external onlyAdmin {\n        require(_wallet != address(0), \"Zero address, be careful\");\n\n        timviWallet = _wallet;\n        emit TimviWalletChanged(_wallet);\n    }\n\n    /// @dev Sets admin address.\n    function changeAdmin(address _newAdmin) external onlyAdmin {\n        require(_newAdmin != address(0), \"Zero address, be careful\");\n        admin = _newAdmin;\n        emit AdminChanged(msg.sender);\n    }\n\n    function convert(uint256 _amount) external validTx {\n        require(_amount \u003e= minOrder, \"Too small amount\");\n        require(IToken(settings.tmvAddress()).allowance(msg.sender, address(this)) \u003e= _amount, \"Gate is not approved to transfer enough tokens\");\n        uint256 eth = tmv2eth(_amount);\n        if (address(this).balance \u003e= eth) {\n            IToken(settings.tmvAddress()).transferFrom(msg.sender, timviWallet, _amount);\n            msg.sender.transfer(eth);\n            emit Converted(msg.sender, _amount, eth);\n        } else {\n            IToken(settings.tmvAddress()).transferFrom(msg.sender, address(this), _amount);\n            uint256 id = orders.push(Order(msg.sender, _amount)).sub(1);\n            emit OrderCreated(id, msg.sender, _amount);\n        }\n    }\n\n    /// @dev Cancels an Order.\n    function cancel(uint256 _id) external {\n        require(orders[_id].owner == msg.sender, \"Order isn\u0027t yours\");\n\n        uint256 tmv = orders[_id].amount;\n        delete orders[_id];\n        IToken(settings.tmvAddress()).transfer(msg.sender, tmv);\n        emit OrderCancelled(_id, msg.sender, tmv);\n    }\n\n    /// @dev Fills Orders by ids array.\n    function multiFill(uint256[] _ids) external onlyAdmin() payable {\n\n        if (msg.value \u003e 0) {\n            emit Funded(msg.value);\n        }\n\n        for (uint256 i = 0; i \u003c _ids.length; i++) {\n            uint256 id = _ids[i];\n\n            require(orders[id].owner != address(0), \"Order doesn\u0027t exist\");\n\n            uint256 tmv = orders[id].amount;\n            uint256 eth = tmv2eth(tmv);\n\n            require(address(this).balance \u003e= eth, \"Not enough funds\");\n\n            address owner = orders[id].owner;\n            if (owner.send(eth)) {\n                delete orders[id];\n                IToken(settings.tmvAddress()).transfer(timviWallet, tmv);\n                emit OrderFilledPool(id, owner, tmv, eth);\n            }\n        }\n    }\n\n    /// @dev Fills an Order by id.\n    function fill(uint256 _id) external payable validTx {\n        require(orders[_id].owner != address(0), \"Order doesn\u0027t exist\");\n\n        // Retrieve values from storage\n        uint256 tmv = orders[_id].amount;\n        address owner = orders[_id].owner;\n\n        // Calculate the demand amount of Ether\n        uint256 eth = tmv.mul(precision()).div(rate());\n\n        require(msg.value \u003e= eth, \"Not enough funds\");\n\n        emit Funded(eth);\n\n        // Calculate execution values\n        uint256 tmvFee = tmv.mul(feePercentTMV).div(precision());\n        uint256 ethFee = eth.mul(feePercentETH).div(precision());\n\n        uint256 tmvExecution = tmv.sub(tmvFee);\n        uint256 ethExecution = eth.sub(ethFee);\n\n        // Remove record about an order\n        delete orders[_id];\n\n        // Transfer order\u0027 funds\n        owner.transfer(ethExecution);\n        IToken(settings.tmvAddress()).transfer(msg.sender, tmvExecution);\n        IToken(settings.tmvAddress()).transfer(timviWallet, tmvFee);\n\n        // Return Ether rest if exist\n        msg.sender.transfer(msg.value.sub(eth));\n\n        emit OrderFilled(_id, owner, tmv, tmvExecution, eth, ethExecution);\n    }\n\n    /// @dev Returns current oracle ETH/USD price with precision.\n    function rate() public view returns(uint256) {\n        return IOracle(settings.oracleAddress()).ethUsdPrice();\n    }\n\n    /// @dev Returns precision using for USD and commission calculation.\n    function precision() public view returns(uint256) {\n        return ITBoxManager(settings.tBoxManager()).precision();\n    }\n\n    /// @dev Calculates the ether amount to pay for a provided TMV amount.\n    function tmv2eth(uint256 _amount) public view returns(uint256) {\n        uint256 equivalent = _amount.mul(precision()).div(rate());\n        return chargeFee(equivalent, feePercentETH);\n    }\n\n    /// @dev Reduces the amount by system fee.\n    function chargeFee(uint256 _amount, uint256 _percent) public view returns(uint256) {\n        uint256 fee = _amount.mul(_percent).div(precision());\n        return _amount.sub(fee);\n    }\n}\n"},"IOracle.sol":{"content":"pragma solidity 0.4.25;\n\n\n/// @title IOracle\n/// @dev Interface for getting the data from the oracle contract.\ninterface IOracle {\n    function ethUsdPrice() external view returns(uint256);\n}\n"},"ISettings.sol":{"content":"pragma solidity 0.4.25;\n\n\n/// @title ISettings\n/// @dev Interface for getting the data from settings contract.\ninterface ISettings {\n    function oracleAddress() external view returns(address);\n    function minDeposit() external view returns(uint256);\n    function sysFee() external view returns(uint256);\n    function userFee() external view returns(uint256);\n    function ratio() external view returns(uint256);\n    function globalTargetCollateralization() external view returns(uint256);\n    function tmvAddress() external view returns(uint256);\n    function maxStability() external view returns(uint256);\n    function minStability() external view returns(uint256);\n    function gasPriceLimit() external view returns(uint256);\n    function isFeeManager(address account) external view returns (bool);\n    function tBoxManager() external view returns(address);\n}\n"},"ITBoxManager.sol":{"content":"pragma solidity 0.4.25;\n\n\n/// @title ILogic\n/// @dev Interface for interaction with the TMV logic contract to manage Boxes.\ninterface ITBoxManager {\n    function create(uint256 withdraw) external payable returns (uint256);\n    function precision() external view returns (uint256);\n    function rate() external view returns (uint256);\n    function transferFrom(address from, address to, uint256 tokenId) external;\n    function close(uint256 id) external;\n    function withdrawPercent(uint256 _collateral) external view returns(uint256);\n    function boxes(uint256 id) external view returns(uint256, uint256);\n    function withdrawEth(uint256 _id, uint256 _amount) external;\n    function withdrawTmv(uint256 _id, uint256 _amount) external;\n    function withdrawableEth(uint256 id) external view returns(uint256);\n    function withdrawableTmv(uint256 collateral) external view returns(uint256);\n    function maxCapAmount(uint256 _id) external view returns (uint256);\n    function collateralPercent(uint256 _id) external view returns (uint256);\n    function capitalize(uint256 _id, uint256 _tmv) external;\n    function boxWithdrawableTmv(uint256 _id) external view returns(uint256);\n    function addEth(uint256 _id) external payable;\n    function capitalizeMax(uint256 _id) external payable;\n    function withdrawTmvMax(uint256 _id) external payable;\n    function addTmv(uint256 _id, uint256 _amount) external payable;\n}\n"},"IToken.sol":{"content":"pragma solidity 0.4.25;\n\n\n/// @title IToken\n/// @dev Interface for interaction with the TMV token contract.\ninterface IToken {\n    function burnLogic(address from, uint256 value) external;\n    function approve(address spender, uint256 value) external;\n    function balanceOf(address who) external view returns (uint256);\n    function mint(address to, uint256 value) external returns (bool);\n    function totalSupply() external view returns (uint256);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function transfer(address to, uint256 value) external returns (bool);\n    function transferFrom(address from, address to, uint256 tokenId) external;\n}\n\n"},"SafeMath.sol":{"content":"pragma solidity 0.4.25;\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that revert on error\n */\nlibrary SafeMath {\n    /**\n    * @dev Multiplies two numbers, reverts on overflow.\n    */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \u0027mul\u0027);\n\n        return c;\n    }\n\n    /**\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\n    */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, \u0027div\u0027);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\n    */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a, \u0027sub\u0027);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n    * @dev Adds two numbers, reverts on overflow.\n    */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \u0027add\u0027);\n\n        return c;\n    }\n\n    /**\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\n    * reverts when dividing by zero.\n    */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0);\n        return a % b;\n    }\n}\n"}}