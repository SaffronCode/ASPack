package videoShow
{
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

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
				stageVideo.stage = null ;
				stageVideo.dispose()
			}
		}
		
		
		
		
		/**load this video file*/
		public function loadThiwVideo(videoURL:String,autoPlay:Boolean=true,Width:Number=NaN,Height:Number=NaN,videoExtention:String=null,useOnHMLTag:Boolean=true)
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
			this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawRect(0,0,W,H);
			
			stageVideo = new StageWebView(userNativeStageWiew);
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
			//stageVideo.loadURL(correctedURL);
			if(useOnHMLTag)
			{
				stageVideo.loadString(videoHTML.split(STAGE_VIDEO_URL).join(correctedURL));
			}
			else
			{
				stageVideo.loadURL(correctedURL);
			}
			controllVideostage();
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
				viewPort.width *= Math.min(stageScaleX,stageScaleY) ;
				viewPort.height *= Math.min(stageScaleX,stageScaleY) ;
				viewPort.x += (stage.nativeWindow.width-stage.stageWidth)/2//*Math.max(stageScaleX-stageScaleY) ;
				//viewPort.y += (stage.nativeWindow.height-stage.stageHeight)/2*Math.max(stageScaleY-stageScaleX) ;
			}
			stageVideo.viewPort = viewPort ;
			if(Obj.isAccesibleByMouse(this))
			{
				stageVideo.stage == this.stage ;
			}
			else
			{
				stageVideo.stage == null ;
			}
		}
		
	}
}