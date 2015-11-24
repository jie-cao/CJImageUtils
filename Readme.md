CJImageUtils
=========
CJImageUtils是一个轻量级的从网络下载图像并进行缓存的库。整个库是基于Swift实现的并且受到了SDWebImage的很多启发。CJImageUtils提供了对swift的原生的支持，不需要额外的配置来运行基于Objective-C的库。整个库包含了从网络获取图像并进行缓存的一系列功能和接口。具体包括：

- 一个UIImageView extension来提供UIImageView从网络异步下载图像并缓存的接口
- CJImageFetchManager来创建和管理图像异步下载的任务
- CJImageFetchOperation提供图像异步网络下载的接口
- CJImageCache提供缓存图片在内存和文件存储的接口
- 一系列图像处理的工具集来图像进行缩放，剪切和在Background解压缩

安装
------------

### 用CocoaPods安装

可以通过CocoaPods来安装CJImageUtils

#### Podfile
```
platform :ios, '8.0'
pod 'CJImageUtils'
```
### 直接嵌入源代码
CJImageUtils是一个开源库，可以从[这里](https://github.com/jie-cao/CJImageUtils)直接找到源代码并加入项目

如何使用
----------

### 使用ImageView Extension
导入的CJImageUtils库后，UIImageView提供了多个从NSURL异步下载图像并缓存的接口。一个简单的例子：

```swift
let url = NSURL(string: "http://image.com/image.jpg")
var imageView = UIImageView()
imageView.imageWithURL(url!)
```

所有的接口可以在CJImageViewExtension文件中找到。

```swift
func imageWithURL(url:NSURL)
func imageWithURL(url:NSURL, options: CJImageFetchOptions?)
func imageWithURL(url:NSURL, options: CJImageFetchOptions?, placeholderImage:UIImage?)
func imageWithURL(url:NSURL, options: CJImageFetchOptions?, placeholderImage:UIImage?, progressHandler:ProgressHandler?)
func imageWithURL(url:NSURL, options:CJImageFetchOptions?, completionHandler:CompletionHandler?)
func imageWithURL(url:NSURL, options:CJImageFetchOptions?, progressHandler:ProgressHandler?, completionHandler:CompletionHandler?)
func imageWithURL(url:NSURL, options:CJImageFetchOptions?, placeholderImage:UIImage?, progressHandler:ProgressHandler?, completionHandler:CompletionHandler?)
```

### 通过CJImageFetchOpetions来设置下载和缓存选项
在下载图像的时候，可以通过创建一个CJImageFetchOptions来对下载和缓存的各环节进行设置。可以设置的选项包括:
1.priority  
负责图像下载队列的优先级。 可以设置为DefaultPriority， LowPriority和HighPriority。  
2.cachePolicy  
设置图像存储的策略。可以设置为NoCache，MemoryCache，FileCache和MemoryAndFileCache。对应不缓存，只在内存缓存和在内存和文件系统同时缓存。  
3.shouldDecode  
图像是否需要解压缩。在图像从网络下载后，UIImageView需要对图像进行解压缩才能显示。这个过程一般是隐式的。并且会发生在UI主线程。可以通过开启这个选项来是图像在后台队列解压从而不阻塞UI主线程。  
4.requestCachePolicy  
CJImageUtils的图像下载是基于NSURLSession来实现的。这个选项对应的NSURLSessionConfiguration的requestCachePolicy选项。可以通过设置这个选项来设置下载时候session的缓存策略。


### UITableView使用的例子
UITableViewCell里面的ImageView可以直接用CJImageViewExtion提供的函数。 

```swift
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		 // get the data ojbect for the indexPath
        let data = self.dataSource[indexPath.row] as! [String :String]        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageTableViewCell
        cell.contentLabel?.text = data["text"]
        let placeholderImage = UIImage(named: "placeholder.jpg")
        // get image URL
        if let imageUrl = NSURL(string: data["url"]!){
            cell.photoView?.imageWithURL(imageUrl, options: nil, placeholderImage: placeholderImage)
            cell.photoView?.contentMode = .ScaleAspectFit
        }
        return cell
    }
    
```
UICollectionViewCell也可以用类似的方法
### 使用 Closure
CJImageUtils定义下面两个Closure来提供下载图像过程中和完成后的callback

```swift
public typealias ProgressHandler = ((receivedSize:Int64, expectedSize:Int64)->Void)
public typealias CompletionHandler = ((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)
```
在CJImageViewExtension中，下来函数可以使用Closure 

```swift
func imageWithURL(url:NSURL, options:CJImageFetchOptions?, placeholderImage:UIImage?, progressHandler:ProgressHandler?)
func imageWithURL(url:NSURL, options:CJImageFetchOptions?, completionHandler:CompletionHandler?)
func imageWithURL(url:NSURL, options:CJImageFetchOptions?, progressHandler:ProgressHandler?, completionHandler:CompletionHandler?)
func imageWithURL(url:NSURL, options:CJImageFetchOptions?,placeholderImage:UIImage?, progressHandler:ProgressHandler?, completionHandler:CompletionHandler?)
```

### 使用 CJImageFetchManager
有时候下载完图像后，不需要直接传递给UIImageView显示并且需要对下载图像的任务进行管理。CJImageUtils提供了CJImageFetchManger单例来创建并管理图像异步下载并缓存的任务。 

```swift
func retrieveImageFromUrl(url:NSURL, options:CJImageFetchOptions? = nil, completionHandler:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?, progressHandler:((receivedSize:Int64, expectedSize:Int64)->Void)?) -> CJImageFetchOperation?
```       
该函数会返回一个CJImageOperation的实例。你可以保持一个实例，从而对一个下载任务进行管理，例如在某些情况下取消下载。  
创建一个图像异步下载任务:  

```swift
if let operation = CJImageFetchManager.sharedInstance.retrieveImageFromUrl(url, options: options, completionHandler:{(image:UIImage?, data:NSData?, error:NSError?,finished:Bool) -> in
	// your completion handler
},
progressHandler: {(receivedSize:Int64, expectedSize:Int64) in
	// your progress handler
}) {
	// save the operation for future management
}
```
取消一个图像下载任务  

```swift
CJImageFetchManager.sharedInstance.cancelOperation(operation)

```
这里的Operation就是之前创建下载任务是得到的CJImageOperation的实例

### 使用 CJImageFetchOperation创建图像下载缓存任务  
CJImageUtils提供一个CJImageFetchOperation来作为图像下载缓存的任务。可以直接创建CJImageFetchOpeation的实例来创建图像下载和缓存的任务。

```swift
init(url:NSURL, options:CJImageFetchOptions, progressHandler:((receivedSize:Int64, expectedSize:Int64)->Void)?, completionHandler:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?)
```
任务创建后不会立即开始下载。需要调用start()来手动开始任务下载。

### 使用CJImageCache
CJImageUtils实现了一个CJImageCache的单例来异步缓存图像。该实例提供一系列函数来实现在内存或者文件系统的存储和读取。

```swift
func storeImage(image:UIImage, key:String, imageData:NSData? = nil, cachePolicy:CJImageCachePolicy, completionHandler:(()-> Void)?)-> Void
func retrieveImageForKey(key: String, options:CJImageFetchOptions, completionHandler: ((UIImage?, CacheType!) -> Void)?) -> Void    
func retrieveImageFromMemoryCache(key: String) -> UIImage?
func loadImageDataFromFile(key: String) -> NSData?    

```
其中在文件系统存取图像信息是异步的，通过传递closure来实现callback

## Licenses

All source code is licensed under the [MIT License](https://raw.github.com/rs/SDWebImage/master/LICENSE).