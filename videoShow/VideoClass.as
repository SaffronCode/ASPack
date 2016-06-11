package videoShow
{
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.media.StageWebView;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	[Event(name="VIDEO_LOADED", type="videoShow.VideoEvents")]
	[Event(name="VIDEO_NOT_FOUND", type="videoShow.VideoEvents")]
	[Event(name="VIDEO_STATUS_CHANGED", type="videoShow.VideoEvents")]
	
	public class VideoClass extends Sprite
	{
		private var 	W:Number = 0,
						H:Number = 0 ;
		
		public var videoObject:Video ;
		
		
		private var netStream:NetStream ;
		
		private var netConnetction:NetConnection ;
		
		private var videoClient:VideoClient ;
		
		private var videoDuration:Number ; 
		
		private var played:Boolean = false;
		
		
		private const STAGE_VIDEO_URL:String = "STAGE_VIDEO_URL";
		
		private var stageVideo:StageWebView,
					videoHTML:String='<video controls><source src="'+STAGE_VIDEO_URL+'" type="video/mp4"></video>';// width="320" height="240" 
		
		
		public function VideoClass()
		{
			super();
			
			videoDuration = 0 ;
			
			netConnetction = new NetConnection();
			netConnetction.connect(null);
			
			videoClient = new VideoClient();
			videoClient.OnMetaData = videoLoaded ;
			videoClient.OnPlayStatus = getPlayStatus;
			videoClient.OnSeekPoint = seekUpdated ;

			netStream = new NetStream(netConnetction);
			netStream.addEventListener(NetStatusEvent.NET_STATUS,listenToNetStatus);
			netStream.addEventListener(IOErrorEvent.IO_ERROR,noFileExists);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,noFileExists);
			netStream.addEventListener(DRMErrorEvent.DRM_ERROR,noFileExists);
			netStream.client = videoClient ;
			videoObject = new Video();
			videoObject.attachNetStream(netStream);
			this.addChild(videoObject);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		protected function noFileExists(event:*):void
		{
			// TODO Auto-generated method stub
			trace("File dose not exists");
			this.dispatchEvent(new VideoEvents(VideoEvents.VIDEO_NOT_FOUND));
		}
		
		/**tells that if the video is loaded or not*/
		public function get isLoaded():Boolean
		{
			if(videoDuration==0)
			{
				return false;
			}
			else
			{
				return true ;
			}
		}
		
		/**this function will tells that if the video is playing */
		public function statusPlay():Boolean
		{
			return played ;
		}
		
		/**stop the video and unload every thing*/
		public function unLoad(e:*=null)
		{
			netConnetction.close();
			netStream.close();
			videoObject.clear();
			this.removeEventListener(Event.ENTER_FRAME,controllStageVideoPose);
			if(stageVideo)
			{
				stageVideo.stage = null ;
			}
		}
		
		/**net status changed*/
		private function listenToNetStatus(e:NetStatusEvent)
		{
			//trace(e);
		}
		
		
		private function getPlayStatus(e)
		{
			trace("Play statis updated : "+JSON.stringify(e,null,' '));
			if(e.code == "NetStream.Play.Complete")
			{
				setseek(0);
				pause();
			}
		}
		
		
		
		
		
		/**load this video file*/
		public function loadThiwVideo(videoURL:String,autoPlay:Boolean=true,Width:Number=NaN,Height:Number=NaN,videoExtention:String=null)
		{
			trace("loadThiwVideo : "+videoURL);
			if(!isNaN(Width))
			{
				W = Width ;
			}
			if(!isNaN(Width))
			{
				H = Height ;
			}
			if(DevicePrefrence.isIOS() && (videoURL.toLocaleLowerCase().lastIndexOf('.mp4')!=-1 || videoExtention.indexOf("mp4")!=-1))
			{
				if(W==0)
				{
					W = 320 ;
				}
				if(H==0)
				{
					H = 480 ;
				}
				
				this.graphics.clear();
				this.graphics.beginFill(0,0);
				this.graphics.drawRect(0,0,W,H);
				
				stageVideo = new StageWebView();
				//stageVideo.loadString(videoHTML.split(stageVideo).join(videoURL));
				var correctedURL:String = videoURL ;
				try
				{
					if(correctedURL.indexOf('http')==-1)
					{
						correctedURL = new File(correctedURL).nativePath;
					}
				}
				catch(e)
				{
					trace("****The video location may be wrong : "+videoURL);
					correctedURL = videoURL ;
				}
				trace("load the video location on stage web: "+correctedURL);
				stageVideo.loadURL(correctedURL);
				controllVideostage();
			}
			else
			{
				played = autoPlay ;
				netStream.useHardwareDecoder = true ;
				netStream.play(videoURL);
				videoObject.smoothing = true ;
			}
		}
		
		private function controllVideostage(e:*=null):void
		{
			if(this.stage!=null)
			{
				stageVideo.stage = this.stage ;
				this.addEventListener(Event.ENTER_FRAME,controllStageVideoPose);
				controllStageVideoPose();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE,controllVideostage);
			}
		}
		
		private function controllStageVideoPose(e:*=null):void
		{
			stageVideo.viewPort = this.getBounds(stage);
			if(Obj.isAccesibleByMouse(this))
			{
				stageVideo.stage == this.stage ;
			}
			else
			{
				stageVideo.stage == null ;
			}
		}
		
		/**pause the video*/
		public function pause()
		{
			if(videoDuration!=0)
			{
				netStream.pause();
				played = false;
			}
			this.dispatchEvent(new VideoEvents(VideoEvents.VIDEO_STATUS_CHANGED,played));
		}
		
		/**seek this video from selected position*/
		public function set seek(position:Number)
		{
			setseek(position);
		}
		
		/**seek this video from selected position*/
		private function setseek(position:Number)
		{
			if(videoDuration!=0)
			{
				position = Math.min(1,Math.max(0,position));
				try
				{
					netStream.seek(Math.floor(position*videoDuration));
				}catch(e){};
			}
		}
		
		protected function seekUpdated(event:*):void
		{
			trace("Seek updated????"+event);
		}
		
		/**play the video*/
		public function play()
		{
			if(videoDuration!=0)
			{
				netStream.resume();
				played = true ;
			}
			this.dispatchEvent(new VideoEvents(VideoEvents.VIDEO_STATUS_CHANGED,played));
		}
		
		/**get the video seek precent*/
		public function get seek():Number
		{
			if(videoDuration!=0)
			{
				return Math.min(1,Math.max(0,netStream.time/videoDuration));
			}
			return 0 ;
		}
		
		/**This is the loaded percent for the current video*/
		public function get loadedStreamPercent():Number
		{
			return netStream.bytesLoaded/netStream.bytesTotal ;
		}
				
			
		
		
		
		
		/**video is loaded*/
		private function videoLoaded(metaData)
		{
			trace("VIDOIEFIOJIEOFJOE JIFOJIO "+JSON.stringify(metaData,null,' '));
			videoDuration = metaData.duration ;
			if(!played)
			{
				pause();
			}
			
			if(W!=0 && H!=0)
			{
				this.graphics.clear();
				this.graphics.beginFill(0x000000,0);
				this.graphics.drawRect(0,0,W,H);
				videoObject.width = W ;
				videoObject.height = H ;
				videoObject.scaleX = videoObject.scaleY = Math.min(videoObject.scaleX,videoObject.scaleY);
				videoObject.x = (W-videoObject.width)/2;
				videoObject.y = (H-videoObject.height)/2;
			}
			
			this.dispatchEvent(new VideoEvents(VideoEvents.VIDEO_LOADED));
			this.dispatchEvent(new VideoEvents(VideoEvents.VIDEO_STATUS_CHANGED,played));
		}
	}
}