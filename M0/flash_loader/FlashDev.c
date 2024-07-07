/***********************************************************************/
/*  This file is part of the ARM Toolchain package                     */
/*  Copyright (c) 2010 Keil - An ARM Company. All rights reserved.     */
/***********************************************************************/
/*                                                                     */
/*  FlashDev.C:  Device Description for New Device Flash               */
/*                                                                     */
/***********************************************************************/

#include "..\FlashOS.H"        // FlashOS Structures


struct FlashDevice const FlashDevice  =  {
   FLASH_DRV_VERS,             // Driver Version, do not modify!
   "FPGA 64KB PGM",        // Device Name 
   ONCHIP,                     // Device Type
   0x00000000,                 // Device Start Address
   0x00010000,                 // Device Size in Bytes (64kB)
   1024,                       // Programming Page Size (1kB)
   0,                          // Reserved, must be 0
   0xFF,                       // Initial Content of Erased Memory
   1,                          // Program Page Timeout 1 mSec
   1,                          // Erase Sector Timeout 1 mSec

// Specify Size and Address of Sectors
   0x00001000, 0x00000000,     // Sector Size  4kB , Address 0x00000000 . (Total 16 Sectors)
   SECTOR_END
};
