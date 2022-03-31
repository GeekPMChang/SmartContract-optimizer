pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract EthDistributor is Ownable {
    
    address contractAddress = address(0xA1CBffC848b0bB1215076CE1b4a98B16a8dFc19e);
    address marketingAddress = address(0x7451C0197489bd35332a5EFb6D2f21F760f0abD8);
    
    event UpdatedContractAddress(address addy);
    event UpdatedMarketingAddress(address marketing);
    
    event EthSentToMarketing(uint256 indexed amount, uint256 timestamp);
    event EthSentToContract(uint256 indexed amount, uint256 timestamp);

    receive() external payable {
        distributeETH();
    }
    
    function updateContract(address addy) external onlyOwner {
        require(addy != address(0), "cannot set to 0 address");
        contractAddress = addy;
        emit UpdatedContractAddress(addy);
    }
    
    function updateMarketing(address marketing) external onlyOwner {
        require(marketing != address(0), "cannot set to 0 address");
        marketingAddress = marketing;
        emit UpdatedMarketingAddress(marketing);
    }
    
    function distributeETH() internal {
        uint256 balance = address(this).balance;
        uint256 contractAmount = balance * 2 / 5;
        uint256 marketingAmount = balance - contractAmount;
        (bool success,) = payable(marketingAddress).call{value: marketingAmount}("");
        if(success){ emit EthSentToMarketing(marketingAmount, block.timestamp);}
        (success,) = payable(contractAddress).call{value: contractAmount}("");
        if(success){ emit EthSentToContract(contractAmount, block.timestamp);}
    }
    
}