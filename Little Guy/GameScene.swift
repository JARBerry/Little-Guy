//
//  GameScene.swift
//  Little Guy
//
//  Created by James and Ray Berry on 08/01/2019.
//  Copyright © 2019 JARBerry. All rights reserved.
//


import SpriteKit

// identify objects in Game
struct PhysicsCategory {
    
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let monster: UInt32 = 0b1
    static let projectile: UInt32 = 0b10
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return(CGPoint(x: left.x + right.x,y:left.y + right.y))
    
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x,y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar,y : point.y * scalar)
    
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar,y : point.y / scalar)
}


#if !(arch(x86_64) || arch(arm64))
func sqrt (a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt (x*x + y*y)
        
    }
    
    func normalized() -> CGPoint {
        
        return self/length()
        
    }
}


class GameScene: SKScene {
    
    
    // define Little Guy Image
    let player = SKSpriteNode(imageNamed: "LittleGuy")
    
    // Time
    var timeLabel:SKLabelNode?

    // Define scores
    var scoreLabel:SKLabelNode!
    
    var score:Int = 0
    
    var currentScore:Int=0
    
    var gameStateIsInGame = true
    
    var backgroundSet:Bool = false
    
    
    
    // Display score
    func updateScore() {
        
        self.childNode(withName: "score")?.removeFromParent()
        
        scoreLabel = self.childNode(withName: "score") as? SKLabelNode
        
        let scorelabel = SKLabelNode(fontNamed: "Chalkduster")
        scorelabel.name = "score"
        scorelabel.text = "Score :  \(score) "
        scorelabel.fontSize = 20
        scorelabel.fontColor = SKColor.white
        scorelabel.position = CGPoint(x: 350, y: 10)
        scorelabel.zPosition = 2
        
        addChild(scorelabel)
        
        
    }
    
    
    
    override func didMove(to view: SKView) {
 
        //   backgroundColor = SKColor.green
        backgroundColor = UIColor(red:0.06, green:0.64, blue:0.30, alpha:1.0)
        
        // add background scene
        let background = SKSpriteNode(imageNamed: "forest.jpg")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        backgroundSet = true
        background.zPosition = 1
        
        
        // display score
        updateScore()
        
        
        // add Little Guy
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.4)
        player.zPosition = 2
        
        addChild(player)
        
        // Sets zero Gravity
        
       
       physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: 1.0)])
        ))
        
        // sets background Music
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        
    }
    
    
    // Set Initial count for monsters destroyed
    var monstersDestroyed = 0
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    // add monsters(Ghosts)
    func addMonster() {
        
        
        let monster = SKSpriteNode(imageNamed: "ghost")
        
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        monster.zPosition = 2
        
        addChild(monster)
        
        
        // check is monster is hit by projectile
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        // if Little Guy hit - game Over
        
        let loseAction = SKAction.run() { [weak self] in
            guard let `self` = self else { return }
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size,won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
            
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        
        guard let touch = touches.first
            else {
                return
                
        }
        
        // play sound when projectile fired
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        let touchLocation = touch.location(in: self)
        
        // display projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        projectile.zPosition = 2
        
        // projectile location based on touch
        let offset = touchLocation - projectile.position
        
        
        if offset.x < 0 { return}
        
        // add projectile node
        addChild(projectile)
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        
        let direction = offset.normalized()
        
        // Speed of the projectile
        
        let shootAmount = direction * 1000
        
        
        let realDest = shootAmount + projectile.position
        
        
        
        // fire projectile
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        
        // when projectile hits monster - remove monster and projectile from screen
        
        projectile.removeFromParent()
        monster.removeFromParent()
        
        // increase monster hit score
        
        
        monstersDestroyed += 1
        // update score
        
        score += 1
        
        updateScore()
        
        // if number of monsters destroyed > 30 Game Over
        if monstersDestroyed > 30 {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
}

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
    
}
