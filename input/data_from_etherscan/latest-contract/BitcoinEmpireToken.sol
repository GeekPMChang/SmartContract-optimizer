{"BitcoinEmpireToken.sol":{"content":"pragma solidity ^0.4.11;\n\n//   _____ _____ _____ \n//  | __  |   __|     |\n//  | __ -|   __| | | |\n//  |_____|_____|_|_|_|\n\n//  The Bitcoin Empire contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20)\n//  It follows the optional extras intended for use by humans https://github.com/consensys/tokens\n\nimport \u0027./IERC20.sol\u0027;\nimport \u0027./SafeMath.sol\u0027;\n\ncontract BitcoinEmpireToken is IERC20 {\n\n  using SafeMath for uint256;\n  \n  string public constant symbol = \"BEM\";\n  string public constant name = \"Bitcoin Empire\";\n  uint8 public constant decimals = 18;\n  uint public _totalSupply = 15000000000000000000000000; // 15,000,000 BEM initial supply assigned to Bitcoin Empire for distribution\n  uint public _totalAvailable = 5000000000000000000000000; // 5,000,000 BEM available to create\n  uint256 public constant MAXTOKENS = 20000000000000000000000000; // 20,000,000 BEM maximum limit\n  uint256 public constant RATE = 8000; // 1 ETH = 8000 BEM\n\n  address public owner;\n  mapping(address =\u003e uint256) balances;\n  mapping(address =\u003e mapping(address =\u003e uint256)) allowed;\n\n  function () payable {\n    createTokens();\n  }\n\n  function BitcoinEmpireToken() {\n    balances[msg.sender] = _totalSupply;\n    owner = msg.sender;\n  }\n\n  function createTokens() payable returns (bool success) {\n    uint256 tokens = msg.value.mul(RATE);\n    require(\n      msg.value \u003e 0\n      \u0026\u0026 _totalAvailable \u003e= tokens\n    );\n    balances[msg.sender] = balances[msg.sender].add(tokens);\n    _totalSupply = _totalSupply.add(tokens);\n    _totalAvailable = _totalAvailable.sub(tokens);\n    owner.transfer(msg.value);\n    return true;\n  }\n\n  function totalSupply() constant returns (uint256 totalSupply) {\n    return _totalSupply;\n  }\n\n  function balanceOf(address _owner) constant returns (uint256 balance) {\n    return balances[_owner];\n  }\n\n  function transfer(address _to, uint256 _value) returns (bool success) {\n    require(\n      _value \u003e 0\n      \u0026\u0026 balances[msg.sender] \u003e= _value\n    );\n    balances[msg.sender] = balances[msg.sender].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    Transfer(msg.sender, _to, _value);\n    return true;\n  }\n\n  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {\n    require(\n      allowed[_from][msg.sender] \u003e= _value\n      \u0026\u0026 balances[_from] \u003e= _value\n      \u0026\u0026 _value \u003e 0\n    );\n    balances[_from] = balances[_from].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n    Transfer(_from, _to, _value);\n    return true;\n  }\n\n  function approve(address _spender, uint256 _value) returns (bool success) {\n    allowed[msg.sender][_spender] = _value;\n    Approval(msg.sender, _spender, _value);\n    return true;\n  }\n\n  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {\n    return allowed[_owner][_spender];\n  }\n\n}\n"},"IERC20.sol":{"content":"pragma solidity ^0.4.11;\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IERC20 {\r\n  function totalSupply() public view returns (uint256);\r\n\r\n  function balanceOf(address _who) public view returns (uint256);\r\n\r\n  function allowance(address _owner, address _spender)\r\n    public view returns (uint256);\r\n\r\n  function transfer(address _to, uint256 _value) public returns (bool);\r\n\r\n  function approve(address _spender, uint256 _value)\r\n    public returns (bool);\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value)\r\n    public returns (bool);\r\n\r\n  event Transfer(\r\n    address indexed from,\r\n    address indexed to,\r\n    uint256 value\r\n  );\r\n\r\n  event Approval(\r\n    address indexed owner,\r\n    address indexed spender,\r\n    uint256 value\r\n  );\r\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.4.18;\n\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\nlibrary SafeMath {\n\n  /**\n  * @dev Multiplies two numbers, throws on overflow.\n  */\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n    if (a == 0) {\n      return 0;\n    }\n    uint256 c = a * b;\n    assert(c / a == b);\n    return c;\n  }\n\n  /**\n  * @dev Integer division of two numbers, truncating the quotient.\n  */\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n    // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\n    uint256 c = a / b;\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n    return c;\n  }\n\n  /**\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\n  */\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n    assert(b \u003c= a);\n    return a - b;\n  }\n\n  /**\n  * @dev Adds two numbers, throws on overflow.\n  */\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\n    uint256 c = a + b;\n    assert(c \u003e= a);\n    return c;\n  }\n}\n"}}