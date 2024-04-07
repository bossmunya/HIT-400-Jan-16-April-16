// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract RealEstate {
    // Struct to represent a property
    struct Property {
        uint256 id;
        uint256 price;
        address payable current_owner;
        bool forSale;
        string propertyTitle;
        string description;
        string location;
        uint256 purchaseDate;
        address[] previousOwners;
        string[] images;
    }

    // Mapping to store properties by their ID
    mapping(uint256 => Property) public properties;

    // Array to store all property IDs
    uint256[] public propertyIds;

    // Events to emit when property is listed, purchased, and ownership is transferred
    event PropertyListed(uint256 indexed propertyId, uint256 price, string propertyTitle, string location, address indexed current_owner);
    event PropertyPurchased(uint256 indexed propertyId, address buyer);
    event OwnershipTransferred(uint256 indexed propertyId, address indexed previousOwner, address indexed newOwner);

    // Function to list a property for sale
    function listPropertyForSale(
        uint256 _propertyId,
        uint256 _price,
        string memory _propertyTitle,
        string memory _description,
        string memory _location,
        string[] memory _images,
        address payable _current_owner
    ) public {
        Property memory newProperty = Property({
            id: _propertyId,
            price: _price,
            current_owner: _current_owner,
            forSale: true,
            propertyTitle: _propertyTitle,
            description: _description,
            location: _location,
            purchaseDate: block.timestamp,
            previousOwners: new address[](0),
            images: _images
        });
        properties[_propertyId] = newProperty;
        propertyIds.push(_propertyId);
        emit PropertyListed(_propertyId, _price, _propertyTitle, _location, _current_owner);
    }

    // Function for a buyer to purchase a property
    function buyProperty(uint256 _propertyId) public payable {
        Property storage property = properties[_propertyId];
        require(property.forSale, "Property is not for sale");
        require(property.price <= msg.value, "Insufficient funds");

        // Transfer ownership
        address payable previousOwner = property.current_owner;
        property.current_owner = payable(msg.sender);
        property.forSale = false;

        // Emit events
        emit PropertyPurchased(_propertyId, msg.sender);
        emit OwnershipTransferred(_propertyId, previousOwner, msg.sender);

        // Transfer funds to seller
        previousOwner.transfer(msg.value);
    }

    // Function to transfer ownership of a property
    function transferOwnership(uint256 _propertyId, address _newOwner) public {
        Property storage property = properties[_propertyId];
        require(property.current_owner == msg.sender, "You are not the owner of this property");

        // Transfer ownership
        address previousOwner = property.current_owner;
        property.current_owner = payable(_newOwner);
        property.previousOwners.push(previousOwner);

        // Emit event
        emit OwnershipTransferred(_propertyId, previousOwner, _newOwner);
    }

    // Function to retrieve all properties owned by a specific address
    function getPropertiesByOwner(address _owner) public view returns (uint256[] memory) {
        uint256[] memory ownedProperties = new uint256[](propertyIds.length);
        uint256 ownedPropertiesIndex = 0;

        for (uint256 i = 0; i < propertyIds.length; i++) {
            if (properties[propertyIds[i]].current_owner == _owner) {
                ownedProperties[ownedPropertiesIndex] = propertyIds[i];
                ownedPropertiesIndex++;
            }
        }

        return ownedProperties;
    }

    // Function to retrieve the history of ownership transfers for a specific property
    function getOwnershipHistory(uint256 _propertyId) public view returns (address[] memory) {
        return properties[_propertyId].previousOwners;
    }

    // Function to retrieve the images of a property
    function getPropertyImages(uint256 _propertyId) public view returns (string[] memory) {
        return properties[_propertyId].images;
    }
}
