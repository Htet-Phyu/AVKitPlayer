//
//  VideoPlayerView.swift
//  AVKitPlayer
//
//  Created by Htet Moe Phyu on 3/20/25.

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State private var pipController: AVPictureInPictureController?
    @State private var player: AVPlayer?
    let videoURL = URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!

    var body: some View {
        VStack {
            VideoView(pipController: $pipController, player: $player)
                .frame(height: 300)
        }
        .onAppear {
            initializePlayer()
            configureAudioSession()
        }
    }

    // Initialize AVPlayer if not already initialized
    private func initializePlayer() {
        if player == nil {
            player = AVPlayer(url: videoURL)
            
            player?.play() // Ensure the player starts playing
            print("Player initialized and playing.")
        }
    }

    // Configure audio session for background playback
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("Audio session configured for background playback.")
        } catch {
            print("Failed to configure audio session for background playback: \(error)")
        }
    }
}

struct VideoView: View {
    @Binding var pipController: AVPictureInPictureController?
    @Binding var player: AVPlayer?

    @State private var pipControllerDelegate: PiPControllerDelegate?

    var body: some View {
        ZStack {
            if let p = player {
                AVPlayerLayerView(player: p)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear(perform: configurePiP)
    }

    // Configure PiP if supported
    private func configurePiP() {
        guard let player = player else { return }

        // Initialize PiP if supported
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipControllerDelegate = PiPControllerDelegate()
            pipController = AVPictureInPictureController(playerLayer: AVPlayerLayer(player: player))
            pipController?.delegate = pipControllerDelegate
            print("PiP Controller initialized successfully.")
        } else {
            print("PiP is NOT supported on this device.")
        }
    }
}

class PiPControllerDelegate: NSObject, AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP is starting!")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP has stopped!")
    }
}

struct AVPlayerLayerView: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Handle updates if necessary
    }
}

    
