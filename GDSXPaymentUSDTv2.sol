// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * 💰 GDSXPaymentUSDT v2
 * ---------------------------------------------
 * ✅ ใช้สำหรับให้ผู้ใช้ซื้อเหรียญ GDSX ด้วย USDT (BEP-20)
 * ✅ ระบบจะโอน USDT จากผู้ใช้เข้าคลัง (treasury)
 * ✅ แล้วโอน GDSX กลับไปยังผู้ซื้อทันที
 * 
 * 🌟 ตัวอย่างการใช้งาน:
 * 1. ผู้ใช้ต้อง Approve USDT ก่อน
 *    USDT.approve(contractAddress, amount);
 * 
 * 2. เรียกฟังก์ชันซื้อ:
 *    buyGDSX(amount);
 * 
 * 🏦 Owner สามารถ:
 * - setRate()     → ตั้งอัตราแลกเปลี่ยน
 * - setTreasury() → เปลี่ยนที่อยู่คลังเก็บ USDT
 * 
 * 🔗 Contract Address:
 *    0x9E8f57E617c1520FD55A0B732C835EAC73a40F34
 * 
 * © 2025 GDSX Project | Gold Digital System X
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GDSXPaymentUSDTv2 is Ownable {
    IERC20 public immutable usdt;   // Token USDT (BEP-20)
    IERC20 public immutable gdsx;   // Token GDSX
    address public treasury;        // ที่อยู่คลังเก็บ USDT
    uint256 public rate;            // จำนวน GDSX ต่อ 1 USDT

    event Bought(address indexed buyer, uint256 usdtAmount, uint256 gdsxAmount);

    constructor(
        address _usdt,
        address _gdsx,
        address _treasury,
        uint256 _rate
    ) Ownable(msg.sender) {
        require(_usdt != address(0) && _gdsx != address(0) && _treasury != address(0), "Invalid address");
        usdt = IERC20(_usdt);
        gdsx = IERC20(_gdsx);
        treasury = _treasury;
        rate = _rate;
    }

    // 🧮 ตั้งอัตราแลกเปลี่ยน GDSX ต่อ 1 USDT
    function setRate(uint256 _rate) external onlyOwner {
        require(_rate > 0, "Invalid rate");
        rate = _rate;
    }

    // 🏦 เปลี่ยนที่อยู่คลังเก็บ USDT
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid address");
        treasury = _treasury;
    }

    // 💵 ฟังก์ชันซื้อ GDSX ด้วย USDT
    function buyGDSX(uint256 usdtAmount) external {
        require(usdtAmount > 0, "Amount must > 0");
        require(rate > 0, "Rate not set");

        uint256 gdsxAmount = usdtAmount * rate;

        // 1️⃣ ดึง USDT จากผู้ใช้ → เข้าคลัง
        require(usdt.transferFrom(msg.sender, treasury, usdtAmount), "USDT transfer failed");

        // 2️⃣ โอน GDSX กลับให้ผู้ใช้
        require(gdsx.transfer(msg.sender, gdsxAmount), "GDSX transfer failed");

        emit Bought(msg.sender, usdtAmount, gdsxAmount);
    }
}
