package
{
	import flash.events.Event;
	
	public class ScrollMTEvent extends Event
	{
		/**This event dispatches to parent. the container scrollers must listen to this to stop their scroll controlling*/
		internal static const TRY_TO_SCROLL:String = "TRY_TO_SCROLL" ;
		
		/**This event will dispatch on all scrolled items childs to tell them that they are scrolling*/
		public static const YOU_ARE_SCROLLING_FROM_YOUR_PARENT:String = "YOU_ARE_SCROLLING_FROM_YOUR_PARENT";
		public static const LOCK_SCROLL_TILL_MOUSE_UP:String = "LOCK_SCROLL_TILL_MOUSE_UP";
		
		/**It will force the scroller to scroll up or down from the command from it's childs*/
		public static const SCROLL_THE_SCROLLER:String = "SCROLL_THE_SCROLLER" ;
		
		public var freeScrollOnTarget_TD:Boolean ;
		public var freeScrollOnTarget_LR:Boolean ;
		
		public var 	dx:Number,
					dy:Number;
		
		public function ScrollMTEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,FreeScrollOnTarget_TD:Boolean=false,FreeScrollOnTarget_LR:Boolean=false,deltaScrollX:Number=0,deltaScrollY:Number=0)
		{
			super(type, bubbles, cancelable);
			freeScrollOnTarget_LR = FreeScrollOnTarget_LR ;
			freeScrollOnTarget_TD = FreeScrollOnTarget_TD ;
			dx = deltaScrollX ;
			dy = deltaScrollY ;
		}
	}
}