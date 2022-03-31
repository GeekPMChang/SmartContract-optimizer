{"ERC20Standard.sol":{"content":"pragma solidity ^0.5.7;\r\n\r\nlibrary SafeMath {\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003e 0);\r\n        uint256 c = a / b;\r\n\r\n    return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003c= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\ncontract ERC20Standard {\r\n    using SafeMath for uint256;\r\n    uint public totalSupply;\r\n\r\n    string public name;\r\n    uint8 public decimals;\r\n    string public symbol;\r\n    string public version;\r\n\r\n    mapping (address =\u003e uint256) balances;\r\n    mapping (address =\u003e mapping (address =\u003e uint)) allowed;\r\n\r\n    //Fix for short address attack against ERC20\r\n    modifier onlyPayloadSize(uint size) {\r\n        assert(msg.data.length == size + 4);\r\n        _;\r\n    }\r\n\r\n    function balanceOf(address _owner) public view returns (uint balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function transfer(address _recipient, uint _value) public onlyPayloadSize(2*32) {\r\n        require(balances[msg.sender] \u003e= _value \u0026\u0026 _value \u003e 0);\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_recipient] = balances[_recipient].add(_value);\r\n        emit Transfer(msg.sender, _recipient, _value);\r\n        }\r\n\r\n    function transferFrom(address _from, address _to, uint _value) public {\r\n        require(balances[_from] \u003e= _value \u0026\u0026 allowed[_from][msg.sender] \u003e= _value \u0026\u0026 _value \u003e 0);\r\n            balances[_to] = balances[_to].add(_value);\r\n            balances[_from] = balances[_from].sub(_value);\r\n            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n            emit Transfer(_from, _to, _value);\r\n        }\r\n\r\n    function  approve(address _spender, uint _value) public {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n    }\r\n\r\n    function allowance(address _spender, address _owner) public view returns (uint balance) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    //Event which is triggered to log all transfers to this contract\u0027s event log\r\n    event Transfer(\r\n        address indexed _from,\r\n        address indexed _to,\r\n        uint _value\r\n        );\r\n\r\n    //Event which is triggered whenever an owner approves a new allowance for a spender.\r\n    event Approval(\r\n        address indexed _owner,\r\n        address indexed _spender,\r\n        uint _value\r\n        );\r\n}\r\n"},"XTToken.sol":{"content":"pragma solidity ^0.5.7;\r\n\r\nimport \"./ERC20Standard.sol\";\r\n\r\ncontract XTToken is ERC20Standard {\r\n    constructor() public {\r\n        totalSupply = 1000000000000000000000000000;\r\n        name = \"ExtStock Token\";\r\n        decimals = 18;\r\n        symbol = \"XT\";\r\n        version = \"1.0\";\r\n        balances[msg.sender] = totalSupply;\r\n    }\r\n}\r\n"}}