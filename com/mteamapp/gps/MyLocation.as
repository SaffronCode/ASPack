package  com.mteamapp.gps
{
	import flash.events.GeolocationEvent;
	import flash.sensors.Geolocation;

	public class MyLocation
	{
		public static var 	GPSLatitude:Number=0,
							GPSLongitude:Number=0
					
		public static var geo:Geolocation;
		
		
		public static function start():void
		{
			if(geo==null)
			{
				geo = new Geolocation();
				geo.addEventListener(GeolocationEvent.UPDATE,iGotGeo);
			}
		}
		
		private static function iGotGeo(e:GeolocationEvent):void
		{
			GPSLatitude = e.latitude ;
			GPSLongitude = e.longitude ;
		}
	}
}