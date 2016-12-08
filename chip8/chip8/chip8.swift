//
//  chip8.swift
//  chip8
//
//  Created by Nicholas Trampe on 12/8/16.
//  Copyright © 2016 Off Kilter Studios. All rights reserved.
//

struct chip8 {
  
  // graphics memory (64 x 32 pixels)
  public var gfx = [UInt8](repeating: 0, count: 64 * 32)
  
  // keypad state
  public var key = [UInt8](repeating: 0, count: 16)
  
  // whether or not to draw
  public var drawFlag = false
  
  
  // current opcode
  private var opcode: UInt16 = 0
  
  // 4K of memory
  private var memory = [UInt8](repeating: 0, count: 4096)
  
  // 15 8-bit registers (V0 - VE) and a carry flag register
  private var V = [UInt8](repeating: 0, count: 16)
  
  // index register
  private var I: UInt16 = 0
  
  // program counter
  private var pc: UInt16 = 0x200
  
  // delay timer
  private var delay_timer: UInt8 = 0
  
  // sound timer
  private var sound_timer: UInt8 = 0
  
  // stack
  private var stack = [UInt16](repeating: 0, count: 16)
  
  // stack pointer
  private var sp: UInt16 = 0
  
  private let debugging = false
  
  // CHIP-8 fontset
  private let chip8_fontset: [UInt8] = [
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80  // F
  ]
  
}
