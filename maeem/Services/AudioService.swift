import AVFoundation
import Foundation

/// Service for audio playback and recording (Quran recitation)
@MainActor
class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?

    @Published var isPlaying = false
    @Published var isRecording = false
    @Published var playbackProgress: Double = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var progressTimer: Timer?

    private override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }

    // MARK: - Playback

    /// Play audio from URL (supports both local and remote URLs)
    func play(url: URL) async throws {
        stop()

        if url.isFileURL {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } else {
            let (data, _) = try await URLSession.shared.data(from: url)
            audioPlayer = try AVAudioPlayer(data: data)
        }

        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        duration = audioPlayer?.duration ?? 0
        audioPlayer?.play()
        isPlaying = true
        startProgressTimer()
    }

    /// Play audio from local file name in Resources/Audio
    func playLocal(filename: String) throws {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil, subdirectory: "Resources/Audio") else {
            throw AudioServiceError.fileNotFound
        }
        Task {
            try await play(url: url)
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startProgressTimer()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        playbackProgress = 0
        currentTime = 0
        stopProgressTimer()
    }

    func seek(to progress: Double) {
        guard let player = audioPlayer else { return }
        let time = progress * player.duration
        player.currentTime = time
        currentTime = time
        playbackProgress = progress
    }

    // MARK: - Recording

    /// Start recording audio (for recitation practice)
    func startRecording() throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "recording_\(Date().timeIntervalSince1970).m4a"
        let audioURL = documentsPath.appendingPathComponent(filename)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
        audioRecorder?.record()
        isRecording = true

        return audioURL
    }

    func stopRecording() -> URL? {
        let url = audioRecorder?.url
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        return url
    }

    // MARK: - Private

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let player = self.audioPlayer else { return }
                self.currentTime = player.currentTime
                self.playbackProgress = player.currentTime / player.duration
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.playbackProgress = 0
            self.currentTime = 0
            self.stopProgressTimer()
        }
    }
}

// MARK: - Errors

enum AudioServiceError: LocalizedError {
    case fileNotFound
    case recordingFailed
    case playbackFailed

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Audio file not found"
        case .recordingFailed:
            return "Recording failed"
        case .playbackFailed:
            return "Playback failed"
        }
    }
}
