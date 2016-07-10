package
{
	import flash.events.Event;
	
	public class ScrollMTEvent extends Event
	{
		/**This event dispatches to parent. the container scrollers must listen to this to stop their scroll controlling*/
		internal static const TRY_TO_SCROLL:String = "TRY_TO_SCROLL" ;
		
		/**This event will dispatch on all scrolled items childs to tell them that they are scrolling*/
		public static const YOU_ARE_SCROLLING_FROM_YOUR_PARENT:String = "YOU_ARE_SCROLLING_FROM_YOUR_PARENT";
		
		public var freeScrollOnTarget_TD:Boolean ;
		public var freeScrollOnTarget_LR:Boolean ;
		
		public function ScrollMTEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,FreeScrollOnTarget_TD:Boolean=false,FreeScrollOnTarget_LR:Boolean=false)
		{
			super(type, bubbles, cancelable);
			freeScrollOnTarget_LR = FreeScrollOnTarget_LR ;
			freeScrollOnTarget_TD = FreeScrollOnTarget_TD ;
		}
	}
}