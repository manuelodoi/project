transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+W:/project {W:/project/dataPath.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/controlPath.v}
vlog -vlog01compat -work work +incdir+W:/project/vga_adapter {W:/project/vga_adapter/vga_pll.v}
vlog -vlog01compat -work work +incdir+W:/project/vga_adapter {W:/project/vga_adapter/vga_controller.v}
vlog -vlog01compat -work work +incdir+W:/project/vga_adapter {W:/project/vga_adapter/vga_address_translator.v}
vlog -vlog01compat -work work +incdir+W:/project/vga_adapter {W:/project/vga_adapter/vga_adapter.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/fill.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/gamescreen.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/pixelratedivider.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/aluAddress.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/startscreen.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/win.v}
vlog -vlog01compat -work work +incdir+W:/project {W:/project/lose.v}

