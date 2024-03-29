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
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import flash.display.Bitmap;

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
		
		/**flash.events.PermissionEvent*/
		private static var PermissionEventClass:Class;
		/**flash.permissions.PermissionStatus*/
		private static var PermissionStatusClass:Class;

		private var fakeCamera:Boolean,
					fakeCameraBitmap:Bitmap,
					fakeCamData:BitmapData ;

		private var framerate:uint ;
		
		private static function setUpShared():void
		{
			if(shared==null)
			{
				shared = SharedObject.getLocal("cameraSharedObject",'/');
			}
		}
		
		private static function setUpPermissionClasses():void
		{
			try
			{
				PermissionEventClass = getDefinitionByName("flash.events.PermissionEvent") as Class;
				PermissionStatusClass = getDefinitionByName("flash.permissions.PermissionStatus") as Class;
			}
			catch(e)
			{
				PermissionEventClass = null ;
				PermissionStatusClass = null ;
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

		private function detectLandscape():void
		{
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
		}
		
		public function MTeamCamera(target:MovieClip,selctedCameraID:String='',fakeCameraWhenNoCameraAccesible:Boolean=false,framerate:uint=60)
		{
			if(selctedCameraID!='')
			{
				currentCamera = selctedCameraID ;
			}
			
			fakeCamera = fakeCameraWhenNoCameraAccesible ;
			this.framerate = framerate ;
			
			targ = target ;
			targWidth = targ.width ;
			targHeight = targ.height;
			targ.scaleX = targ.scaleY = 1 ;
			
			detectLandscape();
			
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
			targ.removeEventListener(Event.ENTER_FRAME,fakeCameraEffect);
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
			Obj.setButton(targ,switchCameras);
			
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
			
		}
		
		/**set up camera*/
		private function setCurrentCam():void
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
			rotation0 = isNaN(rotation0)?vid.rotation:rotation0 ;
			
			camera = Camera.getCamera(currentCamera);
			setUpPermissionClasses();
			if (PermissionStatusClass!=null && (Camera as Object).permissionStatus != PermissionStatusClass.GRANTED)
			{
				camera.addEventListener(PermissionEventClass.PERMISSION_STATUS, function(e:*):void {
					if (e.status == PermissionStatusClass.GRANTED)
					{
						connectCamera();
					}
					else
					{
						// permission denied
						trace("Camera permission denied " +e);
					}
				});
				
				try {
					camera.requestPermission();
				} catch(e:Error)
				{
					// another request is in progress
					trace("Camera another request is in progress " +e);
				}
			}
			else
			{
				connectCamera();
			}
		}
		
		private function connectCamera():void
		{
			Obj.remove(fakeCameraBitmap);
			targ.removeEventListener(Event.ENTER_FRAME,fakeCameraEffect);

			if(camera!=null){
				camera.setQuality(0,70);
				var camScale:Number = Math.max((camWidth/camera.width),(camHeight/camera.height));
				
				camera.setMode(640,480,framerate,true);
				camera.setQuality(1,1);
				vid.attachCamera(camera);
				
				
			}
			else
			{
				trace("camera 1 is not ready");
				if(fakeCamera)
				{
					if(fakeCameraBitmap==null)
					{
						fakeCamData = new BitmapData(targWidth,targHeight,false,0x000000);
						fakeCameraBitmap = new Bitmap(fakeCamData);
					}
					targ.addChild(fakeCameraBitmap);

					fakeCameraEffect(null);
					targ.addEventListener(Event.ENTER_FRAME,fakeCameraEffect);
				}
			}
			updateCustomRotationInterface();
		}

		private function fakeCameraEffect(e:Event):void
		{
			fakeCamData.noise(Math.floor(Math.random()*20),0,255,7,true);
		}
		
		/***Rotate the camera in the custom user rotation*/
		private function updateCustomRotationInterface():void
		{
				vid.height = vid.width = Math.max(targWidth,targHeight) ;
			
			//debug line
			//vid.height = 1000;

			trace("landScape:"+landScape);
			trace("targWidth:"+targWidth+' , targHeight:'+targHeight);
			trace("vid.width:"+vid.width+' , vid.height:'+vid.height);
			
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
		public function switchCameras(e:MouseEvent=null):void
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