//
//  HMLineChartViewController.swift
//  Demo
//
//  Created by powershare on 2024/1/15.
//

import UIKit

class HMLineChartViewController: UIViewController {

    // MARK: Public Method
    
    // MARK: Private Method
    func setChartConfig(_ chartConfig: HMLineChartConfig) -> HMLineChartConfig {
        chartConfig.chartMargin = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        // public var margin: UIEdgeInsets = .init(top: 20, left: 10, bottom: 20, right: 10)
        chartConfig.normalPointStyle = .solid
        chartConfig.selectPointStyle = .hollow
        chartConfig.isHiddenSlideXValue = true
//        chartConfig.pointDescPositionList = [.top, .top]
        chartConfig.pointDescTextColor = UIColor.gray
//        chartConfig.isNeedFillColor = true
        chartConfig.isShowBubble = true
        chartConfig.isShowSelectShadow = false
        chartConfig.selectShadowWidth = 10
        chartConfig.isShowVerticalSeletedLine = true
        chartConfig.pointDescOnlyMaxAndMin = true
        chartConfig.pointDescMaxValue = NSAttributedString(string: "H")
        chartConfig.pointDescMinValue = NSAttributedString(string: "L")
        // chartConfig.lineChartColors = [UIColor(hexString: "#00B940"), UIColor(hexString: "#0A7DA4"), UIColor.red]
        
        let lineConfig1 = HMLineStyleConfig()
        lineConfig1.startIndex = 0
        lineConfig1.endIndex = 3
        lineConfig1.lineStyle = .solid
        lineConfig1.lineColor = .cyan
        lineConfig1.isNeedFillColor = true
        
        let lineConfig2 = HMLineStyleConfig()
        lineConfig2.startIndex = 3
        lineConfig2.endIndex = 6
        lineConfig2.lineStyle = .dash
        lineConfig2.lineColor = .blue
        lineConfig2.isNeedFillColor = true
        
        let lineConfig3 = HMLineStyleConfig()
        lineConfig3.startIndex = 6
        lineConfig3.endIndex = 13
        lineConfig3.lineStyle = .dash
        lineConfig3.lineColor = .red
        lineConfig3.isNeedFillColor = true
        
        chartConfig.lineStyleConfigs = [[lineConfig1, lineConfig2, lineConfig3], [lineConfig1, lineConfig2, lineConfig3]]
        
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
    
    func formateArrayToNumberItemArray(_ array: [[Int]], lineIndex: Int) -> [[(startIndex: Int, endIndex: Int, length: Int)]] {
        var result: [[(startIndex: Int, endIndex: Int, length: Int)]] = []
        
        for line in array {
            var lineResult: [(startIndex: Int, endIndex: Int, length: Int)] = []
            var currentLength = 1
            var startIndex = 0
            var endIndex = 0
            
            for i in 1..<line.count {
                if line[i] == line[i - 1] {
                    if i == lineIndex {
                        endIndex = lineIndex
                        if startIndex == 0 {
                            currentLength = endIndex - startIndex + 1
                        } else {
                            currentLength = endIndex - startIndex
                        }
                        lineResult.append((startIndex, endIndex, currentLength))
                        startIndex = lineIndex
                    }
                } else {
                    endIndex = i - 1
                    if startIndex == 0 {
                        currentLength = endIndex - startIndex + 1
                    } else {
                        currentLength = endIndex - startIndex
                    }
                    if startIndex != endIndex {
                        lineResult.append((startIndex, endIndex, currentLength))
                        startIndex = i - 1
                    }
                    if i == lineIndex {
                        endIndex = lineIndex
                        currentLength = endIndex - startIndex
                        lineResult.append((startIndex, endIndex, currentLength))
                        startIndex = lineIndex
                    }
                }
            }
            
            // 处理最后一个连续序列
            endIndex = line.count - 1
            if startIndex != endIndex {
                currentLength = endIndex - startIndex
                lineResult.append((startIndex, endIndex, currentLength))
            }
            
            result.append(lineResult)
        }
        
        return result
    }
    
    // MARK: Action
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NewLineChart"
        self.view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: UI
    private func setupUI() {
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view)
            make.leading.trailing.bottom.equalTo(self.view)
        }
        
        scrollView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
//        let ylist: [[CGFloat]] = [[20, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, 20, 35, -20, 100, 33, 9, 30, 80, 22]]
        // 2条线，都有值
//        let ylist: [[CGFloat]] = [
//            [30, CGFloat.greatestFiniteMagnitude, 23, 35, 48, -30, 80, 33, -30, 30, 80, 22],
//            [-40, -40, CGFloat.greatestFiniteMagnitude, 40, -40, 40, 25, 20, -40, 30, 40, 20]]
//        let ylist: [[CGFloat]] = [[60, CGFloat.greatestFiniteMagnitude, 40, CGFloat.greatestFiniteMagnitude, 60, CGFloat.greatestFiniteMagnitude, -60, 0, -20, -20, 20, 40]]
        let ylist: [[CGFloat]] = [[25, 50, 25, 60, 25, 20, -20, 0, 20]]
//        let ylist: [[CGFloat]] = [[CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude]]
        let xlist: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        let lineColor: [UIColor] = [UIColor.red, UIColor.blue, UIColor.red]
        
        let maxAndMinValue = HMChartUtil.getMaxAndMinValue(ylist)
        print("图表最大值最小值，原始最大值 = \(maxAndMinValue.max), 最小值 = \(maxAndMinValue.min)")
        let convertMaxAndMinValue = HMChartUtil.getConvertMaxAndMinValue(maxAndMinValue.max, minValue: maxAndMinValue.min)
        print("图表最大值最小值，转化之后最大值 = \(convertMaxAndMinValue.max), 最小值 = \(convertMaxAndMinValue.min)")
        
        let chartData = HMChartData()
        chartData.xlist = xlist
        chartData.ylist = ylist
        chartData.lineIndex = -1
        chartData.maxValue = convertMaxAndMinValue.max
        chartData.minValue = convertMaxAndMinValue.min
//        chartData.lineColors = [UIColor.red, UIColor.blue, UIColor.red]
        // 创建自定义视图
        let curveChartView = HMLineChartView()
        curveChartView.setChartConfig(bgLineConfig, chartConfig: curveChartConfig)
        
        // 添加自定义视图到当前视图控制器的视图中
        bgView.addSubview(curveChartView)
        curveChartView.snp.makeConstraints { make in
            make.top.equalTo(bgView).offset(20)
            make.leading.trailing.equalTo(bgView)
            make.height.equalTo(200)
        }
        curveChartView.chartData = chartData
        
        let stepppedChartView = HMLineChartView()
        stepppedChartView.setChartConfig(bgLineConfig, chartConfig: steppedChartConfig)
        
        // 添加自定义视图到当前视图控制器的视图中
        bgView.addSubview(stepppedChartView)
        stepppedChartView.snp.makeConstraints { make in
            make.top.equalTo(curveChartView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(bgView)
            make.height.equalTo(200)
        }
        stepppedChartView.chartData = chartData
        
        let straightChartView = HMLineChartView()
        
        let testArray: [[Int]] = [
            [0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1],
            [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0]
        ]
        let newTestArray = formateArrayToNumberItemArray(testArray, lineIndex: chartData.lineIndex)
        print("11111111111111 - newTestArray = \(newTestArray)")
        
        var lineStyleConfigs: [[HMLineStyleConfig]] = []
        for i in 0..<newTestArray.count {
            var lineStyleConfigArray: [HMLineStyleConfig] = []
            let originalNumberObjcArray = testArray[i]
            let newNumberObjArray = newTestArray[i]
            
            for j in 0..<newNumberObjArray.count {
                let lineConfig = HMLineStyleConfig()
                let item = newNumberObjArray[j]
                lineConfig.startIndex = item.startIndex
                lineConfig.endIndex = item.endIndex
                lineConfig.lineStyle = .solid
                if originalNumberObjcArray[item.endIndex] == 0 {
                    lineConfig.lineColor = .green
                } else if originalNumberObjcArray[item.endIndex] == 1 {
                    lineConfig.lineColor = .yellow
                }
                if item.endIndex <= chartData.lineIndex {
                    lineConfig.isNeedFillColor = true
                } else {
                    lineConfig.isNeedFillColor = false
                }
                lineStyleConfigArray.append(lineConfig)
            }
            lineStyleConfigs.append(lineStyleConfigArray)
        }
        straightChartConfig.lineStyleConfigs = lineStyleConfigs
        straightChartView.setChartConfig(bgLineConfig, chartConfig: straightChartConfig)
        
        // 添加自定义视图到当前视图控制器的视图中
        bgView.addSubview(straightChartView)
        straightChartView.snp.makeConstraints { make in
            make.top.equalTo(stepppedChartView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(bgView)
            make.height.equalTo(200)
            make.bottom.equalTo(bgView)
        }
        straightChartView.chartData = chartData
        
    }
    
    // MARK: lazy
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView()
        return view
    }()
    
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
    
    lazy var curveChartConfig: HMLineChartConfig = {
        var chartConfig = HMLineChartConfig()
        chartConfig.chartStyle = .curve
        chartConfig = self.setChartConfig(chartConfig)
        return chartConfig
    }()
    
    lazy var steppedChartConfig: HMLineChartConfig = {
        var chartConfig = HMLineChartConfig()
        chartConfig.chartStyle = .stepped
        chartConfig = self.setChartConfig(chartConfig)
        return chartConfig
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
