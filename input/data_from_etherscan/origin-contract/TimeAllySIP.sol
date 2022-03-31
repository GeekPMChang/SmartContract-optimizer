{"SafeMath.sol":{"content":"pragma solidity ^0.5.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     *\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\n     * @dev Get it via `npm install @openzeppelin/contracts@next`.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\n     * @dev Get it via `npm install @openzeppelin/contracts@next`.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\n     * @dev Get it via `npm install @openzeppelin/contracts@next`.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n"},"TimeAllySIP.sol":{"content":"pragma solidity 0.5.12;\n\nimport \u0027./SafeMath.sol\u0027;\n\n/// @title TimeAlly Super Goal Achiever Plan (TSGAP)\n/// @author The EraSwap Team\n/// @notice The benefits are transparently stored in advance in this contract\ncontract TimeAllySIP {\n  using SafeMath for uint256;\n\n  struct SIPPlan {\n    bool isPlanActive;\n    uint256 minimumMonthlyCommitmentAmount; /// @dev minimum amount 500 ES\n    uint256 accumulationPeriodMonths; /// @dev 12 months\n    uint256 benefitPeriodYears; /// @dev 9 years\n    uint256 gracePeriodSeconds; /// @dev 60*60*24*10\n    uint256 monthlyBenefitFactor; /// @dev this is per 1000; i.e 200 for 20%\n    uint256 gracePenaltyFactor; /// @dev penalty on first powerBoosterAmount, this is per 1000; i.e 10 for 1%\n    uint256 defaultPenaltyFactor; /// @dev penalty on first powerBoosterAmount, this is per 1000; i.e 20 for 2%\n  }\n\n  struct SIP {\n    uint256 planId;\n    uint256 stakingTimestamp;\n    uint256 monthlyCommitmentAmount;\n    uint256 totalDeposited;\n    uint256 lastWithdrawlMonthId;\n    uint256 powerBoosterWithdrawls;\n    uint256 numberOfAppointees;\n    uint256 appointeeVotes;\n    mapping(uint256 =\u003e uint256) depositStatus; /// @dev 2 =\u003e ontime, 1 =\u003e grace, 0 =\u003e defaulted / not yet\n    mapping(uint256 =\u003e uint256) monthlyBenefitAmount;\n    mapping(address =\u003e bool) nominees;\n    mapping(address =\u003e bool) appointees;\n  }\n\n  address public owner;\n  ERC20 public token;\n\n  /// @dev 1 Year = 365.242 days for taking care of leap years\n  uint256 public EARTH_SECONDS_IN_MONTH = 2629744;\n\n  /// @notice whenever a deposit is done by user, benefit amount (to be paid\n  /// in due plan time) will be already added to this. and in case of withdrawl,\n  /// it is subtracted from this.\n  uint256 public pendingBenefitAmountOfAllStakers;\n\n  /// @notice deposited by Era Swap Donors. It is given as benefits to  ES stakers.\n  /// on every withdrawl this deposit is reduced, and on some point of time\n  /// if enough fundsDeposit is not available to assure staker benefit,\n  /// contract will allow staker to deposit\n  uint256 public fundsDeposit;\n\n  /// @notice allocating storage for multiple sip plans\n  SIPPlan[] public sipPlans;\n\n  /// @notice allocating storage for multiple sips of multiple users\n  mapping(address =\u003e SIP[]) public sips;\n\n  /// @notice charge is ES amount given as rewards that can be used for SIP in this contract.\n  mapping(address =\u003e uint256) public prepaidES;\n\n  /// @notice event schema for monitoring funds added by donors\n  event FundsDeposited (\n    uint256 _depositAmount\n  );\n\n  /// @notice event schema for monitoring unallocated fund withdrawn by owner\n  event FundsWithdrawn (\n    uint256 _withdrawlAmount\n  );\n\n  /// @notice event schema for monitoring new sips by stakers\n  event NewSIP (\n    address indexed _staker,\n    uint256 _sipId,\n    uint256 _monthlyCommitmentAmount\n  );\n\n  /// @notice event schema for monitoring deposits made by stakers to sips\n  event NewDeposit (\n    address indexed _staker,\n    uint256 indexed _sipId,\n    uint256 _monthId,\n    uint256 _depositAmount,\n    uint256 _benefitQueued,\n    address _depositedBy\n  );\n\n  /// @notice event schema for monitoring sip benefit withdrawn by stakers\n  event BenefitWithdrawl (\n    address indexed _staker,\n    uint256 indexed _sipId,\n    uint256 _fromMonthId,\n    uint256 _toMonthId,\n    uint256 _withdrawlAmount,\n    address _withdrawnBy\n  );\n\n  /// @notice event schema for monitoring power booster withdrawn by stakers\n  event PowerBoosterWithdrawl (\n    address indexed _staker,\n    uint256 indexed _sipId,\n    uint256 _boosterSerial,\n    uint256 _withdrawlAmount,\n    address _withdrawnBy\n  );\n\n  /// @notice event schema for monitoring power booster withdrawn by stakers\n  event NomineeUpdated (\n    address indexed _staker,\n    uint256 indexed _sipId,\n    address indexed _nomineeAddress,\n    bool _nomineeStatus\n  );\n\n  /// @notice event schema for monitoring power booster withdrawls by stakers\n  event AppointeeUpdated (\n    address indexed _staker,\n    uint256 indexed _sipId,\n    address indexed _appointeeAddress,\n    bool _appointeeStatus\n  );\n\n  /// @notice event schema for monitoring power booster withdrawls by stakers\n  event AppointeeVoted (\n    address indexed _staker,\n    uint256 indexed _sipId,\n    address indexed _appointeeAddress\n  );\n\n  /// @notice restricting access to some functionalities to owner\n  modifier onlyOwner() {\n    require(msg.sender == owner, \u0027only deployer can call\u0027);\n    _;\n  }\n\n  /// @notice restricting access of staker\u0027s SIP to them and their sip nominees\n  modifier meOrNominee(address _stakerAddress, uint256 _sipId) {\n    SIP storage _sip = sips[_stakerAddress][_sipId];\n\n    /// @notice if transacter is not staker, then transacter should be nominee\n    if(msg.sender != _stakerAddress) {\n      require(_sip.nominees[msg.sender], \u0027nomination should be there\u0027);\n    }\n    _;\n  }\n\n  /// @notice sets up TimeAllySIP contract when deployed\n  /// @param _token: is EraSwap ERC20 Smart Contract Address\n  constructor(ERC20 _token) public {\n    owner = msg.sender;\n    token = _token;\n  }\n\n  /// @notice this function is used by owner to create plans for new SIPs\n  /// @param _minimumMonthlyCommitmentAmount: minimum SIP monthly amount in exaES\n  /// @param _accumulationPeriodMonths: number of months to deposit commitment amount\n  /// @param _benefitPeriodYears: number of years of benefit\n  /// @param _gracePeriodSeconds: grace allowance to stakers to deposit monthly\n  /// @param _monthlyBenefitFactor: this is per 1000; i.e 200 for 20%\n  /// @param _gracePenaltyFactor: due to late deposits, this is per 1000\n  /// @param _defaultPenaltyFactor: due to missing deposits, this is per 1000\n  function createSIPPlan(\n    uint256 _minimumMonthlyCommitmentAmount,\n    uint256 _accumulationPeriodMonths,\n    uint256 _benefitPeriodYears,\n    uint256 _gracePeriodSeconds,\n    uint256 _monthlyBenefitFactor,\n    uint256 _gracePenaltyFactor,\n    uint256 _defaultPenaltyFactor\n  ) public onlyOwner {\n\n    /// @notice saving new sip plan details to blockchain storage\n    sipPlans.push(SIPPlan({\n      isPlanActive: true,\n      minimumMonthlyCommitmentAmount: _minimumMonthlyCommitmentAmount,\n      accumulationPeriodMonths: _accumulationPeriodMonths,\n      benefitPeriodYears: _benefitPeriodYears,\n      gracePeriodSeconds: _gracePeriodSeconds,\n      monthlyBenefitFactor: _monthlyBenefitFactor,\n      gracePenaltyFactor: _gracePenaltyFactor,\n      defaultPenaltyFactor: _defaultPenaltyFactor\n    }));\n  }\n\n  /// @notice this function is used by owner to disable or re-enable a sip plan\n  /// @dev sips already initiated by a plan will continue only new will be restricted\n  /// @param _planId: select a plan to make it inactive\n  /// @param _newStatus: true or false.\n  function updatePlanStatus(uint256 _planId, bool _newStatus) public onlyOwner {\n    sipPlans[_planId].isPlanActive = _newStatus;\n  }\n\n  /// @notice this function is used by donors to add funds to fundsDeposit\n  /// @dev ERC20 approve is required to be done for this contract earlier\n  /// @param _depositAmount: amount in exaES to deposit\n  function addFunds(uint256 _depositAmount) public {\n\n    /// @notice transfer tokens from the donor to contract\n    require(\n      token.transferFrom(msg.sender, address(this), _depositAmount)\n      , \u0027tokens should be transfered\u0027\n    );\n\n    /// @notice increment amount in fundsDeposit\n    fundsDeposit = fundsDeposit.add(_depositAmount);\n\n    /// @notice emiting event that funds been deposited\n    emit FundsDeposited(_depositAmount);\n  }\n\n  /// @notice this is used by owner to withdraw ES that are not allocated to any SIP\n  /// @param _withdrawlAmount: amount in exaES to withdraw\n  function withdrawFunds(uint256 _withdrawlAmount) public onlyOwner {\n\n    /// @notice check if withdrawing only unutilized tokens\n    require(\n      fundsDeposit.sub(pendingBenefitAmountOfAllStakers) \u003e= _withdrawlAmount\n      , \u0027cannot withdraw excess funds\u0027\n    );\n\n    /// @notice decrement amount in fundsDeposit\n    fundsDeposit = fundsDeposit.sub(_withdrawlAmount);\n\n    /// @notice transfer tokens to withdrawer\n    token.transfer(msg.sender, _withdrawlAmount);\n\n    /// @notice emit that funds are withdrawn\n    emit FundsWithdrawn(_withdrawlAmount);\n  }\n\n  /// @notice this function is used to add ES as prepaid for SIP\n  /// @dev ERC20 approve needs to be done\n  /// @param _amount: ES to deposit\n  function addToPrepaid(uint256 _amount) public {\n    require(token.transferFrom(msg.sender, address(this), _amount));\n    prepaidES[msg.sender] = prepaidES[msg.sender].add(_amount);\n  }\n\n  /// @notice this function is used to send ES as prepaid for SIP\n  /// @param _addresses: address array to send prepaid ES for SIP\n  /// @param _amounts: prepaid ES for SIP amounts to send to corresponding addresses\n  function sendPrepaidESDifferent(\n    address[] memory _addresses,\n    uint256[] memory _amounts\n  ) public {\n    for(uint256 i = 0; i \u003c _addresses.length; i++) {\n      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_amounts[i]);\n      prepaidES[_addresses[i]] = prepaidES[_addresses[i]].add(_amounts[i]);\n    }\n  }\n\n  /// @notice this function is used to initiate a new SIP along with first deposit\n  /// @dev ERC20 approve is required to be done for this contract earlier, also\n  ///  fundsDeposit should be enough otherwise contract will not accept\n  /// @param _planId: choose a SIP plan\n  /// @param _monthlyCommitmentAmount: needs to be more than minimum specified in plan.\n  /// @param _usePrepaidES: should prepaidES be used.\n  function newSIP(\n    uint256 _planId,\n    uint256 _monthlyCommitmentAmount,\n    bool _usePrepaidES\n  ) public {\n    /// @notice check if sip plan selected is active\n    require(\n      sipPlans[_planId].isPlanActive\n      , \u0027sip plan is not active\u0027\n    );\n\n    /// @notice check if commitment amount is at least minimum\n    require(\n      _monthlyCommitmentAmount \u003e= sipPlans[_planId].minimumMonthlyCommitmentAmount\n      , \u0027amount should be atleast minimum\u0027\n    );\n\n    /// @notice calculate benefits to be given during benefit period due to this deposit\n    uint256 _singleMonthBenefit = _monthlyCommitmentAmount\n      .mul(sipPlans[ _planId ].monthlyBenefitFactor)\n      .div(1000);\n\n    uint256 _benefitsToBeGiven = _singleMonthBenefit\n      .mul(sipPlans[ _planId ].benefitPeriodYears);\n\n    /// @notice ensure if enough funds are already present in fundsDeposit\n    require(\n      fundsDeposit \u003e= _benefitsToBeGiven.add(pendingBenefitAmountOfAllStakers)\n      , \u0027enough funds for benefits should be there in contract\u0027\n    );\n\n    /// @notice if staker wants to use charge then use that else take from wallet\n    if(_usePrepaidES) {\n      /// @notice subtracting prepaidES from staker\n      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_monthlyCommitmentAmount);\n    } else {\n      /// @notice begin sip process by transfering first month tokens from staker to contract\n      require(token.transferFrom(msg.sender, address(this), _monthlyCommitmentAmount));\n    }\n\n\n    /// @notice saving sip details to blockchain storage\n    sips[msg.sender].push(SIP({\n      planId: _planId,\n      stakingTimestamp: now,\n      monthlyCommitmentAmount: _monthlyCommitmentAmount,\n      totalDeposited: _monthlyCommitmentAmount,\n      lastWithdrawlMonthId: 0, /// @dev withdrawl monthId starts from 1\n      powerBoosterWithdrawls: 0,\n      numberOfAppointees: 0,\n      appointeeVotes: 0\n    }));\n\n    /// @notice sipId starts from 0. first sip of user will have id 0, then 1 and so on.\n    uint256 _sipId = sips[msg.sender].length - 1;\n\n    /// @dev marking month 1 as paid on time\n    sips[msg.sender][_sipId].depositStatus[1] = 2;\n    sips[msg.sender][_sipId].monthlyBenefitAmount[1] = _singleMonthBenefit;\n\n    /// @notice incrementing pending benefits\n    pendingBenefitAmountOfAllStakers = pendingBenefitAmountOfAllStakers.add(\n      _benefitsToBeGiven\n    );\n\n    /// @notice emit that new sip is initiated\n    emit NewSIP(\n      msg.sender,\n      sips[msg.sender].length - 1,\n      _monthlyCommitmentAmount\n    );\n\n    /// @notice emit that first deposit is done\n    emit NewDeposit(\n      msg.sender,\n      _sipId,\n      1,\n      _monthlyCommitmentAmount,\n      _benefitsToBeGiven,\n      msg.sender\n    );\n  }\n\n  /// @notice this function is used to do monthly commitment deposit of SIP\n  /// @dev ERC20 approve is required to be done for this contract earlier, also\n  ///  fundsDeposit should be enough otherwise contract will not accept\n  ///  Also, deposit can also be done by any nominee of this SIP.\n  /// @param _stakerAddress: address of staker who has an SIP\n  /// @param _sipId: id of SIP in staker address portfolio\n  /// @param _depositAmount: amount to deposit,\n  /// @param _monthId: specify the month to deposit\n  /// @param _usePrepaidES: should prepaidES be used.\n  function monthlyDeposit(\n    address _stakerAddress,\n    uint256 _sipId,\n    uint256 _depositAmount,\n    uint256 _monthId,\n    bool _usePrepaidES\n  ) public meOrNominee(_stakerAddress, _sipId) {\n    SIP storage _sip = sips[_stakerAddress][_sipId];\n    require(\n      _depositAmount \u003e= _sip.monthlyCommitmentAmount\n      , \u0027deposit cannot be less than commitment\u0027\n    );\n\n    /// @notice cannot deposit again for a month in which a deposit is already done\n    require(\n      _sip.depositStatus[_monthId] == 0\n      , \u0027cannot deposit again\u0027\n    );\n\n    /// @notice calculating benefits to be given in future because of this deposit\n    uint256 _singleMonthBenefit = _depositAmount\n      .mul(sipPlans[ _sip.planId ].monthlyBenefitFactor)\n      .div(1000);\n\n    uint256 _benefitsToBeGiven = _singleMonthBenefit\n      .mul(sipPlans[ _sip.planId ].benefitPeriodYears);\n\n    /// @notice checking if enough unallocated funds are available\n    require(\n      fundsDeposit \u003e= _benefitsToBeGiven.add(pendingBenefitAmountOfAllStakers)\n      , \u0027enough funds should be there in SIP\u0027\n    );\n\n    /// @notice check if deposit is allowed according to current time\n    uint256 _depositStatus = getDepositStatus(_stakerAddress, _sipId, _monthId);\n    require(_depositStatus \u003e 0, \u0027grace period elapsed or too early\u0027);\n\n    /// @notice if staker wants to use charge then use that else take from wallet\n    if(_usePrepaidES) {\n      /// @notice subtracting prepaidES from staker\n      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_depositAmount);\n    } else {\n      /// @notice transfering staker tokens to SIP contract\n      require(token.transferFrom(msg.sender, address(this), _depositAmount));\n    }\n\n    /// @notice updating deposit status\n    _sip.depositStatus[_monthId] = _depositStatus;\n    _sip.monthlyBenefitAmount[_monthId] = _singleMonthBenefit;\n\n    /// @notice adding to total deposit in SIP\n    _sip.totalDeposited = _sip.totalDeposited.add(_depositAmount);\n\n    /// @notice adding to pending benefits\n    pendingBenefitAmountOfAllStakers = pendingBenefitAmountOfAllStakers.add(\n      _benefitsToBeGiven\n    );\n\n    /// @notice emit that first deposit is done\n    emit NewDeposit(_stakerAddress, _sipId, _monthId, _depositAmount, _benefitsToBeGiven, msg.sender);\n  }\n\n  /// @notice this function is used to withdraw benefits.\n  /// @dev withdraw can be done by any nominee of this SIP.\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker address portfolio.\n  /// @param _withdrawlMonthId: withdraw month id starts from 1 upto as per plan.\n  function withdrawBenefit(\n    address _stakerAddress,\n    uint256 _sipId,\n    uint256 _withdrawlMonthId\n  ) public meOrNominee(_stakerAddress, _sipId) {\n\n    /// @notice require statements are in this function getPendingWithdrawlAmount\n    uint256 _withdrawlAmount = getPendingWithdrawlAmount(\n      _stakerAddress,\n      _sipId,\n      _withdrawlMonthId,\n      msg.sender != _stakerAddress /// @dev _isNomineeWithdrawing\n    );\n\n    SIP storage _sip = sips[_stakerAddress][_sipId];\n\n    /// @notice marking that user has withdrawn upto _withdrawlmonthId month\n    uint256 _lastWithdrawlMonthId = _sip.lastWithdrawlMonthId;\n    _sip.lastWithdrawlMonthId = _withdrawlMonthId;\n\n    /// @notice updating pending benefits\n    pendingBenefitAmountOfAllStakers = pendingBenefitAmountOfAllStakers.sub(_withdrawlAmount);\n\n    /// @notice updating fundsDeposit\n    fundsDeposit = fundsDeposit.sub(_withdrawlAmount);\n\n    /// @notice transfering tokens to the user wallet address\n    if(_withdrawlAmount \u003e 0) {\n      token.transfer(msg.sender, _withdrawlAmount);\n    }\n\n    /// @notice emit that benefit withdrawl is done\n    emit BenefitWithdrawl(\n      _stakerAddress,\n      _sipId,\n      _lastWithdrawlMonthId + 1,\n      _withdrawlMonthId,\n      _withdrawlAmount,\n      msg.sender\n    );\n  }\n\n  /// @notice this functin is used to withdraw powerbooster\n  /// @dev withdraw can be done by any nominee of this SIP.\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker address portfolio.\n  function withdrawPowerBooster(\n    address _stakerAddress,\n    uint256 _sipId\n  ) public meOrNominee(_stakerAddress, _sipId) {\n    SIP storage _sip = sips[_stakerAddress][_sipId];\n\n    /// @notice taking the next power booster withdrawl\n    /// @dev not using safemath because this is under safe range\n    uint256 _powerBoosterSerial = _sip.powerBoosterWithdrawls + 1;\n\n    /// @notice limiting only 3 powerbooster withdrawls\n    require(_powerBoosterSerial \u003c= 3, \u0027only 3 power boosters\u0027);\n\n    /// @notice calculating allowed time\n    /// @dev not using SafeMath because uint256 range is safe\n    uint256 _allowedTimestamp = _sip.stakingTimestamp\n      + sipPlans[ _sip.planId ].accumulationPeriodMonths * EARTH_SECONDS_IN_MONTH\n      + sipPlans[ _sip.planId ].benefitPeriodYears * 12 * EARTH_SECONDS_IN_MONTH * _powerBoosterSerial / 3 - EARTH_SECONDS_IN_MONTH;\n\n    /// @notice opening window for nominee after sometime\n    if(msg.sender != _stakerAddress) {\n      if(_sip.appointeeVotes \u003e _sip.numberOfAppointees.div(2)) {\n        /// @notice with concensus of appointees, withdraw is allowed in 6 months\n        _allowedTimestamp += EARTH_SECONDS_IN_MONTH * 6;\n      } else {\n        /// @notice otherwise a default of 1 year delay in withdrawing benefits\n        _allowedTimestamp += EARTH_SECONDS_IN_MONTH * 12;\n      }\n    }\n\n    /// @notice restricting early withdrawl\n    require(now \u003e _allowedTimestamp, \u0027cannot withdraw early\u0027);\n\n    /// @notice marking that power booster is withdrawn\n    _sip.powerBoosterWithdrawls = _powerBoosterSerial;\n\n    /// @notice calculating power booster amount\n    uint256 _powerBoosterAmount = _sip.totalDeposited.div(3);\n\n    /// @notice penalising power booster amount as per plan if commitment not met as per plan\n    if(_powerBoosterSerial == 1) {\n      uint256 _totalPenaltyFactor;\n      for(uint256 i = 1; i \u003c= sipPlans[ _sip.planId ].accumulationPeriodMonths; i++) {\n        if(_sip.depositStatus[i] == 0) {\n          /// @notice for defaulted months\n          _totalPenaltyFactor += sipPlans[ _sip.planId ].defaultPenaltyFactor;\n        } else if(_sip.depositStatus[i] == 1) {\n          /// @notice for grace period months\n          _totalPenaltyFactor += sipPlans[ _sip.planId ].gracePenaltyFactor;\n        }\n      }\n      uint256 _penaltyAmount = _powerBoosterAmount.mul(_totalPenaltyFactor).div(1000);\n\n      /// @notice if there is any penalty then apply the penalty\n      if(_penaltyAmount \u003e 0) {\n\n        /// @notice allocate penalty amount into fund.\n        fundsDeposit = fundsDeposit.add(_penaltyAmount);\n\n        /// @notice emiting event that funds been deposited\n        emit FundsDeposited(_penaltyAmount);\n\n        /// @notice subtracting penalty form power booster amount\n        _powerBoosterAmount = _powerBoosterAmount.sub(_penaltyAmount);\n      }\n    }\n\n    /// @notice transfering tokens to wallet of withdrawer\n    token.transfer(msg.sender, _powerBoosterAmount);\n\n    /// @notice emit that power booster withdrawl is done\n    emit PowerBoosterWithdrawl(\n      _stakerAddress,\n      _sipId,\n      _powerBoosterSerial,\n      _powerBoosterAmount,\n      msg.sender\n    );\n  }\n\n  /// @notice this function is used to update nominee status of a wallet address in SIP\n  /// @param _sipId: id of SIP in staker portfolio.\n  /// @param _nomineeAddress: eth wallet address of nominee.\n  /// @param _newNomineeStatus: true or false, whether this should be a nominee or not.\n  function toogleNominee(\n    uint256 _sipId,\n    address _nomineeAddress,\n    bool _newNomineeStatus\n  ) public {\n\n    /// @notice updating nominee status\n    sips[msg.sender][_sipId].nominees[_nomineeAddress] = _newNomineeStatus;\n\n    /// @notice emiting event for UI and other applications\n    emit NomineeUpdated(msg.sender, _sipId, _nomineeAddress, _newNomineeStatus);\n  }\n\n  /// @notice this function is used to update appointee status of a wallet address in SIP\n  /// @param _sipId: id of SIP in staker portfolio.\n  /// @param _appointeeAddress: eth wallet address of appointee.\n  /// @param _newAppointeeStatus: true or false, should this have appointee rights or not.\n  function toogleAppointee(\n    uint256 _sipId,\n    address _appointeeAddress,\n    bool _newAppointeeStatus\n  ) public {\n    SIP storage _sip = sips[msg.sender][_sipId];\n\n    /// @notice if not an appointee already and _newAppointeeStatus is true, adding appointee\n    if(!_sip.appointees[_appointeeAddress] \u0026\u0026 _newAppointeeStatus) {\n      _sip.numberOfAppointees = _sip.numberOfAppointees.add(1);\n      _sip.appointees[_appointeeAddress] = true;\n    }\n\n    /// @notice if already an appointee and _newAppointeeStatus is false, removing appointee\n    else if(_sip.appointees[_appointeeAddress] \u0026\u0026 !_newAppointeeStatus) {\n      _sip.appointees[_appointeeAddress] = false;\n      _sip.numberOfAppointees = _sip.numberOfAppointees.sub(1);\n    }\n\n    emit AppointeeUpdated(msg.sender, _sipId, _appointeeAddress, _newAppointeeStatus);\n  }\n\n  /// @notice this function is used by appointee to vote that nominees can withdraw early\n  /// @dev need to be appointee, set by staker themselves\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker portfolio.\n  function appointeeVote(\n    address _stakerAddress,\n    uint256 _sipId\n  ) public {\n    SIP storage _sip = sips[_stakerAddress][_sipId];\n\n    /// @notice checking if appointee has rights to cast a vote\n    require(_sip.appointees[msg.sender]\n      , \u0027should be appointee to cast vote\u0027\n    );\n\n    /// @notice removing appointee\u0027s rights to vote again\n    _sip.appointees[msg.sender] = false;\n\n    /// @notice adding a vote to SIP\n    _sip.appointeeVotes = _sip.appointeeVotes.add(1);\n\n    /// @notice emit that appointee has voted\n    emit AppointeeVoted(_stakerAddress, _sipId, msg.sender);\n  }\n\n  /// @notice this function is used to read all time deposit status of any staker SIP\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker portfolio.\n  /// @param _monthId: deposit month id starts from 1 upto as per plan\n  /// @return 0 =\u003e no deposit, 1 =\u003e grace deposit, 2 =\u003e on time deposit\n  function getDepositDoneStatus(\n    address _stakerAddress,\n    uint256 _sipId,\n    uint256 _monthId\n  ) public view returns (uint256) {\n    return sips[_stakerAddress][_sipId].depositStatus[_monthId];\n  }\n\n  /// @notice this function is used to calculate deposit status according to current time\n  /// @dev it is used in deposit function require statement.\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker portfolio.\n  /// @param _monthId: deposit month id to calculate status for\n  /// @return 0 =\u003e too late, 1 =\u003e its grace time, 2 =\u003e on time\n  function getDepositStatus(\n    address _stakerAddress,\n    uint256 _sipId,\n    uint256 _monthId\n  ) public view returns (uint256) {\n    SIP storage _sip = sips[_stakerAddress][_sipId];\n\n    /// @notice restricting month between 1 and max accumulation month\n    require(\n      _monthId \u003e= 1 \u0026\u0026 _monthId\n        \u003c= sipPlans[ _sip.planId ].accumulationPeriodMonths\n      , \u0027invalid deposit month\u0027\n    );\n\n    /// @dev not using safemath because _monthId is bounded.\n    uint256 onTimeTimestamp = _sip.stakingTimestamp + EARTH_SECONDS_IN_MONTH * (_monthId - 1);\n\n    /// @notice deposit allowed only one month before deadline\n    if(now \u003c onTimeTimestamp - EARTH_SECONDS_IN_MONTH) {\n      return 0; /// @notice means deposit is in advance than allowed\n    } else if(onTimeTimestamp \u003e= now) {\n      return 2; /// @notice means deposit is ontime\n    } else if(onTimeTimestamp + sipPlans[ _sip.planId ].gracePeriodSeconds \u003e= now) {\n      return 1; /// @notice means deposit is in grace period\n    } else {\n      return 0; /// @notice means even grace period is elapsed\n    }\n  }\n\n  /// @notice this function is used to get avalilable withdrawls upto a withdrawl month id\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker portfolio.\n  /// @param _withdrawlMonthId: withdrawl month id upto which to calculate returns for\n  /// @param _isNomineeWithdrawing: different status in case of nominee withdrawl\n  /// @return gives available withdrawl amount upto the withdrawl month id\n  function getPendingWithdrawlAmount(\n    address _stakerAddress,\n    uint256 _sipId,\n    uint256 _withdrawlMonthId,\n    bool _isNomineeWithdrawing\n  ) public view returns (uint256) {\n    SIP storage _sip = sips[_stakerAddress][_sipId];\n\n    /// @notice check if withdrawl month is in allowed range\n    require(\n      _withdrawlMonthId \u003e 0 \u0026\u0026 _withdrawlMonthId \u003c= sipPlans[ _sip.planId ].benefitPeriodYears * 12\n      , \u0027invalid withdraw month\u0027\n    );\n\n    /// @notice check if already withdrawled upto the withdrawl month id\n    require(\n      _withdrawlMonthId \u003e _sip.lastWithdrawlMonthId\n      , \u0027cannot withdraw again\u0027\n    );\n\n    /// @notice calculate allowed time for staker\n    uint256 withdrawlAllowedTimestamp\n      = _sip.stakingTimestamp\n        + EARTH_SECONDS_IN_MONTH * (\n          sipPlans[ _sip.planId ].accumulationPeriodMonths\n            + _withdrawlMonthId - 1\n        );\n\n    /// @notice if nominee is withdrawing, update the allowed time\n    if(_isNomineeWithdrawing) {\n      if(_sip.appointeeVotes \u003e _sip.numberOfAppointees.div(2)) {\n        /// @notice with concensus of appointees, withdraw is allowed in 6 months\n        withdrawlAllowedTimestamp += EARTH_SECONDS_IN_MONTH * 6;\n      } else {\n        /// @notice otherwise a default of 1 year delay in withdrawing benefits\n        withdrawlAllowedTimestamp += EARTH_SECONDS_IN_MONTH * 12;\n      }\n    }\n\n    /// @notice restricting early withdrawl\n    require(now \u003e= withdrawlAllowedTimestamp\n      , \u0027cannot withdraw early\u0027\n    );\n\n    /// @notice calculate average deposit\n    uint256 _benefitToGive;\n    for(uint256 _i = _sip.lastWithdrawlMonthId + 1; _i \u003c= _withdrawlMonthId; _i++) {\n      uint256 _modulus = _i%sipPlans[ _sip.planId ].accumulationPeriodMonths;\n      if(_modulus == 0) _modulus = sipPlans[ _sip.planId ].accumulationPeriodMonths;\n      _benefitToGive = _benefitToGive.add(\n        _sip.monthlyBenefitAmount[_modulus]\n      );\n    }\n\n    return _benefitToGive;\n  }\n\n  function viewMonthlyBenefitAmount(\n    address _stakerAddress,\n    uint256 _sipId,\n    uint256 _depositMonthId\n  ) public view returns (uint256) {\n    return sips[_stakerAddress][_sipId].monthlyBenefitAmount[_depositMonthId];\n  }\n\n  /// @notice this function is used to view nomination\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker portfolio.\n  /// @param _nomineeAddress: eth wallet address of nominee.\n  /// @return tells whether this address is a nominee or not\n  function viewNomination(\n    address _stakerAddress,\n    uint256 _sipId,\n    address _nomineeAddress\n  ) public view returns (bool) {\n    return sips[_stakerAddress][_sipId].nominees[_nomineeAddress];\n  }\n\n  /// @notice this function is used to view appointation\n  /// @param _stakerAddress: address of initiater of this SIP.\n  /// @param _sipId: id of SIP in staker portfolio.\n  /// @param _appointeeAddress: eth wallet address of apointee.\n  /// @return tells whether this address is a appointee or not\n  function viewAppointation(\n    address _stakerAddress,\n    uint256 _sipId,\n    address _appointeeAddress\n  ) public view returns (bool) {\n    return sips[_stakerAddress][_sipId].appointees[_appointeeAddress];\n  }\n}\n\n/// @dev For interface requirement\ncontract ERC20 {\n  function transfer(address _to, uint256 _value) public returns (bool success);\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\n}\n"}}