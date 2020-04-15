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
add wave -noupdate /tb/u_target/wait_n_s
add wave -noupdate /tb/u_target/port_en_s
add wave -noupdate /tb/u_target/edge_det_s
add wave -noupdate /tb/u_target/last_wr_n_q
add wave -noupdate /tb/u_target/last_data_q
add wave -noupdate -radix unsigned /tb/u_target/counter_s
add wave -noupdate -radix hexadecimal /tb/u_target/shift_r
add wave -noupdate -radix hexadecimal /tb/u_target/port_r
add wave -noupdate /tb/u_target/sck_delayed_s
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
WaveRestoreZoom {5699 ns} {15139 ns}
