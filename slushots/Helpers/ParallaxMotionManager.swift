//
//  ParallaxMotionManager.swift
//  slushots
//
//  Created by Anatoliy Petrov on 1.2.25..
//


import CoreMotion
import SwiftUI

class ParallaxMotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    
    @Published var xOffset: CGFloat = 0
    @Published var yOffset: CGFloat = 0
    
    init() {
        startMotionUpdates()
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0  
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion = motion else { return }
            
            DispatchQueue.main.async {
                self?.xOffset = CGFloat(motion.attitude.roll) * 10
                self?.yOffset = CGFloat(motion.attitude.pitch) * 10
            }
        }
    }
}
