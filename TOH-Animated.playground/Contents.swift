//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

enum StateMachine {
    case start, lift, over, down, completed
}

class Disc: UIView {
 var id = 0
    override func draw(_ rect: CGRect) {
        let colors : [UIColor] = [.red, .yellow, .green, .blue, .orange]
        let color = colors[id%colors.count]
        color.setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 30).fill()
    }
}

var floater: Int?
var towerDisc: [Disc] = []
var model: [[Int]] = [[2, 1, 0],[],[]]
let button = UIButton()
let buttons = [UIButton(), UIButton(), UIButton()]

class AnimatedTowerControl: UIViewController {
    var stateMachine: StateMachine = .start {
        didSet {
            stateChanged()
        }
    }
    
    var animatedDisc: Disc? = nil
    var destination: CGPoint = .zero
    
    func stateChanged() {
        if let floater = floater {
            animatedDisc = towerDisc[floater]
        }
        guard let disc = animatedDisc else {return}
        
        switch stateMachine {
        case .start:
            stateMachine = .lift
        case .lift:
            UIView.animate(withDuration: 2, animations:
            {
                let upLocation = CGPoint(x: disc.center.x, y: disc.center.y-75)
                disc.center = upLocation
            }, completion:
            { [self] finshed in
                if floater == nil { // possible problem
                    self.stateMachine = .over
                } else {
                    print("locked")
                }
            })
        case .over:
            UIView.animate(withDuration: 2, animations:
            { [self] in
                let overLocation = CGPoint(x: self.destination.x, y: disc.center.y)
                disc.center = overLocation
            }, completion:
            { [self] finshed in
                self.stateMachine = .down
            })
        case .down:
            UIView.animate(withDuration: 2, animations:
            { [self] in
                disc.center = self.destination
            }, completion:
            { [self] finshed in
                self.stateMachine = .completed
            })
        case .completed:
                print("move done")
        }
    }
    
    func animatedUpdateUI() {
        let dx = preferredContentSize.width / 4
        let dy = (preferredContentSize.height * 2/3) / CGFloat(towerDisc.count*2)
        var cx: CGFloat = 0
        var cy: CGFloat = 0
        for tower in model {
            cx += dx
            cy = preferredContentSize.height*7/8
            for disc in tower {
                cy -= dy
                let destination = CGPoint(x: cx, y: cy)
                if towerDisc[disc].center != destination {
                    self.destination = destination
                    self.animatedDisc = towerDisc[disc]
                    if stateMachine == .lift {
                        stateMachine = .over
                    } else {
                        stateMachine = .start
                    }
                    return
                }
            }
            if let disc = floater {
                let current = towerDisc[disc].center
                let destination = CGPoint(x: current.x, y: current.y-75)
                self.destination = destination
                self.animatedDisc = towerDisc[disc]
                stateMachine = .start
                return
            }
        }
    }
    
    override func loadView() {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: preferredContentSize)
        view.backgroundColor = .black
        
        for id in 0 ..< model[0].count {
            let disc = Disc()
            disc.id = id
            disc.frame = CGRect(x: 0, y: 0, width: 50+id*30, height: 30)
            view.addSubview(disc)
            towerDisc.append(disc)
        }
        
        for i in 0 ..< buttons.count {
            let button = buttons[i]
            button.backgroundColor = .gray
            button.frame = CGRect(x: CGFloat(i+1) * preferredContentSize.width/4 - preferredContentSize.width/12, y: 265, width: preferredContentSize.width/6, height: 25)
            view.addSubview(button)
            button.addTarget(self, action: #selector(buttonsPressed), for: .touchUpInside)
        }
        self.view = view
        updateUI()
    }
    
    @objc func buttonsPressed(_ sender: UIButton) {
        var index = 0
        while index < buttons.count && sender != buttons[index] {
            index += 1
        }
        if let disc = floater {
            model[index].append(disc)
            floater = nil
        }
        else {
            floater = model[index].popLast()
        }
        animatedUpdateUI()
    }
    
    func updateUI() {
       let dx = preferredContentSize.width / 4
        let dy = preferredContentSize.height*2/3 / CGFloat(towerDisc.count*2)
        var cx : CGFloat = 0
        var cy : CGFloat = 0
        for tower in model {
            cx += dx
            cy = preferredContentSize.height*7/8
            for disc in tower {
                cy -= dy
                CGPoint(x: cx,y: cy)
                UIView.animate(withDuration: 2) {
                    towerDisc[disc].center = CGPoint(x: cx,y: cy)
                }
            }
        }
     
        if let disc = floater {
            UIView.animate(withDuration: 2) {
                towerDisc[disc].center = CGPoint(x: towerDisc[disc].center.x,y: towerDisc[disc].center.y-75)
            }
        }
    }
    
}
let vc = AnimatedTowerControl()
vc.preferredContentSize = CGSize(width: 500, height: 300)
PlaygroundPage.current.liveView = vc
