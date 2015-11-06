package videoShow
{
	import flash.events.Event;
	
	public class VideoEvents extends Event
	{
		public static const VIDEO_LOADED:String = "VIDEO_LOADED";
		public static const VIDEO_NOT_FOUND:String = "VIDEO_LOADED";
		public static const VIDEO_STATUS_CHANGED:String = "VIDEO_LOADED";
		
		public var statusPlay:Boolean ;
		public function VideoEvents(type:String,playStatus:Boolean=false)
		{
			statusPlay = playStatus ;
			super(type,true);
		}
	}
}