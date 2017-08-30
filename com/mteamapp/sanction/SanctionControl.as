package com.mteamapp.sanction
{
	public class SanctionControl
	{
		public static var forceToBeForeingDebug:Boolean = false ;
		
		public static function isForeign():Boolean
		{
			if((DevicePrefrence.isIOS() && new Date().timezoneOffset != -270) || forceToBeForeingDebug)
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