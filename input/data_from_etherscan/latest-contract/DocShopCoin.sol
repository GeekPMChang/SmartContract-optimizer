{"DocShopCoin.sol":{"content":"pragma solidity ^0.4.21;\n\nimport \"./EIP20Interface.sol\";\n\n\ncontract DocShopCoin is EIP20Interface {\n\n    uint256 constant private MAX_UINT256 = 2**256 - 1;\n    mapping (address =\u003e uint256) public balances;\n    mapping (address =\u003e mapping (address =\u003e uint256)) public allowed;\n\n    string public name;\n    uint8 public decimals;\n    string public symbol;\n\n    constructor(\n        uint256 _initialAmount,\n        string _tokenName,\n        uint8 _decimalUnits,\n        string _tokenSymbol\n    ) public {\n        balances[msg.sender] = _initialAmount;\n        totalSupply = _initialAmount;\n        name = _tokenName;\n        decimals = _decimalUnits;\n        symbol = _tokenSymbol;\n    }\n\n    function transfer(address _to, uint256 _value) public returns (bool success) {\n        require(balances[msg.sender] \u003e= _value);\n        balances[msg.sender] -= _value;\n        balances[_to] += _value;\n        emit Transfer(msg.sender, _to, _value);\n        return true;\n    }\n\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\n        uint256 allowance = allowed[_from][msg.sender];\n        require(balances[_from] \u003e= _value \u0026\u0026 allowance \u003e= _value);\n        balances[_to] += _value;\n        balances[_from] -= _value;\n        if (allowance \u003c MAX_UINT256) {\n            allowed[_from][msg.sender] -= _value;\n        }\n        emit Transfer(_from, _to, _value);\n        return true;\n    }\n\n    function balanceOf(address _owner) public view returns (uint256 balance) {\n        return balances[_owner];\n    }\n\n    function approve(address _spender, uint256 _value) public returns (bool success) {\n        allowed[msg.sender][_spender] = _value;\n        emit Approval(msg.sender, _spender, _value);\n        return true;\n    }\n\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\n        return allowed[_owner][_spender];\n    }\n}"},"EIP20Interface.sol":{"content":"pragma solidity ^0.4.21;\n\n\ncontract EIP20Interface {\n\n    uint256 public totalSupply;\n\n    function balanceOf(address _owner) public view returns (uint256 balance);\n\n    function transfer(address _to, uint256 _value) public returns (bool success);\n\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\n\n    function approve(address _spender, uint256 _value) public returns (bool success);\n\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining);\n\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\n}"}}