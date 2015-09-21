package videoShow
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class VideoShow extends Sprite
	{
		//private var myValues:ToolsCompleteData = new ToolsCompleteData(0) ;
		
		private var videoTestDrawCompleted:Function ;
		
		private var videoURL:String ;
		
		private var backMC:MovieClip ;
		
		private var W:Number,H:Number ;
		
		private var video:VideoClass ;
		
		private var margin:Number = 10 ;
		
		
///////////////////////////////////////display objects
		
		private var videoTarget:MovieClip;
		
		private var playButton:MovieClip ;
		
		private var seeker:Seeker ;
		
		private var seekerHeight:Number ;
		
		
		
		
		public function VideoShow(onTestFinished:Function)
		{
			super();
			
			videoTarget = Obj.get('video_target_mc',this);
			playButton = Obj.get('play_mc',this);
			playButton.buttonMode = true ;
			playButton.stop();
			
			seekerHeight = playButton.height/2;
			
			seeker = new Seeker();
			this.addChild(seeker);
			seeker.addEventListener(SeekEvent.SEEK_REQUESTED,getSeek);
			
			videoTestDrawCompleted = onTestFinished ;
			
			backMC = Obj.get('back_mc',this);
			
			playButton.addEventListener(MouseEvent.CLICK,togglePlay);
			
			this.addEventListener(MouseEvent.MOUSE_OVER,showButtons);
			this.addEventListener(MouseEvent.MOUSE_OUT,hideButtons);
			
			this.addEventListener(Event.ENTER_FRAME,drawSeeker);
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			drawSeeker();
		}
		
		/**change the  seek*/
		private function getSeek(e:SeekEvent)
		{
			video.seek = e.seek;
		}
		
		private function drawSeeker(e=null)
		{
			if(video!=null && video.isLoaded)
			{
				seeker.visible = true ;
				seeker.setUp(W,seekerHeight,video.seek);
				seeker.x = W/-2;
				seeker.y = H/2-seekerHeight;
			}
			else
			{
				seeker.visible = false;
			}
		}
		
		private function unLoad(e)
		{	
			this.removeEventListener(Event.ENTER_FRAME,drawSeeker);
			this.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		/**show the controllets*/
		private function showButtons(e)
		{
			//playButton.visible = true ;
			AnimData.fadeIn(playButton);
			AnimData.fadeIn(seeker);
		}
		
		/**hide the controllers*/
		private function hideButtons(e)
		{
			//playButton.visible = false;
			AnimData.fadeOut(playButton);
			AnimData.fadeOut(seeker);
		}
		
		private function resetVideo(target:String)
		{
			if(video!=null)
			{
				videoTarget.removeChild(video);
			}
			video = new VideoClass();
			videoTarget.addChild(video);
			video.addEventListener(videoEvents.VIDEO_LOADED,testDrawingEnded);
			video.addEventListener(videoEvents.VIDEO_STATUS_CHANGED,playStatusChanged);
			video.loadThiwVideo(target);
		}
		
		/**toggle play or pause*/
		private function togglePlay(e)
		{
			if(video!=null)
			{
				if(video.statusPlay())
				{
					video.pause();
				}
				else
				{
					video.play();
				}
			}
		}
		
		/**change the player status*/
		private function playStatusChanged(e:videoEvents)
		{
			if(e.statusPlay)
			{
				playButton.gotoAndStop(2);
			}
			else
			{
				playButton.gotoAndStop(1);
			}
		}
		
		/**drop the video with its real size*/
		public function tryToDraw(prop:ToolsCompleteData)
		{
			myValues = prop;
			videoURL = ToolsManager.getTools(ToolsManager.video_url,myValues).values[0];
			
			this.x = ToolsManager.getTools(ToolsManager.pose_x_tag,myValues).values[0] = stage.mouseX  ;
			this.y = ToolsManager.getTools(ToolsManager.pose_y_tag,myValues).values[0] = stage.mouseY  ;
			resetVideo(videoURL);
			
			trace('video have to play');
			
			
			/*stage.addEventListener(MouseEvent.MOUSE_UP,testDrawingEnded);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,testRedraw);
			testRedraw(null);*/
		}
		
		
		/**first drawing of the item is over*/
		private function testDrawingEnded(e)
		{
			/*stage.removeEventListener(MouseEvent.MOUSE_UP,testDrawingEnded);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,testRedraw);*/
			
			
			video.x = video.width/-2 ;
			video.y = video.height/-2 ;
			video.pause();
			
			//drawBack();
			
			if(videoTestDrawCompleted!=null)
			{
				ToolsManager.getTools(ToolsManager.width_tag,myValues).values[0] = W = video.width ;
				ToolsManager.getTools(ToolsManager.heigth_tag,myValues).values[0] = H = video.height ;
				videoTestDrawCompleted();
				videoTestDrawCompleted = null ;
			}
			else
			{
				W = ToolsManager.getTools(ToolsManager.width_tag,myValues).values[0] ;
				H = ToolsManager.getTools(ToolsManager.heigth_tag,myValues).values[0] ;
			}
			rePoseVideo();
			drawBack();
			drawSeeker();
			
			
			
			//**remove listener to dont send effect after image updated
			//imageTestDrawCompleted = new Function();
		}
		
		/**draw the background of the image*/
		private function drawBack()
		{
			backMC.width = W + margin ;
			backMC.height = H + margin ;
		}
		
		private function rePoseVideo()
		{
			video.width = W ;
			video.height = H ;
			video.x = W/-2;
			video.y = H/-2;
		}
		
		
		
		/**redraw item in test mode*/
		private function testRedraw(e)
		{
			//trace('mouse moved');
			drawImage(this.mouseX*2,this.mouseY*2);
		}
		
		
		/**draw sample image*/
		private function drawImage(Width:Number,Height:Number)
		{
			//trace('draw');
			W = Width ;
			H = Height ;
			
			ToolsManager.getTools(ToolsManager.width_tag,myValues).values[0] = W ;
			ToolsManager.getTools(ToolsManager.heigth_tag,myValues).values[0] = H ;
			
			backMC.width = W ;
			backMC.height = H ;
			
			//ToolsManager.getTools(ToolsManager.pose_x_tag,myValues
			
			/*if(imageIsLoaded)
			{
				imageMC.width = Math.max(0,W-margin) ;
				imageMC.height = Math.max(0,H-margin) ;
				imageMC.x = imageMC.width/-2 ;
				imageMC.y = imageMC.height/-2 ;
			}*/
		}
		
		public function update(newProp:ToolsCompleteData)
		{
			newProp.clone(myValues) ;
			
			var newURL:String = ToolsManager.getTools(ToolsManager.video_url,myValues).values[0] ;
			if(newURL!=videoURL)
			{
				videoURL = newURL ;
				resetVideo(videoURL);
			}
			else
			{
				W = ToolsManager.getTools(ToolsManager.width_tag,myValues).values[0];
				H = ToolsManager.getTools(ToolsManager.heigth_tag,myValues).values[0];
				drawBack();
				rePoseVideo();
				drawSeeker();
			}
			
			//trace('updated : '+ToolsManager.getTools(ToolsManager.width_tag,myValues).values[0]);
			this.x = ToolsManager.getTools(ToolsManager.pose_x_tag,myValues).values[0] ;
			this.y = ToolsManager.getTools(ToolsManager.pose_y_tag,myValues).values[0] ;
			this.rotation = ToolsManager.getTools(ToolsManager.rotation_tag,myValues).values[0];
		}
	}
}