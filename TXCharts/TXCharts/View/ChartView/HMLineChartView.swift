//
//  HMLineChartView.swift
//  Demo
//
//  Created by powershare on 2024/1/17.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// 图表代理回调
@objc protocol HMChartViewDelegate: AnyObject {
    /// 气泡内容
    func bubbleViewContent(view: HMLineChartView, selectedIndex: Int)
}

class HMLineChartView: UIView {

    private var bgLineConfig: HMChartBgLineConfig?
    private var chartConfig: HMBaseChartConfig?
    
    weak var delegate: HMChartViewDelegate?
    
    /// 是否禁止滑动
    public var isDisableSlide: Bool = false {
        didSet {
            moveLineView.isDisableSlide = isDisableSlide
        }
    }
    
    /// 气泡内容
    public var bubbleContent: NSAttributedString? {
        didSet {
            moveLineView.bubbleContent = bubbleContent
        }
    }
    
    // MARK: Public Method
    /// 设置图表配置
    public func setChartConfig(_ bgLineConfig: HMChartBgLineConfig?, chartConfig: HMBaseChartConfig?) {
        bgLineChart.bgLineConfig = bgLineConfig
        self.bgLineConfig = bgLineConfig
        self.chartConfig = chartConfig
    }
    
    public var chartData: HMChartData? {
        didSet {
            if let lineChartData = chartData {
                drawLineView.setChartData(chartData, chartConfig: chartConfig)
                moveLineView.setChartConfig(bgLineConfig, lineChartConfig: chartConfig)
                moveLineView.setChartData(chartData, lineIndex: lineChartData.lineIndex)
                if let delegate = self.delegate, let lineIndex = chartData?.lineIndex {
                    delegate.bubbleViewContent(view: self, selectedIndex: lineIndex)
                }
            }
        }
    }
    
    // MARK: Private Method
    
    // MARK: Action
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI
    private func setupUI() {
        self.addSubview(bgLineChart)
        bgLineChart.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        self.addSubview(drawLineView)
        drawLineView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        self.addSubview(moveLineView)
        moveLineView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        moveLineView.slideChartCallBack = { [weak self] (selectedPos: Int) in
            if let delegate = self?.delegate {
                delegate.bubbleViewContent(view: self!, selectedIndex: selectedPos)
            }
        }
    }
    
    // MARK: lazy
    private lazy var bgLineChart: HMDrawBgLineView = {
        let bgLine = HMDrawBgLineView()
        bgLine.backgroundColor = .clear
        return bgLine
    }()
    
    private lazy var drawLineView: HMDrawLineChartView = {
        let view = HMDrawLineChartView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var moveLineView: HMMoveLineChartView = {
        let view = HMMoveLineChartView()
        view.backgroundColor = .clear
        return view
    }()
}
