// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PLDGVoting {
    struct Proposal {
        string description;
        uint256 voteCount;
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    mapping(address => uint256) public tokenBalance;

    address public owner;

    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter, uint256 weight);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string memory description) public onlyOwner {
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.description = description;
        proposalCount++;

        emit ProposalCreated(proposalCount - 1, description);
    }

    function vote(uint256 proposalId) public {
        require(proposalId < proposalCount, "Proposal does not exist");
        Proposal storage proposal = proposals[proposalId];

        require(!proposal.voted[msg.sender], "Already voted on this proposal");
        require(tokenBalance[msg.sender] > 0, "No tokens to vote with");

        proposal.voteCount += tokenBalance[msg.sender];
        proposal.voted[msg.sender] = true;

        emit Voted(proposalId, msg.sender, tokenBalance[msg.sender]);
    }

    function distributeTokens(address[] memory recipients, uint256[] memory amounts) public onlyOwner {
        require(recipients.length == amounts.length, "Arrays must be of equal length");

        for (uint256 i = 0; i < recipients.length; i++) {
            tokenBalance[recipients[i]] += amounts[i];
        }
    }

    function getProposal(uint256 proposalId) public view returns (string memory description, uint256 voteCount) {
        require(proposalId < proposalCount, "Proposal does not exist");
        Proposal storage proposal = proposals[proposalId];
        return (proposal.description, proposal.voteCount);
    }
}
