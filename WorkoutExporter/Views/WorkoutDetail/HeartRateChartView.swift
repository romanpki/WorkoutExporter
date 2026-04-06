import SwiftUI
import Charts

struct HeartRateChartView: View {
    let samples: [SampleTimeSeries]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("chart.heartRate")
                .font(.headline)

            Chart(samples.indices, id: \.self) { index in
                let sample = samples[index]
                LineMark(
                    x: .value("Temps", sample.timestamp),
                    y: .value("FC", sample.value)
                )
                .foregroundStyle(.red.gradient)
                .interpolationMethod(.catmullRom)
            }
            .chartYAxisLabel("bpm")
            .chartYScale(domain: yDomain)
        }
    }

    private var yDomain: ClosedRange<Double> {
        let values = samples.map(\.value)
        let minVal = (values.min() ?? 60) - 10
        let maxVal = (values.max() ?? 200) + 10
        return max(0, minVal)...maxVal
    }
}
