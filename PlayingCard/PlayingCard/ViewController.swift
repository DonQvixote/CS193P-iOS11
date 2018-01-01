//
//  ViewController.swift
//  PlayingCard
//
//  Created by 夏语诚 on 2018/1/1.
//  Copyright © 2018年 Banana. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for _ in 1...10 {
            if let card = deck.draw() {
                print("\(card)")
            }
        }
    }
}

