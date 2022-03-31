{"Base.sol":{"content":"/*\n  Copyright 2019 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n\npragma solidity ^0.5.2;\n\n\ncontract Base {\n    event LogString(string str);\n\n    address payable internal operator;\n    uint256 constant internal MINIMUM_TIME_TO_REVEAL = 1 days;\n    uint256 constant internal TIME_TO_ALLOW_REVOKE = 7 days;\n    bool internal isRevokeStarted = false;\n    uint256 internal revokeTime = 0; // The time from which we can revoke.\n    bool internal active = true;\n\n    // mapping: (address, commitment) -\u003e time\n    // Times from which the users may claim the reward.\n    mapping (address =\u003e mapping (bytes32 =\u003e uint256)) private reveal_timestamps;\n\n\n    constructor ()\n        internal\n    {\n        operator = msg.sender;\n    }\n\n    modifier onlyOperator()\n    {\n        require(msg.sender == operator, \"ONLY_OPERATOR\");\n        _; // The _; defines where the called function is executed.\n    }\n\n    function register(bytes32 commitment)\n        public\n    {\n        require(reveal_timestamps[msg.sender][commitment] == 0, \"Entry already registered.\");\n        reveal_timestamps[msg.sender][commitment] = now + MINIMUM_TIME_TO_REVEAL;\n    }\n\n\n    /*\n      Makes sure that the commitment was registered at least MINIMUM_TIME_TO_REVEAL before\n      the current time.\n    */\n    function verifyTimelyRegistration(bytes32 commitment)\n        internal view\n    {\n        uint256 registrationMaturationTime = reveal_timestamps[msg.sender][commitment];\n        require(registrationMaturationTime != 0, \"Commitment is not registered.\");\n        require(now \u003e= registrationMaturationTime, \"Time for reveal has not passed yet.\");\n    }\n\n\n    /*\n      WARNING: This function should only be used with call() and not transact().\n      Creating a transaction that invokes this function might reveal the collision and make it\n      subject to front-running.\n    */\n    function calcCommitment(uint256[] memory firstInput, uint256[] memory secondInput)\n        public view\n        returns (bytes32 commitment)\n    {\n        address sender = msg.sender;\n        uint256 firstLength = firstInput.length;\n        uint256 secondLength = secondInput.length;\n        uint256[] memory hash_elements = new uint256[](1 + firstLength + secondLength);\n        hash_elements[0] = uint256(sender);\n        uint256 offset = 1;\n        for (uint256 i = 0; i \u003c firstLength; i++) {\n            hash_elements[offset + i] = firstInput[i];\n        }\n        offset = 1 + firstLength;\n        for (uint256 i = 0; i \u003c secondLength; i++) {\n            hash_elements[offset + i] = secondInput[i];\n        }\n        commitment = keccak256(abi.encodePacked(hash_elements));\n    }\n\n    function claimReward(\n        uint256[] memory firstInput,\n        uint256[] memory secondInput,\n        string memory solutionDescription,\n        string memory name)\n        public\n    {\n        require(active == true, \"This challenge is no longer active. Thank you for participating.\");\n        require(firstInput.length \u003e 0, \"First input cannot be empty.\");\n        require(secondInput.length \u003e 0, \"Second input cannot be empty.\");\n        require(firstInput.length == secondInput.length, \"Input lengths are not equal.\");\n        uint256 inputLength = firstInput.length;\n        bool sameInput = true;\n        for (uint256 i = 0; i \u003c inputLength; i++) {\n            if (firstInput[i] != secondInput[i]) {\n                sameInput = false;\n            }\n        }\n        require(sameInput == false, \"Inputs are equal.\");\n        bool sameHash = true;\n        uint256[] memory firstHash = applyHash(firstInput);\n        uint256[] memory secondHash = applyHash(secondInput);\n        require(firstHash.length == secondHash.length, \"Output lengths are not equal.\");\n        uint256 outputLength = firstHash.length;\n        for (uint256 i = 0; i \u003c outputLength; i++) {\n            if (firstHash[i] != secondHash[i]) {\n                sameHash = false;\n            }\n        }\n        require(sameHash == true, \"Not a collision.\");\n        verifyTimelyRegistration(calcCommitment(firstInput, secondInput));\n\n        active = false;\n        emit LogString(solutionDescription);\n        emit LogString(name);\n        msg.sender.transfer(address(this).balance);\n    }\n\n    function applyHash(uint256[] memory elements)\n        public view\n        returns (uint256[] memory elementsHash)\n    {\n        elementsHash = sponge(elements);\n    }\n\n    function startRevoke()\n        public\n        onlyOperator()\n    {\n        require(isRevokeStarted == false, \"Revoke already started.\");\n        isRevokeStarted = true;\n        revokeTime = now + TIME_TO_ALLOW_REVOKE;\n    }\n\n    function revokeReward()\n        public\n        onlyOperator()\n    {\n        require(isRevokeStarted == true, \"Revoke not started yet.\");\n        require(now \u003e= revokeTime, \"Revoke time not passed.\");\n        active = false;\n        operator.transfer(address(this).balance);\n    }\n\n    function sponge(uint256[] memory inputs)\n        internal view\n        returns (uint256[] memory outputElements);\n\n    function getStatus()\n        public view\n        returns (bool[] memory status)\n    {\n        status = new bool[](2);\n        status[0] = isRevokeStarted;\n        status[1] = active;\n    }\n}\n"},"Sponge.sol":{"content":"/*\n  Copyright 2019 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n\npragma solidity ^0.5.2;\n\n\ncontract Sponge {\n    uint256 prime;\n    uint256 r;\n    uint256 c;\n    uint256 m;\n    uint256 outputSize;\n    uint256 nRounds;\n\n    constructor (uint256 prime_, uint256 r_, uint256 c_, uint256 nRounds_)\n        public\n    {\n        prime = prime_;\n        r = r_;\n        c = c_;\n        m = r + c;\n        outputSize = c;\n        nRounds = nRounds_;\n    }\n\n    function LoadAuxdata()\n        internal view\n        returns (uint256[] memory /*auxdata*/);\n\n    function permutation_func(uint256[] memory /*auxdata*/, uint256[] memory /*elements*/)\n        internal view\n        returns (uint256[] memory /*hash_elements*/);\n\n    function sponge(uint256[] memory inputs)\n        internal view\n        returns (uint256[] memory outputElements)\n    {\n        uint256 inputLength = inputs.length;\n        for (uint256 i = 0; i \u003c inputLength; i++) {\n            require(inputs[i] \u003c prime, \"elements do not belong to the field\");\n        }\n\n        require(inputLength % r == 0, \"Number of field elements is not divisible by r.\");\n\n        uint256[] memory state = new uint256[](m);\n        for (uint256 i = 0; i \u003c m; i++) {\n            state[i] = 0; // fieldZero.\n        }\n\n        uint256[] memory auxData = LoadAuxdata();\n        uint256 n_columns = inputLength / r;\n        for (uint256 i = 0; i \u003c n_columns; i++) {\n            for (uint256 j = 0; j \u003c r; j++) {\n                state[j] = addmod(state[j], inputs[i * r + j], prime);\n            }\n            state = permutation_func(auxData, state);\n        }\n\n        require(outputSize \u003c= r, \"No support for more than r output elements.\");\n        outputElements = new uint256[](outputSize);\n        for (uint256 i = 0; i \u003c outputSize; i++) {\n            outputElements[i] = state[i];\n        }\n    }\n\n    function getParameters()\n        public view\n        returns (uint256[] memory status)\n    {\n        status = new uint256[](4);\n        status[0] = prime;\n        status[1] = r;\n        status[2] = c;\n        status[3] = nRounds;\n    }\n}\n"},"STARK_Friendly_Hash_Challenge_GMiMC_erf_S128e.sol":{"content":"/*\n    This smart contract was written by StarkWare Industries Ltd. as part of the STARK-friendly hash\n    challenge effort, funded by the Ethereum Foundation.\n    The contract will pay out 4 ETH to the first finder of a collision in GMiMC_erf with rate 10\n    and capacity 1 at security level of 128 bits, if such a collision is discovered before the end\n    of March 2020.\n    More information about the STARK-friendly hash challenge can be found\n    here https://starkware.co/hash-challenge/.\n    More information about the STARK-friendly hash selection process (of which this challenge is a\n    part) can be found here\n    https://medium.com/starkware/stark-friendly-hash-tire-kicking-8087e8d9a246.\n    Sage code reference implementation for the contender hash functions available\n    at https://starkware.co/hash-challenge-implementation-reference-code/.\n*/\n\n/*\n  Copyright 2019 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n\npragma solidity ^0.5.2;\n\nimport \"./Base.sol\";\nimport \"./Sponge.sol\";\n\n\ncontract STARK_Friendly_Hash_Challenge_GMiMC_erf_S128e is Base, Sponge {\n    address roundConstantsContract;\n\n    constructor (\n        uint256 prime,\n        uint256 r,\n        uint256 c,\n        uint256 nRounds,\n        address roundConstantsContract_\n        )\n        public payable\n        Sponge(prime, r, c, nRounds)\n    {\n        roundConstantsContract = roundConstantsContract_;\n    }\n\n    function LoadAuxdata()\n        internal view\n        returns (uint256[] memory roundConstants)\n    {\n        roundConstants = new uint256[](nRounds);\n        address contractAddr = roundConstantsContract;\n        assembly {\n            let sizeInBytes := mul(mload(roundConstants), 0x20)\n            extcodecopy(contractAddr, add(roundConstants, 0x20), 0, sizeInBytes)\n        }\n    }\n\n    function permutation_func(uint256[] memory roundConstants, uint256[] memory elements)\n        internal view\n        returns (uint256[] memory)\n    {\n        uint256 length = elements.length;\n        require(length == m, \"elements length is not equal to m.\");\n        for (uint256 i = 0; i \u003c roundConstants.length; i++) {\n            uint256 element0Old = elements[0];\n            uint256 step1 = addmod(elements[0], roundConstants[i], prime);\n            uint256 mask = mulmod(mulmod(step1, step1, prime), step1, prime);\n            for (uint256 j = 0; j \u003c length - 1; j++) {\n                elements[j] = addmod(elements[j + 1], mask, prime);\n            }\n            elements[length - 1] = element0Old;\n        }\n        return elements;\n    }\n}\n"}}