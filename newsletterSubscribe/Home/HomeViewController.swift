//
//  HomeViewController.swift
//  newsletterSubscribe
//
//  Created by Lau on 03/04/2021.
//

import UIKit
import AVKit
import MessageUI
import WebKit

class HomeViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Outlets
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    let emailTextField: CustomTextField
    let subscribeButton: CustomButton
    let errorView: UIView!
    var errorLabel: CustomLabel
    let logoButton: UIButton!
    let backFromWebViewButton: CustomButton!
    let webViewLabel: CustomLabel
    
    var stackView = UIStackView()
    
    private var videoPlayer: AVPlayer?
    private var videoPlayerLayer: AVPlayerLayer?
    
    var playerLooper: AVPlayerLooper?
    var queuePlayer: AVQueuePlayer?
    var myWebView: WKWebView!
    
    var viewModel = HomeViewModel.shared
    
    // MARK: - Properties
    
    var slides: [UIView: URL?] {
        return Slide.createSlides()
    }
    
    // MARK: - Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        self.scrollView = UIScrollView()
        self.emailTextField = CustomTextField(withPlaceholder: "Adresse email")
        self.subscribeButton = CustomButton(title: "Je m'inscris", textColor: .white, withBackgroundColor: .black, font: Constant.font.font20, underline: nil, cornerRadius: 20)
        self.errorView = CustomView(backgroundUIColor: UIColor.white.withAlphaComponent(0.4), radius: 15)
        self.errorLabel = CustomLabel(textString: "Oups une erreur en tappant votre email ?\nEssayez encore !", color: UIColor(named: "red-rdt")!, textFont: Constant.font.font20Bold)
        self.pageControl = UIPageControl()
        self.logoButton = UIButton()
        self.logoButton.setImage(UIImage(named: "logo-rdt"), for: .normal)
        self.backFromWebViewButton = CustomButton(title: "Retour", textColor: UIColor.black, withBackgroundColor: UIColor.clear, font: Constant.font.font14, underline: .none, cornerRadius: 0)
        self.webViewLabel = CustomLabel(textString: "Descendez tout en bas\npour vous inscrire et obtenir votre remise en ligne", color: UIColor(named: "green-rdt")!, textFont: Constant.font.font14)
        
        stackView.addArrangedSubview(errorView)
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(subscribeButton)
        stackView.addArrangedSubview(pageControl)
        stackView.addArrangedSubview(logoButton)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind(to: viewModel)
        
        viewModel.viewWillAppear()
    }
    
    private func bind(to viewModel: HomeViewModel) {
        viewModel.isHidden = { [weak self] state in
            self?.errorView.isHidden = state
        }
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tap)
        
        view.addSubview(self.scrollView)
        createScroolView()
        setupSlideScrollView(slides: slides, scrollView: scrollView)
        
        errorView.isHidden = true
        self.scrollView.addSubview(self.errorView)
        self.errorView.addSubview(self.errorLabel)
        self.scrollView.addSubview(self.emailTextField)
        self.scrollView.addSubview(self.subscribeButton)
        self.scrollView.addSubview(self.pageControl)
        self.scrollView.addSubview(self.logoButton)
        
        createErrorView()
        createEmailTextField()
        createSubscribeButton()
        createPageControl()
        createLogoButton()
        
        emailTextField.delegate = self
        scrollView.delegate = self
        
        settingNotificationCenter()
        
        viewModel.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    // MARK: - Action
    
    @objc func didPressSubscribeButton(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        viewModel.didPressSubscribeButton(email: email)
        viewModel.canSendEmail = { [weak self] state in
            if state == true {
                self!.sendEmail(email: email)
            }
        }
    }
    
    @objc func didPressLogoButton() {
        let url = viewModel.setURL()
        myWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        myWebView.load(NSURLRequest(url: url) as URLRequest)
        self.view.addSubview(myWebView)
        myWebView.addSubview(backFromWebViewButton)
        myWebView.addSubview(webViewLabel)
        createBackButton()
        createWebViewLabel()
    }
    
    @objc func didPressBackFromWebViewButton() {
        myWebView.isHidden = true
    }
    
    @objc private func keyboardWillChange(notification: Notification) {
        
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.view.frame.origin.y = -(keyboardHeight)
        } else {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc private func hideKeyBoard() {
        emailTextField.resignFirstResponder()
    }
    
    // MARK: - Private Functions
    
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
        
        videoPlayer!.play()
        
        videoPlayer?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemEnded), name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: videoPlayer?.currentItem)
        self.videoPlayer?.isMuted = true
    }
    
    @objc func playerItemEnded(_ notification : Notification) {
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: CMTime.zero) { (true) in
        }
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
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyBoard()
        return true
    }
    
    private func sendEmail(email: String) {
        let messageBodyEmail = viewModel.setBodyMessage()
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setSubject("Inscription newsletter")
            mail.setMessageBody(messageBodyEmail, isHTML: true)
            
            present(mail, animated: true)
        } else {
            print("error")
        }
    }
    
    // MARK: - Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / view.frame.width)
    }
}

extension HomeViewController {
    
    // Top
    
    fileprivate func createErrorView() {
        self.errorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.errorView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        self.errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.errorView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor).isActive = true
        self.errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor).isActive = true
        self.errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor).isActive = true
        self.errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor).isActive = true
    }
    
    fileprivate func createEmailTextField() {
        self.emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.emailTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07).isActive = true
        self.emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.emailTextField.topAnchor.constraint(equalTo: errorView.bottomAnchor, constant: 20).isActive = true
    }
    
    fileprivate func createSubscribeButton() {
        self.subscribeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.subscribeButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08).isActive = true
        self.subscribeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.subscribeButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        self.subscribeButton.addTarget(self, action: #selector(didPressSubscribeButton), for: .touchUpInside)
    }
    
    // Bottom
    
    fileprivate func createPageControl() {
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.pageControl.currentPageIndicatorTintColor = .white
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func createLogoButton() {
        self.logoButton.bottomAnchor.constraint(equalTo: self.pageControl.topAnchor, constant: -10).isActive = true
        self.logoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.logoButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        self.logoButton.widthAnchor.constraint(equalTo: self.logoButton.heightAnchor, multiplier: 1.2).isActive = true
        self.logoButton.translatesAutoresizingMaskIntoConstraints = false
        self.logoButton.addTarget(self, action: #selector(didPressLogoButton), for: .touchUpInside)
    }
    
    fileprivate func createBackButton() {
        self.backFromWebViewButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        self.backFromWebViewButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        self.backFromWebViewButton.translatesAutoresizingMaskIntoConstraints = false
        self.backFromWebViewButton.addTarget(self, action: #selector(didPressBackFromWebViewButton), for: .touchUpInside)
        self.backFromWebViewButton.layer.frame.size = CGSize(width: 180, height: 150)
    }
    
    fileprivate func createWebViewLabel() {
        self.webViewLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        self.webViewLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25).isActive = true
        self.webViewLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25).isActive = true
        self.webViewLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func settingNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
