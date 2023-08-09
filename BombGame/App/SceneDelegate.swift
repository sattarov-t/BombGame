//
//  SceneDelegate.swift
//  BombGame
//
//  Created by Александра Савчук on 07.08.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let rootViewController = GameEndViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)

        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goBack))
        backButton.tintColor = .blackBackButton
        rootViewController.navigationItem.leftBarButtonItem = backButton

        navigationController.navigationBar.titleTextAttributes = [
          NSAttributedString.Key.foregroundColor: UIColor.purpleColor,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)
        ]

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    @objc private func goBack() {
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
