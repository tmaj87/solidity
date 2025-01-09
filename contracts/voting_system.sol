// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
 
contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
    }
 
    struct Vote {
        bool voted;
        bool vote;
    }
 
    Proposal[] public proposals;
    mapping(address => mapping(uint => Vote)) voters;
    mapping(address => bool) allowed;
 
    constructor(address[] memory _addresses) {
        for (uint i=0; i < _addresses.length; i++) {
            allowed[_addresses[i]] = true;
        }
        allowed[msg.sender] = true;
    }
 
    function newProposal(address _target, bytes memory _data) external {
        require(allowed[msg.sender]);
        proposals.push(Proposal(_target, _data, 0, 0));
        emit ProposalCreated(proposals.length -1);
    }
 
    function castVote(uint id, bool vote) external {
        require(allowed[msg.sender]);
        if (!voters[msg.sender][id].voted) {
            voters[msg.sender][id].vote = vote;
            voters[msg.sender][id].voted = true;
            vote ?
                proposals[id].yesCount += 1
                : proposals[id].noCount += 1;  
        } else if (voters[msg.sender][id].vote != vote) {
            if (vote) {
                proposals[id].yesCount += 1;
                proposals[id].noCount -= 1;
            } else {
                proposals[id].yesCount -= 1;
                proposals[id].noCount += 1;
            }
            voters[msg.sender][id].vote = vote;
        }
        emit VoteCast(id, msg.sender);
        if (proposals[id].yesCount >= 10) {
            proposals[id].target.call(proposals[id].data);
        }
    }
 
    event ProposalCreated(uint _id);
 
    event VoteCast(uint _id, address _voter);
}