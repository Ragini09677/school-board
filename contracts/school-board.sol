// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SchoolBoardDAO {
    address public chairperson;
    uint public proposalCount;
    uint public memberCount;

    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        bool executed;
        uint requiredVotes; // Number of votes required to execute the proposal
    }
    
    mapping(uint => Proposal) public proposals;
    mapping(address => bool) public members;
    mapping(uint => mapping(address => bool)) public votes;

    event MemberAdded(address member);
    event MemberRemoved(address member);
    event ProposalCreated(uint id, string description, uint requiredVotes);
    event Voted(address voter, uint proposalId);
    event ProposalExecuted(uint id, bool successful);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can execute this");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only members can vote");
        _;
    }

    modifier proposalExists(uint _proposalId) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID");
        _;
    }

    modifier notVoted(uint _proposalId) {
        require(!votes[_proposalId][msg.sender], "You have already voted");
        _;
    }

    modifier proposalNotExecuted(uint _proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        _;
    }

    constructor() {
        chairperson = msg.sender;
        memberCount = 0;
    }

    function addMember(address _member) external onlyChairperson {
        require(!members[_member], "Member already added");
        members[_member] = true;
        memberCount++;
        emit MemberAdded(_member);
    }

    function removeMember(address _member) external onlyChairperson {
        require(members[_member], "Member not found");
        members[_member] = false;
        memberCount--;
        emit MemberRemoved(_member);
    }

    function createProposal(string calldata _description, uint _requiredVotes) external onlyChairperson {
        require(_requiredVotes > 0 && _requiredVotes <= memberCount, "Invalid number of required votes");
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _description, 0, false, _requiredVotes);
        emit ProposalCreated(proposalCount, _description, _requiredVotes);
    }

    function vote(uint _proposalId) external onlyMember proposalExists(_proposalId) notVoted(_proposalId) proposalNotExecuted(_proposalId) {
        votes[_proposalId][msg.sender] = true;
        proposals[_proposalId].voteCount++;
        emit Voted(msg.sender, _proposalId);
    }

    function executeProposal(uint _proposalId) external onlyChairperson proposalExists(_proposalId) proposalNotExecuted(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.voteCount >= proposal.requiredVotes, "Not enough votes to execute");

        proposal.executed = true;

        // Example action: could be anything from transferring funds to changing contract state
        // Perform the actual proposal execution logic here

        emit ProposalExecuted(_proposalId, true);
    }
}


