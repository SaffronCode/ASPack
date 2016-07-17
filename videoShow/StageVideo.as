package videoShow
{
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class StageVideo extends Sprite
	{
		private var userNativeStageWiew:Boolean = false ;
		
		private var 	W:Number = 0,
						H:Number = 0 ;
		
		
		
		private const STAGE_VIDEO_URL:String = "STAGE_VIDEO_URL";
		
		private var stageVideo:StageWebView,
					videoHTML:String='<!DOCTYPE html>\n<html> ' +
						'<meta name="viewport" content="width=device-width, user-scalable=no, target-densitydpi=device-dpi"/>'+
					'<style>*{margin:0;overflow:hidden;}.showVideo{width:100%;}</style>'+
					'<style>body {background-color: black}}</style>'+
					'<body>'+
					'<video class="showVideo" id="showVideo1" controls>'+
					'<source src="'+STAGE_VIDEO_URL+'" type="video/mp4">'+
					'Your browser does not support the video tag.'+
					'</video>'+
					'<script>var scrHeight=window.innerHeight;document.getElementById("showVideo1").style.height=scrHeight +"px";</script>'+
					'</body>\n</html>';// width="320" height="240" 

					private var correctedURL:String;
		
		
		public function StageVideo(Width:Number=0,Height:Number=0)
		{
			super();
			
			if(DevicePrefrence.isItPC)
			{
				userNativeStageWiew = true ;
			}
			
			W = Width ;
			H = Height ;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		
		
		/**stop the video and unload every thing*/
		public function unLoad(e:*=null)
		{
			this.removeEventListener(Event.ENTER_FRAME,controllStageVideoPose);
			if(stageVideo)
			{
				try
				{
					stageVideo.stage = null ;
					stageVideo.dispose()
				}catch(e){};
			}
		}
		
		
		
		
		/**load this video file*/
		public function loadThiwVideo(videoURL:String,autoPlay:Boolean=true,Width:Number=NaN,Height:Number=NaN,videoExtention:String=null)
		{
			var useOnHMLTag:Boolean=true;
			trace("loadThiwVideo : "+videoURL);
			if(!isNaN(Width))
			{
				W = Width ;
			}
			if(!isNaN(Width))
			{
				H = Height ;
			}
			this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawRect(0,0,W,H);
			
			stageVideo = new StageWebView(userNativeStageWiew);
			//stageVideo.loadString(videoHTML.split(stageVideo).join(videoURL));
			correctedURL = videoURL ;
			if(correctedURL.indexOf('http')==-1)
			{
				if(DevicePrefrence.isAndroid())
				{
					this.graphics.beginFill(0,1);
					this.graphics.drawRect(0,0,W,H);
					this.buttonMode = true ;
					this.addEventListener(MouseEvent.MOUSE_DOWN,openVideoFile);
					return;
				}
				else if(DevicePrefrence.isIOS())
				{
				}
			}
			
			trace("load the video location on stage web: "+correctedURL);
			//stageVideo.loadURL(correctedURL);
			if(useOnHMLTag)
			{
				var videoHTMLString:String = videoHTML.split(STAGE_VIDEO_URL).join(correctedURL) ;
				trace("Video HTML string is : "+videoHTMLString);
				stageVideo.loadString(videoHTMLString);
			}
			else
			{
				stageVideo.loadURL(correctedURL);
			}
			controllVideostage();
		}
		
		protected function openVideoFile(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			trace("Open corrected video targer: "+correctedURL);
			navigateToURL(new URLRequest("file://"+correctedURL));
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
			var viewPort:Rectangle = this.getBounds(stage);
			if(userNativeStageWiew)
			{
				var stageScaleX:Number = stage.nativeWindow.width/stage.stageWidth;
				var stageScaleY:Number = stage.nativeWindow.height/stage.stageHeight ;
				
				var minScale:Number = Math.min(stageScaleY,stageScaleX);
				
				viewPort.width *= minScale ;
				viewPort.height *= minScale ;
				
				viewPort.x = Math.max(0,(stage.nativeWindow.width-stage.stageWidth*minScale)/2)+(viewPort.x*minScale) ;
				viewPort.y = Math.max(0,(stage.nativeWindow.height-stage.stageHeight*minScale)/2)+(viewPort.y*minScale) ;
			}
			stageVideo.viewPort = viewPort ;
			if(Obj.isAccesibleByMouse(this))
			{
				stageVideo.stage = this.stage ;
			}
			else
			{
				stageVideo.stage = null ;
			}
		}
		
	}
}