{"BasicToken.sol":{"content":"pragma solidity ^0.5.3;\n\n\nimport \"./ERC20Basic.sol\";\nimport \"./SafeMath.sol\";\n\n\n/**\n * @title Basic token\n * @dev Basic version of StandardToken, with no allowances.\n */\ncontract BasicToken is ERC20Basic {\n  using SafeMath for uint256;\n\n  mapping(address =\u003e uint256) balances;\n\n  uint256 totalSupply_;\n\n  /**\n  * @dev total number of tokens in existence\n  */\n  function totalSupply() public view returns (uint256) {\n    return totalSupply_;\n  }\n\n  /**\n  * @dev transfer token for a specified address\n  * @param _to The address to transfer to.\n  * @param _value The amount to be transferred.\n  */\n  function transfer(address _to, uint256 _value) public returns (bool) {\n    require(_to != address(0));\n    require(_value \u003c= balances[msg.sender]);\n\n    // SafeMath.sub will throw if there is not enough balance.\n    balances[msg.sender] = balances[msg.sender].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    emit Transfer(msg.sender, _to, _value);\n    return true;\n  }\n\n  /**\n  * @dev Gets the balance of the specified address.\n  * @param _owner The address to query the the balance of.\n  * @return An uint256 representing the amount owned by the passed address.\n  */\n  function balanceOf(address _owner) public view returns (uint256 balance) {\n    return balances[_owner];\n  }\n\n}\n"},"BurnableToken.sol":{"content":"pragma solidity ^0.5.3;\n\nimport \"./BasicToken.sol\";\n\n\n/**\n * @title Burnable Token\n * @dev Token that can be irreversibly burned (destroyed).\n */\ncontract BurnableToken is BasicToken {\n\n  event Burn(address indexed burner, uint256 value);\n\n  /**\n   * @dev Burns a specific amount of tokens.\n   * @param _value The amount of token to be burned.\n   */\n  function burn(uint256 _value) public {\n    require(_value \u003c= balances[msg.sender]);\n    // no need to require value \u003c= totalSupply, since that would imply the\n    // sender\u0027s balance is greater than the totalSupply, which *should* be an assertion failure\n\n    address burner = msg.sender;\n    balances[burner] = balances[burner].sub(_value);\n    totalSupply_ = totalSupply_.sub(_value);\n    emit Burn(burner, _value);\n    emit Transfer(burner, address(0), _value);\n  }\n}\n"},"ERC20.sol":{"content":"pragma solidity ^0.5.3;\n\nimport \"./ERC20Basic.sol\";\n\n\n/**\n * @title ERC20 interface\n * @dev see https://github.com/ethereum/EIPs/issues/20\n */\ncontract ERC20 is ERC20Basic {\n  function allowance(address owner, address spender) public view returns (uint256);\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\n  function approve(address spender, uint256 value) public returns (bool);\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"ERC20Basic.sol":{"content":"pragma solidity ^0.5.3;\n\n\n/**\n * @title ERC20Basic\n * @dev Simpler version of ERC20 interface\n * @dev see https://github.com/ethereum/EIPs/issues/179\n */\ncontract ERC20Basic {\n  function totalSupply() public view returns (uint256);\n  function balanceOf(address who) public view returns (uint256);\n  function transfer(address to, uint256 value) public returns (bool);\n  event Transfer(address indexed from, address indexed to, uint256 value);\n}\n"},"GNTDeposit.sol":{"content":"pragma solidity 0.5.11;\n\nimport \"./Ownable.sol\";\nimport \"./GolemNetworkTokenBatching.sol\";\nimport \"./ReceivingContract.sol\";\n\ncontract GNTDeposit is ReceivingContract, Ownable {\n    using SafeMath for uint256;\n\n    address public concent;\n    address public coldwallet;\n\n    // Deposit will be locked for this much longer after unlocking and before\n    // it\u0027s possible to withdraw.\n    uint256 public withdrawal_delay;\n\n    // Contract will not accept new deposits if the total amount of tokens it\n    // holds would exceed this amount.\n    uint256 public maximum_deposits_total;\n    // Maximum deposit value per user.\n    uint256 public maximum_deposit_amount;\n\n    // Limit amount of tokens Concent can reimburse within a single day.\n    uint256 public daily_reimbursement_limit;\n    uint256 private current_reimbursement_day;\n    uint256 private current_reimbursement_sum;\n\n    GolemNetworkTokenBatching public token;\n    // owner =\u003e amount\n    mapping (address =\u003e uint256) public balances;\n    // owner =\u003e timestamp after which withdraw is possible\n    //        | 0 if locked\n    mapping (address =\u003e uint256) public locked_until;\n\n    event ConcentTransferred(address indexed _previousConcent, address indexed _newConcent);\n    event ColdwalletTransferred(address indexed _previousColdwallet, address indexed _newColdwallet);\n    event Deposit(address indexed _owner, uint256 _amount);\n    event Withdraw(address indexed _from, address indexed _to, uint256 _amount);\n    event Lock(address indexed _owner);\n    event Unlock(address indexed _owner);\n    event Burn(address indexed _who, uint256 _amount);\n    event ReimburseForSubtask(address indexed _requestor, address indexed _provider, uint256 _amount, bytes32 _subtask_id);\n    event ReimburseForNoPayment(address indexed _requestor, address indexed _provider, uint256 _amount, uint256 _closure_time);\n    event ReimburseForVerificationCosts(address indexed _from, uint256 _amount, bytes32 _subtask_id);\n    event ReimburseForCommunication(address indexed _from, uint256 _amount);\n\n    constructor(\n        GolemNetworkTokenBatching _token,\n        address _concent,\n        address _coldwallet,\n        uint256 _withdrawal_delay\n    )\n        public\n    {\n        token = _token;\n        concent = _concent;\n        coldwallet = _coldwallet;\n        withdrawal_delay = _withdrawal_delay;\n    }\n\n    // modifiers\n\n    modifier onlyUnlocked() {\n        require(isUnlocked(msg.sender), \"Deposit is not unlocked\");\n        _;\n    }\n\n    modifier onlyConcent() {\n        require(msg.sender == concent, \"Concent only method\");\n        _;\n    }\n\n    modifier onlyToken() {\n        require(msg.sender == address(token), \"Token only method\");\n        _;\n    }\n\n    // views\n\n    function balanceOf(address _owner) external view returns (uint256) {\n        return balances[_owner];\n    }\n\n    function isLocked(address _owner) external view returns (bool) {\n        return locked_until[_owner] == 0;\n    }\n\n    function isTimeLocked(address _owner) external view returns (bool) {\n        return locked_until[_owner] \u003e block.timestamp;\n    }\n\n    function isUnlocked(address _owner) public view returns (bool) {\n        return locked_until[_owner] != 0 \u0026\u0026 locked_until[_owner] \u003c block.timestamp;\n    }\n\n    function getTimelock(address _owner) external view returns (uint256) {\n        return locked_until[_owner];\n    }\n\n    function isDepositPossible(address _owner, uint256 _amount) external view returns (bool) {\n        return !_isTotalDepositsLimitHit(_amount) \u0026\u0026 !_isMaximumDepositLimitHit(_owner, _amount);\n    }\n\n    // management\n\n    function transferConcent(address _newConcent) onlyOwner external {\n        require(_newConcent != address(0), \"New concent address cannot be 0\");\n        emit ConcentTransferred(concent, _newConcent);\n        concent = _newConcent;\n    }\n\n    function transferColdwallet(address _newColdwallet) onlyOwner external {\n        require(_newColdwallet != address(0), \"New coldwallet address cannot be 0\");\n        emit ColdwalletTransferred(coldwallet, _newColdwallet);\n        coldwallet = _newColdwallet;\n    }\n\n    function setMaximumDepositsTotal(uint256 _value) onlyOwner external {\n        maximum_deposits_total = _value;\n    }\n\n    function setMaximumDepositAmount(uint256 _value) onlyOwner external {\n        maximum_deposit_amount = _value;\n    }\n\n    function setDailyReimbursementLimit(uint256 _value) onlyOwner external {\n        daily_reimbursement_limit = _value;\n    }\n\n    // deposit API\n\n    function unlock() external {\n        locked_until[msg.sender] = block.timestamp + withdrawal_delay;\n        emit Unlock(msg.sender);\n    }\n\n    function lock() external {\n        locked_until[msg.sender] = 0;\n        emit Lock(msg.sender);\n    }\n\n    function onTokenReceived(address _from, uint256 _amount, bytes calldata /* _data */) external onlyToken {\n        // Pass 0 as the amount since this check happens post transfer, thus\n        // amount is already accounted for in the balance\n        require(!_isTotalDepositsLimitHit(0), \"Total deposits limit hit\");\n        require(!_isMaximumDepositLimitHit(_from, _amount), \"Maximum deposit limit hit\");\n        balances[_from] += _amount;\n        locked_until[_from] = 0;\n        emit Deposit(_from, _amount);\n    }\n\n    function withdraw(address _to) onlyUnlocked external {\n        uint256 _amount = balances[msg.sender];\n        balances[msg.sender] = 0;\n        locked_until[msg.sender] = 0;\n        require(token.transfer(_to, _amount));\n        emit Withdraw(msg.sender, _to, _amount);\n    }\n\n    function burn(address _whom, uint256 _amount) onlyConcent external {\n        require(balances[_whom] \u003e= _amount, \"Not enough funds to burn\");\n        balances[_whom] -= _amount;\n        if (balances[_whom] == 0) {\n            locked_until[_whom] = 0;\n        }\n        token.burn(_amount);\n        emit Burn(_whom, _amount);\n    }\n\n    function reimburseForSubtask(\n        address _requestor,\n        address _provider,\n        uint256 _amount,\n        bytes32 _subtask_id,\n        uint8 _v,\n        bytes32 _r,\n        bytes32 _s,\n        uint256 _reimburse_amount\n    )\n        onlyConcent\n        external\n    {\n        require(_isValidSignature(_requestor, _provider, _amount, _subtask_id, _v, _r, _s), \"Invalid signature\");\n        require(_reimburse_amount \u003c= _amount, \"Reimburse amount exceeds allowed\");\n        _reimburse(_requestor, _provider, _reimburse_amount);\n        emit ReimburseForSubtask(_requestor, _provider, _reimburse_amount, _subtask_id);\n    }\n\n    function reimburseForNoPayment(\n        address _requestor,\n        address _provider,\n        uint256[] calldata _amount,\n        bytes32[] calldata _subtask_id,\n        uint8[] calldata _v,\n        bytes32[] calldata _r,\n        bytes32[] calldata _s,\n        uint256 _reimburse_amount,\n        uint256 _closure_time\n    )\n        onlyConcent\n        external\n    {\n        require(_amount.length == _subtask_id.length);\n        require(_amount.length == _v.length);\n        require(_amount.length == _r.length);\n        require(_amount.length == _s.length);\n        // Can\u0027t merge the following two loops as we exceed the number of veriables on the stack\n        // and the compiler gives: CompilerError: Stack too deep, try removing local variables.\n        for (uint256 i = 0; i \u003c _amount.length; i++) {\n          require(_isValidSignature(_requestor, _provider, _amount[i], _subtask_id[i], _v[i], _r[i], _s[i]), \"Invalid signature\");\n        }\n        uint256 total_amount = 0;\n        for (uint256 i = 0; i \u003c _amount.length; i++) {\n          total_amount += _amount[i];\n        }\n        require(_reimburse_amount \u003c= total_amount, \"Reimburse amount exceeds total\");\n        _reimburse(_requestor, _provider, _reimburse_amount);\n        emit ReimburseForNoPayment(_requestor, _provider, _reimburse_amount, _closure_time);\n    }\n\n    function reimburseForVerificationCosts(\n        address _from,\n        uint256 _amount,\n        bytes32 _subtask_id,\n        uint8 _v,\n        bytes32 _r,\n        bytes32 _s,\n        uint256 _reimburse_amount\n    )\n        onlyConcent\n        external\n    {\n        require(_isValidSignature(_from, address(this), _amount, _subtask_id, _v, _r, _s), \"Invalid signature\");\n        require(_reimburse_amount \u003c= _amount, \"Reimburse amount exceeds allowed\");\n        _reimburse(_from, coldwallet, _reimburse_amount);\n        emit ReimburseForVerificationCosts(_from, _reimburse_amount, _subtask_id);\n    }\n\n    function reimburseForCommunication(\n        address _from,\n        uint256 _amount\n    )\n        onlyConcent\n        external\n    {\n        _reimburse(_from, coldwallet, _amount);\n        emit ReimburseForCommunication(_from, _amount);\n    }\n\n    // internals\n\n    function _reimburse(address _from, address _to, uint256 _amount) private {\n        require(balances[_from] \u003e= _amount, \"Not enough funds to reimburse\");\n        if (daily_reimbursement_limit != 0) {\n            if (current_reimbursement_day != block.timestamp / 1 days) {\n                current_reimbursement_day = block.timestamp / 1 days;\n                current_reimbursement_sum = 0;\n            }\n            require(current_reimbursement_sum + _amount \u003c= daily_reimbursement_limit, \"Daily reimbursement limit hit\");\n            current_reimbursement_sum += _amount;\n        }\n        balances[_from] -= _amount;\n        if (balances[_from] == 0) {\n            locked_until[_from] = 0;\n        }\n        require(token.transfer(_to, _amount));\n    }\n\n    function _isTotalDepositsLimitHit(uint256 _amount) private view returns (bool) {\n        if (maximum_deposits_total == 0) {\n            return false;\n        }\n        return token.balanceOf(address(this)).add(_amount) \u003e maximum_deposits_total;\n    }\n\n    function _isMaximumDepositLimitHit(address _owner, uint256 _amount) private view returns (bool) {\n        if (maximum_deposit_amount == 0) {\n            return false;\n        }\n        return balances[_owner].add(_amount) \u003e maximum_deposit_amount;\n    }\n\n    function _isValidSignature(\n        address _from,\n        address _to,\n        uint256 _amount,\n        bytes32 _subtask_id,\n        uint8 _v,\n        bytes32 _r,\n        bytes32 _s\n    ) public view returns (bool) {\n        // Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf)\n        // describes what constitutes a valid signature.\n        if (uint256(_s) \u003e 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\n            return false;\n        }\n        if (_v != 27 \u0026\u0026 _v != 28) {\n            return false;\n        }\n        return _from == ecrecover(keccak256(abi.encodePacked(\"\\x19Ethereum Signed Message:\\n124\", address(this), _from, _to, _amount, _subtask_id)), _v, _r, _s);\n    }\n\n}\n"},"GolemNetworkTokenBatching.sol":{"content":"// Copyright 2018 Golem Factory\n// Licensed under the GNU General Public License v3. See the LICENSE file.\n\npragma solidity ^0.5.3;\n\nimport \"./ReceivingContract.sol\";\nimport \"./TokenProxy.sol\";\n\n\n/// GolemNetworkTokenBatching can be treated as an upgraded GolemNetworkToken.\n/// 1. It is fully ERC20 compliant (GNT is missing approve and transferFrom)\n/// 2. It implements slightly modified ERC677 (transferAndCall method)\n/// 3. It provides batchTransfer method - an optimized way of executing multiple transfers\n///\n/// On how to convert between GNT and GNTB see TokenProxy documentation.\ncontract GolemNetworkTokenBatching is TokenProxy {\n\n    string public constant name = \"Golem Network Token Batching\";\n    string public constant symbol = \"GNTB\";\n    uint8 public constant decimals = 18;\n\n\n    event BatchTransfer(address indexed from, address indexed to, uint256 value,\n        uint64 closureTime);\n\n    constructor(ERC20Basic _gntToken) TokenProxy(_gntToken) public {\n    }\n\n    function batchTransfer(bytes32[] calldata payments, uint64 closureTime) external {\n        require(block.timestamp \u003e= closureTime);\n\n        uint balance = balances[msg.sender];\n\n        for (uint i = 0; i \u003c payments.length; ++i) {\n            // A payment contains compressed data:\n            // first 96 bits (12 bytes) is a value,\n            // following 160 bits (20 bytes) is an address.\n            bytes32 payment = payments[i];\n            address addr = address(uint256(payment));\n            require(addr != address(0) \u0026\u0026 addr != msg.sender);\n            uint v = uint(payment) / 2**160;\n            require(v \u003c= balance);\n            balances[addr] += v;\n            balance -= v;\n            emit BatchTransfer(msg.sender, addr, v, closureTime);\n        }\n\n        balances[msg.sender] = balance;\n    }\n\n    function transferAndCall(address to, uint256 value, bytes calldata data) external {\n      // Transfer always returns true so no need to check return value\n      transfer(to, value);\n\n      // No need to check whether recipient is a contract, this method is\n      // supposed to used only with contract recipients\n      ReceivingContract(to).onTokenReceived(msg.sender, value, data);\n    }\n}\n"},"Ownable.sol":{"content":"pragma solidity ^0.5.3;\n\n/**\n * @title Ownable\n * @dev The Ownable contract has an owner address, and provides basic authorization control\n * functions, this simplifies the implementation of \"user permissions\".\n */\ncontract Ownable {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n     * account.\n     */\n    constructor () internal {\n        _owner = msg.sender;\n        emit OwnershipTransferred(address(0), _owner);\n    }\n\n    /**\n     * @return the address of the owner.\n     */\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(isOwner(), \"Owner only method\");\n        _;\n    }\n\n    /**\n     * @return true if `msg.sender` is the owner of the contract.\n     */\n    function isOwner() public view returns (bool) {\n        return msg.sender == _owner;\n    }\n\n    /**\n     * @dev Allows the current owner to relinquish control of the contract.\n     * @notice Renouncing to ownership will leave the contract without an owner.\n     * It will not be possible to call the functions with the `onlyOwner`\n     * modifier anymore.\n     */\n    function renounceOwnership() public onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\n     * @param newOwner The address to transfer ownership to.\n     */\n    function transferOwnership(address newOwner) public onlyOwner {\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers control of the contract to a newOwner.\n     * @param newOwner The address to transfer ownership to.\n     */\n    function _transferOwnership(address newOwner) internal {\n        require(newOwner != address(0));\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"},"ReceivingContract.sol":{"content":"pragma solidity 0.5.11;\n\n/// Contracts implementing this interface are compatible with\n/// GolemNetworkTokenBatching\u0027s transferAndCall method\ncontract ReceivingContract {\n    function onTokenReceived(address _from, uint _value, bytes calldata _data) external;\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.5.3;\n\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\nlibrary SafeMath {\n\n  /**\n  * @dev Multiplies two numbers, throws on overflow.\n  */\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n    if (a == 0) {\n      return 0;\n    }\n    uint256 c = a * b;\n    assert(c / a == b);\n    return c;\n  }\n\n  /**\n  * @dev Integer division of two numbers, truncating the quotient.\n  */\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n    // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\n    uint256 c = a / b;\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n    return c;\n  }\n\n  /**\n  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\n  */\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n    assert(b \u003c= a);\n    return a - b;\n  }\n\n  /**\n  * @dev Adds two numbers, throws on overflow.\n  */\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\n    uint256 c = a + b;\n    assert(c \u003e= a);\n    return c;\n  }\n}\n"},"StandardToken.sol":{"content":"pragma solidity ^0.5.3;\n\nimport \"./BasicToken.sol\";\nimport \"./ERC20.sol\";\n\n\n/**\n * @title Standard ERC20 token\n *\n * @dev Implementation of the basic standard token.\n * @dev https://github.com/ethereum/EIPs/issues/20\n * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\n */\ncontract StandardToken is ERC20, BasicToken {\n\n  mapping (address =\u003e mapping (address =\u003e uint256)) internal allowed;\n\n\n  /**\n   * @dev Transfer tokens from one address to another\n   * @param _from address The address which you want to send tokens from\n   * @param _to address The address which you want to transfer to\n   * @param _value uint256 the amount of tokens to be transferred\n   */\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\n    require(_to != address(0));\n    require(_value \u003c= balances[_from]);\n    require(_value \u003c= allowed[_from][msg.sender]);\n\n    balances[_from] = balances[_from].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n    emit Transfer(_from, _to, _value);\n    return true;\n  }\n\n  /**\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\n   *\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   * @param _spender The address which will spend the funds.\n   * @param _value The amount of tokens to be spent.\n   */\n  function approve(address _spender, uint256 _value) public returns (bool) {\n    require(allowed[msg.sender][_spender] == 0);\n    allowed[msg.sender][_spender] = _value;\n    emit Approval(msg.sender, _spender, _value);\n    return true;\n  }\n\n  /**\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\n   * @param _owner address The address which owns the funds.\n   * @param _spender address The address which will spend the funds.\n   * @return A uint256 specifying the amount of tokens still available for the spender.\n   */\n  function allowance(address _owner, address _spender) public view returns (uint256) {\n    return allowed[_owner][_spender];\n  }\n\n  /**\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\n   *\n   * approve should be called when allowed[_spender] == 0. To increment\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _addedValue The amount of tokens to increase the allowance by.\n   */\n  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {\n    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n  /**\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\n   *\n   * approve should be called when allowed[_spender] == 0. To decrement\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\n   */\n  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {\n    uint oldValue = allowed[msg.sender][_spender];\n    if (_subtractedValue \u003e oldValue) {\n      allowed[msg.sender][_spender] = 0;\n    } else {\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\n    }\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n}\n"},"TokenProxy.sol":{"content":"// Copyright 2018 Golem Factory\n// Licensed under the GNU General Public License v3. See the LICENSE file.\n\npragma solidity ^0.5.3;\n\nimport \"./BurnableToken.sol\";\nimport \"./StandardToken.sol\";\n\n/// The Gate is a contract with unique address to allow a token holder\n/// (called \"User\") to transfer tokens from original Token to the Proxy.\n///\n/// The Gate does not know who its User is. The User-Gate relationship is\n/// managed by the Proxy.\ncontract Gate {\n    ERC20Basic private TOKEN;\n    address private PROXY;\n\n    /// Gates are to be created by the TokenProxy.\n    constructor(ERC20Basic _token, address _proxy) public {\n        TOKEN = _token;\n        PROXY = _proxy;\n    }\n\n    /// Transfer requested amount of tokens from Gate to Proxy address.\n    /// Only the Proxy can request this and should request transfer of all\n    /// tokens.\n    function transferToProxy(uint256 _value) public {\n        require(msg.sender == PROXY);\n\n        require(TOKEN.transfer(PROXY, _value));\n    }\n}\n\n\n/// The Proxy for existing tokens implementing a subset of ERC20 interface.\n///\n/// This contract creates a token Proxy contract to extend the original Token\n/// contract interface. The Proxy requires only transfer() and balanceOf()\n/// methods from ERC20 to be implemented in the original Token contract.\n///\n/// All migrated tokens are in Proxy\u0027s account on the Token side and distributed\n/// among Users on the Proxy side.\n///\n/// For an user to migrate some amount of ones tokens from Token to Proxy\n/// the procedure is as follows.\n///\n/// 1. Create an individual Gate for migration. The Gate address will be\n///    reported with the GateOpened event and accessible by getGateAddress().\n/// 2. Transfer tokens to be migrated to the Gate address.\n/// 3. Execute Proxy.transferFromGate() to finalize the migration.\n///\n/// In the step 3 the User\u0027s tokens are going to be moved from the Gate to\n/// the User\u0027s balance in the Proxy.\ncontract TokenProxy is StandardToken, BurnableToken {\n\n    ERC20Basic public TOKEN;\n\n    mapping(address =\u003e address) private gates;\n\n\n    event GateOpened(address indexed gate, address indexed user);\n\n    event Mint(address indexed to, uint256 amount);\n\n    constructor(ERC20Basic _token) public {\n        TOKEN = _token;\n    }\n\n    function getGateAddress(address _user) external view returns (address) {\n        return gates[_user];\n    }\n\n    /// Create a new migration Gate for the User.\n    function openGate() external {\n        address user = msg.sender;\n\n        // Do not allow creating more than one Gate per User.\n        require(gates[user] == address(0));\n\n        // Create new Gate.\n        address gate = address(new Gate(TOKEN, address(this)));\n\n        // Remember User - Gate relationship.\n        gates[user] = gate;\n\n        emit GateOpened(gate, user);\n    }\n\n    function transferFromGate() external {\n        address user = msg.sender;\n\n        address gate = gates[user];\n\n        // Make sure the User\u0027s Gate exists.\n        require(gate != address(0));\n\n        uint256 value = TOKEN.balanceOf(gate);\n\n        Gate(gate).transferToProxy(value);\n\n        // Handle the information about the amount of migrated tokens.\n        // This is a trusted information becase it comes from the Gate.\n        totalSupply_ += value;\n        balances[user] += value;\n\n        emit Mint(user, value);\n    }\n\n    function withdraw(uint256 _value) external {\n        withdrawTo(_value, msg.sender);\n    }\n\n    function withdrawTo(uint256 _value, address _destination) public {\n        require(_value \u003e 0 \u0026\u0026 _destination != address(0));\n        burn(_value);\n        TOKEN.transfer(_destination, _value);\n    }\n}\n"}}