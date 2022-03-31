{"SafeMath.sol":{"content":"pragma solidity ^0.5.2;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003e 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003c= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n"},"TimeAllyPET.sol":{"content":"pragma solidity 0.5.16;\r\n\r\nimport \u0027./SafeMath.sol\u0027;\r\n\r\n\r\n/// @title Fund Bucket of TimeAlly Personal EraSwap Teller\r\n/// @author The EraSwap Team\r\n/// @notice The returns for PET Smart Contract are transparently stored in advance in this contract\r\ncontract FundsBucketPET {\r\n\r\n  /// @notice address of the maintainer\r\n  address public deployer;\r\n\r\n  /// @notice address of Era Swap ERC20 Smart Contract\r\n  ERC20 public token;\r\n\r\n  /// @notice address of PET Smart Contract\r\n  address public petContract;\r\n\r\n  /// @notice event schema for monitoring funds added by donors\r\n  event FundsDeposited(\r\n    address _depositer,\r\n    uint256 _depositAmount\r\n  );\r\n\r\n  /// @notice event schema for monitoring unallocated fund withdrawn by deployer\r\n  event FundsWithdrawn(\r\n    address _withdrawer,\r\n    uint256 _withdrawAmount\r\n  );\r\n\r\n  /// @notice restricting access to some functionalities to deployer\r\n  modifier onlyDeployer() {\r\n    require(msg.sender == deployer, \u0027only deployer can call\u0027);\r\n    _;\r\n  }\r\n\r\n  /// @notice this function is used to deploy FundsBucket Smart Contract\r\n  ///   the same time while deploying PET Smart Contract\r\n  /// @dev this smart contract is deployed by PET Smart Contract while being set up\r\n  /// @param _token: is EraSwap ERC20 Smart Contract Address\r\n  /// @param _deployer: is address of the deployer of PET Smart Contract\r\n  constructor(ERC20 _token, address _deployer) public {\r\n    token = _token;\r\n    deployer = _deployer;\r\n    petContract = msg.sender;\r\n  }\r\n\r\n  /// @notice this function is used by well wishers to add funds to the fund bucket of PET\r\n  /// @dev ERC20 approve is required to be done for this contract earlier\r\n  /// @param _depositAmount: amount in exaES to deposit\r\n  function addFunds(uint256 _depositAmount) public {\r\n    token.transferFrom(msg.sender, address(this), _depositAmount);\r\n\r\n    /// @dev approving the PET Smart Contract in advance\r\n    token.approve(petContract, _depositAmount);\r\n\r\n    emit FundsDeposited(msg.sender, _depositAmount);\r\n  }\r\n\r\n  /// @notice this function makes it possible for deployer to withdraw unallocated ES\r\n  function withdrawFunds(bool _withdrawEverything, uint256 _withdrawlAmount) public onlyDeployer {\r\n    if(_withdrawEverything) {\r\n      _withdrawlAmount = token.balanceOf(address(this));\r\n    }\r\n\r\n    token.transfer(msg.sender, _withdrawlAmount);\r\n\r\n    emit FundsWithdrawn(msg.sender, _withdrawlAmount);\r\n  }\r\n}\r\n\r\n\r\n/// @title TimeAlly Personal EraSwap Teller Smart Contract\r\n/// @author The EraSwap Team\r\n/// @notice Stakes EraSwap tokens with staker\r\ncontract TimeAllyPET {\r\n  using SafeMath for uint256;\r\n\r\n  /// @notice data structure of a PET Plan\r\n  struct PETPlan {\r\n    bool isPlanActive;\r\n    uint256 minimumMonthlyCommitmentAmount;\r\n    uint256 monthlyBenefitFactorPerThousand;\r\n  }\r\n\r\n  /// @notice data structure of a PET Plan\r\n  struct PET {\r\n    uint256 planId;\r\n    uint256 monthlyCommitmentAmount;\r\n    uint256 initTimestamp;\r\n    uint256 lastAnnuityWithdrawlMonthId;\r\n    uint256 appointeeVotes;\r\n    uint256 numberOfAppointees;\r\n    mapping(uint256 =\u003e uint256) monthlyDepositAmount;\r\n    mapping(uint256 =\u003e bool) isPowerBoosterWithdrawn;\r\n    mapping(address =\u003e bool) nominees;\r\n    mapping(address =\u003e bool) appointees;\r\n  }\r\n\r\n  /// @notice address storage of the deployer\r\n  address public deployer;\r\n\r\n  /// @notice address storage of fundsBucket from which tokens to be pulled for giving benefits\r\n  address public fundsBucket;\r\n\r\n  /// @notice address storage of Era Swap Token ERC20 Smart Contract\r\n  ERC20 public token;\r\n\r\n  /// @dev selected for taking care of leap years such that 1 Year = 365.242 days holds\r\n  uint256 constant EARTH_SECONDS_IN_MONTH = 2629744;\r\n\r\n  /// @notice storage for multiple PET plans\r\n  PETPlan[] public petPlans;\r\n\r\n  /// @notice storage for PETs deployed by stakers\r\n  mapping(address =\u003e PET[]) public pets;\r\n\r\n  /// @notice storage for prepaid Era Swaps available for any wallet address\r\n  mapping(address =\u003e uint256) public prepaidES;\r\n\r\n  /// @notice event schema for monitoring new pet plans\r\n  event NewPETPlan (\r\n    uint256 _minimumMonthlyCommitmentAmount,\r\n    uint256 _monthlyBenefitFactorPerThousand,\r\n    uint256 _petPlanId\r\n  );\r\n\r\n  /// @notice event schema for monitoring new pets by stakers\r\n  event NewPET (\r\n    address indexed _staker,\r\n    uint256 _petId,\r\n    uint256 _monthlyCommitmentAmount\r\n  );\r\n\r\n  /// @notice event schema for monitoring deposits made by stakers to their pets\r\n  event NewDeposit (\r\n    address indexed _staker,\r\n    uint256 indexed _petId,\r\n    uint256 _monthId,\r\n    uint256 _depositAmount,\r\n    // uint256 _benefitAllocated,\r\n    address _depositedBy,\r\n    bool _usingPrepaidES\r\n  );\r\n\r\n  /// @notice event schema for monitoring pet annuity withdrawn by stakers\r\n  event AnnuityWithdrawl (\r\n    address indexed _staker,\r\n    uint256 indexed _petId,\r\n    uint256 _fromMonthId,\r\n    uint256 _toMonthId,\r\n    uint256 _withdrawlAmount,\r\n    address _withdrawnBy\r\n  );\r\n\r\n  /// @notice event schema for monitoring power booster withdrawn by stakers\r\n  event PowerBoosterWithdrawl (\r\n    address indexed _staker,\r\n    uint256 indexed _petId,\r\n    uint256 _powerBoosterId,\r\n    uint256 _withdrawlAmount,\r\n    address _withdrawnBy\r\n  );\r\n\r\n  /// @notice event schema for monitoring penalised power booster burning\r\n  event BoosterBurn (\r\n    address _staker,\r\n    uint256 _petId,\r\n    uint256 _burningAmount\r\n  );\r\n\r\n  /// @notice event schema for monitoring power booster withdrawn by stakers\r\n  event NomineeUpdated (\r\n    address indexed _staker,\r\n    uint256 indexed _petId,\r\n    address indexed _nomineeAddress,\r\n    bool _nomineeStatus\r\n  );\r\n\r\n  /// @notice event schema for monitoring power booster withdrawls by stakers\r\n  event AppointeeUpdated (\r\n    address indexed _staker,\r\n    uint256 indexed _petId,\r\n    address indexed _appointeeAddress,\r\n    bool _appointeeStatus\r\n  );\r\n\r\n  /// @notice event schema for monitoring power booster withdrawls by stakers\r\n  event AppointeeVoted (\r\n    address indexed _staker,\r\n    uint256 indexed _petId,\r\n    address indexed _appointeeAddress\r\n  );\r\n\r\n  /// @notice restricting access to some functionalities to deployer\r\n  modifier onlyDeployer() {\r\n    require(msg.sender == deployer, \u0027only deployer can call\u0027);\r\n    _;\r\n  }\r\n\r\n  /// @notice restricting access of staker\u0027s PET to them and their pet nominees\r\n  modifier meOrNominee(address _stakerAddress, uint256 _petId) {\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n\r\n    /// @notice if transacter is not staker, then transacter should be nominee\r\n    if(msg.sender != _stakerAddress) {\r\n      require(_pet.nominees[msg.sender], \u0027nomination should be there\u0027);\r\n    }\r\n    _;\r\n  }\r\n\r\n  /// @notice sets up TimeAllyPET contract when deployed and also deploys FundsBucket\r\n  /// @param _token: is EraSwap ERC20 Smart Contract Address\r\n  constructor(ERC20 _token) public {\r\n    deployer = msg.sender;\r\n    token = _token;\r\n    fundsBucket = address(new FundsBucketPET(_token, msg.sender));\r\n  }\r\n\r\n  /// @notice this function is used to add ES as prepaid for PET\r\n  /// @dev ERC20 approve needs to be done\r\n  /// @param _amount: ES to deposit\r\n  function addToPrepaid(uint256 _amount) public {\r\n    /// @notice transfering the tokens from user\r\n    token.transferFrom(msg.sender, address(this), _amount);\r\n\r\n    /// @notice then adding tokens to prepaidES\r\n    prepaidES[msg.sender] = prepaidES[msg.sender].add(_amount);\r\n  }\r\n\r\n  /// @notice this function is used to send ES as prepaid for PET\r\n  /// @dev some ES already in prepaid required\r\n  /// @param _addresses: address array to send prepaid ES for PET\r\n  /// @param _amounts: prepaid ES for PET amounts to send to corresponding addresses\r\n  function sendPrepaidESDifferent(\r\n    address[] memory _addresses,\r\n    uint256[] memory _amounts\r\n  ) public {\r\n    for(uint256 i = 0; i \u003c _addresses.length; i++) {\r\n      /// @notice subtracting amount from sender prepaidES\r\n      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_amounts[i]);\r\n\r\n      /// @notice then incrementing the amount into receiver\u0027s prepaidES\r\n      prepaidES[_addresses[i]] = prepaidES[_addresses[i]].add(_amounts[i]);\r\n    }\r\n  }\r\n\r\n  /// @notice this function is used by anyone to create a new PET\r\n  /// @param _planId: id of PET in staker portfolio\r\n  /// @param _monthlyCommitmentAmount: PET monthly commitment amount in exaES\r\n  function newPET(\r\n    uint256 _planId,\r\n    uint256 _monthlyCommitmentAmount\r\n  ) public {\r\n    /// @notice enforcing that the plan should be active\r\n    require(\r\n      petPlans[_planId].isPlanActive\r\n      , \u0027PET plan is not active\u0027\r\n    );\r\n\r\n    /// @notice enforcing that monthly commitment by the staker should be more than\r\n    ///   minimum monthly commitment in the selected plan\r\n    require(\r\n      _monthlyCommitmentAmount \u003e= petPlans[_planId].minimumMonthlyCommitmentAmount\r\n      , \u0027low monthlyCommitmentAmount\u0027\r\n    );\r\n\r\n    /// @notice adding the PET to staker\u0027s pets storage\r\n    pets[msg.sender].push(PET({\r\n      planId: _planId,\r\n      monthlyCommitmentAmount: _monthlyCommitmentAmount,\r\n      initTimestamp: now,\r\n      lastAnnuityWithdrawlMonthId: 0,\r\n      appointeeVotes: 0,\r\n      numberOfAppointees: 0\r\n    }));\r\n\r\n    /// @notice emiting an event\r\n    emit NewPET(\r\n      msg.sender,\r\n      pets[msg.sender].length - 1,\r\n      _monthlyCommitmentAmount\r\n    );\r\n  }\r\n\r\n  /// @notice this function is used by deployer to create plans for new PETs\r\n  /// @param _minimumMonthlyCommitmentAmount: minimum PET monthly amount in exaES\r\n  /// @param _monthlyBenefitFactorPerThousand: this is per 1000; i.e 200 for 20%\r\n  function createPETPlan(\r\n    uint256 _minimumMonthlyCommitmentAmount,\r\n    uint256 _monthlyBenefitFactorPerThousand\r\n  ) public onlyDeployer {\r\n\r\n    /// @notice adding the petPlan to storage\r\n    petPlans.push(PETPlan({\r\n      isPlanActive: true,\r\n      minimumMonthlyCommitmentAmount: _minimumMonthlyCommitmentAmount,\r\n      monthlyBenefitFactorPerThousand: _monthlyBenefitFactorPerThousand\r\n    }));\r\n\r\n    /// @notice emitting an event\r\n    emit NewPETPlan(\r\n      _minimumMonthlyCommitmentAmount,\r\n      _monthlyBenefitFactorPerThousand,\r\n      petPlans.length - 1\r\n    );\r\n  }\r\n\r\n  /// @notice this function is used by deployer to disable or re-enable a pet plan\r\n  /// @dev pets already initiated by a plan will continue only new will be restricted\r\n  /// @param _planId: select a plan to make it inactive\r\n  /// @param _newStatus: true or false.\r\n  function updatePlanStatus(uint256 _planId, bool _newStatus) public onlyDeployer {\r\n    petPlans[_planId].isPlanActive = _newStatus;\r\n  }\r\n\r\n  /// @notice this function is used to update nominee status of a wallet address in PET\r\n  /// @param _petId: id of PET in staker portfolio.\r\n  /// @param _nomineeAddress: eth wallet address of nominee.\r\n  /// @param _newNomineeStatus: true or false, whether this should be a nominee or not.\r\n  function toogleNominee(\r\n    uint256 _petId,\r\n    address _nomineeAddress,\r\n    bool _newNomineeStatus\r\n  ) public {\r\n    /// @notice updating nominee status\r\n    pets[msg.sender][_petId].nominees[_nomineeAddress] = _newNomineeStatus;\r\n\r\n    /// @notice emiting event for UI and other applications\r\n    emit NomineeUpdated(msg.sender, _petId, _nomineeAddress, _newNomineeStatus);\r\n  }\r\n\r\n  /// @notice this function is used to update appointee status of a wallet address in PET\r\n  /// @param _petId: id of PET in staker portfolio.\r\n  /// @param _appointeeAddress: eth wallet address of appointee.\r\n  /// @param _newAppointeeStatus: true or false, should this have appointee rights or not.\r\n  function toogleAppointee(\r\n    uint256 _petId,\r\n    address _appointeeAddress,\r\n    bool _newAppointeeStatus\r\n  ) public {\r\n    PET storage _pet = pets[msg.sender][_petId];\r\n\r\n    /// @notice if not an appointee already and _newAppointeeStatus is true, adding appointee\r\n    if(!_pet.appointees[_appointeeAddress] \u0026\u0026 _newAppointeeStatus) {\r\n      _pet.numberOfAppointees = _pet.numberOfAppointees.add(1);\r\n      _pet.appointees[_appointeeAddress] = true;\r\n    }\r\n\r\n    /// @notice if already an appointee and _newAppointeeStatus is false, removing appointee\r\n    else if(_pet.appointees[_appointeeAddress] \u0026\u0026 !_newAppointeeStatus) {\r\n      _pet.appointees[_appointeeAddress] = false;\r\n      _pet.numberOfAppointees = _pet.numberOfAppointees.sub(1);\r\n    }\r\n\r\n    emit AppointeeUpdated(msg.sender, _petId, _appointeeAddress, _newAppointeeStatus);\r\n  }\r\n\r\n  /// @notice this function is used by appointee to vote that nominees can withdraw early\r\n  /// @dev need to be appointee, set by staker themselves\r\n  /// @param _stakerAddress: address of initiater of this PET.\r\n  /// @param _petId: id of PET in staker portfolio.\r\n  function appointeeVote(\r\n    address _stakerAddress,\r\n    uint256 _petId\r\n  ) public {\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n\r\n    /// @notice checking if appointee has rights to cast a vote\r\n    require(_pet.appointees[msg.sender]\r\n      , \u0027should be appointee to cast vote\u0027\r\n    );\r\n\r\n    /// @notice removing appointee\u0027s rights to vote again\r\n    _pet.appointees[msg.sender] = false;\r\n\r\n    /// @notice adding a vote to PET\r\n    _pet.appointeeVotes = _pet.appointeeVotes.add(1);\r\n\r\n    /// @notice emit that appointee has voted\r\n    emit AppointeeVoted(_stakerAddress, _petId, msg.sender);\r\n  }\r\n\r\n  /// @notice this function is used by stakers to make deposits to their PETs\r\n  /// @dev ERC20 approve is required to be done for this contract earlier if prepaidES\r\n  ///   is not selected, enough funds must be there in the funds bucket contract\r\n  ///   and also deposit can be done by nominee\r\n  /// @param _stakerAddress: address of staker who has a PET\r\n  /// @param _petId: id of PET in staker address portfolio\r\n  /// @param _depositAmount: amount to deposit\r\n  /// @param _usePrepaidES: should prepaidES be used\r\n  function makeDeposit(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    uint256 _depositAmount,\r\n    bool _usePrepaidES\r\n  ) public meOrNominee(_stakerAddress, _petId) {\r\n    /// @notice check if non zero deposit\r\n    require(_depositAmount \u003e 0, \u0027deposit amount should be non zero\u0027);\r\n\r\n    /// @notice get the storage reference of staker\u0027s PET\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n\r\n    /// @notice calculate the deposit month based on time\r\n    uint256 _depositMonth = getDepositMonth(_stakerAddress, _petId);\r\n\r\n    /// @notice enforce no deposits after 12 months\r\n    require(_depositMonth \u003c= 12, \u0027cannot deposit after accumulation period\u0027);\r\n\r\n    if(_usePrepaidES) {\r\n      /// @notice subtracting prepaidES from staker\r\n      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_depositAmount);\r\n    } else {\r\n      /// @notice transfering staker tokens to PET contract\r\n      token.transferFrom(msg.sender, address(this), _depositAmount);\r\n    }\r\n\r\n    /// @notice calculate new deposit amount for the storage\r\n    uint256 _updatedDepositAmount = _pet.monthlyDepositAmount[_depositMonth].add(_depositAmount);\r\n\r\n    /// @notice carryforward small deposits in previous months\r\n    uint256 _previousMonth = _depositMonth - 1;\r\n    while(_previousMonth \u003e 0) {\r\n      if(0 \u003c _pet.monthlyDepositAmount[_previousMonth]\r\n      \u0026\u0026 _pet.monthlyDepositAmount[_previousMonth] \u003c _pet.monthlyCommitmentAmount.div(2)) {\r\n        _updatedDepositAmount = _updatedDepositAmount.add(\r\n          _pet.monthlyDepositAmount[_previousMonth]\r\n        );\r\n        _pet.monthlyDepositAmount[_previousMonth] = 0;\r\n      }\r\n      _previousMonth -= 1;\r\n    }\r\n\r\n    /// @notice calculate old allocation, to adjust it in new allocation\r\n    uint256 _oldBenefitAllocation = _getBenefitAllocationByDepositAmount(\r\n      _pet,\r\n      0,\r\n      _depositMonth\r\n    );\r\n    uint256 _extraBenefitAllocation = _getBenefitAllocationByDepositAmount(\r\n      _pet,\r\n      _updatedDepositAmount,\r\n      _depositMonth\r\n    ).sub(_oldBenefitAllocation);\r\n\r\n    /// @notice pull funds from funds bucket\r\n    token.transferFrom(fundsBucket, address(this), _extraBenefitAllocation);\r\n\r\n    /// @notice recording the deposit by updating the value\r\n    _pet.monthlyDepositAmount[_depositMonth] = _updatedDepositAmount;\r\n\r\n    /// @notice emitting an event\r\n    emit NewDeposit(\r\n      _stakerAddress,\r\n      _petId,\r\n      _depositMonth,\r\n      _depositAmount,\r\n      // _extraBenefitAllocation,\r\n      msg.sender,\r\n      _usePrepaidES\r\n    );\r\n  }\r\n\r\n  /// @notice this function is used by stakers to make lum sum deposit\r\n  /// @dev lum sum deposit is possible in the first month in a fresh PET\r\n  /// @param _stakerAddress: address of staker who has a PET\r\n  /// @param _petId: id of PET in staker address portfolio\r\n  /// @param _totalDepositAmount: total amount to deposit for 12 months\r\n  /// @param _frequencyMode: can be 3, 6 or 12\r\n  /// @param _usePrepaidES: should prepaidES be used\r\n  // deposit frequency mode\r\n  function makeFrequencyModeDeposit(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    uint256 _totalDepositAmount,\r\n    uint256 _frequencyMode,\r\n    bool _usePrepaidES\r\n  ) public {\r\n    uint256 _fees;\r\n    /// @dev using ether because ES also has 18 decimals like ETH\r\n    if(_frequencyMode == 3) _fees = _totalDepositAmount.mul(1).div(100);\r\n    else if(_frequencyMode == 6) _fees = _totalDepositAmount.mul(2).div(100);\r\n    else if(_frequencyMode == 12) _fees = _totalDepositAmount.mul(3).div(100);\r\n    else require(false, \u0027unsupported frequency\u0027);\r\n\r\n    /// @notice check if non zero deposit\r\n    require(_totalDepositAmount \u003e 0, \u0027deposit amount should be non zero\u0027);\r\n\r\n    /// @notice get the reference of staker\u0027s PET\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n\r\n    /// @notice calculate deposit month based on time and enforce first month\r\n    uint256 _depositMonth = getDepositMonth(_stakerAddress, _petId);\r\n    // require(_depositMonth == 1, \u0027allowed only in first month\u0027);\r\n\r\n    uint256 _uptoMonth = _depositMonth.add(_frequencyMode).sub(1);\r\n    require(_uptoMonth \u003c= 12, \u0027cannot deposit after accumulation period\u0027);\r\n\r\n    /// @notice enforce only fresh pets\r\n    require(_pet.monthlyDepositAmount[_depositMonth] == 0, \u0027allowed only in fresh month deposit\u0027);\r\n\r\n    /// @notice calculate monthly deposit amount\r\n    uint256 _monthlyDepositAmount = _totalDepositAmount.div(_frequencyMode);\r\n\r\n    /// @notice check if single monthly deposit amount is at least commitment\r\n    require(\r\n      _monthlyDepositAmount \u003e= _pet.monthlyCommitmentAmount\r\n      , \u0027deposit not crossing commitment\u0027\r\n    );\r\n\r\n    /// @notice calculate benefit for a single month\r\n    uint256 _benefitAllocationForSingleMonth = _getBenefitAllocationByDepositAmount(\r\n      _pet,\r\n      _monthlyDepositAmount,\r\n      1\r\n    );\r\n\r\n    if(_usePrepaidES) {\r\n      /// @notice subtracting prepaidES from staker\r\n      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_totalDepositAmount.add(_fees));\r\n    } else {\r\n      /// @notice transfering staker tokens to PET contract\r\n      token.transferFrom(msg.sender, address(this), _totalDepositAmount.add(_fees));\r\n    }\r\n\r\n    prepaidES[deployer] = prepaidES[deployer].add(_fees);\r\n    // token.transfer(deployer, _fees);\r\n\r\n    /// @notice pull funds from funds bucket\r\n    token.transferFrom(fundsBucket, address(this), _benefitAllocationForSingleMonth.mul(_frequencyMode));\r\n\r\n    for(uint256 _monthId = _depositMonth; _monthId \u003c= _uptoMonth; _monthId++) {\r\n      /// @notice mark deposits in all the months\r\n      _pet.monthlyDepositAmount[_monthId] = _monthlyDepositAmount;\r\n\r\n      /// @notice emit events\r\n      emit NewDeposit(\r\n        _stakerAddress,\r\n        _petId,\r\n        _monthId,\r\n        _monthlyDepositAmount,\r\n        // _benefitAllocationForSingleMonth,\r\n        msg.sender,\r\n        _usePrepaidES\r\n      );\r\n    }\r\n  }\r\n\r\n  /// @notice this function is used to withdraw annuity benefits\r\n  /// @param _stakerAddress: address of staker who has a PET\r\n  /// @param _petId: id of PET in staker address portfolio\r\n  /// @param _endAnnuityMonthId: this is the month upto which benefits to be withdrawn\r\n  function withdrawAnnuity(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    uint256 _endAnnuityMonthId\r\n  ) public meOrNominee(_stakerAddress, _petId) {\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n    uint256 _lastAnnuityWithdrawlMonthId = _pet.lastAnnuityWithdrawlMonthId;\r\n\r\n    /// @notice enforcing withdrawls only once\r\n    require(\r\n      _lastAnnuityWithdrawlMonthId \u003c _endAnnuityMonthId\r\n      , \u0027start should be before end\u0027\r\n    );\r\n\r\n    /// @notice enforcing only 60 withdrawls\r\n    require(\r\n      _endAnnuityMonthId \u003c= 60\r\n      , \u0027only 60 Annuity withdrawls\u0027\r\n    );\r\n\r\n    /// @notice calculating allowed timestamp\r\n    uint256 _allowedTimestamp = getNomineeAllowedTimestamp(\r\n      _stakerAddress,\r\n      _petId,\r\n      _endAnnuityMonthId\r\n    );\r\n\r\n    /// @notice enforcing withdrawls only after allowed timestamp\r\n    require(\r\n      now \u003e= _allowedTimestamp\r\n      , \u0027cannot withdraw early\u0027\r\n    );\r\n\r\n    /// @notice calculating sum of annuity of the months\r\n    uint256 _annuityBenefit = getSumOfMonthlyAnnuity(\r\n      _stakerAddress,\r\n      _petId,\r\n      _lastAnnuityWithdrawlMonthId+1,\r\n      _endAnnuityMonthId\r\n    );\r\n\r\n    /// @notice updating last withdrawl month\r\n    _pet.lastAnnuityWithdrawlMonthId = _endAnnuityMonthId;\r\n\r\n    /// @notice burning penalised power booster tokens in the first annuity withdrawl\r\n    if(_lastAnnuityWithdrawlMonthId == 0) {\r\n      _burnPenalisedPowerBoosterTokens(_stakerAddress, _petId);\r\n    }\r\n\r\n    /// @notice transfering the annuity to withdrawer (staker or nominee)\r\n    if(_annuityBenefit != 0) {\r\n      token.transfer(msg.sender, _annuityBenefit);\r\n    }\r\n\r\n    // @notice emitting an event\r\n    emit AnnuityWithdrawl(\r\n      _stakerAddress,\r\n      _petId,\r\n      _lastAnnuityWithdrawlMonthId+1,\r\n      _endAnnuityMonthId,\r\n      _annuityBenefit,\r\n      msg.sender\r\n    );\r\n  }\r\n\r\n  /// @notice this function is used by staker to withdraw power booster\r\n  /// @param _stakerAddress: address of staker who has a PET\r\n  /// @param _petId: id of PET in staker address portfolio\r\n  /// @param _powerBoosterId: this is serial of power booster\r\n  function withdrawPowerBooster(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    uint256 _powerBoosterId\r\n  ) public meOrNominee(_stakerAddress, _petId) {\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n\r\n    /// @notice enforcing 12 power booster withdrawls\r\n    require(\r\n      1 \u003c= _powerBoosterId \u0026\u0026 _powerBoosterId \u003c= 12\r\n      , \u0027id should be in range\u0027\r\n    );\r\n\r\n    /// @notice enforcing power booster withdrawl once\r\n    require(\r\n      !_pet.isPowerBoosterWithdrawn[_powerBoosterId]\r\n      , \u0027booster already withdrawn\u0027\r\n    );\r\n\r\n    /// @notice enforcing target to be acheived\r\n    require(\r\n      _pet.monthlyDepositAmount[13 - _powerBoosterId] \u003e= _pet.monthlyCommitmentAmount\r\n      , \u0027target not achieved\u0027\r\n    );\r\n\r\n    /// @notice calculating allowed timestamp based on time and nominee\r\n    uint256 _allowedTimestamp = getNomineeAllowedTimestamp(\r\n      _stakerAddress,\r\n      _petId,\r\n      _powerBoosterId*5+1\r\n    );\r\n\r\n    /// @notice enforcing withdrawl after _allowedTimestamp\r\n    require(\r\n      now \u003e= _allowedTimestamp\r\n      , \u0027cannot withdraw early\u0027\r\n    );\r\n\r\n    /// @notice calculating power booster amount\r\n    uint256 _powerBoosterAmount = calculatePowerBoosterAmount(_stakerAddress, _petId);\r\n\r\n    /// @notice marking power booster as withdrawn\r\n    _pet.isPowerBoosterWithdrawn[_powerBoosterId] = true;\r\n\r\n    if(_powerBoosterAmount \u003e 0) {\r\n      /// @notice sending the power booster amount to withdrawer (staker or nominee)\r\n      token.transfer(msg.sender, _powerBoosterAmount);\r\n    }\r\n\r\n    /// @notice emitting an event\r\n    emit PowerBoosterWithdrawl(\r\n      _stakerAddress,\r\n      _petId,\r\n      _powerBoosterId,\r\n      _powerBoosterAmount,\r\n      msg.sender\r\n    );\r\n  }\r\n\r\n  /// @notice this function is used to view nomination\r\n  /// @param _stakerAddress: address of initiater of this PET.\r\n  /// @param _petId: id of PET in staker portfolio.\r\n  /// @param _nomineeAddress: eth wallet address of nominee.\r\n  /// @return tells whether this address is a nominee or not\r\n  function viewNomination(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    address _nomineeAddress\r\n  ) public view returns (bool) {\r\n    return pets[_stakerAddress][_petId].nominees[_nomineeAddress];\r\n  }\r\n\r\n  /// @notice this function is used to view appointation\r\n  /// @param _stakerAddress: address of initiater of this PET.\r\n  /// @param _petId: id of PET in staker portfolio.\r\n  /// @param _appointeeAddress: eth wallet address of apointee.\r\n  /// @return tells whether this address is a appointee or not\r\n  function viewAppointation(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    address _appointeeAddress\r\n  ) public view returns (bool) {\r\n    return pets[_stakerAddress][_petId].appointees[_appointeeAddress];\r\n  }\r\n\r\n  /// @notice this function is used by contract to get nominee\u0027s allowed timestamp\r\n  /// @param _stakerAddress: address of staker who has a PET\r\n  /// @param _petId: id of PET in staker address portfolio\r\n  /// @param _annuityMonthId: this is the month for which timestamp to find\r\n  /// @return nominee allowed timestamp\r\n  function getNomineeAllowedTimestamp(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    uint256 _annuityMonthId\r\n  ) public view returns (uint256) {\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n    uint256 _allowedTimestamp = _pet.initTimestamp\r\n      + (12 + _annuityMonthId - 1) * EARTH_SECONDS_IN_MONTH;\r\n\r\n    /// @notice if tranasction sender is not the staker, then more delay to _allowedTimestamp\r\n    if(msg.sender != _stakerAddress) {\r\n      if(_pet.appointeeVotes \u003e _pet.numberOfAppointees.div(2)) {\r\n        _allowedTimestamp += EARTH_SECONDS_IN_MONTH * 6;\r\n      } else {\r\n        _allowedTimestamp += EARTH_SECONDS_IN_MONTH * 12;\r\n      }\r\n    }\r\n\r\n    return _allowedTimestamp;\r\n  }\r\n\r\n  /// @notice this function is used to retrive monthly deposit in a PET\r\n  /// @param _stakerAddress: address of staker who has PET\r\n  /// @param _petId: id of PET in staket address portfolio\r\n  /// @param _monthId: specify the month to deposit\r\n  /// @return deposit in a particular month\r\n  function getMonthlyDepositedAmount(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    uint256 _monthId\r\n  ) public view returns (uint256) {\r\n    return pets[_stakerAddress][_petId].monthlyDepositAmount[_monthId];\r\n  }\r\n\r\n  /// @notice this function is used to get the current month of a PET\r\n  /// @param _stakerAddress: address of staker who has PET\r\n  /// @param _petId: id of PET in staket address portfolio\r\n  /// @return current month of a particular PET\r\n  function getDepositMonth(\r\n    address _stakerAddress,\r\n    uint256 _petId\r\n  ) public view returns (uint256) {\r\n    return (now - pets[_stakerAddress][_petId].initTimestamp)/EARTH_SECONDS_IN_MONTH + 1;\r\n  }\r\n\r\n  /// @notice this function is used to get total annuity benefits between two months\r\n  /// @param _stakerAddress: address of staker who has a PET\r\n  /// @param _petId: id of PET in staker address portfolio\r\n  /// @param _startAnnuityMonthId: this is the month (inclusive) to start from\r\n  /// @param _endAnnuityMonthId: this is the month (inclusive) to stop at\r\n  function getSumOfMonthlyAnnuity(\r\n    address _stakerAddress,\r\n    uint256 _petId,\r\n    uint256 _startAnnuityMonthId,\r\n    uint256 _endAnnuityMonthId\r\n  ) public view returns (uint256) {\r\n    /// @notice get the storage references of staker\u0027s PET and Plan\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n    PETPlan storage _petPlan = petPlans[_pet.planId];\r\n\r\n    uint256 _totalDeposits;\r\n\r\n    /// @notice calculating both deposits for every month and adding it\r\n    for(uint256 _i = _startAnnuityMonthId; _i \u003c= _endAnnuityMonthId; _i++) {\r\n      uint256 _modulo = _i%12;\r\n      uint256 _depositAmountIncludingPET = _getTotalDepositedIncludingPET(_pet.monthlyDepositAmount[_modulo==0?12:_modulo], _pet.monthlyCommitmentAmount);\r\n\r\n      _totalDeposits = _totalDeposits.add(_depositAmountIncludingPET);\r\n    }\r\n\r\n    /// @notice calculating annuity from total both deposits done\r\n    return _totalDeposits.mul(_petPlan.monthlyBenefitFactorPerThousand).div(1000);\r\n  }\r\n\r\n  /// @notice calculating power booster amount\r\n  /// @param _stakerAddress: address of staker who has PET\r\n  /// @param _petId: id of PET in staket address portfolio\r\n  /// @return single power booster amount\r\n  function calculatePowerBoosterAmount(\r\n    address _stakerAddress,\r\n    uint256 _petId\r\n  ) public view returns (uint256) {\r\n    /// @notice get the storage reference of staker\u0027s PET\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n\r\n    uint256 _totalDepositedIncludingPET;\r\n\r\n    /// @notice calculating total deposited by staker and pet in all 12 months\r\n    for(uint256 _i = 1; _i \u003c= 12; _i++) {\r\n      uint256 _depositAmountIncludingPET = _getTotalDepositedIncludingPET(\r\n        _pet.monthlyDepositAmount[_i],\r\n        _pet.monthlyCommitmentAmount\r\n      );\r\n\r\n      _totalDepositedIncludingPET = _totalDepositedIncludingPET.add(_depositAmountIncludingPET);\r\n    }\r\n\r\n    return _totalDepositedIncludingPET.div(12);\r\n  }\r\n\r\n  /// @notice this function is used internally to burn penalised booster tokens\r\n  /// @param _stakerAddress: address of staker who has a PET\r\n  /// @param _petId: id of PET in staker address portfolio\r\n  function _burnPenalisedPowerBoosterTokens(\r\n    address _stakerAddress,\r\n    uint256 _petId\r\n  ) private {\r\n    /// @notice get the storage references of staker\u0027s PET\r\n    PET storage _pet = pets[_stakerAddress][_petId];\r\n\r\n    uint256 _unachieveTargetCount;\r\n\r\n    /// @notice calculating number of unacheived targets\r\n    for(uint256 _i = 1; _i \u003c= 12; _i++) {\r\n      if(_pet.monthlyDepositAmount[_i] \u003c _pet.monthlyCommitmentAmount) {\r\n        _unachieveTargetCount++;\r\n      }\r\n    }\r\n\r\n    uint256 _powerBoosterAmount = calculatePowerBoosterAmount(_stakerAddress, _petId);\r\n\r\n    /// @notice burning the unacheived power boosters\r\n    uint256 _burningAmount = _powerBoosterAmount.mul(_unachieveTargetCount);\r\n    token.burn(_burningAmount);\r\n\r\n    // @notice emitting an event\r\n    emit BoosterBurn(_stakerAddress, _petId, _burningAmount);\r\n  }\r\n\r\n  /// @notice this function is used by contract to calculate benefit allocation when\r\n  ///   a staker makes a deposit\r\n  /// @param _pet: this is a reference to staker\u0027s pet storage\r\n  /// @param _depositAmount: this is amount deposited by staker\r\n  /// @param _depositMonth: this is month at which deposit takes place\r\n  /// @return benefit amount to be allocated due to the deposit\r\n  function _getBenefitAllocationByDepositAmount(\r\n    PET storage _pet,\r\n    uint256 _depositAmount,\r\n    uint256 _depositMonth\r\n  ) private view returns (uint256) {\r\n    uint256 _planId = _pet.planId;\r\n    uint256 _amount = _depositAmount != 0\r\n      ? _depositAmount : _pet.monthlyDepositAmount[_depositMonth];\r\n    uint256 _monthlyCommitmentAmount = _pet.monthlyCommitmentAmount;\r\n    PETPlan storage _petPlan = petPlans[_planId];\r\n\r\n    uint256 _petAmount;\r\n\r\n    /// @notice if amount is above commitment then amount + commitment + amount / 2\r\n    if(_amount \u003e _monthlyCommitmentAmount) {\r\n      uint256 _topupAmount = _amount.sub(_monthlyCommitmentAmount);\r\n      _petAmount = _monthlyCommitmentAmount.add(_topupAmount.div(2));\r\n    }\r\n    /// @notice otherwise if amount is atleast half of commitment and at most commitment\r\n    ///   then take staker amount as the pet amount\r\n    else if(_amount \u003e= _monthlyCommitmentAmount.div(2)) {\r\n      _petAmount = _amount;\r\n    }\r\n\r\n    /// @notice getting total deposit for the month including pet\r\n    uint256 _depositAmountIncludingPET = _getTotalDepositedIncludingPET(\r\n      _amount,\r\n      _monthlyCommitmentAmount\r\n    );\r\n\r\n    /// @dev starting with allocating power booster amount due to this deposit amount\r\n    uint256 _benefitAllocation = _petAmount;\r\n\r\n    /// @notice calculating the benefits in 5 years due to this deposit\r\n    if(_amount \u003e= _monthlyCommitmentAmount.div(2) || _depositMonth == 12) {\r\n      _benefitAllocation = _benefitAllocation.add(\r\n        _depositAmountIncludingPET.mul(_petPlan.monthlyBenefitFactorPerThousand).mul(5).div(1000)\r\n      );\r\n    }\r\n\r\n    return _benefitAllocation;\r\n  }\r\n\r\n  /// @notice this function is used by contract to get total deposited amount including PET\r\n  /// @param _amount: amount of ES which is deposited\r\n  /// @param _monthlyCommitmentAmount: commitment amount of staker\r\n  /// @return staker plus pet deposit amount based on acheivement of commitment\r\n  function _getTotalDepositedIncludingPET(\r\n    uint256 _amount,\r\n    uint256 _monthlyCommitmentAmount\r\n  ) private pure returns (uint256) {\r\n    uint256 _petAmount;\r\n\r\n    /// @notice if there is topup then add half of topup to pet\r\n    if(_amount \u003e _monthlyCommitmentAmount) {\r\n      uint256 _topupAmount = _amount.sub(_monthlyCommitmentAmount);\r\n      _petAmount = _monthlyCommitmentAmount.add(_topupAmount.div(2));\r\n    }\r\n    /// @notice otherwise if amount is atleast half of commitment and at most commitment\r\n    ///   then take staker amount as the pet amount\r\n    else if(_amount \u003e= _monthlyCommitmentAmount.div(2)) {\r\n      _petAmount = _amount;\r\n    }\r\n\r\n    /// @notice finally sum staker amount and pet amount and return it\r\n    return _amount.add(_petAmount);\r\n  }\r\n}\r\n\r\n\r\n/// @dev For interface requirement\r\ncontract ERC20 {\r\n  function balanceOf(address tokenDeployer) public view returns (uint);\r\n  function approve(address delegate, uint numTokens) public returns (bool);\r\n  function transfer(address _to, uint256 _value) public returns (bool success);\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n  function burn(uint256 value) public;\r\n  function mou() public view returns (uint256);\r\n}"}}