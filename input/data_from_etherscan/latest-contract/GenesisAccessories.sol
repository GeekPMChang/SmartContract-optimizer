// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GenesisAccessories {
    function G_Accessory(uint32 traitId_) public pure returns (string[2] memory) {
        if (traitId_ == 0) return  ["AirPods","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEz////m5uYK7NwXAAAAAXRSTlMAQObYZgAAABhJREFUGNNjYBiSIADOmgBnCWBhKQyE4wCkNAEhlnrVygAAAABJRU5ErkJggg=="];
        if (traitId_ == 1) return  ["Green Bowtie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAD1BMVEVHcEwAAAA6cAQzWQ4wUQ2e5K2CAAAAAXRSTlMAQObYZgAAADRJREFUKM9jYBgFIxoICsIIKGA0UhIQZFRSEkAWUVQSRhFxVjI0EjZGFnExBupyNhbAYjIA5tIEtNE6oYsAAAAASUVORK5CYII="];
        if (traitId_ == 2) return  ["E-Cigarette","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAADFBMVEVHcEwAAACHh4cJ7vrpD+S7AAAAAXRSTlMAQObYZgAAABZJREFUGNNjYBiRQDQExspaiylGIQAAnooB6pbELDkAAAAASUVORK5CYII="];
        if (traitId_ == 3) return  ["Gold Piercing","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEwAAAD/2QD4CUMoAAAAAXRSTlMAQObYZgAAABVJREFUGNNjYBiGwAHGYJyAKUZ7AAB+GgESfUKtNgAAAABJRU5ErkJggg=="];
        if (traitId_ == 4) return  ["Gold Chain","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAQMAAAAAiZmBAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAABlBMVEVHcEz/2QBxSM7qAAAAAXRSTlMAQObYZgAAAC9JREFUCNdjYBhQoIBECoBJDjDJAiaZIYoawKQDmDQAK+AA0gwMbAwHgCTjf5hhAFV2A1bLpJ9NAAAAAElFTkSuQmCC"];
        if (traitId_ == 5) return  ["Cigarette","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAElBMVEVHcEwAAADDw8PW1tajo6P/bwAeyX/rAAAAAXRSTlMAQObYZgAAACtJREFUKM9jYBgFeIACYREmDCUsxJjjQAVzGAUFBVDNETY2DmTAUDPAgQgApSkCPcydacIAAAAASUVORK5CYII="];
        if (traitId_ == 6) return  ["Silver Septum","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEz5+PO1tK0jOmuFAAAAAXRSTlMAQObYZgAAABdJREFUGNNjYBhOoKEBxnJwgLFE6e4KAM3uAZaekX6qAAAAAElFTkSuQmCC"];
        if (traitId_ == 7) return  ["Red Bowtie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAD1BMVEVHcEwAAACdGQV8IhRxHhKz65XXAAAAAXRSTlMAQObYZgAAADRJREFUKM9jYBgFIxoICsIIKGA0UhIQZFRSEkAWUVQSRhFxVjI0EjZGFnExBupyNhbAYjIA5tIEtNE6oYsAAAAASUVORK5CYII="];
        if (traitId_ == 8) return  ["Gold Earring","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAQMAAAAAiZmBAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAABlBMVEVHcEz/2QBxSM7qAAAAAXRSTlMAQObYZgAAABdJREFUCNdjYBhY0AAiGBUQJMMBss0CAGOUAYNrUiSGAAAAAElFTkSuQmCC"];
        if (traitId_ == 9) return  ["Silver Piercing","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEwAAADA+/YkUvCMAAAAAXRSTlMAQObYZgAAABVJREFUGNNjYBiGwAHGYJyAKUZ7AAB+GgESfUKtNgAAAABJRU5ErkJggg=="];
        if (traitId_ == 10) return ["Brown Tie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcExhNgUAAADMfGh4AAAAAXRSTlMAQObYZgAAABhJREFUGNNjYBgFpIFpcJYGphhTaAMDAwAkEgIsM6kSfQAAAABJRU5ErkJggg=="];
        if (traitId_ == 11) return ["Olive Tie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEwAAABJYQVlrBG1AAAAAXRSTlMAQObYZgAAABhJREFUGNNjYBgFpIFMOEsEU4xxlQMDAwAaUQHSopI+ogAAAABJRU5ErkJggg=="];
        if (traitId_ == 12) return ["Green Tie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEwFYVUAAAAeJzlNAAAAAXRSTlMAQObYZgAAABhJREFUGNNjYBgFpIFpcJYGphhTaAMDAwAkEgIsM6kSfQAAAABJRU5ErkJggg=="];
        if (traitId_ == 13) return ["Mole","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAQMAAAAAiZmBAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAABlBMVEVHcExDJA1iryrTAAAAAXRSTlMAQObYZgAAAA9JREFUCB1jGCRAgYFyAAAJTAAh7FQYRQAAAABJRU5ErkJggg=="];
        if (traitId_ == 14) return ["Red Tie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcExhBQoAAABynrp4AAAAAXRSTlMAQObYZgAAABhJREFUGNNjYBgFpIFpcJYGphhTaAMDAwAkEgIsM6kSfQAAAABJRU5ErkJggg=="];
        if (traitId_ == 15) return ["Hidden","iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII="];
        return ["",""];
    }
}