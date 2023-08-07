//
//  GameEndViewController.swift
//  BombGame
//
//  Created by Александра Савчук on 07.08.2023.
//

import Foundation
import UIKit

class GameEndViewController: UIViewController {
    
    private lazy var gradientView: GradientView = {
      let gradientView = GradientView(frame: view.bounds)
      gradientView.translatesAutoresizingMaskIntoConstraints = false
      return gradientView
    }()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subviews()
        setupConstraints()
    }
    
    private func subviews() {
      view.addSubview(gradientView)
    }

    func setupConstraints() {
      NSLayoutConstraint.activate([
        gradientView.topAnchor.constraint(equalTo: view.topAnchor),
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
    }
}
