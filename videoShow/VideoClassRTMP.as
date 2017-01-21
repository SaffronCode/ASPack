package videoShow
{
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoClassRTMP extends Sprite
	{
		private var W:Number,H:Number;
		
		private var streamURL:String ;
		private var streamId:String ;
		private var vid:Video;
		private var nc:NetConnection;

		private var netStreamObj:NetStream;
		private var metaListener:Object;
		private var streamID:String;
		
		public function VideoClassRTMP(Width:Number,Height:Number)
		{
			super();
			W = Width ;
			H = Height ;
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		protected function unLoad(event:Event):void
		{
			// TODO Clear every thing
		}
		
		/**Controll the stage to start application*/
		private function controllStage(e:*=null):void
		{
			if(this.stage==null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE,controllStage);
			}
			else
			{
				start();
			}
		}
		
		/**Load the rtmpURL*/
		public function load(rtmpURL:String):void
		{
			streamURL = rtmpURL.substring(0,rtmpURL.lastIndexOf('/')+1) ;
			streamID = rtmpURL.substring(rtmpURL.lastIndexOf('/')+1) ;
			trace("streamURL : "+streamURL);
			trace("streamID : "+streamID);
			controllStage();
		}
		
		
		protected function start(event:Event=null):void
		{
			
			vid = new Video(); //typo! was "vid = new video();"
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			nc.client = { onBWDone: function():void{} };
			nc.connect(streamURL);
		}
		private function onConnectionStatus(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{
				trace("Creating NetStream");
				netStreamObj = new NetStream(nc);
				
				metaListener = new Object();
				metaListener.onMetaData = received_Meta;
				netStreamObj.client = metaListener;
				
				netStreamObj.play(streamID);
				trace(netStreamObj.bufferTime);
				vid.attachNetStream(netStreamObj);
				vid.smoothing = true ;
				addChild(vid);
				//intervalID = setInterval(playback, 1000);
			}
		}
		
		private function playback():void
		{ 
			//trace((++counter) + " Buffer length: " + netStreamObj.bufferLength); 
		}
		
		public function asyncErrorHandler(event:AsyncErrorEvent):void 
		{ trace("asyncErrorHandler.." + "\r"); }
		
		public function onFCSubscribe(info:Object):void
		{ trace("onFCSubscribe - succesful"); }
		
		public function onBWDone(...rest):void
		{ 
			var p_bw:Number; 
			if (rest.length > 0)
			{ p_bw = rest[0]; }
			trace("bandwidth = " + p_bw + " Kbps."); 
		}
		
		private function received_Meta (data:Object):void
		{
			var _stageW:int = stage.stageWidth;
			var _stageH:int = stage.stageHeight;
			
			var _videoW:int;
			var _videoH:int;
			var _aspectH:int; 
			
			var Aspect_num:Number; //should be an "int" but that gives blank picture with sound
			Aspect_num = data.width / data.height;
			
			//Aspect ratio calculated here..
			_videoW = _stageW;
			_videoH = _videoW / Aspect_num;
			_aspectH = (_stageH - _videoH) / 2;
			
			vid.x = 0;
			vid.y = _aspectH;
			vid.width = _videoW;
			vid.height = _videoH;
		}
		
	} //end class
	
} 
		
