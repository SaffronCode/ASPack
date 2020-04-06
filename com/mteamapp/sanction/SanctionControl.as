package com.mteamapp.sanction
{
	import contents.alert.Alert;

	public class SanctionControl
	{
		public static var forceToBeForeingDebug:Boolean = false ;
		
		private static var _activateForAllOS:Boolean = false ;
		
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
		}
	}
}