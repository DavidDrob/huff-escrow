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
    function testDeposit(uint256 _amount) public payable {
        assertFalse(escrow.paymentState());

        vm.assume(_amount >= escrow.price());
        vm.deal(address(this), 2**256 - 1);
        escrow.deposit{value: _amount}();

        // payment state
        assertTrue(escrow.paymentState());
        // balance
        assertEq(address(escrow).balance, _amount);
    }

    /// @dev Test if the delivery can be confirmed only by the buyer
    function testOnlyBuyerCanConfirm(address _badActor) public {
        assertFalse(escrow.deliveryState());

        vm.assume(_badActor != address(0x3));
        vm.startPrank(_badActor);
        vm.expectRevert();
        escrow.confirmDelivery();
        vm.stopPrank();

        vm.prank(address(0x3));
        escrow.confirmDelivery();

        assertTrue(escrow.deliveryState());
    }

    /// @dev Funds can we withdrawn by the seller
    function testWithdraw(uint256 _amount) public {
        uint256 balanceBefore = address(0x02).balance;

        vm.assume(_amount >= escrow.price());
        vm.deal(address(this), 2**256 - 1);
        escrow.deposit{value: _amount}();
        vm.prank(address(0x3));
        escrow.confirmDelivery();
        escrow.withdraw();

        assertGe(address(0x02).balance, balanceBefore + uint256(0x32));
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

    function withdraw() external returns (uint8);
}
