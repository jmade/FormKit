
import UIKit

public struct Image {}

// Chevron
extension Image {
    
    struct Chevron {
        static let whiteChevronDown: UIImage = chevronDownImage(.white)
        static let blackChevronDown: UIImage = chevronDownImage()
        
        static let whiteChevronLeft: UIImage = chevronLeftImage(.white)
        static let blackChevronLeft: UIImage = chevronLeftImage()
        
        static let nextChevron: UIImage = nextImage(.white)
        static let previousChevron: UIImage = previousImage(.white)
        
        static let nextChevronBlack: UIImage = nextImage(.black)
        static let previousChevronBlack: UIImage = previousImage(.black)
        
        static let attatchment: UIImage = chevronAttatchmentNext()
    }
}


extension Image {
    
    static func chevronDownImage(_ color:UIColor = .black, _ squaredSize:CGFloat = 90.0) -> UIImage {
        let imageSize = CGSize(width: squaredSize, height:squaredSize)
        func chevronImage(_ path:UIBezierPath,_ size:CGSize,_ color:UIColor) -> UIImage {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setStroke()
            path.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            return image
        }
        return chevronImage(Path.makeChevronDownPath(imageSize.width), imageSize, color)
    }
    
    static func chevronLeftImage(_ color:UIColor = .black, _ squaredSize:CGFloat = 90.0) -> UIImage {
        let imageSize = CGSize(width: squaredSize, height:squaredSize)
        func chevronImage(_ path:UIBezierPath,_ size:CGSize,_ color:UIColor) -> UIImage {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setStroke()
            path.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            return image
        }
        return chevronImage(Path.makeChevronLeftPath(imageSize.width), imageSize, color)
    }

    static func chevronRightImage(_ color:UIColor = .black, _ squaredSize:CGFloat = 90.0) -> UIImage {
        let imageSize = CGSize(width: squaredSize, height:squaredSize)
        func chevronImage(_ path:UIBezierPath,_ size:CGSize,_ color:UIColor) -> UIImage {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setStroke()
            path.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            return image
        }
        return chevronImage(Path.makeChevronRightPath(imageSize.width), imageSize, color)
    }
    
    
    static func chevronAttatchmentNext(_ color:UIColor = .white, _ squaredSize:CGFloat = 16) -> UIImage {
        let imageSize = CGSize(width: squaredSize, height:squaredSize)
        
        func chevronImage(_ path:UIBezierPath,_ size:CGSize,_ color:UIColor) -> UIImage {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setStroke()
            path.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            return image
        }
        
        return chevronImage(
            Path.makeChevronPath(imageSize.width, 0.5, 10.0),
            imageSize,
            color
        )
    }
    
    
    

    static func nextImage(_ color:UIColor = .black, _ squaredSize:CGFloat = 24.0) -> UIImage {
        let imageSize = CGSize(width: squaredSize, height:squaredSize)
        func chevronImage(_ path:UIBezierPath,_ size:CGSize,_ color:UIColor) -> UIImage {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setStroke()
            path.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            return image
        }
        return chevronImage(Path.makeNextChevronPath(imageSize.width), imageSize, color)
    }
    
    
    static func previousImage(_ color:UIColor = .black, _ squaredSize:CGFloat = 24.0) -> UIImage {
        let imageSize = CGSize(width: squaredSize, height:squaredSize)
        func chevronImage(_ path:UIBezierPath,_ size:CGSize,_ color:UIColor) -> UIImage {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setStroke()
            path.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            return image
        }
        return chevronImage(Path.makePreviousChevronPath(imageSize.width), imageSize, color)
    }
    
}
