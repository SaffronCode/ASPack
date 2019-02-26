// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package videoPlayer
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import soundPlayer.SoundPlayer;
	
	
	public class myVideoPlayer extends Sprite
	{
		private static var ME:myVideoPlayer;
		
		private var seekLine:MovieClip,
					seek:MovieClip,
					playBTN:MovieClip,
					soundBTN:MovieClip,
					
					seeking:Boolean = false;
					
		/**back groun object*/			
		public static var backGround:MovieClip;
		/**check if the main music is playing or not		
		private static var musicPlaying:Boolean;*/
					
		private static var GPUavail:Boolean,
					sv:StageVideo,
					vid:Video,
					nc:NetConnection,
					ns:NetStream;
		
		/**every thing about playeing video*/
		private static var 	vid_target:String,
							vid_duration:Number,
							vid_width:Number,
							vid_height:Number,
							
							vid_full_width:Number,
							vid_full_height:Number,
							
							vid_x:Number,
							vid_y:Number,
							
							vid_full_x:Number,
							vid_full_y:Number;
		
		public function myVideoPlayer():void
		{
			super();
			ME = this ;
			
			seekLine = gt('seek_line_mc');
			seek = gt('seek_mc');
			playBTN = gt('play_mc');
			playBTN.stop();
			soundBTN = gt('sound_mc');
			soundBTN.stop();
			backGround = gt('back_mc');
			
			controllStage();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			this.addEventListener(Event.ENTER_FRAME,enterFrame);
			
			seek.addEventListener(MouseEvent.MOUSE_DOWN,startSeek);
			seekLine.addEventListener(MouseEvent.MOUSE_DOWN,seekLinePressd);
			playBTN.addEventListener(MouseEvent.MOUSE_DOWN,togglePause);
			backGround.addEventListener(MouseEvent.MOUSE_DOWN,togglePause);
			soundBTN.addEventListener(MouseEvent.MOUSE_DOWN,toggleSound);
			
			hideBTNs();
		}
		
		private function controllStage(e:Event=null)
		{
			if(this.stage!=null)
			{
				stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY,stageVideoIsReady);
				stage.addEventListener(MouseEvent.MOUSE_UP,seekEnded);
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE,controllStage);
			}
		}
		
		/**unload class*/
		private function unLoad(e:*=null)
		{
			if(ns!=null)
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL ;
				ns.close();
			}
			stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY,stageVideoIsReady);
			stage.removeEventListener(MouseEvent.MOUSE_UP,seekEnded);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			this.removeEventListener(Event.ENTER_FRAME,enterFrame);
			
		}
		
		public static function close()
		{
			ns.close();
			//play music again if it was playing befor
			/*if(musicPlaying)
			{
				SoundPlayer.play(Bahaiat.musicID);
			}*/
		}
		
		
		/**stop seeking*/
		private function seekEnded(e)
		{
			seeking = false;	
		}
		
		
		/**stop seeking*/
		private function startSeek(e)
		{
			seeking = true;	
		}
		
		
		/**playe the selected video*/
		public static function playeMyVideo(target:String)
		{
			/*musicPlaying = !SoundPlayer.getStatuse_pause(Bahaiat.musicID);
			SoundPlayer.pause(Bahaiat.musicID);*/
			
			trace('play this video : '+target);
			
			vid_target = target.split('|')[0];
			var file:File = File.applicationDirectory.resolvePath(target);
			if(file.exists)
			{
				ME.setup();
			}
			else
			{
				trace('VIDEO IS NOT EXISTED!!');
			}
		}
		
		public function setup()
		{
			stageVideoIsReady();
		}
		
		
		
		/**hide or show down btns*/
		private function hideBTNs(hideIt:Boolean = true):void
		{
			seekLine.visible = seek.visible = playBTN.visible = soundBTN.visible = !hideIt;
		}
		
		
		/**returns Movie Clip with this name*/
		private function gt(movieClipName:String):MovieClip
		{
			return MovieClip(this.getChildByName(movieClipName));
		}
		
/////////////////////////////////////////////////////////
		
		/**check if video started or stage video started*/
		private function stageVideoIsReady(e=null)
		{
			if(ns!=null)
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL ;
				ns.close();
			}
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.client = this ;
			if(false && stage.stageVideos.length!=0){
				GPUavail = true ;
				sv = stage.stageVideos[0];
				sv.attachNetStream(ns);
			}else{
				GPUavail = false ;
				if(vid!=null)
				{
					Obj.remove(vid);
					vid = null ;
				}
				vid = new Video();
				vid.attachNetStream(ns);
				this.addChild(vid);
			}
			
			checkForReadyVideo();
		}
		
		
		public function onXMPData(w=null)
		{
			
		}
		
		private function checkForReadyVideo()
		{
			if(vid_target!=null && vid_target!='')
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE ;
				ns.play(vid_target);
			}
		}
		
		
////////////////////////////////////////////////////////playe back functions
		public function onMetaData(e)
		{
			//trace('meta')
			var testScale:Number = Math.min(backGround.width/e.width,
											backGround.height/e.height) ;
			
			vid_width = e.width*testScale ;
			vid_height = e.height*testScale ;
			vid_x = (backGround.width - vid_width)/2;
			vid_y = (backGround.height - vid_height)/2 ;
			
			//trace('vid_width : '+vid_width)
			if(!GPUavail){
				vid.width = vid_width;
				vid.height = vid_height;
				vid.x = vid_x+backGround.x ;
				vid.y = vid_y+backGround.y ;
			}
			else
			{
				var base:Rectangle = backGround.getBounds(stage) ;
				sv.viewPort = new Rectangle(vid_x+base.x,vid_y+base.y,vid_width,vid_height);//,,vid_width,vid_height) ;
			}
			vid_duration = e.duration ;
			
			hideBTNs(false);
			playBTN.gotoAndStop(2);
			soundBTN.gotoAndStop(1);
			enterFrame();
		}
		
		
		public function onPlayStatus(e)
		{
			togglePause(null,0);
		}
		
		/**managing the seek and other btns */
		private function enterFrame(e=null)
		{
			var persent:Number;
			if(seeking)
			{
				if(seek.x == mouseX)
				{
					return ;
				}
				seek.x = mouseX ;
				if(seek.x>seekLine.x+seekLine.width)
				{
					seek.x = seekLine.x+seekLine.width ;
				}
				else if(seek.x<seekLine.x)
				{
					seek.x = seekLine.x;
				}
				
				persent = ((seek.x-seekLine.x)/seekLine.width)*vid_duration;
				if(persent>vid_duration-1)
				{
					persent=vid_duration-1;
				}
				ns.seek(Math.floor(persent));
			}
			else
			{
				persent = ns.time/vid_duration;
				seek.x = seekLine.x+seekLine.width*persent;
			}
		}
		
		/**seek line clicked by client*/
		private function seekLinePressd(e)
		{
			/*var persent = ((mouseX-seekLine.x)/seekLine.width);
			if(persent>1)
			{
				persent = 1 ;
			}
			else if (persent<0)
			{
				persent = 0 ;
			}
			trace("persent : "+persent)
			ns.seek(persent*(vid_duration-1));*/
			seeking = true;
		}
		
		/**toggle pause and play<br>
		 * you can force it to play or allways stop with<br>
		 * set playIt to 0 to stop and set playIt to 1 to allways play*/
		private function togglePause(e,playIt=-1)
		{
			if(playBTN.currentFrame==1 || playIt==1)
			{
				if(vid_duration-2<ns.time)
				{
					ns.seek(0);
				}
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE ;
				ns.resume();
				playBTN.gotoAndStop(2);
			}
			else if(playBTN.currentFrame==2 || playIt==0)
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL ;
				ns.pause();
				playBTN.gotoAndStop(1);
			}
		}
		
		/**toggle video volume<br>
		 * you can manage what to doo with setting mute to 0 to allwoys 
		 * volume up or 1 to allways mute the sound */
		private function toggleSound(e,mute=-1)
		{
			if(soundBTN.currentFrame==1 || mute==1)
			{
				ns.soundTransform = new SoundTransform(0);
				soundBTN.gotoAndStop(2);
			}
			else if(soundBTN.currentFrame==2 || mute==0)
			{
				ns.soundTransform = new SoundTransform(1);
				soundBTN.gotoAndStop(1);
			}
		}
	}
}