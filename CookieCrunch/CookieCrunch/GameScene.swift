//
//  GameScene.swift
//  CookieCrunch
//
//  Created by Anthony Fealy on 12/26/17.
//  Copyright © 2017 Anthony Fealy. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var level: Level!
    
    let TileWidth:CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let tilesLayer = SKNode()
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    
    var swipeHandler: ((Swap)->())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        addChild(background)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        tilesLayer.position = layerPosition
        cookiesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(cookiesLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    func addSprites(for cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointFor(column: cookie.column, row: cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth / 2,
            y: CGFloat(row)*TileHeight + TileHeight / 2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x/TileWidth), Int(point.y/TileHeight))
        } else {
            return (false, 0, 0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        
        let (success, column, row) = convertPoint(point: location)
        if success {
            if level.cookieAt(column: column, row: row) != nil { // this was auto fixed was let cookie =
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard swipeFromColumn != nil else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        
        let (success, column, row) = convertPoint(point: location)
        if success {
            
            var horzdelta = 0, vertdelta = 0
            if column < swipeFromColumn! {
                horzdelta = -1
            } else if column > swipeFromColumn! {
                horzdelta = 1
            } else if row < swipeFromRow! {
                vertdelta = -1
            } else if row > swipeFromRow! {
                vertdelta = 1
            }
            
            if horzdelta != 0 || vertdelta != 0 {
                trySwap(horizontal: horzdelta, vertical: vertdelta)
                swipeFromColumn = nil
            }
        }
    }
    
    func trySwap(horizontal: Int, vertical: Int) {
        let toColumn = swipeFromColumn! + horizontal
        let toRow = swipeFromRow! + vertical
        
        guard toColumn >= 0 && toColumn < NumColumns else { return }
        guard toRow >= 0 && toRow < NumRows else { return }
        
        if let toCookie = level.cookieAt(column: toColumn, row: toRow),
            let fromCookie = level.cookieAt(column: swipeFromColumn!, row: swipeFromRow!) {
            if let handler = swipeHandler {
                let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                handler(swap)
            }
        }
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if level.tileAt(column: column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointFor(column: column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func animate(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
    }
}
