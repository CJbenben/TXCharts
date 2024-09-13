//
//  HMBarChartConfig.swift
//  Demo
//
//  Created by powershare on 2024/1/19.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// 柱状图配置
class HMBarChartConfig: HMBaseChartConfig {
    // 柱状图样式
    public enum BarDirection: Int {
        case up      // 向上，都是正值
        case down    // 向下，都是负值
        case auto
    }
    
    /// 柱子方向
    public var direction: BarDirection = .up
    /// 每一段柱状图样式配置
    public var lineStyleConfigs: [[HMLineStyleConfig]]?
    /// 柱子里面填充颜色，默认：线的颜色
    public var fillColor: UIColor?
    /// 柱子的宽度
    public var width: CGFloat = 10.0
}
