# GeoToken

## Project Overview

**GeoToken** is a tokenized platform for secure, privacy-preserving real-time location sharing on the Stacks blockchain. The project aims to provide a decentralized solution for users to share their location data with trusted parties, while maintaining control over their personal information.

Key features of the GeoToken project include:

- Secure, privacy-preserving location sharing via Clarity smart contracts
- Token-based incentive system for location data sharing
- Granular permission controls for managing access to location data
- Basic SIP-010 token functionality for minting, burning, and balance tracking

The project consists of two main Clarity smart contracts:

1. **Location Sharing Contract**: Responsible for the secure and private sharing of location data between users.
2. **GeoToken Contract**: Handles the token-based incentive system and SIP-010 functionality.

## Contract Architecture

### Location Sharing Contract

The Location Sharing contract is responsible for managing the secure and private sharing of location data between users. It includes the following key components:

**Data Structures**:
- `location-data-map`: A map that stores the location data for each user, indexed by their Stacks principal.
- `permission-map`: A map that stores the permission settings for each user, controlling who can access their location data.

**Public Functions**:
- `share-location`: Allows a user to securely share their current location with a trusted party.
- `get-location`: Allows a trusted party to retrieve the location data of a user, subject to permission checks.
- `update-permissions`: Enables users to manage the permissions for who can access their location data.

The contract implements strict permission checks and data validation to ensure the privacy and security of the location data.

### GeoToken Contract

The GeoToken contract is responsible for the token-based incentive system and basic SIP-010 functionality. It includes the following key components:

**Data Structures**:
- `token-balances`: A map that stores the token balances for each principal.
- `token-supply`: The total supply of GeoTokens.

**Public Functions**:
- `mint-tokens`: Allows authorized principals to mint new GeoTokens.
- `burn-tokens`: Allows users to burn their own GeoTokens.
- `get-balance`: Retrieves the token balance for a given principal.
- `transfer`: Enables the transfer of GeoTokens between principals.

The contract ensures that token minting and burning operations are properly authorized and that the token supply is accurately tracked.

## Installation & Setup

To use the GeoToken contracts, you'll need to have Clarinet installed. Follow these steps to set up the project:

1. Clone the GeoToken repository:
   ```
   git clone https://github.com/your-username/geotoken.git
   ```
2. Navigate to the project directory:
   ```
   cd geotoken
   ```
3. Install the project dependencies:
   ```
   clarinet install
   ```

## Usage Guide

### Interacting with the Location Sharing Contract

1. Share your location:
   ```clarity
   (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.location-sharing share-location my-location)
   ```
2. Grant access to your location:
   ```clarity
   (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.location-sharing update-permissions trusted-principal true)
   ```
3. Retrieve a user's location:
   ```clarity
   (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.location-sharing get-location trusted-principal)
   ```

### Interacting with the GeoToken Contract

1. Mint new GeoTokens:
   ```clarity
   (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.geotoken mint-tokens my-principal 1000)
   ```
2. Transfer GeoTokens:
   ```clarity
   (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.geotoken transfer recipient-principal 100)
   ```
3. Burn GeoTokens:
   ```clarity
   (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.geotoken burn-tokens 50)
   ```

## Testing

The GeoToken project includes a comprehensive suite of tests to ensure the correct functionality of the contracts. You can run the tests using the following command:

```
clarinet test
```

The test suite covers the following scenarios:

- Successful location sharing and retrieval
- Permission management for location sharing
- Correct token minting, burning, and balance tracking
- Error handling for invalid inputs and unauthorized actions

## Security Considerations

The GeoToken project has been designed with security and privacy in mind. Some of the key security considerations include:

**Location Sharing Contract**:
- Strict permission checks to control access to location data
- Encrypted storage of location data to prevent unauthorized access
- Input validation to ensure only valid location data is accepted

**GeoToken Contract**:
- Proper authorization checks for token minting and burning operations
- Overflow and underflow protection for token balances
- Adherence to SIP-010 standards for token functionality

The project team has also conducted a thorough security audit to identify and address any potential vulnerabilities.
