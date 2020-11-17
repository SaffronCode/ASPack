// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************


package
{
	import flash.utils.getTimer;

	/**You can keep and updated date on this class. First you need to get the server date and call the update function on this class and after that, the date functin will returns the last updated time based on the server date*/
	public class LocalDate
	{
		private static var lastDate:Date,
							zeroTime:uint;
							
		/**Returns true if the localDate is updated*/
		public static function isUpdated():Boolean
		{
			return lastDate!=null; 
		}
							
		/**Update the last date*/
		public static function update(newDate:Date):void
		{
			if(lastDate==null || date().time>newDate.time )
			{
				lastDate = new Date(newDate.time);
				zeroTime = getTimer();
			}
		}
		
		/**Returns the updated date*/
		public static function date():Date
		{
			if(lastDate==null)
			{
				trace("System date returns");
				return new Date();
			}
			var currentDate:Date = new Date(lastDate.time);
			currentDate.time += getTimer()-zeroTime;
			return currentDate;
		}
	}
}