// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package multiMediaManager
{
	import flash.desktop.NativeApplication;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	/**this class will manage minimize button , minimizeing and fullsreenenig of the app*/
	public class MultiMediaManager
	{
		/**app stage*/
		private static var myStage:Stage;
		
		public static function setUpFullSvreenApp(yourStage:Stage):void
		{
			myStage = yourStage ;
			
			if(DevicePrefrence.isItPC)
			{
				maxit();
				myStage.nativeWindow.addEventListener(Event.DEACTIVATE,getReady);
			}
			myStage.addEventListener(KeyboardEvent.KEY_DOWN,preventScape);
		}
		
		/**now listen to maximizeing apps*/
		private static function getReady(e:*):void
		{
			myStage.nativeWindow.removeEventListener(Event.ACTIVATE,maxit);
			myStage.nativeWindow.addEventListener(Event.ACTIVATE,maxit);
		}
		
		/**prevent scape to act and minimize the app*/
		private static function preventScape(e:*):void
		{
			switch(e.charCode)
			{
				case 27:
				{
					e.preventDefault();
					break;
				}
			}
		}
		
		/**maximize the window*/
		private static function maxit(e:*=null):void
		{
			if(DevicePrefrence.isItPC)
			{
				myStage.nativeWindow.maximize();
				myStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}
		
///////////////////////////////////////////////////////////////////other function s
		
		
		
		/**close app*/
		public static function closeApp(e:*=null):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		
		/**minimize app*/
		public static function minimizeApp(e:*=null):void{
			if(myStage!=null)
			{
				myStage.nativeWindow.minimize();
			}
		}
	}
}