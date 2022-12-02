// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./interfaces/IOuterCircleApp.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract OuterCircleApp is ERC165, IOuterCircleApp {
    bytes32 public appId;

    event NewOuterCircleApp(address indexed appAddress, string name, string description);
    event AppUserFunctions(address indexed appAddress, uint8 numberOfUserFunctions, string[]);

    constructor(string memory name, string memory description) {
        // uint8 numberOfUserFunctions_ = 0; // change value to actual user functions number
        // string[] memory userFunctionsNames = new string[](numberOfUserFunctions_);
        // pass user functions names like below if there are any
        // userFunctionsNames[0] = "myFirstUserFunctionName"
        // userFunctionsNames[1] = "mySecondUserFunctionName"
        // ...

        emit NewOuterCircleApp(address(this), name, description);
        //emit AppUserFunctions(address(this), userFunctionsNames);
    }

    /**
     * @notice ERC165 interface support
     * @dev Need to identify OuterCircleApp
     * @param interfaceId unique id of the interface
     * @return Support or not
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (ERC165, IOuterCircleApp)
        returns (bool)
    {
        return interfaceId == type(IOuterCircleApp).interfaceId || super.supportsInterface(interfaceId);
    }
}
