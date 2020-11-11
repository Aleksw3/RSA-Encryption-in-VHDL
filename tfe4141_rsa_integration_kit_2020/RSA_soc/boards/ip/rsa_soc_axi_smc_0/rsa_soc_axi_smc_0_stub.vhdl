-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
-- Date        : Wed Nov 11 13:52:34 2020
-- Host        : aleksw running 64-bit Ubuntu 18.04.03 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/aleksw/NTNU/First_Year/DDS/Project/tfe4141_rsa_integration_kit_2020/RSA_soc/boards/ip/rsa_soc_axi_smc_0/rsa_soc_axi_smc_0_stub.vhdl
-- Design      : rsa_soc_axi_smc_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rsa_soc_axi_smc_0 is
  Port ( 
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    S00_AXI_awid : in STD_LOGIC;
    S00_AXI_awaddr : in STD_LOGIC;
    S00_AXI_awlen : in STD_LOGIC;
    S00_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_awlock : in STD_LOGIC;
    S00_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awuser : in STD_LOGIC;
    S00_AXI_awvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_awready : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_wid : in STD_LOGIC;
    S00_AXI_wdata : in STD_LOGIC;
    S00_AXI_wstrb : in STD_LOGIC;
    S00_AXI_wlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_wuser : in STD_LOGIC;
    S00_AXI_wvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_wready : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_bid : out STD_LOGIC;
    S00_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_buser : out STD_LOGIC;
    S00_AXI_bvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_bready : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_arid : in STD_LOGIC;
    S00_AXI_araddr : in STD_LOGIC;
    S00_AXI_arlen : in STD_LOGIC;
    S00_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_arlock : in STD_LOGIC;
    S00_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_aruser : in STD_LOGIC;
    S00_AXI_arvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_arready : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_rid : out STD_LOGIC;
    S00_AXI_rdata : out STD_LOGIC;
    S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_rlast : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_ruser : out STD_LOGIC;
    S00_AXI_rvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_rready : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_awid : in STD_LOGIC;
    S01_AXI_awaddr : in STD_LOGIC;
    S01_AXI_awlen : in STD_LOGIC;
    S01_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_awlock : in STD_LOGIC;
    S01_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awuser : in STD_LOGIC;
    S01_AXI_awvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_awready : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_wid : in STD_LOGIC;
    S01_AXI_wdata : in STD_LOGIC;
    S01_AXI_wstrb : in STD_LOGIC;
    S01_AXI_wlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_wuser : in STD_LOGIC;
    S01_AXI_wvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_wready : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_bid : out STD_LOGIC;
    S01_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_buser : out STD_LOGIC;
    S01_AXI_bvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_bready : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_arid : in STD_LOGIC;
    S01_AXI_araddr : in STD_LOGIC;
    S01_AXI_arlen : in STD_LOGIC;
    S01_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_arlock : in STD_LOGIC;
    S01_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_aruser : in STD_LOGIC;
    S01_AXI_arvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_arready : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_rid : out STD_LOGIC;
    S01_AXI_rdata : out STD_LOGIC;
    S01_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_rlast : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_ruser : out STD_LOGIC;
    S01_AXI_rvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_rready : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_awid : out STD_LOGIC;
    M00_AXI_awaddr : out STD_LOGIC;
    M00_AXI_awlen : out STD_LOGIC;
    M00_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_awlock : out STD_LOGIC;
    M00_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awuser : out STD_LOGIC;
    M00_AXI_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_wid : out STD_LOGIC;
    M00_AXI_wdata : out STD_LOGIC;
    M00_AXI_wstrb : out STD_LOGIC;
    M00_AXI_wlast : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_wuser : out STD_LOGIC;
    M00_AXI_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_bid : in STD_LOGIC;
    M00_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_buser : in STD_LOGIC;
    M00_AXI_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_arid : out STD_LOGIC;
    M00_AXI_araddr : out STD_LOGIC;
    M00_AXI_arlen : out STD_LOGIC;
    M00_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_arlock : out STD_LOGIC;
    M00_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_aruser : out STD_LOGIC;
    M00_AXI_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_rid : in STD_LOGIC;
    M00_AXI_rdata : in STD_LOGIC;
    M00_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_ruser : in STD_LOGIC;
    M00_AXI_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_rready : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end rsa_soc_axi_smc_0;

architecture stub of rsa_soc_axi_smc_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,aresetn,S00_AXI_awid,S00_AXI_awaddr,S00_AXI_awlen,S00_AXI_awsize[2:0],S00_AXI_awburst[1:0],S00_AXI_awlock,S00_AXI_awcache[3:0],S00_AXI_awprot[2:0],S00_AXI_awregion[3:0],S00_AXI_awqos[3:0],S00_AXI_awuser,S00_AXI_awvalid[0:0],S00_AXI_awready[0:0],S00_AXI_wid,S00_AXI_wdata,S00_AXI_wstrb,S00_AXI_wlast[0:0],S00_AXI_wuser,S00_AXI_wvalid[0:0],S00_AXI_wready[0:0],S00_AXI_bid,S00_AXI_bresp[1:0],S00_AXI_buser,S00_AXI_bvalid[0:0],S00_AXI_bready[0:0],S00_AXI_arid,S00_AXI_araddr,S00_AXI_arlen,S00_AXI_arsize[2:0],S00_AXI_arburst[1:0],S00_AXI_arlock,S00_AXI_arcache[3:0],S00_AXI_arprot[2:0],S00_AXI_arregion[3:0],S00_AXI_arqos[3:0],S00_AXI_aruser,S00_AXI_arvalid[0:0],S00_AXI_arready[0:0],S00_AXI_rid,S00_AXI_rdata,S00_AXI_rresp[1:0],S00_AXI_rlast[0:0],S00_AXI_ruser,S00_AXI_rvalid[0:0],S00_AXI_rready[0:0],S01_AXI_awid,S01_AXI_awaddr,S01_AXI_awlen,S01_AXI_awsize[2:0],S01_AXI_awburst[1:0],S01_AXI_awlock,S01_AXI_awcache[3:0],S01_AXI_awprot[2:0],S01_AXI_awregion[3:0],S01_AXI_awqos[3:0],S01_AXI_awuser,S01_AXI_awvalid[0:0],S01_AXI_awready[0:0],S01_AXI_wid,S01_AXI_wdata,S01_AXI_wstrb,S01_AXI_wlast[0:0],S01_AXI_wuser,S01_AXI_wvalid[0:0],S01_AXI_wready[0:0],S01_AXI_bid,S01_AXI_bresp[1:0],S01_AXI_buser,S01_AXI_bvalid[0:0],S01_AXI_bready[0:0],S01_AXI_arid,S01_AXI_araddr,S01_AXI_arlen,S01_AXI_arsize[2:0],S01_AXI_arburst[1:0],S01_AXI_arlock,S01_AXI_arcache[3:0],S01_AXI_arprot[2:0],S01_AXI_arregion[3:0],S01_AXI_arqos[3:0],S01_AXI_aruser,S01_AXI_arvalid[0:0],S01_AXI_arready[0:0],S01_AXI_rid,S01_AXI_rdata,S01_AXI_rresp[1:0],S01_AXI_rlast[0:0],S01_AXI_ruser,S01_AXI_rvalid[0:0],S01_AXI_rready[0:0],M00_AXI_awid,M00_AXI_awaddr,M00_AXI_awlen,M00_AXI_awsize[2:0],M00_AXI_awburst[1:0],M00_AXI_awlock,M00_AXI_awcache[3:0],M00_AXI_awprot[2:0],M00_AXI_awregion[3:0],M00_AXI_awqos[3:0],M00_AXI_awuser,M00_AXI_awvalid[0:0],M00_AXI_awready[0:0],M00_AXI_wid,M00_AXI_wdata,M00_AXI_wstrb,M00_AXI_wlast[0:0],M00_AXI_wuser,M00_AXI_wvalid[0:0],M00_AXI_wready[0:0],M00_AXI_bid,M00_AXI_bresp[1:0],M00_AXI_buser,M00_AXI_bvalid[0:0],M00_AXI_bready[0:0],M00_AXI_arid,M00_AXI_araddr,M00_AXI_arlen,M00_AXI_arsize[2:0],M00_AXI_arburst[1:0],M00_AXI_arlock,M00_AXI_arcache[3:0],M00_AXI_arprot[2:0],M00_AXI_arregion[3:0],M00_AXI_arqos[3:0],M00_AXI_aruser,M00_AXI_arvalid[0:0],M00_AXI_arready[0:0],M00_AXI_rid,M00_AXI_rdata,M00_AXI_rresp[1:0],M00_AXI_rlast[0:0],M00_AXI_ruser,M00_AXI_rvalid[0:0],M00_AXI_rready[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "bd_ae75,Vivado 2019.2";
begin
end;
