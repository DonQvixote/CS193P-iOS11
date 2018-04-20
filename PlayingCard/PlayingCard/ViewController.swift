//
//
//  PlayingCard
//
//  Created by 夏语诚 on 2018/1/1.
//  Copyright © 2018年 Banana. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1 }
    }
    
    private var lastChosenCardView: PlayingCardView?
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 && faceUpCardViews[0].rank == faceUpCardViews[1].rank && faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in: animator)

    @IBOutlet var cardViews: [PlayingCardView]!

//    @IBOutlet weak var playingCardView: PlayingCardView! {
//        didSet {
//            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
//            swipe.direction = [.left, .right]
//            playingCardView.addGestureRecognizer(swipe)
//
//            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))
//            playingCardView.addGestureRecognizer(pinch)
//        }
//    }
    
//    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
//        switch sender.state {
//        case .ended:
//            playingCardView.isFaceUp = !playingCardView.isFaceUp
//        default:
//            break
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        for _ in 1...10 {
//            if let card = deck.draw() {
//                print("\(card)")
//            }
//        }
        var cards = [PlayingCard]()
//        print(cardViews.count)
        for _ in 1...((cardViews.count + 1) / 2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CMMotionManager.shared.isAccelerometerAvailable {
            cardBehavior.gravityBehavior.magnitude = 1.0
            CMMotionManager.shared.accelerometerUpdateInterval = 1 / 10
            CMMotionManager.shared.startAccelerometerUpdates(to: .main) { (data, error) in
                if var x = data?.acceleration.x, var y = data?.acceleration.y {
                    switch UIDevice.current.orientation {
                    case .portrait:
                        y *= -1
                    case .portraitUpsideDown:
                        break
                    case .landscapeLeft:
                        swap(&x, &y)
                        y *= -1
                    case .landscapeRight:
                        swap(&x, &y)
                    default:
                        x = 0
                        y = 0
                    }
                    self.cardBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: y)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cardBehavior.gravityBehavior.magnitude = 0
        CMMotionManager.shared.stopAccelerometerUpdates()
    }
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(with: chosenCardView, duration: 0.6, options: [.transitionFlipFromLeft], animations: {
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                }, completion: { finished in
                    let cardsToAnimate = self.faceUpCardViews
                    if self.faceUpCardViewsMatch {
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: {
                            cardsToAnimate.forEach {
                                $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                            }
                        }, completion: { position in
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 0, options: [], animations: {
                                cardsToAnimate.forEach {
                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                    $0.alpha = 0
                                }
                            }, completion: { position in
                                cardsToAnimate.forEach {
                                    $0.isHidden = true
                                    $0.alpha = 1
                                    $0.transform = .identity
                                }
                            })
                        })
                    } else if self.faceUpCardViews.count == 2 {
                        if chosenCardView == self.lastChosenCardView {
                            self.faceUpCardViews.forEach({ cardView in
                                UIView.transition(with: cardView, duration: 0.6, options: [.transitionFlipFromLeft], animations: {
                                    cardView.isFaceUp = false
                                }, completion: { finished in
                                    self.cardBehavior.addItem(cardView)
                                })
                            })
                        }
                    } else {
                        if !chosenCardView.isFaceUp {
                            self.cardBehavior.addItem(chosenCardView)
                        }
                    }
                })
            }
        default:
            break
        }
    }
    
//    @objc func nextCard() {
//        if let card = deck.draw() {
//            playingCardView.rank = card.rank.order
//            playingCardView.suit = card.suit.rawValue
//        }
//    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
