//
//  GameScene.swift
//  TD3
//
//  Created by Will Clark on 2016-05-22.
//  Copyright (c) 2016 Arcster. All rights reserved.
//

import SpriteKit

var screenMin : CGFloat!
var screenMax : CGFloat!
var counter = 0

class GameScene: SKScene {
    
    var bg = SKSpriteNode()
    
    var tileGrid : TileGrid!
    var oldTileGrid = [Bool] (count:100, repeatedValue:false)
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        screenMin = min(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
        screenMax = max(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
        
        tileGrid = TileGrid(gameScene: self)
        
        //self.addChild(tileGrid)
        
        self.backgroundColor = UIColor.blackColor()
        
        bg = SKSpriteNode(texture: SKTexture(imageNamed: "boardBack.png"))
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        bg.size = CGSize(width: screenMin, height: screenMin)
        self.addChild(bg)
        
        for i in 0 ... 99 {
            self.addChild(tileGrid.tileArr[i])
            oldTileGrid[i] = tileGrid.tileArr[i].barrier
        }
        
        showPath()
    
    }
    

    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//       /* Called when a touch begins */
//
//        tileGrid.reskinAll()
// 
//        let newPath = tileGrid.pathFind(90, endTile: 9)
//        
//
//        for i in newPath {
//            tileGrid.colourTile(i.location, newColour: UIColor.greenColor())
//        }
//
//        
//    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if tileGrid.pathFind(90, endTile: 9).count == 0 {
            for i in 0 ... 99 {
                tileGrid.tileArr[i].barrier = oldTileGrid[i]
                tileGrid.reskinAll()
                showPath()
            }
        }
        
        var changed = false
        
        for i in 0 ... 99 {
            if oldTileGrid[i] != tileGrid.tileArr[i].barrier {
                changed = true
            }
        }
        
        if changed {
            showPath()
            
        }
        
        for i in 0 ... 99 {
            oldTileGrid[i] = tileGrid.tileArr[i].barrier
        }
        
    }
    
    override func didChangeSize(oldSize: CGSize) {
        if tileGrid != nil && tileGrid.tileArr.count > 50 {
            tileGrid.arrangeTiles(self)
        }
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    }
    
    func showPath() {
        tileGrid.reskinAll()

        let newPath = tileGrid.pathFind(90, endTile: 9)


        for i in newPath {
            tileGrid.colourTile(i.location, newColour: UIColor.greenColor())
        }
    }
}
