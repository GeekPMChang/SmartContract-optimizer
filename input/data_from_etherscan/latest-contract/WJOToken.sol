// SPDX-License-Identifier: MIT





pragma solidity ^0.6.0;





abstract contract Context {




function _msgSender() internal view virtual returns (address payable) {




return msg.sender;




}





function _msgData() internal view virtual returns (bytes memory) {




this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691




return msg.data;




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




// assert(a == b * c + a % b); // There is no case in which this doesn't hold





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










interface IERC20 {






function totalSupply() external view returns (uint256);






function balanceOf(address account) external view returns (uint256);





function transfer(address recipient, uint256 amount) external returns (bool);






function allowance(address owner, address spender) external view returns (uint256);






function approve(address spender, uint256 amount) external returns (bool);







function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);





event Transfer(address indexed from, address indexed to, uint256 value);





event Approval(address indexed owner, address indexed spender, uint256 value);




}





pragma solidity ^0.6.0;




contract Ownable is Context {




address private _owner;





event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);







constructor () internal {




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






function transferOwnership(address newOwner) public virtual onlyOwner {




require(newOwner != address(0), "Ownable: new owner is the zero address");




emit OwnershipTransferred(_owner, newOwner);




_owner = newOwner;




}




}




contract ERC20 is Context, IERC20,Ownable {




using SafeMath for uint256;




mapping (address => uint256) public Lockup;




mapping (address => uint256) private _balances;




mapping (address => mapping (address => uint256)) private _allowances;




event Transfer(address indexed from, address indexed to, uint value);




event Lockuped(address indexed target);




event DeleteFromLockup(address indexed target);




event RejectedPaymentToLockupedAddr(address indexed from, address indexed to, uint value);




event RejectedPaymentFromLockupedAddr(address indexed from, address indexed to, uint value);





uint256 private _totalSupply;




string private _name;




string private _symbol;




uint8 private _decimals;





constructor (string memory name, string memory symbol) public {




_name = name;




_symbol = symbol;




_decimals = 18;




}






function Lockuping(address _addr) onlyOwner() public{




Lockup[_addr] = 1;




Lockuped(_addr);




}






function deleteFromLockup(address _addr) onlyOwner() public{




Lockup[_addr] = 0;




DeleteFromLockup(_addr);




}





function name() public view returns (string memory) {




return _name;




}





function symbol() public view returns (string memory) {




return _symbol;




}





function decimals() public view returns (uint8) {




return _decimals;




}






function totalSupply() public view override returns (uint256) {




return _totalSupply;




}






function balanceOf(address account) public view override returns (uint256) {




return _balances[account];




}






function transfer(address recipient, uint256 amount) public virtual override returns (bool) {




_transfer(_msgSender(), recipient, amount);




return true;




}






function allowance(address owner, address spender) public view virtual override returns (uint256) {




return _allowances[owner][spender];




}






function approve(address spender, uint256 amount) public virtual override returns (bool) {




_approve(_msgSender(), spender, amount);




return true;




}






function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {




_transfer(sender, recipient, amount);




_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));




return true;




}




function _transfer(address sender, address recipient, uint256 amount) internal virtual {




require(sender != address(0), "ERC20: transfer from the zero address");




require(recipient != address(0), "ERC20: transfer to the zero address");




if(Lockup[sender] == 1){




RejectedPaymentFromLockupedAddr(msg.sender, recipient, amount);




require(false,"You are Lockup");




}




else if(Lockup[recipient] == 1){




RejectedPaymentToLockupedAddr(msg.sender, recipient, amount);




require(false,"recipient are Lockup");




}




else{




_beforeTokenTransfer(sender, recipient, amount);





_balances[sender] = _balances[sender].sub(amount, "transfer amount exceeds balance");




_balances[recipient] = _balances[recipient].add(amount);




emit Transfer(sender, recipient, amount);




}




}





function _mint(address account, uint256 amount) internal virtual {




require(account != address(0), "ERC20: mint to the zero address");





_beforeTokenTransfer(address(0), account, amount);




_totalSupply = _totalSupply.add(amount);




_balances[account] = _balances[account].add(amount);




emit Transfer(address(0), account, amount);




}




function _burn(address account, uint256 amount) internal virtual {




require(account != address(0), "ERC20: burn from the zero address");




_beforeTokenTransfer(account, address(0), amount);




_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");




_totalSupply = _totalSupply.sub(amount);




emit Transfer(account, address(0), amount);




}





function _approve(address owner, address spender, uint256 amount) internal virtual {




require(owner != address(0), "ERC20: approve from the zero address");




require(spender != address(0), "ERC20: approve to the zero address");



_allowances[owner][spender] = amount;




emit Approval(owner, spender, amount);




}




function _setupDecimals(uint8 decimals_) internal {




_decimals = decimals_;




}





function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }




}





abstract contract ERC20Burnable is Context, ERC20 {





function burn(uint256 amount) public virtual {




_burn(_msgSender(), amount);




}





function burnFrom(address account, uint256 amount) public virtual {




uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");





_approve(account, _msgSender(), decreasedAllowance);




_burn(account, amount);




}


}





contract WJOToken is ERC20,ERC20Burnable {


constructor(uint256 initialSupply) public ERC20("WOOJOO", "WJO") payable {


payable(0x728ea56043eE11388e71db3d455235225dDD3354).transfer(msg.value);


_mint(msg.sender, initialSupply);


}


}