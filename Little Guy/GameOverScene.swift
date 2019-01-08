//
//  GameOverScene.swift
//  Little Guy
//
//  Created by James and Ray Berry on 08/01/2019.
//  Copyright © 2019 JARBerry. All rights reserved.
//





import SpriteKit

class GameOverScene: SKScene {
  init(size: CGSize, won:Bool) {
    super.init(size: size)
    
    backgroundColor = SKColor.white
  // display Win or Lose scene
    let message = won ? "You Won Little Guy!" : "Game Over Little Guy !"
  
  // Label font and text
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    
    run(SKAction.sequence([SKAction.wait(forDuration: 3.0),
    SKAction.run() { [weak self] in
    
      guard let `self` = self else { return }
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let scene = GameScene(size: size)
      self.view?.presentScene(scene, transition:reveal)
      }
      ]))
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

