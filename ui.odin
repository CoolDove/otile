package main

import "core:strings"
import "core:math"

import hla "collections/hollow_array"

@(private="file")
_elems : hla.HollowArray(UIElem)

UIElem :: struct {
	id : u64,
	w,h : int,
}

box :: proc(x, y, w, h: int) {
	// 角
	put(x, y, 218)                 // ┌
	put(x + w - 1, y, 191)         // ┐
	put(x, y + h - 1, 192)         // └
	put(x + w - 1, y + h - 1, 217) // ┘

	// 上下边
	for i in 1 ..< w-1 {
		put(x + i, y, 196)         // ─ top
		put(x + i, y + h - 1, 196) // ─ bottom
	}

	// 左右边
	for j in 1 ..< h-1 {
		put(x, y + j, 179)         // │ left
		put(x + w - 1, y + j, 179) // │ right
	}

	// 填充区域（sprid=0 为空）
	for i in 1 ..< w-1 {
		for j in 1 ..< h-1 {
			put(x + i, y + j, 0)
		}
	}
}

uilistv :: proc(title: string, h,w: int) {
}

uibutton :: proc(label: string, h,w: int) {
}

msgbox :: proc(x,y: int, msg: string) {
	box(x,y, math.max(len(msg)+2, 5), 3)
	put_str(x+1,y, "MSG")
	put_str(x+1,y+1, msg)
}
