package stageManager
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class StageManagerEvent extends Event
	{
		public static const STAGE_RESIZED:String = "STAGE_RESIZED";
		public static const STAGE_RESIZING:String = "STAGE_RESIZING";
		
		public var stageRectangle:Rectangle ;
		
		public function StageManagerEvent(type:String,stageRect:Rectangle)
		{
			super(type);
			stageRectangle = stageRect ;
		}
	}
}