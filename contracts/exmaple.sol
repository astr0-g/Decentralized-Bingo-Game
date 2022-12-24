contract exampleCode {
    struct storing {
        uint x;
    }

    mapping(uint => storing) public map;
    uint point = 0;

    function someFunction(uint _x) public {
        storing memory proof = storing({x: _x});
        map[point] = proof;
        point += 1;
    }
}
