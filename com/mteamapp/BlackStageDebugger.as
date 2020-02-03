package com.mteamapp
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import permissionControlManifestDiscriptor.PermissionControl;
	import flash.media.Video;
	import flash.display.MovieClip;
	import animation.Anim_alpha_shine;
	import flash.utils.getTimer;
	import contents.alert.Alert;
	import nativeClasses.distriqtApplication.DistriqtApplication;

	public class BlackStageDebugger
	{
		private static var stage:Stage,
							root:DisplayObject;
							
		private static const orientedStarted:uint=100,
							orientedRestored:uint = 200,
							visibleActivated:uint = 500 ;

		private static var defaultOriented:String;

		private static var stageColor:uint;
		
		private static var timeOutId1:Number,timeOutId2:Number,timeOutId0:Number;
		
		private static var onTheRotationing:Boolean = false ;

		private static var toOrientation:String;
		
		public static function setUp(myStage:Stage,myRoot:DisplayObject):void
		{
			trace("Black screen problem didn't see on Android 5+. The device OS is : "+Capabilities.os );
			if(DevicePrefrence.isAndroid())
			{
				if(DistriqtApplication.isSupported())
				{
					var _letBlackScreenSolverCome:Boolean = false ;
					NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,function(e:*):void{_letBlackScreenSolverCome=true;})
					NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,function(e:*):void{
						if(_letBlackScreenSolverCome)
							DistriqtApplication.solveBlackScreenProblem();
					})
				}
				return ;
				stage = myStage;
				root = myRoot ;
				
				defaultOriented = stage.orientation ;
				stageColor = stage.color ;

				var containVideoIsFalse:Boolean = PermissionControl.controlVideoProblemReverted();
				var vid:Video ;
				var screenBackEffect:MovieClip = new MovieClip();
				screenBackEffect.graphics.beginFill(0x000000);
				screenBackEffect.mouseChildren = screenBackEffect.mouseEnabled = false ;
				var maxW:Number = Math.max(stage.stageHeight,stage.stageWidth)*3;
				screenBackEffect.graphics.drawRect(-(maxW-stage.stageWidth)/2,-(maxW-stage.stageHeight)/2,maxW,maxW);
				if(containVideoIsFalse)
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,function(e:*):void
				{
					if(vid==null)
					{
						vid = new Video(200,200);
						myStage.addChild(vid);
					}
					hideElements();
					//setTimeout(hideElements,100);
				});
				if(containVideoIsFalse)
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,function(e:*):void
				{
					if(getTimer()<10000 && root.visible!=false)
						return;
					hideElements();
					setTimeout(reactiveStageAgain,200);
				});

				function hideElements():void
				{
					root.visible = false ;
					stage.color = 0x000000 ;
				}
				function reactiveStageAgain():void
				{
					root.visible = true ;
					stage.color = stageColor ;
					screenBackEffect.alpha = 1 ;
					stage.addChild(screenBackEffect);
					AnimData.fadeOut(screenBackEffect,removeScreenMaskAgain)
				}
				function removeScreenMaskAgain():void
				{
					Obj.remove(screenBackEffect);
				}
				return ;
				PermissionControl.controlVideoProblem();
				trace("BlackScreen debugger on android...");
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,restoreBlackScreen);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,resetScreend);
			}
		}
		
		protected static function resetScreend(event:Event):void
		{
			
			clearTimeout(timeOutId0);
			clearTimeout(timeOutId1);
			clearTimeout(timeOutId2);
			stage.color = stageColor ;
			stage.setOrientation(defaultOriented);
			root.visible = true ;
			onTheRotationing = false ;
		}
		
		protected static function restoreBlackScreen(event:Event):void
		{
			trace("App is activated");
			clearTimeout(timeOutId0);
			clearTimeout(timeOutId1);
			clearTimeout(timeOutId2);
			
			if(!onTheRotationing)
			{
				defaultOriented = stage.orientation ;
				stageColor = stage.color ;
			}
			onTheRotationing = true;
			
			
			
			trace("deraultOriented : "+defaultOriented+' vs deviceOrientation : '+stage.deviceOrientation+' and orientation : '+stage.orientation);
			switch(stage.orientation) {
                case(StageOrientation.UNKNOWN):
                    //trace("Oriented to : "+StageOrientation.ROTATED_RIGHT);
                    if (DevicePrefrence.isPortrait()) {
                    	toOrientation = (StageOrientation.ROTATED_RIGHT);
					}
					else
					{
                        toOrientation = (StageOrientation.UPSIDE_DOWN);
					}
					break;
				case(StageOrientation.UPSIDE_DOWN):
					//trace("Oriented to : "+StageOrientation.ROTATED_LEFT);
					toOrientation = (StageOrientation.ROTATED_LEFT);
					break;
				case(StageOrientation.ROTATED_LEFT):
					//trace("Oriented to : "+StageOrientation.UPSIDE_DOWN)
					toOrientation = StageOrientation.UPSIDE_DOWN;
					break;
				case(StageOrientation.ROTATED_RIGHT):
					//trace("Oriented to : "+StageOrientation.UPSIDE_DOWN);
					toOrientation = (StageOrientation.UPSIDE_DOWN);
					break;
				case(StageOrientation.DEFAULT):
					trace("Oriented was "+StageOrientation.DEFAULT+" change it to ... ");
                    if (DevicePrefrence.isPortrait()) {
						trace("... "+StageOrientation.ROTATED_LEFT);
                        toOrientation = (StageOrientation.ROTATED_LEFT);
                    }
                    else
                    {
                        trace("... "+StageOrientation.UPSIDE_DOWN);
                        toOrientation = (StageOrientation.UPSIDE_DOWN);
                    }
					break;
				default:
					//trace("Oriented to ... "+StageOrientation.ROTATED_LEFT);
                    toOrientation = (StageOrientation.ROTATED_LEFT);
					break;
			}
			
			trace("to oriention is : "+toOrientation);
			
			root.visible = false ;
			stage.color = 0x000000 ;
			timeOutId0 = setTimeout(startOriention,orientedStarted);
		}
		
			private static function startOriention():void
			{
				trace('stage : '+stage+' oriented to '+toOrientation);
				stage.setOrientation(toOrientation);
				timeOutId1 = setTimeout(backOriention,orientedRestored);
			}
			
			private static function backOriention():void
			{
				trace("now make it back to : "+defaultOriented);
				if(defaultOriented == StageOrientation.DEFAULT && DevicePrefrence.isLandScape())
				{
					trace("This app was landscape so change the oriention to "+StageOrientation.ROTATED_RIGHT)
                    stage.setOrientation(StageOrientation.ROTATED_RIGHT);
				}
				else
				{
					trace("This was a portrait application")
                    stage.setOrientation(defaultOriented);
				}
				timeOutId2 = setTimeout(visibleScreen,visibleActivated);
			}
			
			private static function visibleScreen():void
			{
				root.visible = true ;
				stage.color = stageColor ;
				onTheRotationing = false ;
				trace("Its ok to show now");
			}
	}
}