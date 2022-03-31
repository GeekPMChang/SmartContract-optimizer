{"BasicToken.sol":{"content":"pragma solidity ^0.4.24;\n\n\nimport \"./ERC20Basic.sol\";\nimport \"./SafeMath.sol\";\n\n\n/**\n * @title Basic token\n * @dev Basic version of StandardToken, with no allowances.\n */\ncontract BasicToken is ERC20Basic {\n  using SafeMath for uint256;\n\n  mapping(address =\u003e uint256) internal balances;\n\n  uint256 internal totalSupply_;\n\n  /**\n  * @dev Total number of tokens in existence\n  */\n  function totalSupply() public view returns (uint256) {\n    return totalSupply_;\n  }\n\n  /**\n  * @dev Transfer token for a specified address\n  * @param _to The address to transfer to.\n  * @param _value The amount to be transferred.\n  */\n  function transfer(address _to, uint256 _value) public returns (bool) {\n    require(_value \u003c= balances[msg.sender]);\n    require(_to != address(0));\n\n    balances[msg.sender] = balances[msg.sender].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    emit Transfer(msg.sender, _to, _value);\n    return true;\n  }\n\n  /**\n  * @dev Gets the balance of the specified address.\n  * @param _owner The address to query the the balance of.\n  * @return An uint256 representing the amount owned by the passed address.\n  */\n  function balanceOf(address _owner) public view returns (uint256) {\n    return balances[_owner];\n  }\n\n}\n"},"BDPToken.sol":{"content":"pragma solidity 0.4.25;\n\nimport \"./StandardBurnableToken.sol\";\nimport \"./Whitelist.sol\";\nimport \"./SafeMath.sol\";\n\ncontract BDPToken is StandardBurnableToken, Whitelist {\n    using SafeMath for uint256;\n\n    event Mint(address indexed to, uint256 amount);\n\n    string public name = \"BidiPass\";\n    string public symbol = \"BDP\";\n    uint8 public decimals = 18;\n\n    mapping(address =\u003e uint256) public _burnAllowance;\n\n    /**\n     * @param _beneficiary Beneficiary of whole amount of tokens\n     * @param _cap Total amount of tokens to be minted\n     */\n    constructor(\n        address _beneficiary,\n        uint256 _cap\n    ) public {\n        require(_cap \u003e 0, \"MissingCap\");\n\n        totalSupply_ = totalSupply_.add(_cap);\n        balances[_beneficiary] = balances[_beneficiary].add(_cap);\n\n        emit Mint(_beneficiary, _cap);\n        emit Transfer(address(0), _beneficiary, _cap);\n    }\n\n    /**\n     * @dev Burns a specific amount of tokens.\n     * @param _value The amount of token to be burned.\n     */\n    function burn(uint256 _value) public {\n        uint256 allowance = burnAllowance(msg.sender);\n\n        require(_value \u003e 0, \"MissingValue\");\n        require(allowance \u003e= _value, \"NotEnoughAllowance\");\n\n        _setBurnAllowance(msg.sender, allowance.sub(_value));\n\n        _burn(msg.sender, _value);\n    }\n\n    /**\n     * @dev Get tokens amount allowed to be burned\n     * @param _who Tokens holder address\n     */\n    function burnAllowance(address _who)\n        public\n        view\n        returns (uint256)\n    {\n        return _burnAllowance[_who];\n    }\n\n    /** MANAGER FUNCTIONS */\n\n    /**\n     * @dev Set amount of tokens allowed to be burned by the holder\n     * @param _who Tokens holder address\n     * @param _amount Amount of tokens allowed to be burned\n     */\n    function setBurnAllowance(\n        address _who,\n        uint256 _amount\n    )\n        public\n        onlyIfWhitelisted(msg.sender)\n    {\n        require(_amount \u003c= balances[_who]);\n        _setBurnAllowance(_who, _amount);\n    }\n\n    /** INTERNAL FUNCTIONS */\n\n    /**\n     * @dev Set amount of tokens allowed to be burned by the holder\n     * @param _who Tokens holder address\n     * @param _amount Amount of tokens allowed to be burned\n     */\n    function _setBurnAllowance(\n        address _who,\n        uint256 _amount\n    ) internal {\n        _burnAllowance[_who] = _amount;\n    }\n}\n"},"BurnableToken.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./BasicToken.sol\";\n\n\n/**\n * @title Burnable Token\n * @dev Token that can be irreversibly burned (destroyed).\n */\ncontract BurnableToken is BasicToken {\n\n  event Burn(address indexed burner, uint256 value);\n\n  /**\n   * @dev Burns a specific amount of tokens.\n   * @param _value The amount of token to be burned.\n   */\n  function burn(uint256 _value) public {\n    _burn(msg.sender, _value);\n  }\n\n  function _burn(address _who, uint256 _value) internal {\n    require(_value \u003c= balances[_who]);\n    // no need to require value \u003c= totalSupply, since that would imply the\n    // sender\u0027s balance is greater than the totalSupply, which *should* be an assertion failure\n\n    balances[_who] = balances[_who].sub(_value);\n    totalSupply_ = totalSupply_.sub(_value);\n    emit Burn(_who, _value);\n    emit Transfer(_who, address(0), _value);\n  }\n}\n"},"ERC20.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./ERC20Basic.sol\";\n\n\n/**\n * @title ERC20 interface\n * @dev see https://github.com/ethereum/EIPs/issues/20\n */\ncontract ERC20 is ERC20Basic {\n  function allowance(address _owner, address _spender)\n    public view returns (uint256);\n\n  function transferFrom(address _from, address _to, uint256 _value)\n    public returns (bool);\n\n  function approve(address _spender, uint256 _value) public returns (bool);\n  event Approval(\n    address indexed owner,\n    address indexed spender,\n    uint256 value\n  );\n}\n"},"ERC20Basic.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/**\n * @title ERC20Basic\n * @dev Simpler version of ERC20 interface\n * See https://github.com/ethereum/EIPs/issues/179\n */\ncontract ERC20Basic {\n  function totalSupply() public view returns (uint256);\n  function balanceOf(address _who) public view returns (uint256);\n  function transfer(address _to, uint256 _value) public returns (bool);\n  event Transfer(address indexed from, address indexed to, uint256 value);\n}\n"},"Ownable.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/**\n * @title Ownable\n * @dev The Ownable contract has an owner address, and provides basic authorization control\n * functions, this simplifies the implementation of \"user permissions\".\n */\ncontract Ownable {\n  address public owner;\n\n\n  event OwnershipRenounced(address indexed previousOwner);\n  event OwnershipTransferred(\n    address indexed previousOwner,\n    address indexed newOwner\n  );\n\n\n  /**\n   * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n   * account.\n   */\n  constructor() public {\n    owner = msg.sender;\n  }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  /**\n   * @dev Allows the current owner to relinquish control of the contract.\n   * @notice Renouncing to ownership will leave the contract without an owner.\n   * It will not be possible to call the functions with the `onlyOwner`\n   * modifier anymore.\n   */\n  function renounceOwnership() public onlyOwner {\n    emit OwnershipRenounced(owner);\n    owner = address(0);\n  }\n\n  /**\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address _newOwner) public onlyOwner {\n    _transferOwnership(_newOwner);\n  }\n\n  /**\n   * @dev Transfers control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function _transferOwnership(address _newOwner) internal {\n    require(_newOwner != address(0));\n    emit OwnershipTransferred(owner, _newOwner);\n    owner = _newOwner;\n  }\n}\n"},"RBAC.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./Roles.sol\";\n\n\n/**\n * @title RBAC (Role-Based Access Control)\n * @author Matt Condon (@Shrugs)\n * @dev Stores and provides setters and getters for roles and addresses.\n * Supports unlimited numbers of roles and addresses.\n * See //contracts/mocks/RBACMock.sol for an example of usage.\n * This RBAC method uses strings to key roles. It may be beneficial\n * for you to write your own implementation of this interface using Enums or similar.\n */\ncontract RBAC {\n  using Roles for Roles.Role;\n\n  mapping (string =\u003e Roles.Role) private roles;\n\n  event RoleAdded(address indexed operator, string role);\n  event RoleRemoved(address indexed operator, string role);\n\n  /**\n   * @dev reverts if addr does not have role\n   * @param _operator address\n   * @param _role the name of the role\n   * // reverts\n   */\n  function checkRole(address _operator, string _role)\n    public\n    view\n  {\n    roles[_role].check(_operator);\n  }\n\n  /**\n   * @dev determine if addr has role\n   * @param _operator address\n   * @param _role the name of the role\n   * @return bool\n   */\n  function hasRole(address _operator, string _role)\n    public\n    view\n    returns (bool)\n  {\n    return roles[_role].has(_operator);\n  }\n\n  /**\n   * @dev add a role to an address\n   * @param _operator address\n   * @param _role the name of the role\n   */\n  function addRole(address _operator, string _role)\n    internal\n  {\n    roles[_role].add(_operator);\n    emit RoleAdded(_operator, _role);\n  }\n\n  /**\n   * @dev remove a role from an address\n   * @param _operator address\n   * @param _role the name of the role\n   */\n  function removeRole(address _operator, string _role)\n    internal\n  {\n    roles[_role].remove(_operator);\n    emit RoleRemoved(_operator, _role);\n  }\n\n  /**\n   * @dev modifier to scope access to a single role (uses msg.sender as addr)\n   * @param _role the name of the role\n   * // reverts\n   */\n  modifier onlyRole(string _role)\n  {\n    checkRole(msg.sender, _role);\n    _;\n  }\n\n  /**\n   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)\n   * @param _roles the names of the roles to scope access to\n   * // reverts\n   *\n   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this\n   *  see: https://github.com/ethereum/solidity/issues/2467\n   */\n  // modifier onlyRoles(string[] _roles) {\n  //     bool hasAnyRole = false;\n  //     for (uint8 i = 0; i \u003c _roles.length; i++) {\n  //         if (hasRole(msg.sender, _roles[i])) {\n  //             hasAnyRole = true;\n  //             break;\n  //         }\n  //     }\n\n  //     require(hasAnyRole);\n\n  //     _;\n  // }\n}\n"},"Roles.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/**\n * @title Roles\n * @author Francisco Giordano (@frangio)\n * @dev Library for managing addresses assigned to a Role.\n * See RBAC.sol for example usage.\n */\nlibrary Roles {\n  struct Role {\n    mapping (address =\u003e bool) bearer;\n  }\n\n  /**\n   * @dev give an address access to this role\n   */\n  function add(Role storage _role, address _addr)\n    internal\n  {\n    _role.bearer[_addr] = true;\n  }\n\n  /**\n   * @dev remove an address\u0027 access to this role\n   */\n  function remove(Role storage _role, address _addr)\n    internal\n  {\n    _role.bearer[_addr] = false;\n  }\n\n  /**\n   * @dev check if an address has this role\n   * // reverts\n   */\n  function check(Role storage _role, address _addr)\n    internal\n    view\n  {\n    require(has(_role, _addr));\n  }\n\n  /**\n   * @dev check if an address has this role\n   * @return bool\n   */\n  function has(Role storage _role, address _addr)\n    internal\n    view\n    returns (bool)\n  {\n    return _role.bearer[_addr];\n  }\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\nlibrary SafeMath {\n\n  /**\n  * @dev Multiplies two numbers, throws on overflow.\n  */\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\n    // benefit is lost if \u0027b\u0027 is also tested.\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n    if (_a == 0) {\n      return 0;\n    }\n\n    c = _a * _b;\n    assert(c / _a == _b);\n    return c;\n  }\n\n  /**\n  * @dev Integer division of two numbers, truncating the quotient.\n  */\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\n    // assert(_b \u003e 0); // Solidity automatically throws when dividing by 0\n    // uint256 c = _a / _b;\n    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn\u0027t hold\n    return _a / _b;\n  }\n\n  /**\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\n  */\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\n    assert(_b \u003c= _a);\n    return _a - _b;\n  }\n\n  /**\n  * @dev Adds two numbers, throws on overflow.\n  */\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\n    c = _a + _b;\n    assert(c \u003e= _a);\n    return c;\n  }\n}\n"},"StandardBurnableToken.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./BurnableToken.sol\";\nimport \"./StandardToken.sol\";\n\n\n/**\n * @title Standard Burnable Token\n * @dev Adds burnFrom method to ERC20 implementations\n */\ncontract StandardBurnableToken is BurnableToken, StandardToken {\n\n  /**\n   * @dev Burns a specific amount of tokens from the target address and decrements allowance\n   * @param _from address The address which you want to send tokens from\n   * @param _value uint256 The amount of token to be burned\n   */\n  function burnFrom(address _from, uint256 _value) public {\n    require(_value \u003c= allowed[_from][msg.sender]);\n    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,\n    // this function needs to emit an event with the updated approval.\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n    _burn(_from, _value);\n  }\n}\n"},"StandardToken.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./BasicToken.sol\";\nimport \"./ERC20.sol\";\n\n\n/**\n * @title Standard ERC20 token\n *\n * @dev Implementation of the basic standard token.\n * https://github.com/ethereum/EIPs/issues/20\n * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\n */\ncontract StandardToken is ERC20, BasicToken {\n\n  mapping (address =\u003e mapping (address =\u003e uint256)) internal allowed;\n\n\n  /**\n   * @dev Transfer tokens from one address to another\n   * @param _from address The address which you want to send tokens from\n   * @param _to address The address which you want to transfer to\n   * @param _value uint256 the amount of tokens to be transferred\n   */\n  function transferFrom(\n    address _from,\n    address _to,\n    uint256 _value\n  )\n    public\n    returns (bool)\n  {\n    require(_value \u003c= balances[_from]);\n    require(_value \u003c= allowed[_from][msg.sender]);\n    require(_to != address(0));\n\n    balances[_from] = balances[_from].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n    emit Transfer(_from, _to, _value);\n    return true;\n  }\n\n  /**\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   * @param _spender The address which will spend the funds.\n   * @param _value The amount of tokens to be spent.\n   */\n  function approve(address _spender, uint256 _value) public returns (bool) {\n    allowed[msg.sender][_spender] = _value;\n    emit Approval(msg.sender, _spender, _value);\n    return true;\n  }\n\n  /**\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\n   * @param _owner address The address which owns the funds.\n   * @param _spender address The address which will spend the funds.\n   * @return A uint256 specifying the amount of tokens still available for the spender.\n   */\n  function allowance(\n    address _owner,\n    address _spender\n   )\n    public\n    view\n    returns (uint256)\n  {\n    return allowed[_owner][_spender];\n  }\n\n  /**\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\n   * approve should be called when allowed[_spender] == 0. To increment\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _addedValue The amount of tokens to increase the allowance by.\n   */\n  function increaseApproval(\n    address _spender,\n    uint256 _addedValue\n  )\n    public\n    returns (bool)\n  {\n    allowed[msg.sender][_spender] = (\n      allowed[msg.sender][_spender].add(_addedValue));\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n  /**\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\n   * approve should be called when allowed[_spender] == 0. To decrement\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\n   */\n  function decreaseApproval(\n    address _spender,\n    uint256 _subtractedValue\n  )\n    public\n    returns (bool)\n  {\n    uint256 oldValue = allowed[msg.sender][_spender];\n    if (_subtractedValue \u003e= oldValue) {\n      allowed[msg.sender][_spender] = 0;\n    } else {\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\n    }\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n}\n"},"Whitelist.sol":{"content":"pragma solidity ^0.4.24;\n\n\nimport \"./Ownable.sol\";\nimport \"./RBAC.sol\";\n\n\n/**\n * @title Whitelist\n * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.\n * This simplifies the implementation of \"user permissions\".\n */\ncontract Whitelist is Ownable, RBAC {\n  string public constant ROLE_WHITELISTED = \"whitelist\";\n\n  /**\n   * @dev Throws if operator is not whitelisted.\n   * @param _operator address\n   */\n  modifier onlyIfWhitelisted(address _operator) {\n    checkRole(_operator, ROLE_WHITELISTED);\n    _;\n  }\n\n  /**\n   * @dev add an address to the whitelist\n   * @param _operator address\n   * @return true if the address was added to the whitelist, false if the address was already in the whitelist\n   */\n  function addAddressToWhitelist(address _operator)\n    public\n    onlyOwner\n  {\n    addRole(_operator, ROLE_WHITELISTED);\n  }\n\n  /**\n   * @dev getter to determine if address is in whitelist\n   */\n  function whitelist(address _operator)\n    public\n    view\n    returns (bool)\n  {\n    return hasRole(_operator, ROLE_WHITELISTED);\n  }\n\n  /**\n   * @dev add addresses to the whitelist\n   * @param _operators addresses\n   * @return true if at least one address was added to the whitelist,\n   * false if all addresses were already in the whitelist\n   */\n  function addAddressesToWhitelist(address[] _operators)\n    public\n    onlyOwner\n  {\n    for (uint256 i = 0; i \u003c _operators.length; i++) {\n      addAddressToWhitelist(_operators[i]);\n    }\n  }\n\n  /**\n   * @dev remove an address from the whitelist\n   * @param _operator address\n   * @return true if the address was removed from the whitelist,\n   * false if the address wasn\u0027t in the whitelist in the first place\n   */\n  function removeAddressFromWhitelist(address _operator)\n    public\n    onlyOwner\n  {\n    removeRole(_operator, ROLE_WHITELISTED);\n  }\n\n  /**\n   * @dev remove addresses from the whitelist\n   * @param _operators addresses\n   * @return true if at least one address was removed from the whitelist,\n   * false if all addresses weren\u0027t in the whitelist in the first place\n   */\n  function removeAddressesFromWhitelist(address[] _operators)\n    public\n    onlyOwner\n  {\n    for (uint256 i = 0; i \u003c _operators.length; i++) {\n      removeAddressFromWhitelist(_operators[i]);\n    }\n  }\n\n}\n"}}