package main

import "core:fmt"
import "core:c"
import "core:math"
import "core:strconv"
import win32 "core:sys/windows"
import rl "vendor:raylib"

CELL_SIZE	:: 24
PIXEL_SCALE :: 1
CELL_PIXEL	:: CELL_SIZE * PIXEL_SCALE
WIDTH		:: 32
HEIGHT		:: 26

ATLAS : rl.Texture2D
ATLAS_W :: 16
ATLAS_H :: 16

debug_draw_grid := false

current_atlas       : ^rl.Texture2D
current_transparent : int
current_color       : int
current_color_bg    : int

pallet: [16]rl.Color = {
	{0x00, 0x00, 0x00, 0xFF}, // 0: black
	{0x1D, 0x2B, 0x53, 0xFF}, // 1: dark blue
	{0x7E, 0x25, 0x53, 0xFF}, // 2: dark purple
	{0x00, 0x87, 0x51, 0xFF}, // 3: dark green
	{0xAB, 0x52, 0x36, 0xFF}, // 4: brown
	{0x5F, 0x57, 0x4F, 0xFF}, // 5: dark gray
	{0xC2, 0xC3, 0xC7, 0xFF}, // 6: light gray
	{0xFF, 0xF1, 0xE8, 0xFF}, // 7: white
	{0xFF, 0x00, 0x4D, 0xFF}, // 8: red
	{0xFF, 0xA3, 0x00, 0xFF}, // 9: orange
	{0xFF, 0xEC, 0x27, 0xFF}, // 10: yellow
	{0x00, 0xE4, 0x36, 0xFF}, // 11: green
	{0x29, 0xAD, 0xFF, 0xFF}, // 12: blue
	{0x83, 0x76, 0x9C, 0xFF}, // 13: indigo
	{0xFF, 0x77, 0xA8, 0xFF}, // 14: pink
	{0xFF, 0xCC, 0xAA, 0xFF}, // 15: peach
}

main :: proc() {
	rl.InitWindow(WIDTH*CELL_PIXEL, HEIGHT*CELL_PIXEL, "OTILE")
	ATLAS = rl.LoadTexture("./atlas.png")

	rl.SetTargetFPS(60)

	_clear_mem_page := 120
	init()
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({})
		if rl.IsKeyPressed(.F2) do debug_draw_grid = !debug_draw_grid

		if debug_draw_grid {// draw grid
			grid_color :rl.Color= { 0,42,0, 255 }
			btm :c.int= auto_cast(HEIGHT*CELL_SIZE*PIXEL_SCALE)
			rht :c.int= auto_cast(WIDTH*CELL_SIZE*PIXEL_SCALE)
			for w in 0..<WIDTH {
				x :c.int= auto_cast(w*CELL_SIZE*PIXEL_SCALE)
				rl.DrawLine(x,0, x, btm, grid_color)
			}
			for h in 0..<HEIGHT {
				y :c.int= auto_cast(h*CELL_SIZE*PIXEL_SCALE)
				rl.DrawLine(0,y, rht, y, grid_color)
			}
		}


		update()

		rl.EndDrawing()

		if _clear_mem_page > 0 {
			_clear_mem_page -= 1
			if _clear_mem_page == 0 {
				neg1 :i64= -1
				win32.SetProcessWorkingSetSizeEx(win32.GetCurrentProcess(),
					transmute(win32.SIZE_T)neg1, transmute(win32.SIZE_T)neg1, 0)
			}
		}
	}
	release()
	rl.UnloadTexture(ATLAS)

	rl.CloseWindow()
}

put_strf :: proc(x,y: int, str: string) {
	p := 0
	i := 0
	esc : bool
	estate :rune= 0
	evalue := 0

	skip := 0

	for b in str {
		if skip > 0 {
			skip -= 1
			i += 1
			continue
		}
		draw : bool
		if !esc {
			if b == '[' do esc = true
			else do draw = true
		} else {
			if b == '[' {
				esc = false
				draw = true
			} else if b == ']' {
				if estate == 'c' do color(evalue)
				else if estate == 'b' do colorbg(evalue)
				estate = 0
				evalue = 0
				esc = false
			} else {
				if estate == 0 {
					estate = b
				} else {
					left := str[i:]
					v, ok := strconv.parse_int(left, n=&skip)
					evalue = v
					if skip>0 do skip -= 1
				}
			}
		}
		if draw {
			put(x+p, y, cast(int)(b))
			p += 1
		}
		i += 1
	}
}
put_str :: proc(x,y: int, str: string) {
	i := 0
	for b in str {
		put(x+i, y, cast(int)(b))
		i += 1
	}
}
put :: proc(x,y: int, sprid: int) {
	ux := cast(c.int)(sprid % ATLAS_W)
	uy := cast(c.int)(sprid / ATLAS_W)
	if current_color_bg != current_transparent {
		rl.DrawRectangleV(
			{cast(f32)(x*CELL_PIXEL), cast(f32)(y*CELL_PIXEL)},
			{cast(f32)CELL_PIXEL, cast(f32)CELL_PIXEL},
			pallet[current_color_bg]
		);
	}
	rl.DrawTexturePro(current_atlas^,
		{cast(f32)ux*CELL_SIZE, cast(f32)uy*CELL_SIZE, cast(f32)CELL_SIZE, cast(f32)CELL_SIZE},
		{cast(f32)(x*CELL_PIXEL), cast(f32)(y*CELL_PIXEL), cast(f32)CELL_PIXEL, cast(f32)CELL_PIXEL},
		{0,0,}, 0,
		pallet[current_color]
	);
}

atlas :: #force_inline proc(atlas: ^rl.Texture2D) {
	current_atlas = atlas
}
transparentbg :: #force_inline proc(t: int) {
	current_transparent = t
}
colorbg :: #force_inline proc(c: int) {
	current_color_bg = c
}
color :: #force_inline proc(c: int) {
	current_color = c
}
