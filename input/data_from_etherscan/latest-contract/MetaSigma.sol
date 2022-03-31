{"MetaSigma.sol":{"content":"//SPDX-License-Identifier: \u003cSPDX License\u003e\r\n// Compatible with version\r\n// of compiler upto 0.6.6\r\npragma solidity ^0.6.6;\r\n\r\n// Creating a Contract\r\ncontract MetaSigma\r\n{\r\n\r\n// Table to map addresses\r\n// to their balance\r\nmapping(address =\u003e uint256) balances;\r\n\r\n// Mapping owner address to\r\n// those who are allowed to\r\n// use the contract\r\nmapping(address =\u003e mapping (\r\n\t\taddress =\u003e uint256)) allowed;\r\n\r\n// totalSupply\r\nuint256 _totalSupply = 122800000;\r\n\r\n// owner address\r\naddress public owner;\r\n\r\n// Triggered whenever\r\n// approve(address _spender, uint256 _value)\r\n// is called.\r\nevent Approval(address indexed _owner,\r\n\t\t\t\taddress indexed _spender,\r\n\t\t\t\tuint256 _value);\r\n\r\n// Event triggered when\r\n// tokens are transferred.\r\nevent Transfer(address indexed _from,\r\n\t\t\taddress indexed _to,\r\n\t\t\tuint256 _value);\r\n\r\n// totalSupply function\r\nfunction totalSupply()\r\n\t\tpublic view returns (\r\n\t\tuint256 theTotalSupply)\r\n{\r\ntheTotalSupply = _totalSupply;\r\nreturn theTotalSupply;\r\n}\r\n\r\n// balanceOf function\r\nfunction balanceOf(address _owner)\r\n\t\tpublic view returns (\r\n\t\tuint256 balance)\r\n{\r\nreturn balances[_owner];\r\n}\r\n\r\n// function approve\r\nfunction approve(address _spender,\r\n\t\t\t\tuint256 _amount)\r\n\t\t\t\tpublic returns (bool success)\r\n{\r\n\t// If the address is allowed\r\n\t// to spend from this contract\r\nallowed[msg.sender][_spender] = _amount;\r\n\t\r\n// Fire the event \"Approval\"\r\n// to execute any logic that\r\n// was listening to it\r\nemit Approval(msg.sender,\r\n\t\t\t\t_spender, _amount);\r\nreturn true;\r\n}\r\n\r\n// transfer function\r\nfunction transfer(address _to,\r\n\t\t\t\tuint256 _amount)\r\n\t\t\t\tpublic returns (bool success)\r\n{\r\n\t// transfers the value if\r\n\t// balance of sender is\r\n\t// greater than the amount\r\n\tif (balances[msg.sender] \u003e= _amount)\r\n\t{\r\n\t\tbalances[msg.sender] -= _amount;\r\n\t\tbalances[_to] += _amount;\r\n\t\t\r\n\t\t// Fire a transfer event for\r\n\t\t// any logic that is listening\r\n\t\temit Transfer(msg.sender,\r\n\t\t\t\t\t_to, _amount);\r\n\t\t\treturn true;\r\n\t}\r\n\telse\r\n\t{\r\n\t\treturn false;\r\n\t}\r\n}\r\n\r\n\r\n/* The transferFrom method is used for\r\na withdraw workflow, allowing\r\ncontracts to send tokens on\r\nyour behalf, for example to\r\n\"deposit\" to a contract address\r\nand/or to charge fees in sub-currencies;*/\r\nfunction transferFrom(address _from,\r\n\t\t\t\t\taddress _to,\r\n\t\t\t\t\tuint256 _amount)\r\n\t\t\t\t\tpublic returns (bool success)\r\n{\r\nif (balances[_from] \u003e= _amount \u0026\u0026\r\n\tallowed[_from][msg.sender] \u003e=\r\n\t_amount \u0026\u0026 _amount \u003e 0 \u0026\u0026\r\n\tbalances[_to] + _amount \u003e balances[_to])\r\n{\r\n\t\tbalances[_from] -= _amount;\r\n\t\tbalances[_to] += _amount;\r\n\t\t\r\n\t\t// Fire a Transfer event for\r\n\t\t// any logic that is listening\r\n\t\temit Transfer(_from, _to, _amount);\r\n\treturn true;\r\n\r\n}\r\nelse\r\n{\r\n\treturn false;\r\n}\r\n}\r\n\r\n// Check if address is allowed\r\n// to spend on the owner\u0027s behalf\r\nfunction allowance(address _owner,\r\n\t\t\t\taddress _spender)\r\n\t\t\t\tpublic view returns (uint256 remaining)\r\n{\r\nreturn allowed[_owner][_spender];\r\n}\r\n}\r\n"},"MTASigma.sol":{"content":"//SPDX-License-Identifier: UNLICENSED\r\npragma solidity ^0.6.6;\r\n\r\ncontract MTASBankContract {\r\n    \r\n    struct client_account{\r\n        int client_id;\r\n        address client_address;\r\n        uint client_balance_in_ether;\r\n    }\r\n    \r\n    client_account[] clients;\r\n    \r\n    int clientCounter; \r\n    address payable manager;\r\n    mapping(address =\u003e uint) public interestDate;\r\n    \r\n    modifier onlyManager() {\r\n        require(msg.sender == manager, \"Only manager can call this!\");\r\n        _;\r\n    }\r\n    \r\n    modifier onlyClients() {\r\n        bool isclient = false;\r\n        for(uint i=0;i\u003cclients.length;i++){\r\n            if(clients[i].client_address == msg.sender){\r\n                isclient = true;\r\n                break;\r\n            }\r\n        }\r\n        require(isclient, \"Only clients can call this!\");\r\n        _;\r\n    }\r\n    \r\n    constructor() public{\r\n        clientCounter = 0;\r\n    }\r\n    \r\n    receive() external payable { }\r\n    \r\n    function setManager(address managerAddress) public returns(string memory){\r\n        manager = payable(managerAddress);\r\n        return \"\";\r\n    }\r\n   \r\n    function joinAsClient() public payable returns(string memory){\r\n        interestDate[msg.sender] = now;\r\n        clients.push(client_account(clientCounter++, msg.sender, address(msg.sender).balance));\r\n        return \"\";\r\n    }\r\n    \r\n    function deposit() public payable onlyClients{\r\n        payable(address(this)).transfer(msg.value);\r\n    }\r\n    \r\n    function withdraw(uint amount) public payable onlyClients{\r\n        msg.sender.transfer(amount * 1 ether);\r\n    }\r\n    \r\n    function sendInterest() public payable onlyManager{\r\n        for(uint i=0;i\u003cclients.length;i++){\r\n            address initialAddress = clients[i].client_address;\r\n            uint lastInterestDate = interestDate[initialAddress];\r\n            if(now \u003c lastInterestDate + 10 seconds){\r\n                revert(\"It\u0027s just been less than 10 seconds!\");\r\n            }\r\n            payable(initialAddress).transfer(1 ether);\r\n            interestDate[initialAddress] = now;\r\n        }\r\n    }\r\n    \r\n    function getContractBalance() public view returns(uint){\r\n        return address(this).balance;\r\n    }\r\n}"}}