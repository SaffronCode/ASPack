// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package
{
	public class TimeToString
	{
		/**return the time from seconds to string 10:54*/
		public static function timeInString(seconds:Number):String
		{
			seconds = Math.ceil(seconds);
			var min:Number = Math.floor(seconds/60);
			seconds = seconds%60;
			var hour:Number = Math.floor(min/60);
			min = min%60;
			if(hour>0)
			{
				return numToString(hour)+':'+numToString(min)+':'+numToString(seconds);
			}
			else
			{
				return numToString(min)+':'+numToString(seconds);
			}
		}
		
		/**12:105*/
		public static function miliSecontToString(milisecond:Number):String
		{
			var sec:uint = Math.floor(milisecond/1000)
			var mil:uint = milisecond-sec*1000;
			
			return sec+':'+mil ;
		}
		
		/**1 > 001*/
		public static function numToString(num:*,numberLenght:uint=2)
		{
			num = String(num);
			while(num.length<numberLenght)
			{
				num = '0'+num;
			}
			return num;
		}
	}
}