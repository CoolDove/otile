package main

import "core:math"
import rl "vendor:raylib"

GAME_SIZE :: 10

ground : [GAME_SIZE*GAME_SIZE]int
entities : [dynamic]Entity

Entity :: struct {
	position : [2]int,
	id       : int,
}

_debug_draw_atlas : bool

init :: proc() {
	// @TEMPORARY
	entities = make([dynamic]Entity, 0, 256)
	append(&entities, Entity{{}, 1})
	boy = &entities[0]
}
release :: proc() {
	delete(entities)
}

boy : ^Entity

update :: proc() {
	atlas(&ATLAS)
	if _debug_draw_atlas {
		for y in 0..<16 {
			for x in 0..<16 {
				col := (x+y)%16 
				color(col)
				if col == 0 do colorbg(7)
				else do colorbg(0)

				put(x,y, x+y*16)
			}
		}
	}
	if rl.IsKeyPressed(.F1) do _debug_draw_atlas = !_debug_draw_atlas

	if rl.IsKeyPressed(.H)      || rl.IsKeyPressedRepeat(.H) do boy.position.x -= 1
	else if rl.IsKeyPressed(.L) || rl.IsKeyPressedRepeat(.L) do boy.position.x += 1
	else if rl.IsKeyPressed(.J) || rl.IsKeyPressedRepeat(.J) do boy.position.y += 1
	else if rl.IsKeyPressed(.K) || rl.IsKeyPressedRepeat(.K) do boy.position.y -= 1
	boy.position.x = math.clamp(boy.position.x, 0, GAME_SIZE-1)
	boy.position.y = math.clamp(boy.position.y, 0, GAME_SIZE-1)

	transparentbg(0)
	color(5); colorbg(0)
	for x in 0..<GAME_SIZE {
		for y in 0..<GAME_SIZE {
			idx := x + y * GAME_SIZE
			g := ground[idx]
			if g == 0 do put(x,y, '.')
			else if g == 1 do put(x,y, '+')
		}
	}
	transparentbg(-1)
	for e in entities {
		if e.id == 1 {
			color(2); colorbg(0)
			put(e.position.x,e.position.y, '@')
		}
	}
	transparentbg(0)
	color(7); colorbg(0)
	put_strf(1,0, "Hello, [c8][b7]World[b0][c7]! PRINT TEST!")

	color(7); colorbg(8); transparentbg(-1)
	box(4,4, 12,8)
	put_strf(4+1,4, "Box!")
	colorbg(0)
	msgbox(6,20, "Hello, world!")
	colorbg(1)
	msgbox(8,16, "E")
}

Option :: struct {
	child : ^Option,
	next : ^Option,
}
