//
//  HMLineChartStraightViewController.swift
//  HEMS
//
//  Created by powershare on 2024/1/15.
//

import UIKit

class HMLineChartStraightViewController: UIViewController, HMChartViewDelegate {

    private var straightChartView: HMLineChartView!
    private var chartData: HMChartData!
    // MARK: Public Method
    
    // MARK: Private Method
    func setChartConfig(_ chartConfig: HMLineChartConfig) -> HMLineChartConfig {
        chartConfig.chartMargin = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        // public var margin: UIEdgeInsets = .init(top: 20, left: 10, bottom: 20, right: 10)
        chartConfig.normalPointStyle = .solid
        chartConfig.selectPointStyle = .hollow
        chartConfig.isHiddenSlideXValue = true
//        chartConfig.pointDescPositionList = [.top, .top]
//        chartConfig.pointDescTextColor = UIColor.gray
//        chartConfig.isNeedFillColor = true
        chartConfig.isShowBubble = true
        chartConfig.isShowSelectShadow = false
        chartConfig.selectShadowWidth = 10
        chartConfig.isShowVerticalSeletedLine = true
        chartConfig.isShowHorizontalSeletedLine = true
        chartConfig.pointDescOnlyMaxAndMin = false
        chartConfig.pointDescMaxValue = NSAttributedString(string: "H")
        chartConfig.pointDescMinValue = NSAttributedString(string: "L")
        // chartConfig.lineChartColors = [UIColor(hexString: "#00B940"), UIColor(hexString: "#0A7DA4"), UIColor.red]
        
        let lineConfig1 = HMLineStyleConfig()
        lineConfig1.startIndex = 0
        lineConfig1.endIndex = 5
        lineConfig1.lineStyle = .solid
        lineConfig1.lineColor = .red
        lineConfig1.isNeedFillColor = true
        lineConfig1.pointDescPosition = .top
        
        let lineConfig11 = HMLineStyleConfig()
        lineConfig11.startIndex = 5
        lineConfig11.endIndex = 11
        lineConfig11.lineStyle = .dash
        lineConfig11.lineColor = .cyan
        lineConfig11.isNeedFillColor = true
        lineConfig11.pointDescPosition = .auto
        
        let lineConfig2 = HMLineStyleConfig()
        lineConfig2.startIndex = 0
        lineConfig2.endIndex = 11
        lineConfig2.lineStyle = .solid
        lineConfig2.lineColor = .blue
        lineConfig2.isNeedFillColor = false
        lineConfig2.pointDescPosition = .auto
        
        chartConfig.lineStyleConfigs = [[lineConfig1, lineConfig11]]
        
        let xAxis = HMXAxis()
        xAxis.enabled = true
        xAxis.style = .dash
        xAxis.position = .zero
        xAxis.offset = .zero
        xAxis.xValueStyle = .minMax
        xAxis.valuePosition = .top
        xAxis.valueOffSet = 5
        chartConfig.xAxis = xAxis
        
        let yAxis = HMYAxis()
        yAxis.position = .left
        yAxis.valuePosition = .left
        yAxis.offset = .zero
        yAxis.showValueCount = 5
        chartConfig.yAxis = yAxis
        return chartConfig
    }
    
    // MARK: Action
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "折线图-直线"
        self.view.backgroundColor = UIColor(red: 246 / 255.0, green: 247 / 255.0, blue: 240 / 255.0, alpha: 1)
        setupUI()
    }
    
    // MARK: HMChartViewDelegate
    func bubbleViewContent(view: HMLineChartView, selectedIndex: Int) {
        if let xlist = chartData.xlist, let ylist = chartData.ylist {
            var content = xlist[selectedIndex] + " & "
            for ylistAry in ylist {
                content += String(format: "%.0f", ylistAry[selectedIndex])
            }
            straightChartView.bubbleContent = NSAttributedString(string: content)
        }
    }
    
    // MARK: UI
    private func setupUI() {
//        let ylist: [[CGFloat]] = [[25, 50, 25, 60, 25, 20, -20, 0, 20]]
        let ylist: [[CGFloat]] = [[25, 50, CGFloat.greatestFiniteMagnitude, 60, 25, 20, -20, 0, 20]]
        let xlist: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        
        let maxAndMinValue = HMChartUtil.getMaxAndMinValue(ylist)
        print("图表最大值最小值，原始最大值 = \(maxAndMinValue.max), 最小值 = \(maxAndMinValue.min)")
        let convertMaxAndMinValue = HMChartUtil.getConvertMaxAndMinValue(maxAndMinValue.max, minValue: maxAndMinValue.min)
        print("图表最大值最小值，转化之后最大值 = \(convertMaxAndMinValue.max), 最小值 = \(convertMaxAndMinValue.min)")
        
        chartData = HMChartData()
        chartData.xlist = xlist
        chartData.ylist = ylist
        chartData.lineIndex = 0
        chartData.maxValue = convertMaxAndMinValue.max
        chartData.minValue = convertMaxAndMinValue.min
//        chartData.lineColors = [UIColor.red, UIColor.blue, UIColor.red]
        // 添加自定义视图到当前视图控制器的视图中
        straightChartView = HMLineChartView()
        straightChartView.delegate = self
        straightChartView.setChartConfig(bgLineConfig, chartConfig: straightChartConfig)
        
        // 添加自定义视图到当前视图控制器的视图中
        self.view.addSubview(straightChartView)
        straightChartView.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(88)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(200)
        }
        straightChartView.chartData = chartData
        
    }
    
    // MARK: lazy
    lazy var bgLineConfig: HMChartBgLineConfig = {
        var bgLineConfig = HMChartBgLineConfig()
        bgLineConfig.enabled = true
        // bgLineConfig.style = .solid
        bgLineConfig.margin = UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20)
        bgLineConfig.margin = .zero
        bgLineConfig.lineColor = .gray
        bgLineConfig.horizontalLineCount = 9
        bgLineConfig.verticalLineCount = 11
        return bgLineConfig
    }()
    
    lazy var straightChartConfig: HMLineChartConfig = {
        var chartConfig = HMLineChartConfig()
        chartConfig.chartStyle = .straight
        chartConfig = self.setChartConfig(chartConfig)
        return chartConfig
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
