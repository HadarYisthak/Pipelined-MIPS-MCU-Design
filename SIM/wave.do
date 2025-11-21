onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mips_tb/rst_tb_i
add wave -noupdate /mips_tb/clk_tb_i
add wave -noupdate -radix hexadecimal /mips_tb/BPADDR_tb_i
add wave -noupdate -radix hexadecimal /mips_tb/IFpc_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/IDpc_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/EXpc_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/MEMpc_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/WBpc_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/IFinstruction_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/IDinstruction_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/EXinstruction_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/MEMinstruction_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/WBinstruction_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/INSTCNT_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/CLKCNT_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/STCNT_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/FHCNT_tb_o
add wave -noupdate /mips_tb/STRIGERR_tb_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {1331200 ps} {2355200 ps}
