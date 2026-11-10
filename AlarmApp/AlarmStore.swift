import AlarmKit
import AVFoundation
import Observation
import SwiftUI

struct AlarmInfo: AlarmMetadata {}

@MainActor
@Observable
final class AlarmStore {
    // One stable identifier prevents duplicate alarms across launches.
    private let alarmID = UUID(uuidString: "B8D9C284-14B0-4B38-A190-DBD034239710")!
    private let manager = AlarmManager.shared
    private(set) var activeAlarm: Alarm?
    private(set) var isBusy = false
    private(set) var hasLoaded = false
    var errorMessage: String?

    var scheduledDate: Date? {
        guard let activeAlarm, case .fixed(let date) = activeAlarm.schedule else { return nil }
        return date
    }

    func refresh() {
        // First launch must leave Set enabled so it can request permission.
        guard manager.authorizationState == .authorized else {
            activeAlarm = nil
            hasLoaded = true
            return
        }
        do {
            activeAlarm = try manager.alarms.first { $0.id == alarmID }
            hasLoaded = true
        } catch {
            hasLoaded = false
            errorMessage = error.localizedDescription
        }
    }

    func observe() async {
        refresh()
        for await _ in manager.alarmUpdates {
            guard !Task.isCancelled else { return }
            // Read current system state instead of applying a potentially stale event.
            if !isBusy { refresh() }
        }
    }

    func setAlarm(time: Date, sound: Int) async {
        guard !isBusy, hasLoaded, activeAlarm == nil else { return }
        isBusy = true
        defer {
            isBusy = false
            refresh()
        }
        do {
            let authorization = try await manager.requestAuthorization()
            guard authorization == .authorized else {
                errorMessage = "Allow alarms for AlarmApp in Settings, then try again."
                return
            }
            let filename = "alarm\(sound)"
            guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
                errorMessage = "Missing \(filename).wav. Add it to the app’s Sounds folder and rebuild."
                return
            }
            let audio = try AVAudioPlayer(contentsOf: url)
            guard audio.duration > 0, audio.duration < 30 else {
                errorMessage = "Use a WAV sound shorter than 30 seconds."
                return
            }
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            guard let date = Calendar.current.nextDate(
                after: .now,
                matching: components,
                matchingPolicy: .nextTime
            ) else {
                errorMessage = "Couldn’t find the next occurrence of that time."
                return
            }
            let alert = AlarmPresentation.Alert(
                title: "Alarm",
                stopButton: AlarmButton(text: "Stop", textColor: .white, systemImageName: "stop.fill")
            )
            let attributes = AlarmAttributes(
                presentation: AlarmPresentation(alert: alert),
                metadata: AlarmInfo(),
                tintColor: .orange
            )
            let configuration = AlarmManager.AlarmConfiguration.alarm(
                schedule: .fixed(date),
                attributes: attributes,
                sound: .named("\(filename).wav")
            )
            activeAlarm = try await manager.schedule(id: alarmID, configuration: configuration)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancel() {
        guard !isBusy, activeAlarm != nil else { return }
        isBusy = true
        defer {
            isBusy = false
            refresh()
        }
        do {
            try manager.cancel(id: alarmID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
