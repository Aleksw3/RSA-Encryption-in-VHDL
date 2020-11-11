# aclk {FREQ_HZ 100000000 CLK_DOMAIN bd_ae75_aclk PHASE 0.000}
# Clock Domain: bd_ae75_aclk
create_clock -name aclk -period 10,000 [get_ports aclk]
# Generated clocks
