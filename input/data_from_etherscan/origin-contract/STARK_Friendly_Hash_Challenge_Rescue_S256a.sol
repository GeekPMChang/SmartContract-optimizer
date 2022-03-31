{"Base.sol":{"content":"/*\n  Copyright 2019 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n\npragma solidity ^0.5.2;\n\n\ncontract Base {\n    event LogString(string str);\n\n    address payable internal operator;\n    uint256 constant internal MINIMUM_TIME_TO_REVEAL = 1 days;\n    uint256 constant internal TIME_TO_ALLOW_REVOKE = 7 days;\n    bool internal isRevokeStarted = false;\n    uint256 internal revokeTime = 0; // The time from which we can revoke.\n    bool internal active = true;\n\n    // mapping: (address, commitment) -\u003e time\n    // Times from which the users may claim the reward.\n    mapping (address =\u003e mapping (bytes32 =\u003e uint256)) private reveal_timestamps;\n\n\n    constructor ()\n        internal\n    {\n        operator = msg.sender;\n    }\n\n    modifier onlyOperator()\n    {\n        require(msg.sender == operator, \"ONLY_OPERATOR\");\n        _; // The _; defines where the called function is executed.\n    }\n\n    function register(bytes32 commitment)\n        public\n    {\n        require(reveal_timestamps[msg.sender][commitment] == 0, \"Entry already registered.\");\n        reveal_timestamps[msg.sender][commitment] = now + MINIMUM_TIME_TO_REVEAL;\n    }\n\n\n    /*\n      Makes sure that the commitment was registered at least MINIMUM_TIME_TO_REVEAL before\n      the current time.\n    */\n    function verifyTimelyRegistration(bytes32 commitment)\n        internal view\n    {\n        uint256 registrationMaturationTime = reveal_timestamps[msg.sender][commitment];\n        require(registrationMaturationTime != 0, \"Commitment is not registered.\");\n        require(now \u003e= registrationMaturationTime, \"Time for reveal has not passed yet.\");\n    }\n\n\n    /*\n      WARNING: This function should only be used with call() and not transact().\n      Creating a transaction that invokes this function might reveal the collision and make it\n      subject to front-running.\n    */\n    function calcCommitment(uint256[] memory firstInput, uint256[] memory secondInput)\n        public view\n        returns (bytes32 commitment)\n    {\n        address sender = msg.sender;\n        uint256 firstLength = firstInput.length;\n        uint256 secondLength = secondInput.length;\n        uint256[] memory hash_elements = new uint256[](1 + firstLength + secondLength);\n        hash_elements[0] = uint256(sender);\n        uint256 offset = 1;\n        for (uint256 i = 0; i \u003c firstLength; i++) {\n            hash_elements[offset + i] = firstInput[i];\n        }\n        offset = 1 + firstLength;\n        for (uint256 i = 0; i \u003c secondLength; i++) {\n            hash_elements[offset + i] = secondInput[i];\n        }\n        commitment = keccak256(abi.encodePacked(hash_elements));\n    }\n\n    function claimReward(\n        uint256[] memory firstInput,\n        uint256[] memory secondInput,\n        string memory solutionDescription,\n        string memory name)\n        public\n    {\n        require(active == true, \"This challenge is no longer active. Thank you for participating.\");\n        require(firstInput.length \u003e 0, \"First input cannot be empty.\");\n        require(secondInput.length \u003e 0, \"Second input cannot be empty.\");\n        require(firstInput.length == secondInput.length, \"Input lengths are not equal.\");\n        uint256 inputLength = firstInput.length;\n        bool sameInput = true;\n        for (uint256 i = 0; i \u003c inputLength; i++) {\n            if (firstInput[i] != secondInput[i]) {\n                sameInput = false;\n            }\n        }\n        require(sameInput == false, \"Inputs are equal.\");\n        bool sameHash = true;\n        uint256[] memory firstHash = applyHash(firstInput);\n        uint256[] memory secondHash = applyHash(secondInput);\n        require(firstHash.length == secondHash.length, \"Output lengths are not equal.\");\n        uint256 outputLength = firstHash.length;\n        for (uint256 i = 0; i \u003c outputLength; i++) {\n            if (firstHash[i] != secondHash[i]) {\n                sameHash = false;\n            }\n        }\n        require(sameHash == true, \"Not a collision.\");\n        verifyTimelyRegistration(calcCommitment(firstInput, secondInput));\n\n        active = false;\n        emit LogString(solutionDescription);\n        emit LogString(name);\n        msg.sender.transfer(address(this).balance);\n    }\n\n    function applyHash(uint256[] memory elements)\n        public view\n        returns (uint256[] memory elementsHash)\n    {\n        elementsHash = sponge(elements);\n    }\n\n    function startRevoke()\n        public\n        onlyOperator()\n    {\n        require(isRevokeStarted == false, \"Revoke already started.\");\n        isRevokeStarted = true;\n        revokeTime = now + TIME_TO_ALLOW_REVOKE;\n    }\n\n    function revokeReward()\n        public\n        onlyOperator()\n    {\n        require(isRevokeStarted == true, \"Revoke not started yet.\");\n        require(now \u003e= revokeTime, \"Revoke time not passed.\");\n        active = false;\n        operator.transfer(address(this).balance);\n    }\n\n    function sponge(uint256[] memory inputs)\n        internal view\n        returns (uint256[] memory outputElements);\n\n    function getStatus()\n        public view\n        returns (bool[] memory status)\n    {\n        status = new bool[](2);\n        status[0] = isRevokeStarted;\n        status[1] = active;\n    }\n}\n"},"Sponge.sol":{"content":"/*\n  Copyright 2019 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n\npragma solidity ^0.5.2;\n\n\ncontract Sponge {\n    uint256 prime;\n    uint256 r;\n    uint256 c;\n    uint256 m;\n    uint256 outputSize;\n    uint256 nRounds;\n\n    constructor (uint256 prime_, uint256 r_, uint256 c_, uint256 nRounds_)\n        public\n    {\n        prime = prime_;\n        r = r_;\n        c = c_;\n        m = r + c;\n        outputSize = c;\n        nRounds = nRounds_;\n    }\n\n    function LoadAuxdata()\n        internal view\n        returns (uint256[] memory /*auxdata*/);\n\n    function permutation_func(uint256[] memory /*auxdata*/, uint256[] memory /*elements*/)\n        internal view\n        returns (uint256[] memory /*hash_elements*/);\n\n    function sponge(uint256[] memory inputs)\n        internal view\n        returns (uint256[] memory outputElements)\n    {\n        uint256 inputLength = inputs.length;\n        for (uint256 i = 0; i \u003c inputLength; i++) {\n            require(inputs[i] \u003c prime, \"elements do not belong to the field\");\n        }\n\n        require(inputLength % r == 0, \"Number of field elements is not divisible by r.\");\n\n        uint256[] memory state = new uint256[](m);\n        for (uint256 i = 0; i \u003c m; i++) {\n            state[i] = 0; // fieldZero.\n        }\n\n        uint256[] memory auxData = LoadAuxdata();\n        uint256 n_columns = inputLength / r;\n        for (uint256 i = 0; i \u003c n_columns; i++) {\n            for (uint256 j = 0; j \u003c r; j++) {\n                state[j] = addmod(state[j], inputs[i * r + j], prime);\n            }\n            state = permutation_func(auxData, state);\n        }\n\n        require(outputSize \u003c= r, \"No support for more than r output elements.\");\n        outputElements = new uint256[](outputSize);\n        for (uint256 i = 0; i \u003c outputSize; i++) {\n            outputElements[i] = state[i];\n        }\n    }\n\n    function getParameters()\n        public view\n        returns (uint256[] memory status)\n    {\n        status = new uint256[](4);\n        status[0] = prime;\n        status[1] = r;\n        status[2] = c;\n        status[3] = nRounds;\n    }\n}\n"},"STARK_Friendly_Hash_Challenge_Rescue_S256a.sol":{"content":"/*\n    This smart contract was written by StarkWare Industries Ltd. as part of the STARK-friendly hash\n    challenge effort, funded by the Ethereum Foundation.\n    The contract will pay out 8 ETH to the first finder of a collision in Rescue with rate 4\n    and capacity 4 at security level of 256 bits, if such a collision is discovered before the end\n    of March 2020.\n    More information about the STARK-friendly hash challenge can be found\n    here https://starkware.co/hash-challenge/.\n    More information about the STARK-friendly hash selection process (of which this challenge is a\n    part) can be found here\n    https://medium.com/starkware/stark-friendly-hash-tire-kicking-8087e8d9a246.\n    Sage code reference implementation for the contender hash functions available\n    at https://starkware.co/hash-challenge-implementation-reference-code/.\n*/\n\n/*\n  Copyright 2019 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n\npragma solidity ^0.5.2;\n\nimport \"./Base.sol\";\nimport \"./Sponge.sol\";\n\n\ncontract STARK_Friendly_Hash_Challenge_Rescue_S256a is Base, Sponge {\n    uint256 MAX_CONSTANTS_PER_CONTRACT = 768;\n\n    address roundConstantsContract;\n    address mdsContract;\n    uint256 inv3;\n\n    constructor (\n        uint256 prime,  uint256 r,  uint256 c, uint256 nRounds,\n        uint256 inv3_, address roundConstantsContract_, address mdsContract_)\n        public payable\n        Sponge(prime, r, c, nRounds)\n    {\n        inv3 = inv3_;\n        roundConstantsContract = roundConstantsContract_;\n        mdsContract = mdsContract_;\n    }\n\n    function LoadAuxdata()\n    internal view\n    returns (uint256[] memory auxData)\n    {\n        uint256 round_constants = m * (2 * nRounds + 1);\n        require (\n            round_constants \u003c= MAX_CONSTANTS_PER_CONTRACT,\n            \"The code supports up to one roundConstantsContracts.\" );\n\n        uint256 mdsSize = m * m;\n        auxData = new uint256[](round_constants + mdsSize);\n\n        address roundsContractAddr = roundConstantsContract;\n        address mdsContractAddr = mdsContract;\n\n        assembly {\n            let offset := add(auxData, 0x20)\n            let roundConstantsLength := mul(round_constants, 0x20)\n            extcodecopy(roundsContractAddr, offset, 0, roundConstantsLength)\n            offset := add(offset, roundConstantsLength)\n            extcodecopy(mdsContractAddr, offset, 0, mul(mdsSize, 0x20))\n        }\n    }\n\n\n    function permutation_func(uint256[] memory auxData, uint256[] memory elements)\n        internal view\n        returns (uint256[] memory)\n    {\n        uint256 length = elements.length;\n        require(length == m, \"elements length is not equal to m.\");\n\n        uint256 prime_ = prime;\n        uint256[] memory workingArea = new uint256[](length);\n        for (uint256 i = 0; i \u003c length; i++) {\n            elements[i] = addmod(elements[i], auxData[i], prime_);\n        }\n\n        uint256 nRounds2 = nRounds * 2;\n        uint256 inv3_ = inv3;\n        for (uint256 round = 0; round \u003c nRounds2; round++) {\n            for (uint256 i = 0; i \u003c m; i++) {\n                uint256 element = elements[i];\n                if (round % 2 != 0) {\n                    workingArea[i] = mulmod(mulmod(element, element, prime_), element, prime_);\n                }\n                else {\n                    assembly {\n                        function expmod(base, exponent, modulus) -\u003e res {\n                            let p := mload(0x40)\n                            mstore(p, 0x20)                 // Length of Base.\n                            mstore(add(p, 0x20), 0x20)      // Length of Exponent.\n                            mstore(add(p, 0x40), 0x20)      // Length of Modulus.\n                            mstore(add(p, 0x60), base)      // Base.\n                            mstore(add(p, 0x80), exponent)  // Exponent.\n                            mstore(add(p, 0xa0), modulus)   // Modulus.\n                            // Call modexp precompile.\n                            if iszero(staticcall(not(0), 0x05, p, 0xc0, p, 0x20)) {\n                                revert(0, 0)\n                            }\n                            res := mload(p)\n                        }\n                        let position := add(workingArea, mul(add(i, 1), 0x20))\n                        mstore(position, expmod(element, inv3_, prime_))\n                    }\n                }\n            }\n\n\n            // To get the offset of the MDS matrix we need to skip auxData.length\n            // and all the round constants.\n            uint256 mdsByteOffset = 0x20 * (1 + length * (nRounds2 + 1));\n\n            // MixLayer\n            // elements = params.mds * workingArea\n            assembly {\n                let mdsRowPtr := add(auxData, mdsByteOffset)\n                let stateSize := mul(length, 0x20)\n                let workingAreaPtr := add(workingArea, 0x20)\n                let statePtr := add(elements, 0x20)\n                let mdsEnd := add(mdsRowPtr, mul(length, stateSize))\n\n                for {} lt(mdsRowPtr, mdsEnd) { mdsRowPtr := add(mdsRowPtr, stateSize) } {\n                    let sum := 0\n                    for { let offset := 0} lt(offset, stateSize) { offset := add(offset, 0x20) } {\n                        sum := addmod(\n                            sum,\n                            mulmod(mload(add(mdsRowPtr, offset)),\n                                mload(add(workingAreaPtr, offset)),\n                                prime_),\n                            prime_)\n                    }\n\n                    mstore(statePtr, sum)\n                    statePtr := add(statePtr, 0x20)\n                }\n            }\n\n            for (uint256 i = 0; i \u003c length; i++) {\n                elements[i] = addmod(elements[i], auxData[length * (round + 1) + i], prime_);\n            }\n        }\n\n        return elements;\n    }\n}\n"}}