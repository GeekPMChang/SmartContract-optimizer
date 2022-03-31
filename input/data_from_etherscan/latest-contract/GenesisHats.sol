// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GenesisHats {
    function G_Hats(uint32 traitId_) public pure returns (string[2] memory) {
        if (traitId_ == 0) return  ["Laurel Wreath","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAADFBMVEVHcExbqGFVlFpMf1DJ4Q/MAAAAAXRSTlMAQObYZgAAAEBJREFUGNNjYKAWYGFlYAwA0qyskioMTA5Alo6k6hIGhgNAlsXKuFSIqmehzg0Q1j/nCw4QFv+EDzBDnjAMAwAAzgkLGImTK3sAAAAASUVORK5CYII="];
        if (traitId_ == 1) return  ["Viking Helmet","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAElBMVEVHcEy5ubl7e3vd3bbHx57///+zOcN9AAAAAXRSTlMAQObYZgAAAIBJREFUGBntwcEJwzAMhtEPkwV+Qe+W6AAJ6gCBaIHuv0zt3Aw99tj3+OJkscO1Ay0GhtyhEsLl8oDMHbbMJplkisoCtisPySW5nq+ToTIP02CyYtoqD3/o/ZDbya1KrsnUubkUg1tEMDXJGFqHxtSkzsKlziLCO4sgOovO3499AP6VD5uBm5FwAAAAAElFTkSuQmCC"];
        if (traitId_ == 2) return  ["Brain","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAElBMVEVHcEykSovHa63te8zxidPYc7t5AAHpAAAAAXRSTlMAQObYZgAAAEZJREFUKM9jYKAuUHZ0VDRAERAyFDISdkAIMCsqCykJCSnDBRgFTQWFDJ0UHeEiisqiwkaGKobGAnAhJSBWYDZgGAVDDwAADWoF0V8fKskAAAAASUVORK5CYII="];
        if (traitId_ == 3) return  ["Banana Hat","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAADFBMVEVHcEwAAAD/2QDStxxaH+++AAAAAXRSTlMAQObYZgAAAFZJREFUGNNjYAACFgYYkIQxGMNCoSzxVasCIEJV61ctAbPYV8a/rASz5JawvooEs7IuMFTFOYBYVQ4MUu4gFuNLoAJHsNYnDAyyEEMuILOgFjswDCsAAGxNEXMpN3bEAAAAAElFTkSuQmCC"];
        if (traitId_ == 4) return  ["Headband","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEwAav////8bUkacAAAAAXRSTlMAQObYZgAAAB9JREFUGNNjYKASYAwNDXUAs7RWrVq1ACYUGsIw4gAAp28FsoyVMLgAAAAASUVORK5CYII="];
        if (traitId_ == 5) return  ["CK Cap","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAFVBMVEVHcEwAAAA/bP83Xt8dPqg1WMsWMIRjos2CAAAAAXRSTlMAQObYZgAAAGVJREFUKM/tjMERQEAUQ3c78GMV8NPByowGUIGhAPrvwYE1XJwdvFveJAnhBTOrHiKS9EcBTvgtawMAlFns1WWCxmKS2tUzeXViP3WsM4lylMZ5ZSMj/DBxGJZZaZKk09iN8PNpdoL8DPkTKLMPAAAAAElFTkSuQmCC"];
        if (traitId_ == 6) return  ["Top Hat","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEwAAAD///8W1S+BAAAAAXRSTlMAQObYZgAAADlJREFUGNNjYEAA1lAgCIGxUqfAWNNgYmGRMFZkKoyVOhXGmhbqGuoAYoVFAjU5QIwLhUg6MIwgAADkMxINv1J5ZwAAAABJRU5ErkJggg=="];
        if (traitId_ == 7) return  ["Headphones","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAElBMVEVHcEwAAAClpaWNjY12dXXX19chK4aGAAAAAXRSTlMAQObYZgAAAF9JREFUKM9jYCAaMAoKCgqgCAgpKSkpIosABQRQNQkJCqKZoohhLoaIkABBEWoZoxSIJiKsFIqqiNFZUBRVEaOjUSCGiCJhEWNFRXSThdAcLWJsjB5eLo7ojkYP0sEOAJ/zCbaMNbYVAAAAAElFTkSuQmCC"];
        if (traitId_ == 8) return  ["Hard Hat","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAFVBMVEVHcEwAAADagQT/lQDsiwP15M33oimbFkBGAAAAAXRSTlMAQObYZgAAAFtJREFUKM9jYMAFGAUFBVAEBIWNnAMFkQVUjI2MzVIRqhhdnI1VjI3NAuEiQk5gEWNjuCIhIBcsAlMkqAQHUAuFlFRcgMAZpMoQbC5cBVDCEeo4BBBgGAWDGQAAVYAPRcTic3MAAAAASUVORK5CYII="];
        if (traitId_ == 9) return  ["Straw Hat","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAHlBMVEVHcEwAAADUwij/AADAryKvoSWuBATQBweklymUBATMbxTWAAAAAXRSTlMAQObYZgAAAFBJREFUKM9jYMAFBAUFUfiMgkpKSoICSAIiTkARJUWEkGiIEhgowpW0ujhBhAQQpsIAVEQyLb3cGAwMYRYhgADUmFAXFxeEQcgqEKpGwSAFALvUDPUwnpqIAAAAAElFTkSuQmCC"];
        if (traitId_ == 10) return ["Head Mirror","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAAFVBMVEVHcEwAAADd9/TR8u1WVla+3tr///9eHjyQAAAAAXRSTlMAQObYZgAAAE5JREFUKM9jYCAJCAqiCTAqqQmgiggpqSWiKglWUkoTQBVRFFKCiTAKgkCwohJcRMQFCBxDjY2VBOHWgoBosLKiIKpBxsYChFw4CgYaAABTtwg7ucdTMAAAAABJRU5ErkJggg=="];
        if (traitId_ == 11) return ["Propeller Hat","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAALVBMVEVHcEwAAAAAkf//2QD/DQBV/wDwDwMDjPRJygjgvwYFhOPpxwXxzgbgEAQ+rwZcEysGAAAAAXRSTlMAQObYZgAAAF5JREFUKM9jYMAOGAXBAE0QmxoBJAHRYGMjJRVHhJBE6GSgiJJLIlxJa6SxsVGRkoubAFzJbGNj8yIlFZgixhcgEatyoLZcAahI5+w9Z6xWFSmlwUQEEUCAYRQMagAAs48U2l8cSMAAAAAASUVORK5CYII="];
        if (traitId_ == 12) return ["Green Beanie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAADFBMVEVHcEwTjw0AAAAQqwgqORpWAAAAAXRSTlMAQObYZgAAAEJJREFUGNNjYCAAmFatWgFhad4tv9cAZm0vv/v9AVjyfvn92hsgFnft9/u130As1VAQACnUvQsCIJbWKhBoYBgZAAB4lhthdWriogAAAABJRU5ErkJggg=="];
        if (traitId_ == 13) return ["Blue Bandana","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEwWbbUSYKFTZGqGAAAAAXRSTlMAQObYZgAAAD9JREFUGNNjYCAEtFatgDCYpoaGNYBZnKGhoQlgliqQFQGk2ZiWQlmcs1atmhq1CiQpAdS8AKwzAWYYF8MIAADVng0FSLV2IQAAAABJRU5ErkJggg=="];
        if (traitId_ == 14) return ["Grey Beanie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAADFBMVEVHcExqamp6enoAAACxT+7nAAAAAXRSTlMAQObYZgAAAEJJREFUGNNjYCAAmP///wNh2c5Mm30AzHqWNnPZBrDkrLRZmXNALL7MZbMyl4NYpqEgAFJoORMEQCz7/yBwgGFkAAC3uhrH08ZcGwAAAABJRU5ErkJggg=="];
        if (traitId_ == 15) return ["Green Bandana","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcExatRZPoRIpSJs4AAAAAXRSTlMAQObYZgAAAD9JREFUGNNjYCAEtFatgDCYpoaGNYBZnKGhoQlgliqQFQGk2ZiWQlmcs1atmhq1CiQpAdS8AKwzAWYYF8MIAADVng0FSLV2IQAAAABJRU5ErkJggg=="];
        if (traitId_ == 16) return ["Afro","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAQMAAAAAiZmBAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAABlBMVEVHcEwAAACfKoRRAAAAAXRSTlMAQObYZgAAAE5JREFUCNelxLEJg0AABdAHgVRHHMFNvNEuo2WUG+FKC/FbiEFImVc8aj5oGTySjSnZma9Dvd3O99LIaiHD63v3JF0hHbYOKxg/v2//7QC84C8qK5nK1gAAAABJRU5ErkJggg=="];
        if (traitId_ == 17) return ["Yellow Bandana","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEy1khahghKgbkuwAAAAAXRSTlMAQObYZgAAAD9JREFUGNNjYCAEtFatgDCYpoaGNYBZnKGhoQlgliqQFQGk2ZiWQlmcs1atmhq1CiQpAdS8AKwzAWYYF8MIAADVng0FSLV2IQAAAABJRU5ErkJggg=="];
        if (traitId_ == 18) return ["Flat Top","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAQMAAAAAiZmBAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAABlBMVEVHcEwAAACfKoRRAAAAAXRSTlMAQObYZgAAAD5JREFUCNdjYIAA9v8PgKQ8mLQHk/X/PwDJ/yCSEUb+YGBg/iO/A0g+YOYAajoA1gom+R8gSB4wyaHAQF8AALJMGImRZHbGAAAAAElFTkSuQmCC"];
        if (traitId_ == 19) return ["Purple Bandana","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAACVBMVEVHcEx1FrVnEqEcNXdjAAAAAXRSTlMAQObYZgAAAD9JREFUGNNjYCAEtFatgDCYpoaGNYBZnKGhoQlgliqQFQGk2ZiWQlmcs1atmhq1CiQpAdS8AKwzAWYYF8MIAADVng0FSLV2IQAAAABJRU5ErkJggg=="];
        if (traitId_ == 20) return ["Orange Beanie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAADFBMVEVHcEzVhRQAAAD/mgzh7PF3AAAAAXRSTlMAQObYZgAAAEJJREFUGNNjYCAAmFatWgFhad4tv9cAZm0vv/v9AVjyfvn92hsgFnft9/u130As1VAQACnUvQsCIJbWKhBoYBgZAAB4lhthdWriogAAAABJRU5ErkJggg=="];
        if (traitId_ == 21) return ["Blue Beanie","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAgMAAABHKeNRAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAADFBMVEVHcEwHT7UAAAAAWtlSfN4VAAAAAXRSTlMAQObYZgAAAEJJREFUGNNjYCAAmFatWgFhad4tv9cAZm0vv/v9AVjyfvn92hsgFnft9/u130As1VAQACnUvQsCIJbWKhBoYBgZAAB4lhthdWriogAAAABJRU5ErkJggg=="];
        if (traitId_ == 22) return ["Mohawk","iVBORw0KGgoAAAANSUhEUgAAACIAAAAiAQMAAAAAiZmBAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAAABlBMVEVHcEwAAACfKoRRAAAAAXRSTlMAQObYZgAAACFJREFUCNdjYIACZjDJDybrQQTjf7AwmGSQA5M8DIMaAADhJAK+ZSrrIAAAAABJRU5ErkJggg=="];
        if (traitId_ == 23) return ["Hidden","iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII="];
        return ["",""];
    }
}