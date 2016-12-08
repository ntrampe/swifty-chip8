//
//  GameScene.swift
//  chip8
//
//  Created by Nicholas Trampe on 12/8/16.
//  Copyright © 2016 Off Kilter Studios. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
  var graphics = [SKShapeNode?](repeating: nil, count: 64 * 32) 
  
  override func didMove(to view: SKView) {
    
    initializeGrid(size: view.frame.size)
  }
  
  func initializeGrid(size: CGSize) {
    let minds = min(size.width, size.height)
    let pixelSize = CGSize(width: minds / 64, height: minds / 32)
    
    for i in 0...graphics.count-1 {
      guard let node = graphics[i] else {
        continue
      }
      
      node.removeFromParent()
    }
    
    for x in 0...63 {
      for y in 0...31 {
        let xConverted = (CGFloat(x) * pixelSize.width)
        let yConverted = size.height - (CGFloat(y) * pixelSize.height)
        let shape = SKShapeNode(rect: CGRect(x: xConverted, y: yConverted, width: pixelSize.width, height: pixelSize.height))
        shape.fillColor = UIColor.white
        shape.strokeColor = UIColor.clear
        self.addChild(shape)
        self.graphics[x + (64 * y)] = shape
      }
    }
  }
  
  func touchDown(atPoint pos : CGPoint) {
    
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    
  }
  
  func touchUp(atPoint pos : CGPoint) {
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {  
    for t in touches { self.touchDown(atPoint: t.location(in: self)) }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
}
