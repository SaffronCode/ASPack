package
{
	import flash.events.Event;
	import flash.utils.getDefinitionByName;

	public class VideoManaerAsist
	{
		/**	trace("selected");
			trace(e.data.id); // media id
			trace(e.data.url); // file url for air
			trace(e.data.rawPath); // raw path
			trace(e.data.resultCode); // android result code
			trace(e.data.title); // media title*/
		public static var 	id:Number,// media id
							url:String,// file url for air
							rawPath:String,// raw path
							resultCode:int,// android result code
							title:String;// media title
							
		private static var onDone:Function;
		
		private static var videoManager:*,
							videoManagerClass:Class,
							mediaRollClass:Class;
		
		/**import com.flashvisions.mobile.android.extensions.video.VideoManager;
		import com.flashvisions.mobile.android.extensions.video.event.MediaRollEvent;*/
		public static function isSupports():Boolean
		{
			setUp();
			if(videoManagerClass==null)
			{
				trace("The video manager native is not added");
				return false ;
			}
			if(!DevicePrefrence.isAndroid())
			{
				trace("VideoManager is not supporting on this device");
				return false ;
			}
			return true ;
		}
		
		/**Set the VideoManager class*/
		private static function setUp():void
		{
			if(videoManager==null)
			{
				try
				{
					videoManagerClass = getDefinitionByName('com.flashvisions.mobile.android.extensions.video.VideoManager') as Class ;
					mediaRollClass = getDefinitionByName('com.flashvisions.mobile.android.extensions.video.event.MediaRollEvent') as Class ;
				}
				catch(e)
				{
					trace(e);
				}
				if(videoManagerClass!=null)
				{
					videoManager = new videoManagerClass();
					videoManager.addEventListener((mediaRollClass as Object).SELECT,onVideoSelected);
				}
			}
		}
		
			/**Some video loaded to the gallery*/
			protected static function onVideoSelected(e:*):void
			{
				trace("selected");
				id = e.data.id; // media id
				url = e.data.url; // file url for air
				rawPath = e.data.rawPath; // raw path
				resultCode = e.data.resultCode; // android result code
				title = e.data.title; 
				
				onDone();
			}
		
		/**Required to load a video from the videoGallery and call OnDone function*/
		public static function loadVideoFromGallery(OnDone:Function):void
		{
			onDone = OnDone ;
			if(isSupports())
			{
				setUp();
				videoManager.browseForVideo();
			}
			else
			{
				trace("Video gallery not supports");
			}
		}
	}
}