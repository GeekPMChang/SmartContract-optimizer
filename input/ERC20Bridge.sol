{"ERC20.sol":{"content":"pragma solidity ^0.4.26;\n\ncontract ERC20Basic {\n  function totalSupply() public view returns (uint256);\n  function balanceOf(address _who) public view returns (uint256);\n  function transfer(address _to, uint256 _value) public returns (bool);\n  event Transfer(address indexed from, address indexed to, uint256 value);\n}\n\n\ncontract ERC20 is ERC20Basic {\n  function allowance(address _owner, address _spender)\n    public view returns (uint256);\n\n  function transferFrom(address _from, address _to, uint256 _value)\n    public returns (bool);\n\n  function approve(address _spender, uint256 _value) public returns (bool);\n  event Approval(\n    address indexed owner,\n    address indexed spender,\n    uint256 value\n  );\n}"},"ERC20Bridge.sol":{"content":"pragma solidity ^0.4.26;\r\n\r\nimport \"SafeMath.sol\";\r\nimport \"Ownable.sol\";\r\nimport \"ERC20.sol\";\r\n\r\n/**\r\n * @title ERC20Bridge\r\n * @dev Ethereum ERC20 Coin to Charg Network Bridge\r\n */\r\ncontract ERC20Bridge is Ownable {\r\n\r\n\tusing SafeMath for uint;\r\n\r\n    uint public validatorsCount = 0;\r\n    uint public validationsRequired = 2;\r\n\r\n    ERC20 private erc20Instance;  \r\n\r\n    struct Transaction {\r\n\t\taddress initiator;\r\n\t\tuint amount;\r\n\t\tuint validated;\r\n\t\tbool completed;\r\n\t}\r\n\r\n    event FundsReceived(address indexed initiator, uint amount);\r\n\r\n    event ValidatorAdded(address indexed validator);\r\n    event ValidatorRemoved(address indexed validator);\r\n\r\n    event Validated(bytes32 indexed txHash, address indexed validator, uint validatedCount, bool completed);\r\n\r\n    mapping (address =\u003e bool) public isValidator;\r\n\r\n    mapping (bytes32 =\u003e Transaction) public transactions;\r\n\tmapping (bytes32 =\u003e mapping (address =\u003e bool)) public validatedBy; // is validated by \r\n\r\n\tconstructor(address _addr) public {\r\n\t\terc20Instance = ERC20(_addr);\r\n    }\r\n\r\n    //fallback\r\n\tfunction() external payable {\r\n\t\trevert();\r\n\t}\r\n\r\n\tfunction setValidationsRequired( uint value ) onlyOwner public {\r\n        require (value \u003e 0);\r\n        validationsRequired = value;\r\n\t}\r\n\r\n\tfunction addValidator( address _validator ) onlyOwner public {\r\n        require (!isValidator[_validator]);\r\n        isValidator[_validator] = true;\r\n        validatorsCount = validatorsCount.add(1);\r\n        emit ValidatorAdded(_validator);\r\n\t}\r\n\r\n\tfunction removeValidator( address _validator ) onlyOwner public {\r\n        require (isValidator[_validator]);\r\n        isValidator[_validator] = false;\r\n        validatorsCount = validatorsCount.sub(1);\r\n        emit ValidatorRemoved(_validator);\r\n\t}\r\n\r\n\tfunction validate(bytes32 _txHash, address _initiator, uint _amount) public {\r\n        \r\n        require (isValidator[msg.sender]);\r\n        require ( !transactions[_txHash].completed );\r\n        require ( !validatedBy[_txHash][msg.sender] );\r\n\r\n        if ( transactions[_txHash].initiator == address(0) ) {\r\n            require ( _amount \u003e 0 \u0026\u0026 erc20Instance.balanceOf(address(this)) \u003e _amount );\r\n            transactions[_txHash].initiator = _initiator;\r\n            transactions[_txHash].amount = _amount;\r\n            transactions[_txHash].validated = 1;\r\n\r\n        } else {\r\n            require ( transactions[_txHash].amount \u003e 0 );\r\n            require ( erc20Instance.balanceOf(address(this)) \u003e transactions[_txHash].amount );\r\n            require ( _initiator == transactions[_txHash].initiator );\r\n            require ( transactions[_txHash].validated \u003c validationsRequired );\r\n            transactions[_txHash].validated = transactions[_txHash].validated.add(1);\r\n        }\r\n        validatedBy[_txHash][msg.sender] = true;\r\n        if (transactions[_txHash].validated \u003e= validationsRequired) {\r\n    \t\t//_initiator.transfer(_amount);\r\n            erc20Instance.transfer(_initiator, _amount);\r\n            transactions[_txHash].completed = true;\r\n        }\r\n        emit Validated(_txHash, msg.sender, transactions[_txHash].validated, transactions[_txHash].completed);\r\n\t}\r\n}"},"Ownable.sol":{"content":"pragma solidity ^0.4.26;\n\n/**\n * @title Ownable\n * @dev The Ownable contract has an owner address, and provides basic authorization control\n * functions, this simplifies the implementation of \"user permissions\".\n */\ncontract Ownable {\n\n    address public owner;\n\n    /**\n     * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n     * account.\n     */\n    constructor() public {\n        owner = msg.sender;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(msg.sender == owner);\n        _;\n    }\n\n    /**\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\n     * @param newOwner The address to transfer ownership to.\n     */\n    function transferOwnership(address newOwner) onlyOwner public {\n        require(newOwner != address(0));\n        owner = newOwner;\n    }\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.4.26;\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\n\nlibrary SafeMath {\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a * b;\n        assert(a == 0 || c / a == b);\n        return c;\n    }\n\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n        return c;\n    }\n\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        assert(b \u003c= a);\n        return a - b;\n    }\n\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        assert(c \u003e= a);\n        return c;\n    }\n}"}}