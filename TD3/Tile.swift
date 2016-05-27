//
//  Tile.swift
//  TD3
//
//  Created by Will Clark on 2016-05-23.
//  Copyright © 2016 Arcster. All rights reserved.
//

import UIKit
import SpriteKit

class Tile: SKSpriteNode {
    
    var place : Int
    
    var xVal : CGFloat
    var yVal : CGFloat
    
    var barrier : Bool = false
    
    var protected : Bool = false
    
    init(place : Int, size : CGFloat){
        
        self.place = place
        
        xVal = CGFloat(place % 10) * size
        yVal = CGFloat(place / 10) * size
        
        super.init(texture : SKTexture(imageNamed: "tile1.png"), color: UIColor.redColor(), size: CGSizeMake(size, size))
        
        self.userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if !protected {
            
            barrier = !barrier
            
            self.reskin()
        
        }
    }
    
    func reskin() {
        if barrier {
            self.texture = SKTexture(imageNamed: "tile2.png")
        } else {
            self.texture = SKTexture(imageNamed: "tile1.png")
        }
    }
    
}

