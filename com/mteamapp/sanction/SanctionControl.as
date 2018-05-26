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
			if(((_activateForAllOS || DevicePrefrence.isIOS()) && (new Date().timezoneOffset != -270 && new Date().timezoneOffset != -210)) || forceToBeForeingDebug)
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