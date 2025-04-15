//
//  MusicPlayerView.swift
//  AVKitPlayer
//
//  Created by Htet Moe Phyu on 4/8/25.
//

import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    @State private var progress: Double = 0
    @State private var isPlaying = false
    @State private var isFinished = false
    @State private var player: AVPlayer?
    @State private var duration: Double = 0
    @State private var timeObserver: Any?

    let audioURL = URL(
        string: "https://www.bensound.com/bensound-music/bensound-sunny.mp3"
    )!

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [Color(red: 0.32, green: 0.0, blue: 0.37), .black]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                
                // Top Bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    Text("Now Playing")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                // Album Art
                Image("music") // replace with image url
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Title and Artist
                VStack(spacing: 4) {
                    Text("Sunny")
                        .foregroundColor(.cyan)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Benjamin Tissot")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.subheadline)
                }

                // Progress Bar
                VStack(spacing: 4) {
                    Slider(
                        value: $progress,
                        in: 0...(duration == 0 ? 1 : duration),
                        onEditingChanged: sliderEditingChanged
                    )
                    .accentColor(.cyan)

                    HStack {
                        Text(formatTime(seconds: progress))
                        Spacer()
                        Text(
                            "-\(formatTime(seconds: max(duration - progress, 0)))"
                        )
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal)

                // Playback Controls
                HStack(spacing: 48) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Button(action: togglePlayPause) {
                        Image(
                            systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill"
                        )
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                    }
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }

                // Add & Favorite
                HStack {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 48)

                // Lyrics toggle
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Lyrics")
                        Image(systemName: "chevron.up")
                    }
                    .foregroundColor(.white)
                }

                Spacer()
            }
            .padding(.top, 40)
            .onAppear(perform: setupPlayer)
            .onDisappear(perform: cleanupPlayer)
        }
    }

    // MARK: - Setup

    func setupPlayer() {
        let newPlayer = AVPlayer(url: audioURL)
        player = newPlayer

        // Time observer
        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserver = newPlayer
            .addPeriodicTimeObserver(
                forInterval: interval,
                queue: .main
            ) { time in
                progress = time.seconds
                if let total = newPlayer.currentItem?.duration.seconds, total.isFinite {
                    duration = total
                }
            }

        // End-of-play observer
        NotificationCenter.default
            .addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                         object: newPlayer.currentItem,
                         queue: .main) { _ in
                isPlaying = false
                isFinished = true
                progress = 0
            }
    }

    func cleanupPlayer() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    // MARK: - Playback Controls
    func togglePlayPause() {
        guard let player = player else { return }

        if isFinished {
            player.seek(to: .zero)
            isFinished = false
        }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }

        isPlaying.toggle()
    }

    func sliderEditingChanged(editing: Bool) {
        guard let player = player,
              let duration = player.currentItem?.duration.seconds,
              duration.isFinite else { return }

        if !editing {
            let newTime = CMTime(seconds: progress, preferredTimescale: 600)
            player.seek(to: newTime)
        }
    }

    func formatTime(seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    MusicPlayerView()
}
