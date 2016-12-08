//
//  GameViewController.swift
//  chip8
//
//  Created by Nicholas Trampe on 12/8/16.
//  Copyright © 2016 Off Kilter Studios. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  var scene: GameScene! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let view = self.view as! SKView? {
      scene = GameScene(size: view.frame.size)
      scene.scaleMode = .aspectFill
      
      view.presentScene(scene)
      view.ignoresSiblingOrder = true
      
      view.showsFPS = true
      view.showsNodeCount = true
    }
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: { (context) in
      
    }) { (context) in
      self.scene.initializeGrid(size: size)
    }
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
