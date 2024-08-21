//
//  WaveformView.swift
//  Fetal_health_V1.0
//
//  Created by School on 8/13/24.
//

import UIKit

class WaveformView: UIView {
    private var samples: [CGFloat] = []
    private let lineWidth: CGFloat = 4.0
    var waveformColor: UIColor = UIColor.red // Default color


    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
    }
    
//    func update(with samples: [CGFloat]) {
//        print("update(with:) called with \(samples.count) samples")
//
//        self.samples = samples
//        setNeedsDisplay()
//    }
    

    func update(with samples: [CGFloat]) {
        let testSamples = (0..<100).map { _ in CGFloat.random(in: 0.1...1.0) }
        self.samples = testSamples
        setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        guard !samples.isEmpty else { return }
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        
        let midY = bounds.height / 2
        let sampleWidth = bounds.width / CGFloat(samples.count)

        for (index, sample) in samples.enumerated() {
            let x = CGFloat(index) * sampleWidth
            let y = midY * (1 - sample) // Adjust this scaling if needed
            path.move(to: CGPoint(x: x, y: midY))
            path.addLine(to: CGPoint(x: x, y: y))
        }

        waveformColor.setStroke()
        path.stroke()
    }
//    override func draw(_ rect: CGRect) {
//        guard !samples.isEmpty else { return }
//        let path = UIBezierPath()
//        path.lineWidth = lineWidth
//        
//        let midY = bounds.height / 2
//        let sampleWidth = bounds.width / CGFloat(samples.count)
//
//        for (index, sample) in samples.enumerated() {
//            let x = CGFloat(index) * sampleWidth
//            let y = midY * sample
////            let y = midY * (1 - sample ) // Multiply sample by a factor to make it more visible
//            path.move(to: CGPoint(x: x, y: midY))
//            path.addLine(to: CGPoint(x: x, y: y))
//        }
//
//        UIColor.red.setStroke()
//        path.stroke()
//    }

}

