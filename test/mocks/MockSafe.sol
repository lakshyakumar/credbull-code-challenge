// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.0;

/**
 * @title MockSafe
 * @dev A mock contract to simulate a safe that can execute transactions based on authorization.
 */
contract MockSafe {
    // Address of the authorized module
    address public module;

    // Custom error for unauthorized access
    error NotAuthorized(address unacceptedAddress);

    // Fallback function to accept incoming Ether
    receive() external payable {}

    /**
     * @notice Enables a module to perform transactions.
     * @dev Only the owner can set the authorized module address.
     * @param _module The address of the module to be authorized.
     */
    function enableModule(address _module) external {
        // Set the authorized module address
        module = _module;
    }

    /**
     * @notice Executes a transaction to a specified address with a given value and data.
     * @param to The target address of the transaction.
     * @param value The value (in Wei) to be sent with the transaction.
     * @param data The data payload for the transaction.
     */
    function exec(
        address payable to,
        uint256 value,
        bytes calldata data
    ) external {
        // Execute the transaction and handle any revert with assembly
        bool success;
        bytes memory response;
        (success, response) = to.call{value: value}(data);
        if (!success) {
            assembly {
                revert(add(response, 0x20), mload(response))
            }
        }
    }

    /**
     * @notice Executes a transaction from the authorized module.
     * @dev Only the authorized module can call this function.
     * @param to The target address of the transaction.
     * @param value The value (in Wei) to be sent with the transaction.
     * @param data The data payload for the transaction.
     * @param operation The type of operation (1 for delegatecall, 0 for call).
     * @return success A boolean indicating whether the transaction was successful.
     */
    function execTransactionFromModule(
        address payable to,
        uint256 value,
        bytes calldata data,
        uint8 operation
    ) external returns (bool success) {
        // Check if the caller is the authorized module
        if (msg.sender != module) {
            revert NotAuthorized(msg.sender);
        }

        // Execute the transaction based on the specified operation
        if (operation == 1) {
            (success, ) = to.delegatecall(data);
        } else {
            (success, ) = to.call{value: value}(data);
        }
    }
}
