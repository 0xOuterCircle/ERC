struct Transaction {
    address to;
    uint value;
    bytes data;
}

struct Proposal {
    uint256 creation;
    uint256 expiration;
    uint256 delay;
    Transaction[] pipeline;
}