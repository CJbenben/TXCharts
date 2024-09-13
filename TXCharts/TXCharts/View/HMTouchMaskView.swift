//
//  HMTouchMaskView.swift
//  ChartDemo
//
//  Created by 朱洁 on 2023/9/8.
//

import UIKit

@objc protocol MaskViewTouchDelegate: AnyObject {
    func maskViewTouchesBegan(touchLocation: CGPoint)
    func maskViewTouchesMoved(touchLocation: CGPoint)
    func maskViewTouchesEnded(touchLocation: CGPoint)
}

@objcMembers class HMTouchMaskView: UIButton, UIGestureRecognizerDelegate {
    weak var delegate: MaskViewTouchDelegate?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var isEnd: Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressGesture)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            return self
        }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
    
    func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: self)
        
        if gestureRecognizer.state == .began {
            isEnd = false
        }
        
        if gestureRecognizer.state == .ended {
            if delegate != nil {
                if !isEnd {
                    isEnd = false
                    delegate!.maskViewTouchesEnded(touchLocation: touchLocation)
                } else {
                    isEnd = false
                }
                
            }
        }
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        let touchLocation = sender.location(in: self)
        if sender.state == .began {
            isEnd = false
            if delegate != nil {
                delegate!.maskViewTouchesBegan(touchLocation: touchLocation )
            }
        } else if sender.state == .ended {
            isEnd = false
            if delegate != nil {
                delegate!.maskViewTouchesEnded(touchLocation: touchLocation)
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true // 允许同时识别手势
        }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let touchLocation = sender.location(in: self)
        switch sender.state {
        case .began:
            if delegate != nil {
                delegate!.maskViewTouchesBegan(touchLocation: touchLocation)
                isEnd = false
            }
        case .changed:
            if delegate != nil {
                delegate!.maskViewTouchesMoved(touchLocation: touchLocation)
                isEnd = false
            }
        case .ended:
            if delegate != nil {
                delegate!.maskViewTouchesEnded(touchLocation: touchLocation)
                isEnd = true
            }
        default:
            break
        }
    }
    
}
