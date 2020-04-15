onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_n_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_s
add wave -noupdate /tb/cs_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate /tb/wait_n_s
add wave -noupdate /tb/spi_sclk_s
add wave -noupdate /tb/spi_miso_s
add wave -noupdate /tb/spi_mosi_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/state_s
add wave -noupdate -radix unsigned /tb/u_target/count_q
add wave -noupdate /tb/u_target/start_s
add wave -noupdate /tb/u_target/ff_clr_s
add wave -noupdate /tb/u_target/ff_q
add wave -noupdate /tb/u_target/prev_spi_clk_s
add wave -noupdate /tb/u_target/spi_clk_buf_s
add wave -noupdate /tb/u_target/spi_clk_out_s
add wave -noupdate -radix hexadecimal /tb/u_target/shift_reg_s
add wave -noupdate -radix hexadecimal /tb/u_target/spi_data_buf_s
add wave -noupdate -radix hexadecimal /tb/u_target/spi_data_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10258 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 41
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {18880 ns}
