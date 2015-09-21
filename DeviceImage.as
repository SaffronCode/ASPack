package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.media.CameraRollBrowseOptions;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.getQualifiedClassName;
	

	public class DeviceImage
	{
		private static var onDone:Function ;
		
		/**Device images are always in jpeg*/
		public static var imageBytes:ByteArray ;
		
		/**This is the loaded image bitmap data*/
		public static var imageBitmapData:BitmapData ;
		
		
		private static var camera:CameraUI,
							dataSource:IDataInput,
							cameraRoll:CameraRoll;
			
		/**Below variables will uses when user requests ResizeFunction*/
		private static var W:Number,H:Number;
		
		
		/**uses to load image for resizing*/
		private static var loader:Loader;
		
		public static var autoResize:Boolean = true ;
		
		private static var tempW:Number,tempH:Number; 
							
		
		public static function get isSupported():Boolean
		{
			return CameraUI.isSupported; 
		}
		
		
		
		/**No image selected*/
		private static function mediaLoadingCanseled(e:Event):void
		{
			imageBytes==null;
			imageBitmapData = null;
			onDone();
		}
		
		/**When the image is ready, you can get its image from imageBytes*/
		public static function getCameraImage(onImageReady:Function,imageW:Number=NaN,imageH:Number=NaN,loadThisFileIfNotSupporting:String=null):void
		{
			imageBytes = null;
			imageBitmapData = null ;
			
			if(!CameraUI.isSupported)
			{
				loadFile(onImageReady,new File(loadThisFileIfNotSupporting),imageW,imageH);
				return ;
			}
			
			tempW = imageW;
			tempH = imageH ;
			
			camera = new CameraUI();
			camera.addEventListener(MediaEvent.COMPLETE,sendCameraImage);
			camera.addEventListener(Event.CANCEL,mediaLoadingCanseled);
			camera.launch(MediaType.IMAGE);
			
			onDone = onImageReady ;
		}
		
		protected static function sendCameraImage(ev:MediaEvent):void
		{
			// TODO Auto-generated method stub
			
			if(ev.data.file!=null)
			{
				loadThisImageToSend(ev.data.file)	;
			}
			else
			{
				dataSource = ev.data.open();
				if(ev.data.isAsync)
				{
					var eventSource:IEventDispatcher = dataSource as IEventDispatcher;
					eventSource.addEventListener( Event.COMPLETE, readMediaData ); 
				}
				else
				{
					readMediaData(); 
				}
			}
		}
		
		private static function readMediaData(e=null):void 
		{
			imageBytes = new ByteArray();
			dataSource.readBytes(imageBytes);
			imageBytes.position = 0 ;
			
			if(autoResize || !isNaN(tempW))
			{
				resizeLoadedImage(onDone,tempW,tempH,imageBytes);
			}
			else
			{
				onDone();
			}
		}
		
		public static function loadFile(onImageReady:Function,file:File,imageW:Number=NaN,imageH:Number=NaN)
		{
			tempW = imageW;
			tempH = imageH ;
			
			onDone = onImageReady ;
			loadThisImageToSend(file);
		}
		
		private static function loadThisImageToSend(file:File):void
		{
			// TODO Auto Generated method stub
			var fileStream:FileStream = new FileStream();
			fileStream.open(file,FileMode.READ);
			imageBytes = new ByteArray();
			fileStream.readBytes(imageBytes,0,fileStream.bytesAvailable);
			imageBytes.position = 0 ;
			fileStream.close();
			
			if(autoResize || !isNaN(tempW))
			{
				resizeLoadedImage(onDone,tempW,tempH,imageBytes);
			}
			else
			{
				onDone();
			}
		}
		
	/////////////////////////////////////////////////////////////////
		/**Load image from file then it will call your function*/
		public static function loadImageFromGallery(onImageLoaded:Function,rect:Rectangle=null,imageW:Number=NaN,imageH:Number=NaN,loadThisFileIfNotSupporting:String=null):void
		{
			imageBitmapData = null;
			imageBytes = null ;
			
			tempW = imageW;
			tempH = imageH ;
			
			if(!CameraRoll.supportsBrowseForImage)
			{
				loadFile(onImageLoaded,new File(loadThisFileIfNotSupporting),imageW,imageH);
				return ;
			}
			onDone = onImageLoaded ;
			
			cameraRoll = new CameraRoll();
			var browsOptions:CameraRollBrowseOptions;
			if(rect!=null)
			{
				browsOptions = new CameraRollBrowseOptions();
				browsOptions.origin = rect.clone() ;
			}
			cameraRoll.addEventListener(MediaEvent.SELECT,addThisImageTo);
			cameraRoll.addEventListener(Event.CANCEL,mediaLoadingCanseled);
			cameraRoll.browseForImage(browsOptions);
		}
		
		private static function addThisImageTo(ev:MediaEvent):void
		{
			// TODO Auto-generated method stub
			var media:MediaPromise = ev.data ;
			
			if(media.file!=null)
			{
				loadThisImageToSend(media.file);
			}
			else
			{
				dataSource = media.open();
				if(media.isAsync)
				{
					var eventSource:IEventDispatcher = dataSource as IEventDispatcher;
					eventSource.addEventListener( Event.COMPLETE, readMediaData ); 
				}
				else
				{
					readMediaData(); 
				}
			}
		}
		
	////////////////////////////////Resize funciton
		/**This function can also uses to convert byteArray to BitmapData in requseted size*/
		public static function resizeLoadedImage(onResized:Function,newWidth:Number=NaN,newHeight:Number=NaN,fileBytes:ByteArray=null,forceToResize:Boolean=true):void
		{
			onDone = onResized ;
			
			if(fileBytes == null && imageBytes==null)
			{
				trace(new Error("No image loaded yet"));
				onDone();
				return ;
			}
			else
			{
				if(fileBytes == null)
				{
					fileBytes = imageBytes ;
				}
			}
			imageBytes = fileBytes ;
			
			W = newWidth;
			H = newHeight ;
			

			if(forceToResize && isNaN(H))
			{
				H = 768;
			}
			if(forceToResize && isNaN(W))
			{
				W = 1024;
			}
			
			loader = new Loader();
			var loaderContext:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			loaderContext.allowCodeImport = true ;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,fileLoaderToResize);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,fileLoaderError);
			loader.loadBytes(fileBytes,loaderContext);
		}
		
		protected static function fileLoaderError(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			trace(new Error("File cannot load"));
		}
		
		protected static function fileLoaderToResize(event:Event):void
		{
			trace("Image loaded to resize");
			// TODO Auto-generated method stub
			var bitmap:Bitmap = loader.content as Bitmap ;
			var resizedPhoto:BitmapData ;
			if(!isNaN(W) && !isNaN(H) && ( bitmap.width>W || bitmap.height>H ))
			{
				resizedPhoto = BitmapEffects.changeSize(bitmap.bitmapData,W,H,true,true,false);
				imageBytes = resizedPhoto.encode(resizedPhoto.rect,new JPEGEncoderOptions(70));
				imageBitmapData = resizedPhoto.clone() ;
			}
			else
			{
				imageBitmapData = bitmap.bitmapData.clone() ;
			}
			
			trace("Stored bitmapData is : "+imageBitmapData);
			
			onDone();
		}
		
		
	//////////////////////////////////////////////////////Save image
		private static var lastBitmap:Bitmap ;
		
		private static var imageLoder:Loader ;
		
		private static var cashedOnDone:Function ;
		
		public static function saveImageToGallery(file:ByteArray, onImageSaved:Function):void
		{
			// TODO Auto Generated method stub
			cashedOnDone = onDone = onImageSaved ;
			
			createBitmapFromByteOrURL(file,saveToGall);
		}
		
		private static function saveToGall():void
		{
			if(CameraRoll.supportsAddBitmapData)
			{
				cameraRoll = new CameraRoll();
				cameraRoll.addBitmapData(lastBitmap.bitmapData);
			}
			else
			{
				trace("save not supports");
			}
			cashedOnDone();
		}
		
		private static function createBitmapFromByteOrURL(file:*,onCreated:Function):void
		{
			//trace("save this iamge : "+file);
			trace(" > "+getQualifiedClassName(file));
			onDone = onCreated ;
			imageLoder = new Loader();
			var context:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			context.allowLoadBytesCodeExecution = true ;
			imageLoder.contentLoaderInfo.addEventListener(Event.COMPLETE,fileIsReady);
			if(file is ByteArray)
			{
				imageLoder.loadBytes(file as ByteArray,context);
			}
			else
			{
				imageLoder.load(new URLRequest(file as String),context);
			}
		}
		
		protected static function fileIsReady(event:Event):void
		{
			// TODO Auto-generated method stub
			lastBitmap = imageLoder.content as Bitmap ;
			onDone();
		}
	}
}