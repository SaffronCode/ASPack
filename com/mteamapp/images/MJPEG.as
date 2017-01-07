// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * BY M.E.Sepehr
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// ******


package com.mteamapp.images
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class MJPEG extends Bitmap
	{
		private var loader1:Loader;
		private var loader2:URLStream ;
		private var cameraURL:URLRequest;
		//private var cameraURL:URLRequest = new URLRequest("http://www.onyxservers.com/guides/images/ipcamera_webcamxpfilter.jpg");
		
		private var lastImageTime:Number = 0;
		
		var bitdata:BitmapData ;
		
		private var currentBytes:ByteArray;
		private var H:Number;
		private var W:Number;
		private var noStream:Function;
		private var myStageFrame:Rectangle;
		
		public function MJPEG(url:String,Width:Number=0,Height:Number=0,noStreamHere:Function=null,myFrame:Rectangle=null)
		{
			super();
			
			myStageFrame = myFrame ;
			
			W = Width ;
			H = Height ;
			
			noStream = noStreamHere ;
			
			cameraURL = new URLRequest(url);
			bitdata = new BitmapData(Width,Height,false,0xaaaaaa);
			this.bitmapData = bitdata ;
			this.smoothing = true ;
			
			if(myStageFrame!=null)
			{
				this.x = myStageFrame.x+(myStageFrame.width-this.width)/2 ;
				this.y = myStageFrame.y+(myStageFrame.height-this.height)/2 ;
			}
			
			currentBytes = new ByteArray();
			
			loader2 = new URLStream();
			loader2.addEventListener(ProgressEvent.PROGRESS,getThisImage);
			loader2.addEventListener(IOErrorEvent.IO_ERROR,connectionFaild);
			loader2.addEventListener(Event.COMPLETE,connectionFaild);
			loader2.load(cameraURL);
		}
		
		public function stopLoadingImage()
		{
			if(loader2!=null && loader2.connected)
			{
				loader2.close();
			}
		}
		
		public function startLoadingAgain()
		{
			stopLoadingImage();
			loader2.load(cameraURL);
		}
		
		protected function connectionFaild(event:*):void
		{
			
			trace("mjpeg connection faild");
			noStream();
		}
		
		protected function getThisImage(event:ProgressEvent):void
		{
			
			//trace(loader2.bytesAvailable+' vs '+event.bytesLoaded);
			var readedBytes:ByteArray = new ByteArray();
			
			//readedBytes.writeBoolean(true);
			loader2.readBytes(readedBytes,0,loader2.bytesAvailable);
			
			readedBytes.position = 0 ;
			
			currentBytes.position = currentBytes.length ;
			
			currentBytes.writeBytes(readedBytes,0,readedBytes.bytesAvailable);
			
			//trace("currentBytes : "+currentBytes.length);
			
			
			currentBytes.position = 0 ;
			var po1:Number ;
			var po2:Number ;
			var jpgminPose:uint = 0 ;
			var jpgmaxPose:uint = 0 ;
			while(true)
			{
				if(currentBytes.bytesAvailable)
				{
					po1 = currentBytes.readUnsignedByte();
					if(po1 != 255)
					{
						continue ;
					}
				}
				else
				{
					break ;
				}
				if(currentBytes.bytesAvailable)
				{
					po2 = currentBytes.readUnsignedByte();
				}
				else
				{
					break ;
				}
				if(po2 == 216)
				{
					//trace('founded at '+currentBytes.position)
					if( jpgminPose == 0 )
					{
						jpgminPose = currentBytes.position-2 ;
					}
					else if( jpgmaxPose == 0 )
					{
						jpgmaxPose = currentBytes.position-2;
						break ;
					}
				}
			}
			
			
			//trace("jpgmaxPose : "+jpgminPose+' to '+jpgmaxPose);
			if(jpgmaxPose>jpgminPose)
			{
				
				var jpgBytes:ByteArray = new ByteArray();
				currentBytes.position = jpgminPose ;
				currentBytes.readBytes(jpgBytes,0,jpgmaxPose-jpgminPose);
				
				currentBytes = new ByteArray();
				
				loader1 = new Loader();
				loader1.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoaded);
				loader1.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,didntLoad);
				var contest:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
				contest.allowLoadBytesCodeExecution = true ;
				//trace("jpg founds and it is : "+jpgBytes.length);
				//loader2.close();
				
				stopLoadingImage();
				
				jpgBytes.position = 0 ;
				loader1.loadBytes(jpgBytes);
			}
		}
		
		protected function didntLoad(event:IOErrorEvent):void
		{
			
			trace('dont understand');
		}
		
		private function imageLoaded(e:*):void
		{
			if(loader1.content is Bitmap)
			{
				//trace('yes');
				//trace("last image was : "+(getTimer()-lastImageTime))
				lastImageTime = getTimer();
				this.bitmapData = (loader1.content as Bitmap).bitmapData ;
				
				if(W!=0 && H!=0)
				{
					this.width = W ;
					this.height = H ;
					this.scaleX = this.scaleY = Math.min(this.scaleX,this.scaleY);
				}
				
				if(myStageFrame!=null)
				{
					this.x = myStageFrame.x+(myStageFrame.width-this.width)/2 ;
					this.y = myStageFrame.y+(myStageFrame.height-this.height)/2 ;
				}
				
				startLoadingAgain();
			}
			else
			{
				trace('no')
			}
		}
	}
}