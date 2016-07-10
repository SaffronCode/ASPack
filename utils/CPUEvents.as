package utils
{
	import flash.events.Event;
	
	public class CPUEvents extends Event
	{
		public static const PERVECT_CPU:String = "PERVECT_CPU" ;
		public static const SLOW_CPU:String = "SLOW_CPU" ;
		public static const DOWN_CPU:String = "DOWN_CPU" ;
		
		public function CPUEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}