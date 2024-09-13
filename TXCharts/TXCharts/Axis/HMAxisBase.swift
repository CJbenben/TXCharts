//
//  HMAxisBase.swift
//  Demo
//
//  Created by powershare on 2024/1/19.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// 坐标轴
class HMAxisBase: NSObject {
    /// 是否显示坐标轴
    public var enabled: Bool = false
    /// 坐标轴样式
    public var style: BgLineStyle = .solid
    /// 坐标轴距离 charts 的偏移
    public var offset: CGPoint = .zero
    /// 坐标轴的高度/宽度
    public var axisWidth: CGFloat = 1.0
    /// 坐标轴的颜色
    public var axisColor: UIColor = UIColor(red: 211 / 255.0, green: 211 / 255.0, blue: 211 / 255.0, alpha: 1)
    /// 坐标轴上的值距离 坐标轴的距离
    public var valueOffSet: CGFloat = 4.0
    /// 坐标轴上的值颜色
    public var textColor = UIColor(red: 160 / 255.0, green: 162 / 255.0, blue: 165 / 255.0, alpha: 1)
    /// 坐标轴上的值字体
    public var textFont = UIFont.systemFont(ofSize: 11)
    /// 坐标轴上的值选中时颜色
    public var selectTextColor = UIColor.black
    /// 坐标轴上的值选中时字体
    public var selectTextFont = UIFont.systemFont(ofSize: 12)
    
    public var isEnabled: Bool { return enabled }
}
