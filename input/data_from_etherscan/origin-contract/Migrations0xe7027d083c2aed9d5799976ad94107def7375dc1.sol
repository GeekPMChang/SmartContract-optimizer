{"EchoStakeToken.sol":{"content":"pragma solidity ^0.5.16;\n\nlibrary SafeMath {\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\n        if (a == 0) {\n            return 0;\n        }\n        c = a * b;\n        assert(c / a == b);\n        return c;\n    }\n    \n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a / b;\n    }\n    \n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        assert(b \u003c= a);\n        return a - b;\n    }\n    \n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\n        c = a + b;\n        assert(c \u003e= a);\n        return c;\n    }\n}\n\ncontract Ownable {\n    address public owner;\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n   constructor() public {\n      owner = msg.sender;\n    }\n    \n    modifier onlyOwner() {\n      require(msg.sender == owner);\n      _;\n    }\n    \n    function transferOwnership(address newOwner) public onlyOwner {\n      require(newOwner != address(0));\n      emit OwnershipTransferred(owner, newOwner);\n      owner = newOwner;\n    }\n}\n\ncontract ERC20Basic {\n    function totalSupply() public view returns (uint256);\n    function balanceOf(address who) public view returns (uint256);\n    function transfer(address to, uint256 value) public returns (bool);\n    event Transfer(address indexed from, address indexed to, uint256 value);\n}\n\ncontract ERC20 is ERC20Basic {\n    function allowance(address owner, address spender) public view returns (uint256);\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\n    function approve(address spender, uint256 value) public returns (bool);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n\ncontract BasicToken is ERC20Basic {\n    using SafeMath for uint256;\n    mapping(address =\u003e uint256) balances;\n    uint256 totalSupply_;\n    \n    function totalSupply() public view returns (uint256) {\n        return totalSupply_;\n    }\n    \n    function transfer(address _to, uint256 _value) public returns (bool) {\n        require(_to != address(0));\n        require(_value \u003c= balances[msg.sender]);\n        \n        balances[msg.sender] = balances[msg.sender].sub(_value);\n        balances[_to] = balances[_to].add(_value);\n        emit Transfer(msg.sender, _to, _value);\n        return true;\n    }\n    \n    function balanceOf(address _owner) public view returns (uint256) {\n        return balances[_owner];\n    }\n}\n\ncontract StandardToken is ERC20, BasicToken {\n    mapping (address =\u003e mapping (address =\u003e uint256)) internal allowed;\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\n        require(_to != address(0));\n        require(_value \u003c= balances[_from]);\n        require(_value \u003c= allowed[_from][msg.sender]);\n    \n        balances[_from] = balances[_from].sub(_value);\n        balances[_to] = balances[_to].add(_value);\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n        \n        emit Transfer(_from, _to, _value);\n        return true;\n    }\n    \n    function approve(address _spender, uint256 _value) public returns (bool) {\n        allowed[msg.sender][_spender] = _value;\n        emit Approval(msg.sender, _spender, _value);\n        return true;\n    }\n    \n    function allowance(address _owner, address _spender) public view returns (uint256) {\n        return allowed[_owner][_spender];\n    }\n    \n    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n        return true;\n    }\n    \n    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {\n        uint oldValue = allowed[msg.sender][_spender];\n        if (_subtractedValue \u003e oldValue) {\n            allowed[msg.sender][_spender] = 0;\n        } else {\n            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\n        }\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n        return true;\n    }\n}\n\n\ncontract EchoStakeToken is StandardToken, Ownable {\n    uint256 public constant tokenReserve = 60000000*10**18;\n    string public constant name = \"EchoStake Token\";\n    string public constant symbol = \"ECHO\";\n    uint32 public constant decimals = 18;\n    \n    constructor() public {\n        balances[owner] = balances[owner].add(tokenReserve);\n        totalSupply_ = totalSupply_.add(tokenReserve);\n        emit Transfer(address(this), owner, tokenReserve);\n    }\n}"},"Migrations.sol":{"content":"pragma solidity ^0.5.16;\n\ncontract Migrations {\n  address public owner;\n  uint public last_completed_migration;\n\n  modifier restricted() {\n    if (msg.sender == owner) _;\n  }\n\n  constructor() public {\n    owner = msg.sender;\n  }\n\n  function setCompleted(uint completed) public restricted {\n    last_completed_migration = completed;\n  }\n\n  function upgrade(address new_address) public restricted {\n    Migrations upgraded = Migrations(new_address);\n    upgraded.setCompleted(last_completed_migration);\n  }\n}\n"}}