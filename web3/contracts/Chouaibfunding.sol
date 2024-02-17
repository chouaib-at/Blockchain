// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Chouaibfunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    event CampaignCreated(uint256 indexed id, address indexed owner, string title, uint256 deadline);

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        require(_deadline > block.timestamp, "The deadline should be a date in the future.");

        numberOfCampaigns++;
        Campaign storage newCampaign = campaigns[numberOfCampaigns];

        newCampaign.owner = _owner;
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.target = _target;
        newCampaign.deadline = _deadline;
        newCampaign.amountCollected = 0; // Initialize to zero
        newCampaign.image = _image;
        newCampaign.donators = new address[](0);
        newCampaign.donations = new uint256[](0);

        emit CampaignCreated(numberOfCampaigns, _owner, _title, _deadline);

        return numberOfCampaigns;
    }

    function donateToCampaign(uint256 _id) public payable {
        require(_id <= numberOfCampaigns, "Invalid campaign ID");

        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent, ) = payable(campaign.owner).call{value: amount}("");

        if (sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        require(_id <= numberOfCampaigns, "Invalid campaign ID");
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 1; i <= numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i - 1] = item;
        }
        return allCampaigns;
    }
}
