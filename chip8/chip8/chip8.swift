//
//  chip8.swift
//  chip8
//
//  Created by Nicholas Trampe on 12/8/16.
//  Copyright © 2016 Off Kilter Studios. All rights reserved.
//

import Foundation

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
  
  init() {
    
    // load fontset
    for i in 0...chip8_fontset.count-1 {
      memory[i] = chip8_fontset[i]
    }
    
    // reset timers
    
    srand48(time(nil))
  }
  
  mutating func emulateCycle() {
    // fetch opcode
    
    let counter = Int(exactly: pc)!
    
    opcode = (UInt16(memory[counter]) << 8) | UInt16(memory[counter + 1])
    
    debugPrint(words: "opcode: \(getHEXString(number: opcode))")
    
    // decode and execute opcode
    // https://en.wikipedia.org/wiki/CHIP-8#Opcode_table
    
    switch opcode & 0xF000 {
      
    case 0x0000:
      
      switch opcode & 0x000F {
      case 0x0000: // 00E0	Clears the screen.
        debugPrint(words: "Clearing the screen")
        gfx = [UInt8](repeating: 0, count: 64 * 32)
        drawFlag = true
        pc += 2
        break
        
      case 0x000E: // 00EE	Returns from a subroutine.
        debugPrint(words: "Returning from subroutine")
        sp -= 1
        pc = stack[Int(sp)]
        pc += 2
        break
        
      default: // unknown
        print("Unknown opcode \(getHEXString(number: opcode))")
        break
      }
      
      break
      
    case 0x1000: // 1NNN	Jumps to address NNN.
      
      pc = opcode & 0x0FFF
      
      debugPrint(words: "Jumping to address \(getHEXString(number: pc))")
      
      break
      
    case 0x2000: // 2NNN	Calls subroutine at NNN.
      
      stack[Int(sp)] = pc
      sp += 1
      pc = opcode & 0x0FFF
      
      debugPrint(words: "Calling subroutine at \(getHEXString(number: pc))")
      
      break
      
    case 0x3000: // 3XNN	Skips the next instruction if VX equals NN.
      
      let X = Int((opcode & 0x0F00) >> 8)
      let NN = UInt8(opcode & 0x00FF)
      
      debugPrint(words: "Skipping next instruction if V[\(X)] == \(getHEXString(number: NN))")
      
      if V[X] == NN {
        pc += 4
      } else {
        pc += 2
      }
      
      break
      
    case 0x4000: // 4XNN	Skips the next instruction if VX doesn't equal NN.
      
      let X = Int((opcode & 0x0F00) >> 8)
      let NN = UInt8(opcode & 0x00FF)
      
      debugPrint(words: "Skipping next instruction if V[\(X)] != \(getHEXString(number: NN))")
      
      if V[X] != NN {
        pc += 4
      } else {
        pc += 2
      }
      
      break
      
    case 0x5000: // 5XY0	Skips the next instruction if VX equals VY.
      
      let X = Int((opcode & 0x0F00) >> 8)
      let Y = Int((opcode & 0x00F0) >> 4)
      
      debugPrint(words: "Skipping next instruction if V[\(X)] == V[\(Y)]")
      
      if V[X] == V[Y] {
        pc += 4
      } else {
        pc += 2
      }
      
      break
      
    case 0x6000: // 6XNN	Sets VX to NN.
      
      let X = Int((opcode & 0x0F00) >> 8)
      let NN = UInt8(opcode & 0x00FF)
      
      debugPrint(words: "Setting V[\(X)] = \(getHEXString(number: NN))")
      
      V[X] = NN
      
      pc += 2
      
      break
      
    case 0x7000: // 7XNN	Adds NN to VX.
      
      let X = Int((opcode & 0x0F00) >> 8)
      let NN = UInt8(opcode & 0x00FF)
      
      debugPrint(words: "Adding \(getHEXString(number: NN)) to V[\(X)]")
      
      V[X] = V[X] &+ NN
      
      pc += 2
      
      break
      
    case 0x8000:
      
      switch opcode & 0x000F {
        
      case 0x0000: // 8XY0	Sets VX to the value of VY.
        
        let X = Int((opcode & 0x0F00) >> 8)
        let Y = Int((opcode & 0x00F0) >> 4)
        
        debugPrint(words: "Setting V[\(X)] to V[\(Y)]")
        
        V[X] = V[Y]
        
        pc += 2
        
        break
        
      case 0x0001: // 8XY1	Sets VX to VX or VY.
        
        let X = Int((opcode & 0x0F00) >> 8)
        let Y = Int((opcode & 0x00F0) >> 4)
        
        debugPrint(words: "Setting V[\(X)] to V[\(X)] | V[\(Y)]")
        
        V[X] |= V[Y]
        
        pc += 2
        
        break
        
      case 0x0002: // 8XY2	Sets VX to VX and VY.
        
        let X = Int((opcode & 0x0F00) >> 8)
        let Y = Int((opcode & 0x00F0) >> 4)
        
        debugPrint(words: "Setting V[\(X)] to V[\(X)] & V[\(Y)]")
        
        V[X] &= V[Y]
        
        pc += 2
        
        break
        
      case 0x0003: // 8XY3	Sets VX to VX xor VY.
        
        let X = Int((opcode & 0x0F00) >> 8)
        let Y = Int((opcode & 0x00F0) >> 4)
        
        debugPrint(words: "Setting V[\(X)] to V[\(X)] ^ V[\(Y)]")
        
        V[X] ^= V[Y]
        
        pc += 2
        
        break
        
      case 0x0004: // 8XY4	Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
        
        let X = Int((opcode & 0x0F00) >> 8)
        let Y = Int((opcode & 0x00F0) >> 4)
        
        debugPrint(words: "Adding V[\(Y)] to V[\(X)]")
        
        if V[Y] > (0xFF - V[X]) {
          V[0xF] = 1
        } else {
          V[0xF] = 0
        }
        
        V[X] = V[X] &+ V[Y]
        
        pc += 2
        
        break
        
      case 0x0005: // 8XY5	VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
        
        let X = Int((opcode & 0x0F00) >> 8)
        let Y = Int((opcode & 0x00F0) >> 4)
        
        debugPrint(words: "Subtracting V[\(Y)] from V[\(X)]")
        
        if V[Y] > V[X] {
          V[0xF] = 0
        } else {
          V[0xF] = 1
        }
        
        V[X] = V[X] &- V[Y]
        
        pc += 2
        
        break
        
      case 0x0006: // 8XY6	Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        debugPrint(words: "Shifting V[\(X)] right by 1")
        
        V[0xF] = V[X] & 0x1
        
        V[X] >>= 1
        
        pc += 2
        
        break
        
      case 0x0007: // 8XY7	Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
        
        let X = Int((opcode & 0x0F00) >> 8)
        let Y = Int((opcode & 0x00F0) >> 4)
        
        debugPrint(words: "Setting V[\(X)] to V[\(Y)] minus V[\(X)]")
        
        if V[X] > V[Y] {
          V[0xF] = 0
        } else {
          V[0xF] = 1
        }
        
        V[X] = V[Y] &- V[X]
        
        pc += 2
        
        break
        
      case 0x000E: // 8XYE	Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        debugPrint(words: "Shifting V[\(X)] left by 1")
        
        V[0xF] = V[X] >> 7
        
        V[X] <<= 1
        
        pc += 2
        
        break
        
      default: // unknown
        print("Unknown opcode \(opcode)")
        break
      }
      
      break
      
    case 0x9000: // 9XY0	Skips the next instruction if VX doesn't equal VY.
      
      let X = Int((opcode & 0x0F00) >> 8)
      let Y = Int((opcode & 0x00F0) >> 4)
      
      debugPrint(words: "Skipping next instruction if V[\(X)] != V[\(Y)]")
      
      if V[X] != V[Y] {
        pc += 4
      } else {
        pc += 2
      }
      
      break
      
    case 0xA000: // ANNN	Sets I to the address NNN.
      
      I = opcode & 0x0FFF
      
      debugPrint(words: "Setting I to \(getHEXString(number: I))")
      
      pc += 2
      
      break
      
    case 0xB000: // BNNN	Jumps to the address NNN plus V0.
      
      pc = (opcode & 0x0FFF) + UInt16(V[0])
      
      debugPrint(words: "Jumping to \(getHEXString(number: pc))")
      
      break
      
    case 0xC000: // CXNN	Sets VX to the result of a bitwise and operation on a random number and NN.
      
      let X = Int((opcode & 0x0F00) >> 8)
      let NN = UInt8(opcode & 0x00FF)
      let rn = UInt8(arc4random() % 0xFF)
      
      debugPrint(words: "Setting V[\(X)] to \(getHEXString(number: NN)) & \(getHEXString(number: rn))")
      
      V[X] = NN & rn
      
      pc += 2
      
      break
      
    case 0xD000: // Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen
      
      let x = UInt16(V[Int((opcode & 0x0F00) >> 8)])
      let y = UInt16(V[Int((opcode & 0x00F0) >> 4)])
      let height = UInt16(opcode & 0x000F)
      var pixel: UInt16 = 0
      
      debugPrint(words: "Drawing sprite at (\(x), \(y)) h:\(height)")
      
      V[0xF] = 0
      
      for yLine in 0...height-1 {
        pixel = UInt16(memory[Int(I + yLine)])
        for xLine in 0...7 {
          if (pixel & UInt16(0x80 >> UInt8(xLine)) != 0) {
            let gfxLocation = (Int(x) + xLine + Int((y + yLine) * 64))
            if gfx[gfxLocation] == 1 {
              V[0xF] = 1
            }
            gfx[gfxLocation] = gfx[gfxLocation] ^ 1
          }
        }
      }
      
      drawFlag = true
      pc += 2
      
      break
      
    case 0xE000:
      
      switch opcode & 0x000F {
        
      case 0x000E: // EX9E	Skips the next instruction if the key stored in VX is pressed.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        if key[Int(V[X])] != 0 {
          pc += 4
        } else {
          pc += 2
        }
        
        break
        
      case 0x0001: // EXA1	Skips the next instruction if the key stored in VX isn't pressed.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        if key[Int(V[X])] == 0 {
          pc += 4
        } else {
          pc += 2
        }
        
        break
        
      default: // unknown
        print("Unknown opcode \(opcode)")
        break
      }
      
      break
      
    case 0xF000:
      
      switch opcode & 0x00FF {
        
      case 0x0007: // FX07	Sets VX to the value of the delay timer.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        V[X] = delay_timer
        
        pc += 2
        
        break
        
      case 0x000A: // FX0A	A key press is awaited, and then stored in VX.
        
        let X = Int((opcode & 0x0F00) >> 8)
        var keyPressed = false
        
        for i in 0...key.count-1 {
          if key[i] != 0 {
            V[X] = UInt8(i)
            keyPressed = true
          }
        }
        
        if keyPressed == false {
          return;
        }
        
        pc += 2
        
        break
        
      case 0x0015: // FX15	Sets the delay timer to VX.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        delay_timer = V[X]
        
        pc += 2
        
        break
        
      case 0x0018: // FX18	Sets the sound timer to VX.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        sound_timer = V[X]
        
        pc += 2
        
        break
        
      case 0x001E: // FX1E	Adds VX to I.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        if(I + UInt16(V[X]) > 0xFFF) {	// VF is set to 1 when range overflow (I+VX>0xFFF), and 0 when there isn't.
          V[0xF] = 1
        } else {
          V[0xF] = 0
        }
        
        I += UInt16(V[X])
        
        pc += 2
        
        break
        
      case 0x0029: // FX29  Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        I = UInt16(V[X] * 0x5)
        
        pc += 2
        
        break
        
      case 0x0033: // FX33  Stores the binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2.
        
        let xIndex = Int((opcode & 0x0F00) >> 8)
        let mIndex = Int(I)
        
        // TODO: look into this
        
        memory[mIndex] =      (V[xIndex] / 100)
        memory[mIndex + 1] =  (V[xIndex] / 10) % 10
        memory[mIndex + 2] =  (V[xIndex] % 100) % 10
        
        pc += 2
        
        break
        
      case 0x0055: // FX55  Stores V0 to VX (including VX) in memory starting at address I.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        for i in 0...X {
          let mIndex = Int(I) + i
          memory[mIndex] = V[i]
        }
        
        I += ((opcode & 0x0F00) >> 8) + 1
        
        pc += 2
        
        break
        
      case 0x0065: // FX65  Fills V0 to VX (including VX) with values from memory starting at address I.
        
        let X = Int((opcode & 0x0F00) >> 8)
        
        for i in 0...X {
          let mIndex = Int(I) + i
          V[i] = memory[mIndex]
        }
        
        I += ((opcode & 0x0F00) >> 8) + 1
        
        pc += 2
        
        break
        
      default: // unknown
        print("Unknown opcode \(opcode)")
        break
      }
      
      break
      
    default: // unknown
      print("Unknown opcode \(opcode)")
      break
    }
    
    // update timers
    
    if delay_timer > 0 {
      delay_timer = delay_timer - 1
    }
    
    if sound_timer > 0 {
      if sound_timer == 1 {
        print("BEEP!")
      }
      sound_timer = sound_timer - 1
    }
  }
  
  func printGfx() {
    
    var str = ""
    
    for y in 0...31 {
      for x in 0...63 {
        str += (gfx[x + (64 * y)] == 1 ? "O" : " ")
      }
      
      str += "\n"
    }
    
    print(str)
  }
  
  private func getHEXString(number: UInt16) -> String {
    return String(format:"%2X", number)
  }
  
  private func getHEXString(number: UInt8) -> String {
    return String(format:"%2X", number)
  }
  
  private func debugPrint(words: String) {
    if debugging {
      print(words)
    }
  }
}
