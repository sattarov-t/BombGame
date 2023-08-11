//
//  GameViewController.swift
//  BombGame
//
//  Created by Александра Савчук on 07.08.2023.
//

import UIKit
import AVKit
import AVFoundation

enum GameState {
  case idle
  case playing
  case paused
}

class GameViewController: UIViewController, AVAudioPlayerDelegate {

  var playerBG: AVAudioPlayer?
  var playerTimer: AVAudioPlayer?
  var bombSoundPlayer: AVAudioPlayer?
  var bombShortImageView: UIImageView!
  var bombLongImageView: UIImageView!
  var gameState: GameState = .idle
  var gameTimer: DispatchSourceTimer?
  var timerPausedTime: TimeInterval?
  var gameDuration: TimeInterval = 10
  var remainingTime: TimeInterval = 0
  var gamePausedTime: Date?

  let questions = DataManager.shared.categories
    .filter { UserDefaultsManager.shared.selectedCategories.contains($0.name) }
    .flatMap { $0.questions }

  let playButton = CustomButton(customTitle: "Запустить")

  private lazy var gradientView: GradientView = {
    let gradientView = GradientView(frame: view.bounds)
    gradientView.translatesAutoresizingMaskIntoConstraints = false
    return gradientView
  }()

  let textLabel: UILabel = {
    let textLabel = UILabel()
    textLabel.text = "Нажмите “Запустить” чтобы начать игру"
    textLabel.frame = CGRect(x: 24, y: 127, width: 329, height: 200)
    textLabel.numberOfLines = 0
    textLabel.lineBreakMode = .byWordWrapping
    textLabel.textColor = .purpleLabel
    textLabel.textAlignment = .center
    textLabel.font = UIFont.boldSystemFont(ofSize: 35)
    return textLabel
  } ()

  let textLabelPause: UILabel = {
    let textLabelPause = UILabel()
    textLabelPause.text = "ПАУЗА"
    textLabelPause.frame = CGRect(x: 24, y: 127, width: 329, height: 200)
    textLabelPause.numberOfLines = 0
    textLabelPause.lineBreakMode = .byWordWrapping
    textLabelPause.textColor = .purpleLabel
    textLabelPause.textAlignment = .center
    textLabelPause.font = UIFont.boldSystemFont(ofSize: 35)
    return textLabelPause
  } ()

  private lazy var timerLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 20)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Игра"
    textLabelPause.isHidden = true
    addRightNavButton()
    setup()
    subviews()
    setupConstraints()
    setupGIFs()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    gameState = .idle
    stopAllSoundsAndAnimations()
    endGame()
  }

  private func subviews() {
    view.addSubview(gradientView)
    view.addSubview(textLabel)
    view.addSubview(playButton)
    view.addSubview(textLabelPause)
    view.addSubview(timerLabel)
  }

  func setupConstraints() {
    NSLayoutConstraint.activate([
      gradientView.topAnchor.constraint(equalTo: view.topAnchor),
      gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
      playButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 2 / 3),
      playButton.heightAnchor.constraint(equalToConstant: 80),

      timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
    ])
  }

  private func stopAllSoundsAndAnimations() {
    playerBG?.stop()
    playerTimer?.stop()
    bombSoundPlayer?.stop()
    bombShortImageView.layer.removeAllAnimations()
    bombLongImageView.layer.removeAllAnimations()
    gameTimer?.cancel()
    gameTimer = nil
  }

  private func addRightNavButton() {
    let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "pause.circle"), style: .plain, target: self, action: #selector(pauseButtonPressed))
    navigationItem.rightBarButtonItem = rightBarButton
  }

  private func setup() {
    playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
  }

  @objc func playButtonPressed() {
    if gameState == .idle || gameState == .paused {
      let randomIndex = Int.random(in: 0..<questions.count)
      textLabel.text = questions[randomIndex]
      playButton.isHidden = true
      gameState = .playing
      startGameTimer()
      playBGSound()
      playTimerSound()
      startGIFLoop()
    }
  }

  @objc private func pauseButtonPressed() {
    if gameState == .playing {
      playerBG?.pause()
      playerTimer?.pause()
      timerPausedTime = playerTimer?.currentTime ?? 0
      bombSoundPlayer?.pause()
      bombShortImageView.layer.pauseAnimation()
      bombLongImageView.layer.pauseAnimation()
      gamePausedTime = Date()
      gameState = .paused
      remainingTime -= Date().timeIntervalSince(gamePausedTime ?? Date())
      textLabel.isHidden = true
      playButton.isHidden = true
      bombShortImageView.isHidden = true
      bombLongImageView.isHidden = true
      textLabelPause.isHidden = false
      gameTimer?.suspend()
    } else if gameState == .paused {
      let timeElapsed = Date().timeIntervalSince(gamePausedTime ?? Date())
      playerBG?.play()
      playerTimer?.play()
      if let pausedTime = timerPausedTime {
        playerTimer?.currentTime = pausedTime + timeElapsed
        timerPausedTime = nil
      }
      if let bombSoundPlayer = bombSoundPlayer, !bombSoundPlayer.isPlaying {
        bombSoundPlayer.play()
      }
      bombShortImageView.layer.resumeAnimation()
      bombLongImageView.layer.resumeAnimation()
      gameState = .playing
      textLabel.isHidden = false
      playButton.isHidden = true
      bombShortImageView.isHidden = false
      bombLongImageView.isHidden = false
      textLabelPause.isHidden = true
      gameTimer?.resume()
    }
  }

  
  //MARK: Play video

  private func setupGIFs() {

    guard let bombShortGIF = UIImageView.gifImageWithName(frame: CGRect(x: 0, y: 0, width: 70, height: 70) , resourceName: "bombShort") else {
      fatalError("Failed to load bombShort.gif")
    }

    guard let bombLongGIF = UIImageView.gifImageWithName(frame: CGRect(x: 0, y: 0, width: 70, height: 70), resourceName: "bombLong") else {
      fatalError("Failed to load bombLong.gif")
    }

    bombShortImageView = bombShortGIF
    bombShortImageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bombShortImageView)
    NSLayoutConstraint.activate([
      bombShortImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bombShortImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
    ])

    bombLongImageView = bombLongGIF
    bombLongImageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bombLongImageView)
    NSLayoutConstraint.activate([
      bombLongImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bombLongImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
    ])
    bombLongImageView.isHidden = true
  }

  private func startGIFLoop() {
    bombShortImageView.startAnimating()
    let timeUntilLongGIF: TimeInterval = gameDuration - 0.9
    let deadline = DispatchTime.now() + timeUntilLongGIF
    DispatchQueue.global().asyncAfter(deadline: deadline) { [weak self] in
      DispatchQueue.main.async {
        self?.switchToLongGIF()
      }
    }
  }

  @objc private func switchToLongGIF() {
    guard gameState == .playing else {
      return
    }
    bombShortImageView.isHidden = true
    bombLongImageView.isHidden = false
    bombLongImageView.startAnimating()
    let longGIFDuration: TimeInterval = 0.9
    let deadline = DispatchTime.now() + longGIFDuration
    self.playBombSound()
    DispatchQueue.global().asyncAfter(deadline: deadline) { [weak self] in
      DispatchQueue.main.async {
        if self?.gameState == .playing {
                         self?.playBombSound()
                     }
        self?.stopGIFLoop()
        let gameVC = GameEndViewController()
        self?.navigationController?.pushViewController(gameVC, animated: true)
      }
    }
  }

  @objc private func stopGIFLoop() {
    bombLongImageView.isHidden = true
    bombShortImageView.isHidden = true
    playButton.isEnabled = true
  }

  //MARK: Play sound

  private func playBGSound() {
    if let soundPath = Bundle.main.url(forResource: "fon1", withExtension: "mp3") {
      do {
        playerBG = try AVAudioPlayer(contentsOf: soundPath)
        playerBG?.numberOfLoops = -1
        playerBG?.volume = 0.5
        playerBG?.prepareToPlay()
      } catch {
        print("Ошибка создания цикла \(error)")
      }
    }
    playerBG!.play()
    DispatchQueue.main.asyncAfter(deadline: .now() + gameDuration) {
      self.playerBG!.stop()
    }
  }

  private func startGameTimer() {
    remainingTime = gameDuration
    gameTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
    gameTimer?.schedule(deadline: .now(), repeating: .seconds(1))
    gameTimer?.setEventHandler { [weak self] in
      DispatchQueue.main.async {
        self?.gameDuration -= 1
        self?.timerLabel.text = "\(self?.gameDuration ?? 0) сек"
        if self?.gameDuration == 0 {
          self?.endGame()
        }
      }
    }
    gameTimer?.resume()
  }


  private func endGame() {
    gameTimer = nil
    playerTimer = nil
  }

  private func playTimerSound() {
    DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
      if let soundPath = Bundle.main.url(forResource: "timer1", withExtension: "mp3"),
         let remainingTime = self?.remainingTime {
        do {
          self?.playerTimer = try AVAudioPlayer(contentsOf: soundPath)
          self?.playerTimer?.numberOfLoops = -1
          self?.playerTimer?.prepareToPlay()

          self?.playerTimer?.play()
          DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) { [weak self] in
            self?.playerTimer?.stop()
          }
        } catch {
          print("Ошибка создания цикла \(error)")
        }
      }
    }
  }

  private func playBombSound() {
    if let additionalSoundPath = Bundle.main.url(forResource: "explosion1", withExtension: "mp3") {
      do {
        bombSoundPlayer = try AVAudioPlayer(contentsOf: additionalSoundPath)
        bombSoundPlayer?.prepareToPlay()
        bombSoundPlayer?.play()
      } catch {
        print("Ошибка создания дополнительного звука \(error)")
      }
    }
  }
}
