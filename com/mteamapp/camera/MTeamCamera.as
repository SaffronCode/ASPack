package com.mteamapp.camera
{
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class MTeamCamera
	{
		/**its looks like you can not have boteh cameras to gather */
		private var camera:Camera;
							
		private var vid:Video;
		
		private static var currentCamera:String='0';
		
		public static var firstCamID:String = '0',
					secondCamID:String = '1';
		
		private var targ:MovieClip,
					targWidth:Number,
					targHeight:Number,
					targMask:MovieClip;
					
		/**this will cause to mask the camera under the target area*/
		private var enableMask:Boolean = true;
		
		private var camWidth:Number,
					camHeight:Number;
					
		private var landScape:Boolean = true ;
		
		public static var dont_controll_portrate_screen:Boolean = false ;

		private var timOut:Number;
		
		private var rotateToRight:Boolean = false ;
		
		private static var shared:SharedObject ;
		
		private var rotation0:Number ;
		
		private static function setUpShared():void
		{
			if(shared==null)
			{
				shared = SharedObject.getLocal("cameraSharedObject",'/');
			}
		}
		
		private static function get customRotation():Number
		{
			setUpShared();
			var rotat:Number = shared.data['r'+currentCamera] ;
			
			if(isNaN(rotat))
			{
				return 0 ;
			}
			else
			{
				return rotat ;
			}
		}
		
		private static function setCustonRotation(value:Number):void
		{
			setUpShared();
			//trace("value : "+value);
			var newVal:Number = (value%360);
			//trace("newVal 1 : "+newVal);
			if(newVal<-180)
			{
				newVal+=360;
			}
			//trace("newVal 2 : "+newVal);
			if(newVal>=180)
			{
				newVal-=360;
			}
			//trace("newVal 3 : "+newVal);
			shared.data['r'+currentCamera] = newVal ;
		}
		
		public function MTeamCamera(target:MovieClip,selctedCameraID:String='')
		{
			DevicePrefrence.isItPC
			if(selctedCameraID!='')
			{
				currentCamera = selctedCameraID ;
			}
			
			
			targ = target ;
			targWidth = targ.width ;
			targHeight = targ.height;
			targ.scaleX = targ.scaleY = 1 ;
			
			if(dont_controll_portrate_screen || targ.stage.stageWidth > targ.stage.stageHeight || DevicePrefrence.isItPC)
			{
				landScape = true ;
			}
			else
			{
				//This device, makes camera upside down. I don't know what to do to detect them. ..
				if(Capabilities.os == "Linux 3.4.39-3098518")
				{
					rotateToRight = false ;
				}
				else
				{
					rotateToRight = true ;
				}
				landScape = false ;
			}
			
			if(landScape)
			{
				camWidth = targWidth*2;
				camHeight = targHeight*2;
			}
			else
			{
				camHeight = targWidth*2;
				camWidth = targHeight*2;
			}
			
			targMask = new MovieClip();
			if(enableMask)
			{
				targMask.graphics.beginFill(0);
			}
			else
			{
				targMask.graphics.lineStyle(0,0);
			}
			targMask.graphics.lineTo(targWidth,0);
			targMask.graphics.lineTo(targWidth,targHeight);
			targMask.graphics.lineTo(0,targHeight);
			targMask.graphics.lineTo(0,0);
			targMask.graphics.endFill();
			
			controllStage();
		}
		
		private function controllStage(e:*=null):void
		{
			
			if(targ.stage==null)
			{
				targ.addEventListener(Event.ADDED_TO_STAGE,controllStage);
			}
			else
			{
				targ.removeEventListener(Event.ADDED_TO_STAGE,controllStage);
				createCamera();
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,activateCamera);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,deactivateCamera);
				targ.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			}
		}
		
		protected function unLoad(event:Event):void
		{
			
			deactivateCamera();
		}
		
		public function deactivateCamera(e:*=null):void
		{
			clearTimeout(timOut);
			vid.attachCamera(null);
			//targ.removeChild(vid);
			//camera = null ;
		}
		
		public function activateCamera(e:*=null):void
		{
			timOut = setTimeout(activeCamWithTimeOut,1000);
		}
		
		private function activeCamWithTimeOut():void
		{
			if(targ.stage!=null)
			{
				vid.attachCamera(camera);
			}
		}
		
		public function createCamera():void
		{
			
			
			//remove every thing↓
			targ.removeChildren();
			
			//add video ↓
			vid = new Video();
			targ.addChild(vid);
			
			
			//add mask ↓
			targ.addChild(targMask);
			
			
			//set mask ↓
			if(enableMask)
			{
				vid.mask = targMask;
			}
			
			setCurrentCam();
			
			Obj.setButton(targ,switchCameras);
		}
		
		/**set up camera*/
		private function setCurrentCam()
		{
			if(!landScape)
			{
				if(rotateToRight)
				{
					vid.rotation = 90 ;
				}
				else
				{
					vid.rotation = -90 ;
				}
			}
			rotation0 = vid.rotation ;
			
			camera = Camera.getCamera(currentCamera);
			
			if(camera!=null){
				camera.setQuality(0,100);
				var camScale:Number = Math.max((camWidth/camera.width),(camHeight/camera.height));
				
				camera.setMode(Math.floor(camera.width*camScale),Math.floor(camera.height*camScale),24,true);
				vid.attachCamera(camera);

				if(landScape)
				{
					vid.width = targWidth ;
					vid.height = targHeight ;
				}
				else
				{
					vid.height = targWidth ;
					vid.width = targHeight ;
				}
				
				//debug line
				//vid.height = 1000;
				
				vid.scaleX = vid.scaleY = Math.max(vid.scaleX,vid.scaleY);
				if(landScape)
				{
					vid.x = (targWidth-vid.width)/2;
					vid.y = (targHeight-vid.height)/2;
				}
				else
				{
					if(rotateToRight)
					{
						vid.x = targWidth-(targWidth-vid.width)/2;
						vid.y = (targHeight-vid.height)/2;
					}
					else
					{
						vid.x = (targWidth-vid.width)/2;
						vid.y = targHeight-(targHeight-vid.height)/2;
					}
				}
			}
			else
			{
				trace("camera 1 is not ready");
			}
			updateCustomRotationInterface();
		}
		
		/***Rotate the camera in the custom user rotation*/
		private function updateCustomRotationInterface():void
		{
			
			//trace("customRotation is : "+customRotation);
			vid.rotation = rotation0 + customRotation ;
			switch(vid.rotation)
			{
				case(90):
					vid.x = targWidth-(targWidth-vid.width)/2;
					vid.y = (targHeight-vid.height)/2;
					break
				case(-90):
					vid.x = (targWidth-vid.width)/2;
					vid.y = targHeight-(targHeight-vid.height)/2;
					break
				case(-180):
				case(180):
					vid.x = targWidth-(targWidth-vid.width)/2;
					vid.y = targHeight-(targHeight-vid.height)/2;
					break
				case(0):
				default:
					vid.x = (targWidth-vid.width)/2;
					vid.y = (targHeight-vid.height)/2;
					break
			}
		}
		
	////////////////////////////////////public functions ↓
		
		/**switch cameras*/
		public function switchCameras(e:MouseEvent=null)
		{
			trace("switch cameras")
			if(currentCamera == firstCamID)
			{
				currentCamera = secondCamID ;
			}
			else
			{
				currentCamera = firstCamID ;
			}
			setCurrentCam();
		}
		
		/**returns current bitmap data*/
		public function getBitmapData():BitmapData
		{
			var bd:BitmapData = new BitmapData(targWidth,targHeight,false,0);
			bd.draw(targ);
			return bd;
		}
		
		/**tells if camera supported on this device*/
		public static function get isSupported():Boolean
		{
			var testCamera:Camera = Camera.getCamera(firstCamID);
			
			return Camera.isSupported && (testCamera!=null) ;
		}
	
		public function rotateLeft():void
		{
			
			//trace("customRotation : "+customRotation);
			//trace("customRotation-90 : "+(customRotation-90));
			setCustonRotation(customRotation-90) ;
			updateCustomRotationInterface();
		}
		
		/**Rotate the default camera to left*/
		public static function rotateLeft():void
		{
			setCustonRotation(customRotation-90) ;
		}
		
		/**Rotate the default camera to right*/
		public static function rotateRight():void
		{
			setCustonRotation(customRotation+90) ;
		}
		
		public function rotateRight():void
		{
			
			//trace("customRotation : "+customRotation);
			//trace("customRotation+90 : "+(customRotation+90));
			setCustonRotation(customRotation+90) ;
			updateCustomRotationInterface();
		}
	}
}