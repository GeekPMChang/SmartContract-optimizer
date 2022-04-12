{"ev5_vender.sol":{"content":"/**\n *Submitted for verification at Etherscan.io on 2019-09-23\n*/\npragma solidity \u003e=0.4.22 \u003c0.6.0;\nimport \u0027./safemath.sol\u0027;\n/**\n * @title -EV5.Win- v0.5.11\n * ╔═╗┌─┐┬ ┬┬─┐┌─┐┌─┐┌─┐  ┌─┐┌┐┌┌┬┐  ┬ ┬┬┌─┐┌┬┐┌─┐┌┬┐  ┌─┐┬─┐┌─┐  ┌┬┐┬ ┬┌─┐  ┌┐ ┌─┐┌─┐┌┬┐  ┬ ┬┌─┐┌─┐┬  ┌┬┐┬ ┬\n * ║  │ ││ │├┬┘├─┤│ ┬├┤   ├─┤│││ ││  ││││└─┐ │││ ││││  ├─┤├┬┘├┤    │ ├─┤├┤   ├┴┐├┤ └─┐ │   │││├┤ ├─┤│   │ ├─┤\n * ╚═╝└─┘└─┘┴└─┴ ┴└─┘└─┘  ┴ ┴┘└┘─┴┘  └┴┘┴└─┘─┴┘└─┘┴ ┴  ┴ ┴┴└─└─┘   ┴ ┴ ┴└─┘  └─┘└─┘└─┘ ┴   └┴┘└─┘┴ ┴┴─┘ ┴ ┴ ┴\n *\n * ==(\u0027-.==========(`-. ====================(`\\ .-\u0027) /`===============.-\u0027) _====================================\n * _(  OO)      _(OO  )_                  `.( OO ),\u0027              ( OO ) )\n * (,------. ,--(_/   ,. \\.------.      ,--./  .--.    ,-.-\u0027)  ,--./ ,--,\u0027\n *  |  .---\u0027 \\   \\   /(__/|   ___|      |      |  |    |  |OO) |   \\ |  |\\\n *  |  |      \\   \\ /   / |  \u0027--.       |  |   |  |,   |  |  \\ |    \\|  | )\n * (|  \u0027--.    \\   \u0027   /, `---.  \u0027.     |  |.\u0027.|  |_)  |  |(_/ |  .     |/\n *  |  .--\u0027     \\     /__).-   |  |     |         |   ,|  |_.\u0027 |  |\\    |\n *  |  `---.     \\   /    | `-\u0027   / .-. |   ,\u0027.   |  (_|  |    |  | \\   |          © Cargo Keep Team Inc. 2019\n *  `------\u0027      `-\u0027      `----\u0027\u0027  `-\u0027 \u0027--\u0027   \u0027--\u0027    `--\u0027    `--\u0027  `--\u0027\n * =============================================================================================================\n*/\ncontract Vendor {\n    uint ethWei = 1 ether;\n    uint public trustRo = 5;\n    uint public feeRo = 35;\n    uint public maxCoin = 30;\n    using SafeMath for *;\n    //getlv\n    function getLv(uint _value) external view returns(uint){\n        if(_value \u003e= 1*ethWei \u0026\u0026 _value \u003c= 5*ethWei){\n            return 1;\n        }if(_value \u003e= 6*ethWei \u0026\u0026 _value \u003c= 10*ethWei){\n            return 2;\n        }if(_value\u003e= 11*ethWei \u0026\u0026 _value \u003c= 15*ethWei){\n            return 3;\n        }if(_value \u003e= 16*ethWei \u0026\u0026 _value \u003c= 30*ethWei){\n            return 4;\n        }\n        return 0;\n    }\n    //getQueueLv\n    function getQueueLv(uint _value) external view returns(uint){\n        if(_value \u003e= 1*ethWei \u0026\u0026 _value \u003c= 5*ethWei){\n            return 1;\n        }if(_value \u003e= 6*ethWei \u0026\u0026 _value \u003c= 10*ethWei){\n            return 2;\n        }if(_value \u003e= 11*ethWei \u0026\u0026 _value \u003c= 15*ethWei){\n            return 3;\n        }if(_value \u003e= 16*ethWei \u0026\u0026 _value \u003c= 29*ethWei){\n            return 4;\n        }if(_value == 30*ethWei){\n            return 5;\n        }\n        return 0;\n    }\n\n    //level-bonus ratio/1000\n    function getBonusRo(uint _level) external pure returns(uint){\n        if(_level == 1){\n            return 5;\n        }if(_level == 2){\n            return 6;\n        }if(_level == 3){\n            return 10;\n        }if(_level ==4){\n            return 10;\n        }\n        return 0;\n    }\n\n    //level-fired ratio/10\n    function getFireRo(uint _linelevel) external pure returns(uint){\n        if(_linelevel == 1){\n            return 2;\n        }if(_linelevel == 2){\n            return 4;\n        }if(_linelevel == 3) {\n            return 6;\n        }if(_linelevel == 4){\n            return 5;\n        }\n        return 0;\n    }\n\n    //params:_level \u0026 _era =\u003e Invite Ratio/1000\n    function getReferRo(uint _linelevel,uint _era) external pure returns(uint){\n        if(_linelevel == 1 \u0026\u0026 _era == 1){\n            return 500;\n        }if(_linelevel == 2 \u0026\u0026 _era == 1){\n            return 500;\n        }if(_linelevel == 2 \u0026\u0026 _era == 2){\n            return 300;\n        }if(_linelevel == 3) {\n            if(_era == 1){\n                return 1000;\n            }if(_era == 2){\n                return 700;\n            }if(_era == 3){\n                return 500;\n            }if(_era \u003e= 4 \u0026\u0026 _era \u003c= 10){\n                return 80;\n            }if(_era \u003e= 11 \u0026\u0026 _era \u003c= 20){\n                return 30;\n            }if(_era \u003e= 21){\n                return 5;\n            }\n        }if(_linelevel == 4 || _linelevel == 5) {\n            if(_era == 1){\n                return 1200;\n            }if(_era == 2){\n                return 800;\n            }if(_era == 3){\n                return 600;\n            }if(_era \u003e= 4 \u0026\u0026 _era \u003c= 10){\n                return 100;\n            }if(_era \u003e= 11 \u0026\u0026 _era \u003c= 20){\n                return 50;\n            }if(_era \u003e= 21){\n                return 10;\n            }\n        }\n        return 0;\n    }\n\n    //params:_level \u0026 _era =\u003e Invite Ratio/10\n    function getReferProRo(uint _linelevel, uint _era) external pure returns(uint){\n        if(_linelevel == 5){\n            if(_era == 1){\n                return 1;\n            }if(_era == 2){\n                return 2;\n            }if(_era == 3){\n                return 4;\n            }if(_era \u003e= 4){\n                return 8;\n            }\n        }\n        return 0;\n    }\n\n    function caleReadyTime(uint _frozenCoin, uint8 _level) external pure returns(uint32){\n        uint addHour = 24;\n        if(_level == 1){\n            addHour = addHour.add(40);\n        } if(_level == 2){\n            addHour = addHour.add(30);\n        } if(_level == 3){\n            addHour = addHour.add(20);\n        } if(_level == 0){\n            addHour = addHour.add(24);\n        }\n\n        uint coin = _frozenCoin;\n        if(coin == 15 * 1 ether){\n            addHour = addHour.add(10);\n        } if(coin \u003e= 11 * 1 ether \u0026\u0026 coin \u003c 15 * 1 ether){\n            addHour = addHour.add(20);\n        } if(coin \u003e= 6 * 1 ether \u0026\u0026 coin \u003c 11 * 1 ether){\n            addHour = addHour.add(30);\n        } if(coin \u003e= 1 * 1 ether \u0026\u0026 coin \u003c 6 * 1 ether){\n            addHour = addHour.add(40);\n        }\n        return uint32(addHour * 1 hours);\n    }\n}\n"},"safemath.sol":{"content":"pragma solidity \u003e=0.4.22 \u003c0.6.0;\n\nlibrary SafeMath {\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) {\n            return 0;\n        }\n        uint256 c = a * b;\n        require(c / a == b);\n\n        return c;\n    }\n\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003e 0);\n        uint256 c = a / b;\n\n        return c;\n    }\n\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a);\n\n        return c;\n    }\n\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0);\n        return a % b;\n    }\n}\n"}}