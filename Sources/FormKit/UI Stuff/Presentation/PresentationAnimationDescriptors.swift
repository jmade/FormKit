import UIKit

public struct PresentationDescriptors {
    
   public struct Presentation {
        // This describes what the Presented Frame is on the Screen...
       public struct Frame {
            
           public static func centered() -> PresentedFrameClosure {
                let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
                    return CGRect(
                        origin: CGPoint((containerBounds.size.width - size.width)/2, (containerBounds.size.height - size.height)/2),
                        size: size)
                }
                return presentedFrame
            }
            
          public  static func upper() -> PresentedFrameClosure {
                let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
                  return CGRect(
                        origin: CGPoint((containerBounds.size.width - size.width)/2, (containerBounds.height/3)/2),
                        size: size)
                }
                return presentedFrame
            }
            
           public static func lowerThird() -> PresentedFrameClosure {
                let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
                    return CGRect(
                        origin: CGPoint(0,containerBounds.height-containerBounds.height/3),
                        size: size)
                }
                return presentedFrame
            }
            
        }
        
        
        
        
        
        
        
       public struct Animation {
            
           public static func fadeInOverlay(_ duration:TimeInterval = 0.3) -> TransitioningContextClosure {
                return { (context) in
                    let presentationVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
                    // Customize Views for Display
                    PresentationDescriptors.roundCorners(presentationVC.view, .all)
                    // Initial Frames
                    // set the initial frame as the final frame, since were fading it in.
                    presentationVC.view.frame = context.finalFrame(for: presentationVC)
                    context.containerView.addSubview(presentationVC.view)
                    presentationVC.view.alpha = 0.0
                    presentationVC.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                    // Animate Transition
                    UIView.animate(withDuration: duration, animations: {
                        presentationVC.view.transform = .identity
                        presentationVC.view.alpha = 1.0
                    }) { context.completeTransition($0) }
                }
            }
            
            
           public static func upFromBottom(_ duration:TimeInterval = 0.3) -> TransitioningContextClosure {
                return { (context) in
                    let presentationVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
                    // Customize Views for Display
                    PresentationDescriptors.roundCorners(presentationVC.view, .all)
                    // Initial Frames
                    // set the initial frame as the final frame, since were fading it in.
                    presentationVC.view.frame = context.finalFrame(for: presentationVC)
                    presentationVC.view.frame.y += context.containerView.bounds.height
                    context.containerView.addSubview(presentationVC.view)
                    // Animate Transition
                    UIView.animate(withDuration: duration, animations: {
                        presentationVC.view.frame = context.finalFrame(for: presentationVC)
                    }) { context.completeTransition($0) }
                }
            }
            
            
            
            
        }
        
    }
    
    
   public struct Dismissal {
        
       public struct Animation {
            
            public static func fadeOutOverlay(_ duration:TimeInterval = 0.3) -> TransitioningContextClosure {
                return { (context) in
                    let dismissedVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
                    // Animate Transition
                    UIView.animate(withDuration: duration, animations: {
                        dismissedVC.view.alpha = 0.0
                        dismissedVC.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                    }) { context.completeTransition($0) }
                }
            }
            
            
           public static func downToBottom(_ duration:TimeInterval = 0.3) -> TransitioningContextClosure {
                return { (context) in
                    let dismissedVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
                    // Animate Transition
                    UIView.animate(withDuration: duration, animations: {
                        //dismissedVC.view.alpha = 0.0
                        dismissedVC.view.frame.y = dismissedVC.view.frame.y + dismissedVC.view.bounds.height
                    }) { context.completeTransition($0) }
                }
            }
            
        }
    }
    
    
    // Presentation Frame

    
    //: MARK: - Presentations -
    //
   public static func presentNotesFromOptionsMenu(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            // Shift Options
            let shiftOptionsSize = shiftOptionsController.view.bounds.size
            
            let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let toFinalFrame = context.finalFrame(for: toVC)
            
            // Add Notes to Container
            context.containerView.addSubview(toVC.view)
            // Prepare Notes View
            roundCorners(toVC.view, .all)
            
            // Prepare Notes View
            toVC.view.frame = toFinalFrame
            toVC.view.alpha = 0.8
            toVC.view.transform = CGAffineTransform(translationX: 0.0, y: -500.0)
            
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                shiftOptionsController.view.frame.y += shiftOptionsSize.height
                shiftOptionsController.view.alpha = 0.0
                
                toVC.view.alpha = 1.0
                toVC.view.transform = .identity
                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to:nil, from:nil, for:nil)
            }) { context.completeTransition($0) }
        }
    }
    
    public
    static func presentActuals(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
//            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
//            // Shift Options
//            let shiftOptionsSize = shiftOptionsController.view.bounds.size
            
            let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let toFinalFrame = context.finalFrame(for: toVC)
            
            // Add Notes to Container
            context.containerView.addSubview(toVC.view)
            // Prepare Notes View
            roundCorners(toVC.view, .all)
            
            // Prepare Notes View
            toVC.view.frame = toFinalFrame
            toVC.view.alpha = 0.8
            toVC.view.transform = CGAffineTransform(translationX: 0.0, y: -500.0)
            
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
//                shiftOptionsController.view.frame.y += shiftOptionsSize.height
//                shiftOptionsController.view.alpha = 0.0
                
                toVC.view.alpha = 1.0
                toVC.view.transform = .identity
                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to:nil, from:nil, for:nil)
            }) { context.completeTransition($0) }
        }
    }
    
    public
    static func halfScreenPresentation(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
            let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let toFinalFrame = context.finalFrame(for: toVC)
            
            // setup the Views
            toVC.view.frame = toFinalFrame
            toVC.view.frame.origin.y = context.containerView.bounds.height
            toVC.view.alpha = 0.5
            
            // add the `to` View controller
            context.containerView.addSubview(toVC.view)
            
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                toVC.view.frame = toFinalFrame
                toVC.view.alpha = 1.0
            }) { context.completeTransition($0) }
        }
    }
    
    public
    static func presentFullFromOptionsMenu(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
            
            // Shift Options Menu is the `From` Controller.
            // We need to dismiss it while presenting the Full Screen Overlay
            
            // Identify Controllers
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            // Shift Options
            let shiftOptionsSize = shiftOptionsController.view.bounds.size

            let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            // Customize Views for Display
            roundCorners(toVC.view, .all)
            // Initial Frames
            // set the initial frame as the final frame, since were fading it in.
            toVC.view.frame = context.finalFrame(for: toVC)
            context.containerView.addSubview(toVC.view)
            toVC.view.alpha = 0.0
            toVC.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                // From
                shiftOptionsController.view.frame.y += shiftOptionsSize.height
                shiftOptionsController.view.alpha = 0.0
                // To
                toVC.view.transform = .identity
                toVC.view.alpha = 1.0
            }) { context.completeTransition($0) }
        }
    }

    
    
    
    
    //: MARK: - Dismissals -
    public
    static func dismissBottomOfScreen(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
            let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            
            UIView.animate(withDuration: duration, animations: {
                fromVC.view.frame.y = context.containerView.bounds.height
                fromVC.view.alpha = 0.0
            }) {context.completeTransition($0)}
        }
    }
    
    public
    static func dismissFullToOptionsMenu(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
            
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            let optionsHeight = context.containerView.bounds.height - shiftOptionsController.view.bounds.size.height
            shiftOptionsController.view.alpha = 0.0
            
            UIView.animate(withDuration: duration, animations: {
                // From
                fromVC.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                fromVC.view.alpha = 0.0
                // To
                shiftOptionsController.view.frame.y = optionsHeight
                shiftOptionsController.view.alpha = 1.0
            }) {context.completeTransition($0)}
        }
    }
    
    public
    static func notesDismissalToOptionsMenu(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
            let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let optionsHeight = context.containerView.bounds.height - shiftOptionsController.view.bounds.size.height
            shiftOptionsController.view.alpha = 0.0
            
            UIView.animate(withDuration: duration, animations: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                fromVC.view.transform = CGAffineTransform(translationX: 0.0, y: -500.0)
                shiftOptionsController.view.frame.y = optionsHeight
                shiftOptionsController.view.alpha = 1.0
            }) {context.completeTransition($0)}
        }
    }
    
    public
    static func ActualsDismissal(_ duration:TimeInterval) -> TransitioningContextClosure {
        return { (context) in
            let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)!

            UIView.animate(withDuration: duration, animations: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                fromVC.view.transform = CGAffineTransform(translationX: 0.0, y: -500.0)
            }) {context.completeTransition($0)}
        }
    }
    
    
    
    
    
    
    //: MARK: - AnimationDescriptors -
    
    
    // this is descriptor that will animate the options menu on the screen
    public
    static func presentShiftOptionsMenu() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation = halfScreenPresentation(duration)
        let dismissal = dismissBottomOfScreen(duration)
        // Presentation Frame
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            var presentedViewFrame = CGRect.zero
            presentedViewFrame.size = size
            if containerBounds.width > containerBounds.height {
                presentedViewFrame.origin = CGPoint(containerBounds.size.width/2 - presentedViewFrame.size.width/2, containerBounds.size.height - presentedViewFrame.size.height)
            } else {
                presentedViewFrame.origin = CGPoint(0, (containerBounds.size.height - presentedViewFrame.size.height))
            }
            return presentedViewFrame
        }
        

        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if parentSize.width > parentSize.height {
                let size = min(parentSize.width,parentSize.height)
                return CGSize(size * 1.25, parentSize.height * 0.70)
            } else {
                let size = min(parentSize.width,parentSize.height)
                return CGSize(size, parentSize.height * 0.50)
            }
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
    }

    
    // Shift Options will be presenting...
    // we will need to dismiss the shift options view as we are presenting the next view.
    // then upon dismissal we need to present the options back on screen
    public
    static func scaleTicket() -> PresentationAnimationDescriptor {
        let dimBackground = false
        let duration = 0.3
        
        let presentation = presentFullFromOptionsMenu(duration)
        let dismissal = dismissFullToOptionsMenu(duration)
        
        // Presentation Frame
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            return CGRect(
                origin: CGPoint((containerBounds.size.width - size.width)/2, (containerBounds.size.height - size.height)/2),
                size: size)
        }
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: parentSize.width * 0.65, height: parentSize.height * 0.62)
            } else {
                if parentSize.width > parentSize.height {
                     return CGSize(width: parentSize.width * 0.80, height: parentSize.height * 0.80)
                } else {
                    return CGSize(width: parentSize.width * 0.95, height: parentSize.height * 0.80)
                }
            }
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
    }
    
    public
    static func shiftNotes() -> PresentationAnimationDescriptor {
        let dimBackground = false
        let duration = 0.3
        let presentation = presentNotesFromOptionsMenu(duration)
        let dismissal = notesDismissalToOptionsMenu(duration)
        
        // Presentation Frame
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            return CGRect(
                origin: CGPoint((containerBounds.size.width - size.width)/2, containerBounds.size.height * 0.15),
                size: size
            )
        }
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: parentSize.width * 0.65, height: parentSize.height * 0.33)
            } else {
                if parentSize.width > parentSize.height {
                    return CGSize(width: parentSize.width * 0.80, height: parentSize.height * 0.33)
                } else {
                    return CGSize(width: parentSize.width * 0.95, height: parentSize.height * 0.33)
                }
            }
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
    }
    
    
    public
    static func actualsNotes(_ withHiredHauler:Bool = false) -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation = presentActuals(duration)
        let dismissal = ActualsDismissal(duration)
        
        // Presentation Frame
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            return CGRect(
                origin: CGPoint((containerBounds.size.width - size.width)/2, containerBounds.size.height * 0.15),
                size: size
            )
        }
        
        var height: CGFloat = 184
        
        if withHiredHauler {
            height = 264
        }
        
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: parentSize.width * 0.65, height: height)
            } else {
                if parentSize.width > parentSize.height {
                    return CGSize(width: parentSize.width * 0.80, height: height)
                } else {
                    return CGSize(width: parentSize.width * 0.95, height: height)
                }
            }
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
    }
    
    
}


//: MARK: - Custom Alert -  
extension PresentationDescriptors {
    public
    static func customAlert() -> PresentationAnimationDescriptor {
        
        let dimBackground = true
        let duration = 0.3
        
        let presentation: TransitioningContextClosure = { (context) in
            let dateInputController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            // Set Frame
            dateInputController.view.frame = context.finalFrame(for: dateInputController)
            // Customize Views for Display
            roundCorners(dateInputController.view, .all)
            // Add the datePicker View to the container for the transition
            context.containerView.addSubview(dateInputController.view)
            // Prepare Views to Be animated in
            dateInputController.view.alpha = 0.0
            dateInputController.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                dateInputController.view.alpha = 1.0
                dateInputController.view.transform = .identity
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let dismissal: TransitioningContextClosure = { (context) in
            let datePickerController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            UIView.animate(withDuration: duration, animations: {
                datePickerController.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                datePickerController.view.alpha = 0.0
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        
        let presentedFrame = Presentation.Frame.centered()
        
        let containerSize: ContainerSizeClosure = { (parentSize) in
            let smallestParentSize = min(parentSize.width,parentSize.height)
            return CGSize(width: smallestParentSize * 0.90, height: smallestParentSize * 0.5)
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
    }
    
    
}




extension PresentationDescriptors {
    // from options menu transition
    public
  static func optionsMenu() -> PresentationAnimationDescriptor {
        let dimBackground = false
        let duration = 0.3
    
        let presentation: TransitioningContextClosure = { (context) in
            
            let toController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            
            // Calculate Frames
            let bottomOfContainerOrigin = CGPoint(0, context.containerView.frame.size.height)
            let toSize = toController.view.bounds.size
            
            let toInitialFrame = CGRect(origin: bottomOfContainerOrigin, size: toSize)
            let toFinalFrame = context.finalFrame(for: toController)
            
            // Shift Options
            let shiftOptionsSize = shiftOptionsController.view.bounds.size
            let shiftOptionsFinalFrame = CGRect(x: 0, y: bottomOfContainerOrigin.y + shiftOptionsSize.height, width: shiftOptionsSize.width, height: shiftOptionsSize.height)
            
            // Customize Views for Display
            if #available(iOS 11.0, *) {
                toController.view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
                toController.view.layer.masksToBounds = true
                toController.view.layer.cornerRadius = 12.0
            } else {
                // Fallback on earlier versions
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: toSize), byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 12, height: 12))
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                toController.view.layer.mask = mask
            }
            
            
            // Set Initial Frames
            toController.view.frame = toInitialFrame
            // NOTE: the initial frame for the ShiftOptions Controller is already on the screen.
            
            // Add the KPIGraph View to the container for the transition
            context.containerView.addSubview(toController.view)
            
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                toController.view.frame = toFinalFrame
                shiftOptionsController.view.frame = shiftOptionsFinalFrame
            }) { finished in
                context.completeTransition(finished)
            }
        }
    
    
        let dismissal: TransitioningContextClosure = { (context) in
            
            let kpiGraphController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let shiftOptionsSize = shiftOptionsController.view.bounds.size
            
            var dismissedFrame = context.finalFrame(for: kpiGraphController)
            dismissedFrame.origin.y = context.containerView.frame.size.height
            
            let kpiGraphFinalFrame = dismissedFrame
            let shiftOptionsFinalFrame = CGRect(origin: CGPoint(0, context.containerView.frame.size.height - shiftOptionsSize.height), size: shiftOptionsSize)
            
            UIView.animate(withDuration: duration, animations: {
                kpiGraphController.view.frame = kpiGraphFinalFrame
                shiftOptionsController.view.frame = shiftOptionsFinalFrame
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            return CGRect(origin: CGPoint(0, containerBounds.size.height - size.height), size: size)
        }
        
        let containerSize: ContainerSizeClosure = { (parentSize) in
            return CGSize(width: parentSize.width, height: parentSize.height * 0.9)
        }
        
        return PresentationAnimationDescriptor(dimBackground, duration, containerSize, presentedFrame, presentation, dismissal)
    }
}


extension PresentationDescriptors {
    public
    static func kpiGraph() -> PresentationAnimationDescriptor {
        let dimBackground = false
        let duration = 0.3
        
        let presentation: TransitioningContextClosure = { (context) in
            let kpiGraphController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            
            // Calculate Frames
            // KPIGraph
            let bottomOfContainerOrigin = CGPoint(0, context.containerView.frame.size.height)
            let kpiGraphViewSize = kpiGraphController.view.bounds.size
            
            let kpiGraphInitialFrame = CGRect(origin: bottomOfContainerOrigin, size: kpiGraphViewSize)
            let kpiGraphFinalFrame = context.finalFrame(for: kpiGraphController)
            
            // Shift Options
            let shiftOptionsSize = shiftOptionsController.view.bounds.size
            let shiftOptionsFinalFrame = CGRect(x: 0, y: bottomOfContainerOrigin.y + shiftOptionsSize.height, width: shiftOptionsSize.width, height: shiftOptionsSize.height)
            
            // Add the KPIGraph View to the container for the transition
            context.containerView.addSubview(kpiGraphController.view)
            // Customize Views for Display
            if #available(iOS 11.0, *) {
                kpiGraphController.view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
                kpiGraphController.view.layer.masksToBounds = true
                kpiGraphController.view.layer.cornerRadius = 12.0
            } else {
                // Fallback on earlier versions
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: kpiGraphViewSize), byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 12, height: 12))
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                kpiGraphController.view.layer.mask = mask
            }
            
            
            // Set Initial Frames
            kpiGraphController.view.frame = kpiGraphInitialFrame
            // NOTE: the initial frame for the ShiftOptions Controller is already on the screen.
            
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                kpiGraphController.view.frame = kpiGraphFinalFrame
                shiftOptionsController.view.frame = shiftOptionsFinalFrame
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let dismissal: TransitioningContextClosure = { (context) in
            let kpiGraphController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            let shiftOptionsController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let shiftOptionsSize = shiftOptionsController.view.bounds.size
            
            var dismissedFrame = context.finalFrame(for: kpiGraphController)
            dismissedFrame.origin.y = context.containerView.frame.size.height
            
            let kpiGraphFinalFrame = dismissedFrame
            let shiftOptionsFinalFrame = CGRect(origin: CGPoint(0, context.containerView.frame.size.height - shiftOptionsSize.height), size: shiftOptionsSize)
            
            UIView.animate(withDuration: duration, animations: {
                kpiGraphController.view.frame = kpiGraphFinalFrame
                shiftOptionsController.view.frame = shiftOptionsFinalFrame
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            return CGRect(origin: CGPoint(0, containerBounds.size.height - size.height), size: size)
        }
        
        let containerSize: ContainerSizeClosure = { (parentSize) in
            return CGSize(width: parentSize.width, height: parentSize.height * 0.9)
        }
        
        return PresentationAnimationDescriptor(dimBackground, duration, containerSize, presentedFrame, presentation, dismissal)
    }
    
}


extension PresentationDescriptors {
    public
   static func datePicker() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation: TransitioningContextClosure = { (context) in
            let datePickerController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            // Set Frame
            datePickerController.view.frame = context.finalFrame(for: datePickerController)
            // Customize Views for Display
            roundCorners(datePickerController.view, .all)
            // Add the datePicker View to the container for the transition
            context.containerView.addSubview(datePickerController.view)
            // Prepare Views to Be animated in
            datePickerController.view.alpha = 0.0
            datePickerController.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                datePickerController.view.alpha = 1.0
                datePickerController.view.transform = .identity
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let dismissal: TransitioningContextClosure = { (context) in
            let datePickerController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            UIView.animate(withDuration: duration, animations: {
                datePickerController.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                datePickerController.view.alpha = 0.0
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            return CGRect(origin: CGPoint(containerBounds.size.width/2 - size.width/2, containerBounds.size.height/2 - size.height/2), size: size)
        }
        
        let containerSize: ContainerSizeClosure = { (parentSize) in
            let smallestParentSize = min(parentSize.width,parentSize.height)
            return CGSize(width: smallestParentSize * 0.90, height: smallestParentSize * 0.90)
        }
        
        return PresentationAnimationDescriptor(dimBackground, duration, containerSize, presentedFrame, presentation, dismissal)
    }
}


extension PresentationDescriptors {
    
    static func dateInput() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        
        let presentation: TransitioningContextClosure = { (context) in
            let dateInputController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            // Set Frame
            dateInputController.view.frame = context.finalFrame(for: dateInputController)
            // Customize Views for Display
            roundCorners(dateInputController.view, .all)
            // Add the datePicker View to the container for the transition
            context.containerView.addSubview(dateInputController.view)
            // Prepare Views to Be animated in
            dateInputController.view.alpha = 0.0
            dateInputController.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                dateInputController.view.alpha = 1.0
                dateInputController.view.transform = .identity
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let dismissal: TransitioningContextClosure = { (context) in
            let datePickerController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            UIView.animate(withDuration: duration, animations: {
                datePickerController.view.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                datePickerController.view.alpha = 0.0
            }) { finished in
                context.completeTransition(finished)
            }
        }
    
        
        let presentedFrame = Presentation.Frame.centered()
        
        let containerSize: ContainerSizeClosure = { (parentSize) in
            let smallestParentSize = min(parentSize.width,parentSize.height)
            return CGSize(width: smallestParentSize * 0.90, height: smallestParentSize * 0.90)
        }
        
        return PresentationAnimationDescriptor(
                dimBackground,
                duration,
                containerSize,
                presentedFrame,
                presentation,
                dismissal
        )
    }
}





extension PresentationDescriptors {
    public
    static func reportFilter() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation: TransitioningContextClosure = Presentation.Animation.fadeInOverlay(duration)
        let dismissal: TransitioningContextClosure = Dismissal.Animation.fadeOutOverlay(duration)
        let presentedFrame = Presentation.Frame.centered()
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: parentSize.width * 0.65, height: parentSize.height * 0.62)
            } else {
                if parentSize.width > parentSize.height {
                    return CGSize(width: parentSize.width * 0.75, height: parentSize.height * 0.80)
                } else {
                    return CGSize(width: parentSize.width * 0.75, height: parentSize.height * 0.80)
                }
            }
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
        
    }
    
    
}


extension PresentationDescriptors {
    public
    static func overlay() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation: TransitioningContextClosure = Presentation.Animation.fadeInOverlay(duration)
        let dismissal: TransitioningContextClosure = Dismissal.Animation.fadeOutOverlay(duration)
        let presentedFrame = Presentation.Frame.centered()
     
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: parentSize.width * 0.65, height: parentSize.height * 0.62)
            } else {
                if parentSize.width > parentSize.height {
                    return CGSize(width: parentSize.width * 0.80, height: parentSize.height * 0.80)
                } else {
                    return CGSize(width: parentSize.width * 0.95, height: parentSize.height * 0.80)
                }
            }
            
            
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
        
    }
    
}


extension PresentationDescriptors {
    public
    static func fullScreenOverlay() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation: TransitioningContextClosure = Presentation.Animation.fadeInOverlay(duration)
        let dismissal: TransitioningContextClosure = Dismissal.Animation.fadeOutOverlay(duration)
        let presentedFrame = Presentation.Frame.centered()
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            return parentSize
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal
        )
        
    }
    
}



extension PresentationDescriptors {
    public
    static func hiredHaulerOverlay(_ containerHeight:CGFloat = 0.0) -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation: TransitioningContextClosure = Presentation.Animation.fadeInOverlay(duration)
        let dismissal: TransitioningContextClosure = Dismissal.Animation.fadeOutOverlay(duration)
        let presentedFrame = Presentation.Frame.upper()
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if containerHeight.isZero {
                return CGSize(width: parentSize.width * 0.90, height: parentSize.height * 0.33)
            } else {
                return CGSize(width: parentSize.width * 0.90, height: containerHeight)
            }
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal,
            true
        )
        
    }
    
    
    public
    static func editActuals(_ containerHeight:CGFloat = 0.0) -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation: TransitioningContextClosure = Presentation.Animation.fadeInOverlay(duration)
        let dismissal: TransitioningContextClosure = Dismissal.Animation.fadeOutOverlay(duration)
        let presentedFrame = Presentation.Frame.centered()
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
            if containerHeight.isZero {
                return CGSize(width: parentSize.width * 0.90, height: parentSize.height * 0.80)
            } else {
                return CGSize(width: parentSize.width * 0.90, height: containerHeight)
            }
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal,
            true
        )
        
    }
    
    
    public
    static func lowerThird() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        let presentation: TransitioningContextClosure = Presentation.Animation.upFromBottom()
        let dismissal: TransitioningContextClosure = Dismissal.Animation.downToBottom()
        let presentedFrame = Presentation.Frame.lowerThird()
        
        // Presentation Container size
        let containerSize: ContainerSizeClosure = { (parentSize) in
           return CGSize(width: parentSize.width, height: parentSize.height/3)
        }
        
        return PresentationAnimationDescriptor(
            dimBackground,
            duration,
            containerSize,
            presentedFrame,
            presentation,
            dismissal,
            true
        )
        
    }
    
    
    
    
}










extension PresentationDescriptors {
    public
  static func betaSettings() -> PresentationAnimationDescriptor {
        let dimBackground = true
        let duration = 0.3
        
        let presentation: TransitioningContextClosure = { (context) in
            
            let datePickerController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            
            

            //let datePickerFinalFrame = context.finalFrame(for: datePickerController)
            
            // Add the datePicker View to the container for the transition
            context.containerView.addSubview(datePickerController.view)
        
            roundCorners(datePickerController.view, .all)
            
            // Set Initial Frames
            datePickerController.view.frame = context.finalFrame(for: datePickerController)
            datePickerController.view.frame.y = context.containerView.frame.size.height
            // NOTE: the initial frame for the completedShifts Controller is already on the screen.
            
            // Animate Transition
            UIView.animate(withDuration: duration, animations: {
                datePickerController.view.frame = context.finalFrame(for: datePickerController)
            }) { finished in
                context.completeTransition(finished)
            }
        }
        
        let dismissal: TransitioningContextClosure = { (context) in
            let datePickerController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
            var dismissedFrame = context.finalFrame(for: datePickerController)
            dismissedFrame.origin.y = context.containerView.frame.size.height
            
            UIView.animate(withDuration: duration, animations: {
                datePickerController.view.frame = dismissedFrame
            }) { finished in
                context.completeTransition(finished)
            }
        }
    
    /*
        let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
            return CGRect(origin: CGPoint(containerBounds.size.width/2 - size.width/2, containerBounds.size.height/2 - size.height/2), size: size)
        }
        
        let containerSize: ContainerSizeClosure = { (parentSize) in
            let smallestParentSize = min(parentSize.width,parentSize.height)
            
            return CGSize(width: smallestParentSize * 0.75, height: smallestParentSize * 0.90)
        }
    */
    
    // Presentation Frame
    let presentedFrame: PresentedFrameClosure = { (containerBounds,size) in
        return CGRect(
            origin: CGPoint((containerBounds.size.width - size.width)/2, (containerBounds.size.height - size.height)/2),
            size: size)
    }
    
    // Presentation Container size
    let containerSize: ContainerSizeClosure = { (parentSize) in
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: parentSize.width * 0.65, height: parentSize.height * 0.62)
        } else {
            if parentSize.width > parentSize.height {
                return CGSize(width: parentSize.width * 0.80, height: parentSize.height * 0.80)
            } else {
                return CGSize(width: parentSize.width * 0.95, height: parentSize.height * 0.80)
            }
        }
    }
        
        return PresentationAnimationDescriptor(dimBackground, duration, containerSize, presentedFrame, presentation, dismissal)
    }
}



 //: MARK: - Utility -
extension PresentationDescriptors {
    
    static let topCornersMask: CACornerMask = [
        CACornerMask.layerMaxXMinYCorner,
        CACornerMask.layerMinXMinYCorner,
        ]
    
    static let allCornersMask: CACornerMask = [
        CACornerMask.layerMaxXMaxYCorner,
        CACornerMask.layerMaxXMinYCorner,
        CACornerMask.layerMinXMaxYCorner,
        CACornerMask.layerMinXMinYCorner,
        ]
    
    
    enum Corners {
        case all, top, none
    }
    
    
    static func roundCorners(_ view:UIView,_ corners:Corners,_ radius:CGFloat = 12.0) {
        if #available(iOS 11.0, *) {
            switch corners {
            case .all:
                view.layer.maskedCorners = allCornersMask
                view.layer.masksToBounds = true
                view.layer.cornerRadius = radius
            case .top:
                view.layer.maskedCorners = topCornersMask
                view.layer.masksToBounds = true
                view.layer.cornerRadius = radius
            case .none:
                break
            }
        } else { // Fallback on earlier versions
            switch corners {
            case .all:
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: view.bounds.size), byRoundingCorners: [.topLeft,.topRight,.bottomLeft,.bottomRight], cornerRadii: CGSize(width: radius, height: radius))
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                view.layer.mask = mask
            case .top:
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: view.bounds.size), byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: radius, height: radius))
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                view.layer.mask = mask
            case .none:
                break
            }
        }
    }
    
    
}

