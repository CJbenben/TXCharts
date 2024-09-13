//
//  HMYAxis.swift
//  Demo
//
//  Created by powershare on 2024/1/19.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// y 轴
class HMYAxis: HMAxisBase {
    // y 轴位置
    public enum YAxisPosition: Int {
        case left           // 左边
        case right          // 右边
    }
    
    /// y 轴上的值 需要显示的数量
    public var showValueCount: Int = 0
    /// y 轴位置
    public var position: YAxisPosition = .left
    /// y 轴上的值相对于 y 轴位置
    public var valuePosition: YAxisPosition = .left
    
}
