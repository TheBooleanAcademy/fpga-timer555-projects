
# 555 signal input
set_property -dict { PACKAGE_PIN N14  IOSTANDARD LVCMOS33 } [get_ports { sig_555 }];

# Clock (already in your XDC)
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { clk }];

# Reset button (centre pushbutton)
set_property -dict {PACKAGE_PIN M6 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {rst_btn}];

# UART Transmitter output (to PC)
set_property -dict { PACKAGE_PIN T12  IOSTANDARD LVCMOS33 } [get_ports { uart_txd }];
