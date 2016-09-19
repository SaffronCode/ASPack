package
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class GoogleMap
	{
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
	}
}