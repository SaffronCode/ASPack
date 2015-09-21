// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package myMultiTouch
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	public class MTouchManager
	{
		private static var 	targs:Vector.<MovieClip>,
							onTouches:Vector.<Function>,
							onDrages:Vector.<Function>,
							onDropes:Vector.<Function>,
							touchID:Vector.<int>;
							
		private static var myStage:Stage;
		
		
		/**set up the MTouchManager class*/
		public static function setUp(MyStage:Stage)
		{
			myStage = MyStage;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			if(targs == null)
			{
				targs = new Vector.<MovieClip>();
				onTouches = new Vector.<Function>();
				onDrages = new Vector.<Function>();
				onDropes = new Vector.<Function>();
				touchID = new Vector.<int>();
				
				if(Multitouch.supportsTouchEvents)
				{
					myStage.addEventListener(TouchEvent.TOUCH_MOVE,TouchMoved);
					myStage.addEventListener(TouchEvent.TOUCH_END,TouchEnds);
				}
				else
				{
					myStage.addEventListener(MouseEvent.MOUSE_MOVE,TouchMoved);
					myStage.addEventListener(MouseEvent.MOUSE_UP,TouchEnds);
				}
			}
		}
							
		/**this class will returns XY touch points value to functions*/					
		public static function getObject(targ:DisplayObject,onTouched:Function,onDraged:Function,onDroped:Function)
		{
			if(myStage==null)
			{
				setUp(targ.stage);
			}
			
			
			targs.push(targ);
			onTouches.push(onTouched);
			onDrages.push(onDraged);
			onDropes.push(onDroped);
			touchID.push(-1);
			
			if(Multitouch.supportsTouchEvents)
			{
				//trace('touch looker');
				targ.addEventListener(TouchEvent.TOUCH_BEGIN,Touched);
			}
			else
			{
				targ.addEventListener(MouseEvent.MOUSE_DOWN,Touched);
			}
			targ.addEventListener(Event.REMOVED_FROM_STAGE,unLoadME);
		}
		
		/**remove this target from list*/
		private static function unLoadME(e:Event)
		{
			var targ:DisplayObject = DisplayObject(e.currentTarget) ;
			
			targ.addEventListener(TouchEvent.TOUCH_BEGIN,Touched);
			targ.addEventListener(Event.REMOVED_FROM_STAGE,unLoadME);
			var I:int = getI(targ);
			
			if(I>0)
			{
				targs.splice(I,1);
				onTouches.splice(I,1);
				onDrages.splice(I,1);
				onDropes.splice(I,1);
				touchID.splice(I,1);
			}
		}
		
		/**touch is moving on stage*/
		private static function TouchMoved(e:*)
		{
			//trace('draging');
			var i;
			if(e is TouchEvent)
			{
				for(i=0;i<targs.length;i++)
				{
					if(touchID[i]!=-1 && touchID[i] == e.touchPointID)
					{
						if(onDrages[i]!=null)
						{
							onDrages[i](e.stageX,e.stageY);
						}
					}
				}
			}
			else
			{
				for(i=0;i<targs.length;i++)
				{
					if(touchID[i]!=-1)
					{
						if(onDrages[i]!=null)
						{
							onDrages[i](e.stageX,e.stageY);
						}
					}
				}
			}
		}
		
		/**touch is ended from stage*/
		private static function TouchEnds(e:*)
		{
			//trace('touch ends');
			var i ;
			if(e is TouchEvent)
			{
				for(i=0;i<targs.length;i++)
				{
					if(touchID[i] == e.touchPointID)
					{
						touchID[i] = -1;
						if(onDropes[i]!=null)
						{
							onDropes[i](e.stageX,e.stageY);
						}
					}
				}
			}
			else
			{
				for(i=0;i<targs.length;i++)
				{
					if(touchID[i]!=-1)
					{
						touchID[i] = -1;
						if(onDropes[i]!=null)
						{
							onDropes[i](e.stageX,e.stageY);
						}
					}
				}
			}
		}
		
		/**touch is started on the target*/
		private static function Touched(e:*)
		{
			var targ:DisplayObject = DisplayObject(e.currentTarget) ;
			
			var I = getI(targ);
			
			if(I!=-1)
			{
				if(e is TouchEvent)
				{
					if(onTouches[I]!=null)
					{
						onTouches[I](e.stageX,e.stageY);
					}
					touchID[I] = (e.touchPointID);
				}
				else
				{
					if(onTouches[I]!=null)
					{
						onTouches[I](e.stageX,e.stageY);
					}
					touchID[I] = 0 ;
				}
			}
			
		}
		
		/**returns index of touched object from list*/
		private static function getI(targ:DisplayObject):int
		{
			return targs.indexOf(targ);
		}
	}
}