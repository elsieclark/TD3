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
    
    var tileArr : [Tile] = []
    
    var bg = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        screenMin = min(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
        screenMax = max(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
        
        self.backgroundColor = UIColor.blackColor()
        
        bg = SKSpriteNode(texture: SKTexture(imageNamed: "boardBack.png"))
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        bg.size = CGSize(width: screenMin, height: screenMin)
        self.addChild(bg)
        
        createTiles()
        arrangeTiles()
        
        
    }
    
    
    
    func portrait() -> Bool {
        if (CGRectGetWidth(self.frame) < CGRectGetHeight(self.frame)) {
            return true
        }
        return false
    }
    
    func createTiles() {
        for i in 0 ... 99 {
            
            let newTile = Tile(place: i, size: screenMin * 0.098)
            
            self.addChild(newTile)
            
            if i == 9 || i == 90 {
                newTile.protected = true
            }
            
            tileArr.append(newTile)
        }
        
    }
    
    func pathFind(startTile: Int, endTile: Int) -> [Movement] {
        
        
        
        
        var startMove : Movement = Movement()
        startMove.location = startTile
        startMove.direction = -1
        startMove.pastCost = 0
        startMove.futureCost = findDist(startTile, tile2: endTile)
        startMove.totalCost = startMove.pastCost + startMove.futureCost
        
        
        var open : [Movement] = [startMove]
        var closed : [Movement] = []
        
        
        while tileInArray(endTile, array: open) == -1 {
            
            
            open.sortInPlace({$0.totalCost < $1.totalCost})
            
            if open.isEmpty {
                print("Ho")
                return []
            }
            
            
            for i in 0 ... 7 {
                var candidate : Movement = Movement()
                candidate.direction = (i + 4) % 8
                candidate.location =  getDirFromDirNumb(i, loc: open[0].location)
                candidate.futureCost = findDist(candidate.location, tile2: endTile)
                
                var valid : Bool = true
                
                if i % 2 == 0 { // Up, down, left, or right
                    candidate.pastCost = open[0].pastCost + 1
                } else { // Diagonals
                    candidate.pastCost = open[0].pastCost + 0.99 * sqrt(2)
                    
                    let cwBarrier : Int = getDirFromDirNumb((i+1)%8, loc: open[0].location)
                    
                    if (cwBarrier >= 0 && cwBarrier < 100)
                    {
                        if tileArr[cwBarrier].barrier {
                            valid = false
                            print(String(candidate.location) + " " + String(candidate.direction) + " CCW")
                        }
                    }
                    
                    let ccwBarrier : Int = getDirFromDirNumb((i-1)%8, loc: open[0].location)
                    
                    if (ccwBarrier >= 0 && ccwBarrier < 100)
                    {
                        if tileArr[ccwBarrier].barrier {
                            valid = false
                            print(String(candidate.location) + " " + String(candidate.direction) + " CCW")
                        }
                    }
                    
                }
                
                
                
                candidate.totalCost = candidate.pastCost + candidate.futureCost
                
                let placeInOpen = tileInArray(candidate.location, array: open)
                
                if (valid && candidate.location >= 0 && candidate.location < 100 && !tileArr[candidate.location].barrier && tileInArray(candidate.location, array: closed) == -1 && placeInOpen == -1) {
                    
                    let status : String = String(valid) + " " + String(candidate.location) + " " + String(candidate.direction) + " " + String(open[0].location)
                    
                    print(status)
                    

                    open.append(candidate)
            
                }
            }
 
            closed.append(open[0])
            open.removeAtIndex(0)
            
            
        }
        
        
         
        closed.append(open[tileInArray(endTile, array: open)])

        
        print(String(closed))
        
        
        var target : Movement = closed[tileInArray(endTile, array: closed)]
        var finalPath : [Movement] = []
        
        while target.location != startTile {

            //print(String(target.location))
            
            finalPath.insert(target, atIndex: 0)
            target = closed[tileInArray(getDirFromMovement(finalPath[0]), array: closed)]
        }
        
        finalPath.insert(target, atIndex: 0)
        

 
        
        return finalPath
        
    }
    
    func tileInArray(targetTile : Int, array : [Movement]) -> Int {
        if let i = array.indexOf({$0.location == targetTile}) {
            return i
        }
        return -1
    }
    
    
    func findDist (tile1 : Int, tile2 : Int) -> Float32 {
        
        let xDist : Float32 = Float32(abs((tile1 % 10) - (tile2 % 10)))
        let yDist : Float32 = Float32(abs((tile1 / 10) - (tile2 / 10)))
        
        return sqrt( (xDist * xDist) + (yDist * yDist) )
    }
    
    
    
    func isInGrid (tileNumber : Int) -> Bool {
        if (tileNumber <= 99 && tileNumber >= 0) {
            return true
        }
        return false
    }
    
    func getDirFromDirNumb(dir : Int, loc : Int) -> Int {
        
        var newLoc : Int = -1
        
        
        if dir == 0 {
            newLoc = loc + 10 // Up
        }
        if dir == 1 {
            newLoc = loc + 11
        }
        if dir == 2 {
            newLoc = loc + 1 // Right
        }
        if dir == 3 {
            newLoc = loc - 9
        }
        if dir == 4 {
            newLoc = loc - 10 // Down
        }
        if dir == 5 {
            newLoc = loc - 11
        }
        if dir == 6 {
            newLoc = loc - 1 // Left
        }
        if dir == 7 {
            newLoc = loc + 9
        }
        
        if newLoc % 10 == 9 && loc % 10 == 0 {
            return -10
        }
        
        if newLoc % 10 == 0 && loc % 10 == 9 {
            return -10
        }
        
        //if (abs(dir % 10 - newLoc % 10) > 1) {
        //    return -1
        //}
        
        return newLoc
    }
    
    func getDirFromMovement(dir : Movement) -> Int {
        
        if dir.direction == 0 {
            return dir.location + 10 // Up
        }
        if dir.direction == 1 {
            return dir.location + 11
        }
        if dir.direction == 2 {
            return dir.location + 1 // Right
        }
        if dir.direction == 3 {
            return dir.location - 9
        }
        if dir.direction == 4 {
            return dir.location - 10 // Down
        }
        if dir.direction == 5 {
            return dir.location - 11
        }
        if dir.direction == 6 {
            return dir.location - 1 // Left
        }
        if dir.direction == 7 {
            return dir.location + 9
        }
        
        
        return -100
    }
    
    
    
    
    func arrangeTiles() {
        
        for i in 0 ... 99 {
            
            tileArr[i].position = CGPointMake(CGRectGetMidX(self.frame) - screenMin * 0.441 + tileArr[i].xVal, CGRectGetMidY(self.frame) - screenMin * 0.441 + tileArr[i].yVal)
        }
    }
    

    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */

        
        
        
        
        for i in 0 ... 99 {
            tileArr[i].reskin()
            tileArr[i].color = UIColor.redColor()
        }
 
        let newPath = pathFind(90, endTile: 9)
        

        for i in newPath {
            tileArr[i.location].texture = nil
            tileArr[i.location].color = UIColor.greenColor()
        }
        
        
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func didChangeSize(oldSize: CGSize) {
        if tileArr.endIndex > 50 {
            arrangeTiles()
        }
    }
}
