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
import FirebaseFirestore

class HomeViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Outlets
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    let nameTextField: CustomTextField
    let emailTextField: CustomTextField
    let subscribeButton: CustomButton
    let errorView: CustomView
    let subscriptionValidatedView: CustomView
    let subscriptionValidatedLabel: CustomLabel
    var errorLabel: CustomLabel
    let logoButton: CustomButton
    let backFromWebViewButton: CustomButton!
    let webViewLabel: CustomLabel
    let bottomLabel: CustomLabel
    
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
    
    var swipe: UISwipeGestureRecognizer!
    
    var state: Bool = false
    
    private var data: [HomeDataItem] = []
    
    // MARK: - Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        self.scrollView = UIScrollView()
        self.emailTextField = CustomTextField(typeKeyboard: .emailAddress)
        self.nameTextField = CustomTextField(typeKeyboard: .default)
        self.subscribeButton = CustomButton(textColor: .white, withBackgroundColor: .black, font: Constant.font.font20, underline: nil, cornerRadius: 20)
        self.errorView = CustomView(backgroundUIColor: UIColor.white.withAlphaComponent(0.4), radius: 15)
        self.errorLabel = CustomLabel(color: Constant.color.red, textFont: Constant.font.font20Bold)
        self.pageControl = UIPageControl()
        self.bottomLabel = CustomLabel(color: .white, textFont: Constant.font.font20)
        self.logoButton = CustomButton()
        self.backFromWebViewButton = CustomButton(textColor: UIColor.black, withBackgroundColor: UIColor.clear, font: Constant.font.font14, underline: .none, cornerRadius: 0)
        self.webViewLabel = CustomLabel(color: Constant.color.green, textFont: Constant.font.font14)
        self.subscriptionValidatedView = CustomView(backgroundUIColor: .white, radius: 20)
        self.subscriptionValidatedLabel = CustomLabel(color: .black, textFont: Constant.font.font20)
        
        stackView.addArrangedSubview(errorView)
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(subscribeButton)
        stackView.addArrangedSubview(pageControl)
        stackView.addArrangedSubview(bottomLabel)
        stackView.addArrangedSubview(logoButton)
        stackView.addArrangedSubview(subscriptionValidatedView)
        stackView.addArrangedSubview(subscriptionValidatedLabel)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind(to: viewModel)
        viewModel.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tap)
        
        view.addSubview(self.scrollView)
        createScroolView()
        setupSlideScrollView(slides: slides, scrollView: scrollView)
        
        self.scrollView.addSubview(self.errorView)
        self.errorView.addSubview(self.errorLabel)
        self.scrollView.addSubview(self.emailTextField)
        self.scrollView.addSubview(self.nameTextField)
        self.scrollView.addSubview(self.subscribeButton)
        self.scrollView.addSubview(self.pageControl)
        self.scrollView.addSubview(self.bottomLabel)
        self.scrollView.addSubview(self.logoButton)
        self.scrollView.addSubview(self.subscriptionValidatedView)
        self.subscriptionValidatedView.addSubview(self.subscriptionValidatedLabel)
        
        createErrorView()
        createEmailTextField()
        createNameTextField()
        createSubscribeButton()
        createPageControl()
        createBottomLabel()
        createLogoButton()
        createSubscriptionValidatedView()
        
        emailTextField.delegate = self
        scrollView.delegate = self
        
        settingNotificationCenter()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    // MARK: - Action
    
    @objc func didPressOutOfElements(_ sender: UIView) {
        hideKeyBoard()
    }
    
    @objc func didPressSubscribeButton(_ sender: UIButton) {
        let name = nameTextField.text
        let email = emailTextField.text
        viewModel.didPressSubscribeButton(name: name, email: email)
        if state == true {
            self.sendEmail(email: email!)
            subscriptionValidatedView.isHidden = false
        }
    }
    
    @objc func didPressLogoButton() {
        let url = viewModel.setURL()
        myWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        myWebView.load(NSURLRequest(url: url) as URLRequest)
        self.view.addSubview(myWebView)
        myWebView.addSubview(backFromWebViewButton)
        createBackButton()
    }
    
    @objc func didPressBackFromWebViewButton() {
        myWebView.isHidden = true
    }
    
    @objc private func keyboardWillChange(notification: Notification) {
        
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height - 70
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.view.frame.origin.y = -(keyboardHeight)
        } else {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc private func hideKeyBoard() {
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        errorView.isHidden = true
        subscriptionValidatedView.isHidden = true
    }
    
    // MARK: - Private Functions
    
    fileprivate func bind(to viewModel: HomeViewModel) {
        viewModel.errorViewIsHidden = { [weak self] state in
            self?.errorView.isHidden = state
        }
        viewModel.canSendEmail = { [weak self] state in
            self?.state = state
        }
        viewModel.errorText = { [weak self] text in
            self?.errorLabel.text = text
        }
        viewModel.visibleItems = { [weak self] items in
            guard let data = items.first else { return }
            guard let self = self else { return }
            self.emailTextField.attributedPlaceholder = NSAttributedString(string: data.emailTextField, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            self.nameTextField.attributedPlaceholder = NSAttributedString(string: data.nameTextField, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            self.subscribeButton.setTitle(data.subscribeButton, for: .normal)
            self.backFromWebViewButton.setTitle(data.backButton, for: .normal)
            self.bottomLabel.text = data.bottomLabel
            self.subscriptionValidatedLabel.text = data.subscriptionValidatedLabel
            self.logoButton.setImage(Constant.image.logo, for: .normal)
        }
        viewModel.validatedViewIsHidden = { [weak self] state in
            self?.subscriptionValidatedView.isHidden = state
        }
    }
    
    fileprivate func setUpBackgroundVideo(view: UIView, url: URL) {
        let item = AVPlayerItem(url: url)
        videoPlayer = AVPlayer(playerItem: item)
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        videoPlayerLayer?.frame = CGRect(x: 0,
                                         y: 0,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
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
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyBoard()
        return true
    }
    
    fileprivate func settingNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    fileprivate func sendEmail(email: String) {
        guard let emailData = viewModel.setEmailData().first else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setSubject(emailData.key)
            mail.setMessageBody(emailData.value, isHTML: true)
            
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

// MARK: - Constraints

extension HomeViewController {
    
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
    
    // Top
    
    fileprivate func createErrorView() {
        self.errorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.errorView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        self.errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.errorView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
        
        self.errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor).isActive = true
        self.errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor).isActive = true
        self.errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor).isActive = true
        self.errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor).isActive = true
    }
    
    fileprivate func createNameTextField() {
        self.nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.nameTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06).isActive = true
        self.nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.nameTextField.topAnchor.constraint(equalTo: errorView.bottomAnchor, constant: 20).isActive = true
    }
    
    fileprivate func createEmailTextField() {
        self.emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.emailTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06).isActive = true
        self.emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20).isActive = true
    }
    
    fileprivate func createSubscribeButton() {
        self.subscribeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.subscribeButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07).isActive = true
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
    
    fileprivate func createBottomLabel() {
        self.bottomLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        self.bottomLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25).isActive = true
        self.bottomLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25).isActive = true
        self.bottomLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func createLogoButton() {
        self.logoButton.bottomAnchor.constraint(equalTo: self.bottomLabel.topAnchor, constant: -10).isActive = true
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
    
    fileprivate func createSubscriptionValidatedView() {
        self.subscriptionValidatedView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        self.subscriptionValidatedView.heightAnchor.constraint(equalTo: subscriptionValidatedView.widthAnchor).isActive = true
        self.subscriptionValidatedView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.subscriptionValidatedView.centerYAnchor.constraint(equalTo: emailTextField.centerYAnchor, constant: -20).isActive = true
        
        self.subscriptionValidatedLabel.topAnchor.constraint(equalTo: subscriptionValidatedView.topAnchor).isActive = true
        self.subscriptionValidatedLabel.bottomAnchor.constraint(equalTo: subscriptionValidatedView.bottomAnchor).isActive = true
        self.subscriptionValidatedLabel.leadingAnchor.constraint(equalTo: subscriptionValidatedView.leadingAnchor, constant: 20).isActive = true
        self.subscriptionValidatedLabel.trailingAnchor.constraint(equalTo: subscriptionValidatedView.trailingAnchor, constant: -20).isActive = true
        
    }
}
