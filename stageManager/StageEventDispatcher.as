package stageManager
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="STAGE_RESIZED", type="stageManager.StageManagerEvent")]
	[Event(name="STAGE_RESIZING", type="stageManager.StageManagerEvent")]
	public class StageEventDispatcher extends EventDispatcher
	{
		
		public function StageEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}