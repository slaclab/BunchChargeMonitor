------------------------------------------------------------------------------
-- This file is part of 'LCLS2 LLRF Development'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 LLRF Development', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Version is

   constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"00000003";  -- MAKE_VERSION

   constant BUILD_STAMP_C : string := "AmcCarrierSsrlEth2x: Vivado v2016.2 (x86_64) Built Thu Sep  1 10:07:10 PDT 2016 by ulegat";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
--
-- 05/26/2016 (0x00000001): Initial Build
-- 07/28/2016 (0x00000002): Added RTM, RF switch, trig SW, and ADC Valids
-- 08/22/2016 (0x00000003): New waveform interface
-------------------------------------------------------------------------------

