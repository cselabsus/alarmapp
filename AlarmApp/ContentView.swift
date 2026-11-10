import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store = AlarmStore()
    @State private var time = Date.now.addingTimeInterval(60)
    @AppStorage("selectedSound") private var sound = 1

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "alarm.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            Text("Alarm")
                .font(.largeTitle.bold())

            DatePicker("Alarm time", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .disabled(store.activeAlarm != nil || store.isBusy)

            Picker("Alarm sound", selection: $sound) {
                Text("Sound 1").tag(1)
                Text("Sound 2").tag(2)
            }
            .pickerStyle(.segmented)
            .disabled(store.activeAlarm != nil || store.isBusy)

            if let date = store.scheduledDate {
                Text("Set for \(date.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("One alarm. Your sound.")
                    .foregroundStyle(.secondary)
            }

            Button {
                if store.activeAlarm != nil {
                    store.cancel()
                } else {
                    Task { await store.setAlarm(time: time, sound: sound) }
                }
            } label: {
                Text(store.isBusy ? "Setting…" : store.activeAlarm == nil ? "Set alarm" : "Cancel alarm")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(store.isBusy || !store.hasLoaded)
            Spacer()
        }
        .padding(28)
        .task { await store.observe() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active && !store.isBusy { store.refresh() }
        }
        .alert("Couldn’t update alarm", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { store.errorMessage = nil }
        } message: {
            Text(store.errorMessage ?? "Please try again.")
        }
    }
}
