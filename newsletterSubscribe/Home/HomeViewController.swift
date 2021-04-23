//
//  HomeViewController.swift
//  newsletterSubscribe
//
//  Created by Lau on 03/04/2021.
//

import UIKit
import AVKit
import MessageUI

class HomeViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Outlets
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    let emailTextField: CustomTextField
    let subscribeButton: CustomButton
    let errorView: UIView!
    let errorLabel: CustomLabel
    let logoButton: UIButton!

    
    var stackView = UIStackView()
    
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
        self.emailTextField = CustomTextField(withPlaceholder: "Adresse email")
        self.subscribeButton = CustomButton(title: "Je m'inscris", textColor: .white, withBackgroundColor: .black, font: Constant.font.font20, underline: nil, cornerRadius: 20)
        self.errorView = CustomView(backgroundUIColor: UIColor.white.withAlphaComponent(0.4), radius: 15)
        self.errorLabel = CustomLabel(textString: "Oups une erreur en tappant votre email ?\nEssayez encore !", color: UIColor(named: "red-rdt")!, textFont: Constant.font.font17)
        self.pageControl = UIPageControl()
        self.logoButton = UIButton()
        self.logoButton.setImage(UIImage(named: "logo-rdt"), for: .normal)
        
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
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tap)
        
        view.addSubview(self.scrollView)
        createScroolView()
        setupSlideScrollView(slides: slides, scrollView: scrollView)
        
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    // MARK: - Action
    
    @objc func didPressSubscribeButton(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        if validateEmail(enterEmail: email) {
            sendEmail(email: email)
        } else {
            errorView.isHidden = false
        }
    }
    
    @objc func didPressLogoButton() {
        print("didPressLogoButton")
    }
    
    @objc func playerItemEnded() {
        videoPlayer!.seek(to: CMTime.zero)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer!.currentItem)
        videoPlayer!.seek(to: CMTime.zero)
        videoPlayer!.play()
        self.videoPlayer?.isMuted = true
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
    
    fileprivate func settingNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyBoard()
        return true
    }
    
    private func sendEmail(email: String) {
        let randomInt = Int.random(in: 100000..<10000000)
        
        let messageBodyEmail = "Vous êtes inscrits à notre newsletter. Veuillez valider puis donner votre code de réduction  en caisse. Code : \(randomInt)"
        
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
    
    //Email validation
   private func validateEmail(enterEmail:String) -> Bool{
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@",emailFormat)
        return emailPredicate.evaluate(with:enterEmail)
    }

    
    // MARK: - Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
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

