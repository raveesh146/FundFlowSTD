// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
contract CrowdFunding {
        address public owner;
   

    Campaign[] public arr;    

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        mapping(address => uint256) donations;
        address[] contributors;
        bool goalReached;
        bool deadlineReached;
        uint256[] milestones;
        uint256 totalMilestoneAmount;
    }

    struct Request {
        bool completed;
        uint256 noOfVoters;
        address[] voters;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Request) public requests;
    uint256 public numberOfCampaigns = 0;
    uint256 public noOfContributors = 0;

    event CampaignCreated(uint256 indexed campaignId, address indexed owner);
    event DonationReceived(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event FundingGoalReached(uint256 indexed campaignId);
    event FundingDeadlineReached(uint256 indexed campaignId);
    event FundsWithdrawn(uint256 indexed campaignId, address indexed owner, uint256 amountRefunded);
    event RefundIssued(uint256 indexed campaignId, address indexed contributor, uint256 amountRefunded);
    event MilestoneAchieved(uint256 indexed campaignId, uint256 milestoneNumber, uint256 amountReleased);
    event RefundSent(address indexed contributor, uint256 amountRefunded);

   
    function refundContributors(uint256 _requestNo) public onlyOwner {
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "The request has been completed");
        require(thisRequest.noOfVoters <= noOfContributors / 2, "Majority supports the request");


        for (uint256 i = 0; i < thisRequest.noOfVoters; i++) {
            address contributor = thisRequest.voters[i];
            uint256 amountContributed = campaigns[numberOfCampaigns].donations[contributor];

            if (amountContributed > 0) {
                campaigns[numberOfCampaigns].donations[contributor] = 0;
                campaigns[numberOfCampaigns].amountCollected -= amountContributed;
                payable(contributor).transfer(amountContributed);
                emit RefundSent(contributor, amountContributed);
            }
        }
    }

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image,
        uint256[] memory _milestones
    ) external {
        require(_milestones.length > 0, "At least one milestone should be provided");

        numberOfCampaigns++;

        Campaign storage newCampaign = campaigns[numberOfCampaigns];
        newCampaign.owner = msg.sender;
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.target = _target;
        newCampaign.deadline = block.timestamp + _deadline;
        newCampaign.amountCollected = 0;
        newCampaign.image = _image;
        newCampaign.goalReached = false;
        newCampaign.deadlineReached = false;
        newCampaign.milestones = _milestones;
        newCampaign.totalMilestoneAmount = 0;

        emit CampaignCreated(numberOfCampaigns, msg.sender);
    }

    function donateToCampaign(uint256 _id) external payable {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp < campaign.deadline, "Campaign deadline reached");
        require(!campaign.goalReached, "Campaign funding goal already reached");

        uint256 amount = msg.value;
        campaign.amountCollected += amount;
        campaign.donations[msg.sender] += amount;

        if (campaign.amountCollected >= campaign.target) {
            campaign.goalReached = true;
            emit FundingGoalReached(_id);
        }

        emit DonationReceived(_id, msg.sender, amount);
    }

    function getCampaignDetails(uint256 _id)
        external
        view
        returns (
            address owner,
            string memory title,
            string memory description,
            uint256 target,
            uint256 deadline,
            uint256 amountCollected,
            string memory image,
            bool goalReached,
            bool deadlineReached,
            uint256[] memory milestones,
            uint256 totalMilestoneAmount
        )
    {
        Campaign storage campaign = campaigns[_id];
        return (
            campaign.owner,
            campaign.title,
            campaign.description,
            campaign.target,
            campaign.deadline,
            campaign.amountCollected,
            campaign.image,
            campaign.goalReached,
            block.timestamp >= campaign.deadline,
            campaign.milestones,
            campaign.totalMilestoneAmount
        );
    }

    function withdrawFunds(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];

        require(msg.sender == campaign.owner, "Only the campaign owner can withdraw funds");
        require(campaign.goalReached, "Campaign funding goal not reached");
        require(!campaign.deadlineReached, "Campaign deadline reached");

        (bool success, ) = payable(msg.sender).call{value: campaign.totalMilestoneAmount}("");
        require(success, "Failed to withdraw funds");

        emit FundsWithdrawn(_id, msg.sender, campaign.totalMilestoneAmount);

        campaign.deadlineReached = true;
    }

    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp >= campaign.deadline, "Campaign deadline not reached");
        require(!campaign.goalReached, "Campaign funding goal reached");
        require(campaign.donations[msg.sender] > 0, "No donation to refund");

        uint256 amountToRefund = (campaign.donations[msg.sender] * campaign.amountCollected) / campaign.target;
        campaign.donations[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amountToRefund}("");
        require(success, "Failed to refund");

        emit RefundIssued(_id, msg.sender, amountToRefund);
    }

    function checkMilestone(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp >= campaign.deadline, "Campaign deadline not reached");
        require(!campaign.deadlineReached, "Campaign deadline already reached");

        for (uint256 i = 0; i < campaign.milestones.length; i++) {
             if (campaign.amountCollected >= campaign.milestones[i] && campaign.milestones[i] > campaign.totalMilestoneAmount) {
                uint256 milestoneAmount = (campaign.milestones[i] - campaign.totalMilestoneAmount) * 10 / 100;
                campaign.totalMilestoneAmount += milestoneAmount;

                // Send funds to the campaign owner
                (bool success, ) = payable(campaign.owner).call{value: milestoneAmount}("");
                require(success, "Failed to release milestone funds");

                emit MilestoneAchieved(_id, i + 1, milestoneAmount);
            }
        }
    }

   function get_data (uint256 i) view internal returns(Campaign storage) {
     return arr[i];
   }

}