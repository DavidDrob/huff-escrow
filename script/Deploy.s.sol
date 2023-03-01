// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

interface Escrow {
    function price() external view returns (uint256);

    function buyer() external view returns (address);

    function seller() external view returns (address);

    function paymentState() external view returns (bool);

    function deposit() external payable;
}

contract Deploy is Script {
    function run() public returns (Escrow escrow) {
        escrow = Escrow(
            HuffDeployer
                .config()
                .with_args(
                    bytes.concat(
                        abi.encode(address(0x32)),
                        abi.encode(address(0x3)),
                        abi.encode(address(0x2))
                    )
                )
                .deploy("Escrow")
        );

        // console.log(escrow.paymentState());

        escrow.deposit{value: uint256(0x32)}();

        // console.log(escrow.paymentState());

        return escrow;
    }
}
