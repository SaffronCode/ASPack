package com.mteamapp.sanction
//com.mteamapp.sanction.SanctionControl
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.MovieClip;

	public class SanctionControl extends MovieClip
	{
		public static var forceToBeForeingDebug:Boolean = false ;
		
		private static var _activateForAllOS:Boolean = false ;

		private static var dispatcher:EventDispatcher = new EventDispatcher();

		public function SanctionControl()
		{
			super();
			stop();
			updateVisibilatyStatus(null);
			dispatcher.addEventListener(Event.CHANGE,updateVisibilatyStatus)
		}

		private function updateVisibilatyStatus(e:Event):void
		{
			if(this.totalFrames==2)
			{
				if(isForeign())
				{
					this.gotoAndStop(2);
				}
				else
				{
					this.gotoAndStop(1);
				}
			}
			else
			{
				this.visible = !isForeign();
			}
		}






		
		public static function isForeign():Boolean
		{
			//Alert.show("Time zone is : "+new Date().timezoneOffset);
			var currentDate:Date = new Date();
			var isSummerTime:Boolean = ( currentDate.month==2 && currentDate.date>20 ) || ( currentDate.month>2 && currentDate.month<8 ) || ( currentDate.month==8 && currentDate.date<21 ) ;
			trace("isSummerTime : "+isSummerTime+" - "+currentDate.timezoneOffset+" >> "+((currentDate.timezoneOffset != -210 && isSummerTime)));
			if(
				(
					(
						_activateForAllOS 
						|| 
						DevicePrefrence.isIOS()
					) 
					&& 
					(
						(
							isSummerTime
							&&
							currentDate.timezoneOffset != -270 
						)
						||
						(
							!isSummerTime
							&&
							currentDate.timezoneOffset != -210 
						)
					)
				) 
				|| 
				forceToBeForeingDebug
			)
			{
				return true ;
			}
			else
			{
				return false ;
			}
		}
		
		public static function activateSanctionForAllOSs(status:Boolean=true):void
		{
			_activateForAllOS = status ;
			dispatcher.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}