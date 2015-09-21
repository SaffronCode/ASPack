package videoShow
{
	import flash.events.Event;
	
	
	public class videoEvents extends Event
	{
		public static const VIDEO_LOADED:String = "videoFileIsLoaded";
		public static const VIDEO_NOT_FOUND:String = "videoNotFound";
		public static const VIDEO_STATUS_CHANGED:String = "videoStatusChanged";
		
		public var statusPlay:Boolean ;
		public function videoEvents(type:String,playStatus:Boolean=false)
		{
			statusPlay = playStatus ;
			super(type,true);
		}
	}
}