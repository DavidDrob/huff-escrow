// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract EscrowTest is Test {
    /// @dev Address of the Escrow contract.
    Escrow public escrow;

    /// @dev Setup the testing environment.
    function setUp() public {
        escrow = Escrow(
            HuffDeployer
                .config()
                .with_args(
                    bytes.concat(
                        abi.encode(uint256(0x32)),
                        abi.encode(address(0x3)),
                        abi.encode(address(0x2))
                    )
                )
                .deploy("Escrow")
        );
    }

    /// @dev Ensure the buyer's and seller's addresses and the price is set correctly.
    function testSetAddressesAndPrice() public {
        assertEq(escrow.price(), uint256(0x32));
        assertEq(escrow.buyer(), address(0x3));
        assertEq(escrow.seller(), address(0x2));
    }

    /// @dev Check if paymentState is set correctly and if contract balance is as expected.
    function testDeposit() public payable {
        assertFalse(escrow.paymentState());

        escrow.deposit{value: uint256(0x32)}();

        // payment state
        assertTrue(escrow.paymentState());
        // balance
        assertEq(address(escrow).balance, uint256(0x32));
    }

    /// @dev Test if the delivery can be confirmed
    function testConfirmDelivery() public {
        assertFalse(escrow.deliveryState());

        escrow.confirmDelivery();

        assertTrue(escrow.deliveryState());
    }
}

interface Escrow {
    function price() external view returns (uint256);

    function buyer() external view returns (address);

    function seller() external view returns (address);

    function paymentState() external view returns (bool);

    function deliveryState() external view returns (bool);

    function deposit() external payable;

    function confirmDelivery() external payable;
}
