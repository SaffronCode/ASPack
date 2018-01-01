package com.mteamapp.sanction
{
	import contents.alert.Alert;

	public class SanctionControl
	{
		public static var forceToBeForeingDebug:Boolean = false ;
		
		public static function isForeign():Boolean
		{
			//Alert.show("Time zone is : "+new Date().timezoneOffset);
			if((DevicePrefrence.isIOS() && (new Date().timezoneOffset != -270 && new Date().timezoneOffset != -210)) || forceToBeForeingDebug)
			{
				return true ;
			}
			else
			{
				return false ;
			}
		}
	}
}