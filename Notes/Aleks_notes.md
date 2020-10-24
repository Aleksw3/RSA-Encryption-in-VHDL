
Exponentiation 
	inputs
		generic
			bit_width
		port
			Message
			Key
			clk
			rst_n




Control logic
	initialize/start process
		key_shift_reg<= key
		message_reg  <= message
		N			 <= N  // Modulus

	State diagram
		mux_select_low/high
			State 0:
				mux_select_low/high = 00
				dont count
			State 1:
				mux_select_low/high = 01
				count
			state 2:
				mux_select_low/high = 10
				dont count


	Multiplexers
		When output of mux selected and sent through
			MonPro_x_rdy = '1'
				One clock tick?


MonPro blocks:
	MonPro_C
	MonPro_S