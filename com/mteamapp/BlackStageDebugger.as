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

	public class BlackStageDebugger
	{
		private static var stage:Stage,
							root:DisplayObject;
							
		private static const orientedStarted:uint=200,
							orientedRestored:uint = 400,
							visibleActivated:uint = 900 ;

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
				trace("BlackScreen debugger on android...");
				stage = myStage;
				root = myRoot ;
				
				defaultOriented = stage.orientation ;
				stageColor = stage.color ;
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,restoreBlackScreen);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,resetScreend);
			}
		}
		
		protected static function resetScreend(event:Event):void
		{
			// TODO Auto-generated method stub
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
			
			// TODO Auto-generated method stub
			
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