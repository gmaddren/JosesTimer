import Foundation
import AVFoundation
import SwiftUI

public class TimerViewModel: ObservableObject {
    @Published public var timeRemaining: TimeInterval
    @Published public var isRunning = false
    @Published public var currentRound = 1
    @Published public var isWorkRound = true
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    public init() {
        self.timeRemaining = TimerConfig.workRoundDuration
        setupAudio()
    }
    
    private func setupAudio() {
        guard let soundURL = Bundle.main.url(forResource: "beep", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound: \(error)")
        }
    }
    
    public func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    public func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        timeRemaining -= 1
        
        if timeRemaining <= TimerConfig.warningTime {
            audioPlayer?.play()
        }
        
        if timeRemaining <= 0 {
            switchRound()
        }
    }
    
    private func switchRound() {
        if isWorkRound {
            isWorkRound = false
            timeRemaining = TimerConfig.restRoundDuration
        } else {
            isWorkRound = true
            timeRemaining = TimerConfig.workRoundDuration
            currentRound += 1
        }
        
        if currentRound > TimerConfig.totalRounds {
            stopTimer()
            currentRound = 1
        }
    }
}
