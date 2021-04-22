//
//  HomeViewController.swift
//  newsletterSubscribe
//
//  Created by Lau on 03/04/2021.
//

import UIKit
import AVKit

class HomeViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    let emailTextField: CustomTextField
    let subscribeButton: CustomButton
    
    var VStackTop = UIStackView()
    var VStackBottom = UIStackView()
    
    private var videoPlayer: AVPlayer?
    private var videoPlayerLayer: AVPlayerLayer?
    
    var playerLooper: AVPlayerLooper?
    var queuePlayer: AVQueuePlayer?
    
    // MARK: - Properties
    
    var slides: [UIView: URL?] {
        return Slide.createSlides()
    }
    
    // MARK: - Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.scrollView = UIScrollView()
        self.pageControl = UIPageControl()
        self.emailTextField = CustomTextField(withPlaceholder: "Adresse email")
        self.subscribeButton = CustomButton(title: "Connexion", textColor: .white, withBackgroundColor: .black, font: Constant.font.font20, underline: nil, cornerRadius: 20)
        
        VStackTop.addArrangedSubview(pageControl)
        VStackBottom.addArrangedSubview(emailTextField)
        VStackBottom.addArrangedSubview(subscribeButton)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        view.addSubview(self.scrollView)
        createScroolView()
        setupSlideScrollView(slides: slides, scrollView: scrollView)
        
        self.scrollView.addSubview(self.pageControl)
        self.scrollView.addSubview(self.emailTextField)
        self.scrollView.addSubview(self.subscribeButton)
        
        createPageControl()
        createEmailTextField()
        createSubscribeButton()
        
        emailTextField.delegate = self
        scrollView.delegate = self
        
    }
    
    private func setupSlideScrollView(slides : [UIView: URL?], scrollView: UIScrollView) {
        slides.enumerated().forEach { (index, item) in
            item.key.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(item.key)
            item.key.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            item.key.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: view.frame.width * CGFloat(index)).isActive = true
            item.key.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            item.key.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            self.pageControl.numberOfPages = slides.count
            setUpBackgroundVideo(view: item.key, url: item.value!)
        }
    }
    
    fileprivate func setUpBackgroundVideo(view: UIView, url: URL) {
        let item = AVPlayerItem(url: url)
        videoPlayer = AVPlayer(playerItem: item)
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        // adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: 0,
                                         y: 0,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
        
        // add it to the view and play it
        guard videoPlayer != nil else { return }
        videoPlayer!.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        videoPlayer!.playImmediately(atRate: 1)
        videoPlayerLayer?.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer!.currentItem)
        videoPlayer!.seek(to: CMTime.zero)
        videoPlayer!.play()
        self.videoPlayer?.isMuted = true
    }
    
    @objc func playerItemEnded() {
        videoPlayer!.seek(to: CMTime.zero)
    }
    
    fileprivate func createScroolView() {
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
    }
    
    fileprivate func createPageControl() {
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.pageControl.currentPageIndicatorTintColor = .white
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func createEmailTextField() {
        self.emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.emailTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.10).isActive = true
        self.emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150).isActive = true
    }
    
    fileprivate func createSubscribeButton() {
        self.subscribeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.subscribeButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.10).isActive = true
        self.subscribeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.subscribeButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        self.subscribeButton.addTarget(self, action: #selector(didPressSubscribeButton), for: .touchUpInside)
    }
    // MARK: - Action
    
    @objc func didPressSubscribeButton(_ sender: UIButton) {
        guard let text = emailTextField.text else { return }
        print("email = \(text)")
    }
    
    
    // MARK: - Private Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / view.frame.width)
    }
    
}

struct Constant {
    struct font {
        static let font20: UIFont = UIFont.systemFont(ofSize: 20)
        static let font17: UIFont = UIFont.boldSystemFont(ofSize: 20)
    }
}
