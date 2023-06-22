pragma solidity >= 0.7.0 < 0.9.0;

contract Voting {
    uint private Id = 0;
    address public owner;
    address public winner;
    mapping(address => bool) voterDetails;
    mapping(address => bool) candDetails;
    mapping(address => uint) candFeeDetails;
    address[] public participants;
    uint[] public votesCount;

    event CandRegistered(address Id);
    event ElectionWinner(address winner, uint votes);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function votingForCandidates(uint candId) payable public returns(bool) {
        require(!voterDetails[msg.sender], "Already voted!");

        votesCount[candId] += 1;
        voterDetails[msg.sender] = true;

        return true;
    }

    function registerForCandidature() payable public returns(bool) {
        require(!candDetails[msg.sender], "Already registered!");

        Id += 1;
        candDetails[msg.sender] = true;
        participants.push(msg.sender);
        votesCount.push(0);

        emit CandRegistered(msg.sender);
        return true;
    }

    function getAllParticipants() public view returns (address[] memory) {
        return participants;
    }

    function getVotesCount() public view returns (uint[] memory) {
        return votesCount;
    }

    function declareWinner() public onlyOwner returns(uint candidateId, uint votes) {
        uint highestVotes = 0;
        uint candId;

        for (uint i = 0; i < votesCount.length; i++) {
            if (votesCount[i] > highestVotes) {
                highestVotes = votesCount[i];
                candId = i;
            }
        }

        winner = participants[candId];

        emit ElectionWinner(winner, votes);

        return (candId, highestVotes);
    }

}
