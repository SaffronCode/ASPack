package
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class GoogleMap
	{

		public static function open(latitiude:*,longitude:*,title:String=''):void
		{
			openMap(latitiude+","+longitude,title);
		}
		/**Pass the latitude and longitude togather as locationString and seperate them by , : 3.4324324,5.4324343*/
		public static function openMap(locationString:String,locationTitle:String=''):void
		{
			if(DevicePrefrence.isIOS())
			{
				navigateToURL(new URLRequest("maps:q="+locationString));
			}
			else
			{
				navigateToURL(new URLRequest("geo://"+locationString+"?z=1&q="+locationString+" ("+locationTitle+")"));
			}
		}


		/**returns in kilometers */
		public  static function CalculationByDistance(startLat:Number,startLon:Number,endLat:Number,endLon:Number):Number
		{
			var Radius:int = 6371;// radius of earth in Km
			var dLat:Number = toRadians(endLat - startLat);
			var dLon:Number = toRadians(endLon - startLon);
			var a:Number = Math.sin(dLat / 2) * Math.sin(dLat / 2)
				+ Math.cos(toRadians(startLat))
				* Math.cos(toRadians(endLat)) * Math.sin(dLon / 2)
				* Math.sin(dLon / 2);
			var c:Number = 2 * Math.asin(Math.sqrt(a));
			return Radius * c;
		}
		private static function toDegrees(radians:Number):Number
		{
			return radians * 180/Math.PI;
		}
		
		private static function toRadians(degrees:Number):Number
		{
			return degrees * Math.PI / 180;
		}
	}
}