import Foundation
import UIKit

func saveImageToDocumentDirectory(imageName: String, image: UIImage, AlbumCoverName: String) {
    // 1. 이미지를 저장할 경로를 설정해줘야함 - 도큐먼트 폴더,File 관련된건 Filemanager가 관리함(싱글톤 패턴)
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
    let imageURL = documentDirectory.appendingPathComponent(AlbumCoverName).appendingPathComponent(imageName)
    // 2. 이미지 파일 이름 & 최종 경로 설정
    NSLog(imageURL.path())
    // 돌아가는 방향 잡는 부분
    let changedImage = fixOrientation(image: image)

    // 3. 이미지 압축(image.pngData())
    // 압축할거면 jpegData로~(0~1 사이 값)
    guard let data = changedImage.pngData() else {
        print("압축이 실패했습니다.")
        return
    }

    // 4. 이미지 저장: 동일한 경로에 이미지를 저장하게 될 경우, 덮어쓰기하는 경우
    // 4-1. 이미지 경로 여부 확인
    if FileManager.default.fileExists(atPath: imageURL.path) {
        // 4-2. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
        do {
            try FileManager.default.removeItem(at: imageURL)
            print("이미지 삭제 완료")
        } catch {
            print("이미지를 삭제하지 못했습니다.")
        }
    }

    // 5. 이미지를 도큐먼트에 저장
    // 파일을 저장하는 등의 행위는 조심스러워야하기 때문에 do try catch 문을 사용
    do {
        try data.write(to: imageURL)
        print("이미지 저장완료")
    } catch {
        print("이미지를 저장하지 못했습니다.")
    }
}

func loadImageFromDocumentDirectory(imageName: String, albumTitle: String) -> UIImage? {
    // 1. 도큐먼트 폴더 경로가져오기
    let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

    if let directoryPath = path.first {
        // 2. 이미지 URL 찾기
        let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(albumTitle).appendingPathComponent(imageName)
        // 3. UIImage로 불러오기
        let loadImage = UIImage(contentsOfFile: imageURL.path)
        return fixOrientation(image: loadImage!)
    }

    return nil
}

func deleteImageFromDocumentDirectory(imageName: String) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}

    let imageURL = documentDirectory.appendingPathComponent(imageName)

    if FileManager.default.fileExists(atPath: imageURL.path) {
        do {
            try FileManager.default.removeItem(at: imageURL)
            print("이미지 삭제 완료")
        } catch {
            print("이미지를 삭제하지 못했습니다.")
        }
    }
}

func resizeingImage(image: UIImage, width: Int, height: Int) -> UIImage? {
    let customImage = image
    let newImageRect = CGRect(x: 0, y: 0, width: width, height: height)
    UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    customImage.draw(in: newImageRect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
    UIGraphicsEndImageContext()
    return newImage
}

func fixOrientation(image: UIImage) -> UIImage{
    if(image.imageOrientation == .up){
        return image
    }
    // 방향 돌아가는 이유랑 다시 돌리는 원리 다시 보기!!
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    image.draw(in: rect)
    let normailizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return normailizedImage
}

extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in self.draw(in: CGRect(origin: .zero, size: size))}
        
        return renderImage
    }
}

