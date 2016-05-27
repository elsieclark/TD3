//
//  tileGrid.swift
//  TD3
//
//  Created by Will Clark on 2016-05-27.
//  Copyright © 2016 Arcster. All rights reserved.
//

import UIKit
import SpriteKit

class TileGrid: SKNode {
    
    var tileArr : [Tile] = []
    
    init(gameScene : GameScene) {
        
        super.init()
        
        for i in 0 ... 99 {
            
            let newTile = Tile(place: i, size: screenMin * 0.098)
            
            self.userInteractionEnabled = true
            
            //self.addChild(newTile)
            
            if i == 9 || i == 90 {
                newTile.protected = true
            }
            
            tileArr.append(newTile)
        }
        
        self.arrangeTiles(gameScene)

    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reskinAll() {
        for i in tileArr {
            i.reskin()
        }
    }
    
    
    func arrangeTiles(gameScene : GameScene) {
        for i in 0 ... 99 {
            tileArr[i].position = CGPointMake(CGRectGetMidX(gameScene.frame) - screenMin * 0.441 + tileArr[i].xVal, CGRectGetMidY(gameScene.frame) - screenMin * 0.441 + tileArr[i].yVal)
        }
    }
    
    func colourTile(tile : Int, newColour : UIColor) {
        if tile < 100 && tile >= 0 {
            tileArr[tile].texture = nil
            tileArr[tile].color = newColour
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
                        }
                    }
                    
                    let ccwBarrier : Int = getDirFromDirNumb((i-1)%8, loc: open[0].location)
                    
                    if (ccwBarrier >= 0 && ccwBarrier < 100)
                    {
                        if tileArr[ccwBarrier].barrier {
                            valid = false
                        }
                    }
                    
                }
                
                
                
                candidate.totalCost = candidate.pastCost + candidate.futureCost
                
                let placeInOpen = tileInArray(candidate.location, array: open)
                
                if (valid && candidate.location >= 0 && candidate.location < 100 && !tileArr[candidate.location].barrier && tileInArray(candidate.location, array: closed) == -1 && placeInOpen == -1) {
                    
                    let status : String = String(valid) + " " + String(candidate.location) + " " + String(candidate.direction) + " " + String(open[0].location)
                    
                    
                    open.append(candidate)
                    
                }
            }
            
            closed.append(open[0])
            open.removeAtIndex(0)
            
            
        }
        
        
        
        closed.append(open[tileInArray(endTile, array: open)])
        
        
        
        var target : Movement = closed[tileInArray(endTile, array: closed)]
        var finalPath : [Movement] = []
        
        while target.location != startTile {
            
            //print(String(target.location))
            
            finalPath.insert(target, atIndex: 0)
            target = closed[tileInArray(getDirFromDirNumb(finalPath[0].direction, loc: finalPath[0].location), array: closed)]
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
    
    
    func getDirFromDirNumb(dir : Int, loc : Int) -> Int {
        
        var newLoc = -1
        
        switch dir {
        case 0:
            newLoc = loc + 10
        case 1:
            newLoc = loc + 11
        case 2:
            newLoc = loc + 1
        case 3:
            newLoc = loc - 9
        case 4:
            newLoc = loc - 10
        case 5:
            newLoc = loc - 11
        case 6:
            newLoc = loc - 1
        case 7:
            newLoc = loc + 9
        default: break
        }
        
        if (abs(loc % 10 - newLoc % 10) > 1) {
            return -1
        }
        
        return newLoc
        
    }

}
