package utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	
	[Event(name="PERVECT_CPU", type="utils.CPUEvents")]
	[Event(name="SLOW_CPU", type="utils.CPUEvents")]
	[Event(name="DOWN_CPU", type="utils.CPUEvents")]
	public class CPUController extends EventDispatcher
	{
		private static var enterFrameHandler:Sprite ;
		
		public static var eventDispatcher:CPUController ; 
		
		private static var bestTimePerFrame:uint ;
		
		private static var lastTime:uint ;
		
		/**1: perfect, 2: slow, 3:awful*/
		private static var lastStatus:uint ;
		
		private static var cpuEvent_perfect:CPUEvents,cpuEvent_slow:CPUEvents,cpuEvent_down:CPUEvents ;
		
		private static var _isSatUp:Boolean = false ;
		
		public static function get isSatUp():Boolean
		{
			return _isSatUp ;
		}
		
		public function CPUController():void
		{
			super();
		}
		
		public static function setUp():void
		{
			if(!_isSatUp)
			{
				_isSatUp = true ;
				enterFrameHandler = new Sprite();
				enterFrameHandler.addEventListener(Event.ENTER_FRAME,controlFrameTime);
				
				cpuEvent_perfect = new CPUEvents(CPUEvents.PERVECT_CPU);
				cpuEvent_slow = new CPUEvents(CPUEvents.SLOW_CPU);
				cpuEvent_down = new CPUEvents(CPUEvents.DOWN_CPU);
				
				eventDispatcher = new CPUController();
				
				lastTime = getTimer();
				bestTimePerFrame = 1000/30 ;
			}
		}
		
		protected static function controlFrameTime(event:Event):void
		{
			var newTime:uint = getTimer();
			var delta:uint = newTime-lastTime ; 
			if(delta<=bestTimePerFrame+1)
			{
				lastStatus = 1 ;
				eventDispatcher.dispatchEvent(cpuEvent_perfect);
			}
			else if(delta<=bestTimePerFrame+bestTimePerFrame/2)
			{
				lastStatus = 2 ;
				eventDispatcher.dispatchEvent(cpuEvent_slow);
			}
			else
			{
				lastStatus = 3 ;
				eventDispatcher.dispatchEvent(cpuEvent_down);
			}
			lastTime = newTime ;
		}
		
		
	////////////////////////////////////////////
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			return ;
			switch(lastStatus)
			{
				case 1:
				{
					eventDispatcher.dispatchEvent(cpuEvent_perfect);
					break;
				}
				case 2:
				{
					eventDispatcher.dispatchEvent(cpuEvent_slow);
					break;
				}
				case 3:
				{
					eventDispatcher.dispatchEvent(cpuEvent_down);
					break;
				}
				default:
				{
					return ;
				}
			}
		}
	}
}