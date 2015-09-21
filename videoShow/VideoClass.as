package videoShow
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	[Event(name="videoFileIsLoaded", type="videoShow")]
	[Event(name="videoNotFound", type="videoShow")]
	[Event(name="videoStatusChanged", type="videoShow")]
	
	public class VideoClass extends Sprite
	{
		private var 	W:Number = 0,
						H:Number = 0 ;
		
		private var video:Video ;
		
		
		private var netStream:NetStream ;
		
		private var netConnetction:NetConnection ;
		
		private var videoClient:VideoClient ;
		
		private var videoDuration:Number ; 
		
		private var played:Boolean = false;
		
		
		public function VideoClass()
		{
			super();
			
			videoDuration = 0 ;
			
			netConnetction = new NetConnection();
			netConnetction.connect(null);
			
			videoClient = new VideoClient();
			videoClient.OnMetaData = videoLoaded ;
			videoClient.OnPlayStatus = getPlayStatus;

			netStream = new NetStream(netConnetction);
			netStream.addEventListener(NetStatusEvent.NET_STATUS,listenToNetStatus);
			netStream.client = videoClient ;
			
			video = new Video();
			video.attachNetStream(netStream);
			this.addChild(video);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
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
		private function unLoad(e)
		{
			netConnetction.close();
			netStream.close();
			video.clear();
		}
		
		/**net status changed*/
		private function listenToNetStatus(e:NetStatusEvent)
		{
			//trace(e);
		}
		
		
		private function getPlayStatus(e)
		{
			if(e.code == "NetStream.Play.Complete")
			{
				setseek(0);
				pause();
			}
		}
		
		
		
		
		
		/**load this video file*/
		public function loadThiwVideo(videoURL:String,autoPlay:Boolean=true)
		{
			played = autoPlay ;
			netStream.useHardwareDecoder = true ;
			netStream.play(videoURL);
			video.smoothing = true ;
		}
		
		/**pause the video*/
		public function pause()
		{
			if(videoDuration!=0)
			{
				netStream.pause();
				played = false;
			}
			this.dispatchEvent(new videoEvents(videoEvents.VIDEO_STATUS_CHANGED,played));
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
		
		/**play the video*/
		public function play()
		{
			if(videoDuration!=0)
			{
				netStream.resume();
				played = true ;
			}
			this.dispatchEvent(new videoEvents(videoEvents.VIDEO_STATUS_CHANGED,played));
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
				
			
		
		
		
		
		/**video is loaded*/
		private function videoLoaded(metaData)
		{
			videoDuration = metaData.duration ;
			if(!played)
			{
				pause();
			}
			this.dispatchEvent(new videoEvents(videoEvents.VIDEO_LOADED));
			this.dispatchEvent(new videoEvents(videoEvents.VIDEO_STATUS_CHANGED,played));
		}
	}
}