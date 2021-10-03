// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	public class MouseDrag
	{
		/**between 0 to allway moves , and1 to move hard*/
		private static var mouseDragDelta:Number=0.5;
		
		private static var myStage:Stage ;
		
		private static var myRect:Vector.<Rectangle>;
		
		private static var nextFunc:Vector.<Function>,
							prevFunc:Vector.<Function>,
							funcId:Vector.<uint> ;
		
		private static var 	mouseFirstX:Number,
							mouseFirstY:Number,
							dragTime:Number;
							
		private static var currentFuncId:uint = 1 ;
		
		public static function setUp(getStage:Stage,sens:Number=0.7):void
		{
			if(myStage == null)
			{
				myStage = getStage ;
				reset();
				
				myStage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDragStarted);
				myStage.addEventListener(MouseEvent.MOUSE_UP,mouseDragStopd);
			}
			
			mouseDragDelta = sens ;
		}
		
		public static function reset():void
		{
			//SaffronLogger.log("▬ Mouse Drag resets");
			nextFunc = new Vector.<Function>();
			prevFunc = new Vector.<Function>();
			myRect = new Vector.<Rectangle>();
			funcId = new Vector.<uint>();
		}
		
		/**This function will return the nextPrevFunction id to make you able to remove it*/
		public static function addFunctions(next_f:Function,preve_f:Function,rect:Rectangle):uint
		{
			//SaffronLogger.log("▬ Listen to mouse drag");
			var prevIndex:int = prevFunc.indexOf(preve_f);
			var nextIndex:int = nextFunc.indexOf(next_f);
			
			if(prevIndex!=-1 && nextIndex!=-1)
			{
				prevFunc.splice(prevIndex,1);
				nextFunc.splice(prevIndex,1);
				myRect.splice(prevIndex,1);
			}
			prevFunc.push(preve_f);
			nextFunc.push(next_f);
			myRect.push(rect);
			funcId.push(currentFuncId);
			currentFuncId++;
			
			SaffronLogger.log("Add mouse drag : "+(currentFuncId-1));
			
			return currentFuncId-1 ;
		}
		
		/**Remove function listener*/
		public static function removeFunction(addFunctionId:uint):void
		{
			var funcIndex:int = funcId.indexOf(addFunctionId);
			if(funcIndex!=-1)
			{
				prevFunc.splice(funcIndex,1);
				nextFunc.splice(funcIndex,1);
				myRect.splice(funcIndex,1);
				funcId.splice(funcIndex,1);
				SaffronLogger.log("**** mouse drag removed *** : "+funcIndex);
			}
			else
			{
				SaffronLogger.log("Muse cannot remove : "+addFunctionId);
			}
		}
		
		
		
		
		private static function mouseDragStarted(e:MouseEvent):void
		{
			mouseFirstX = myStage.mouseX;
			mouseFirstY = myStage.mouseY;
			dragTime = getTimer();
			//SaffronLogger.log("▬ Listen to mouse Dragg");
		}
		
		
		/**mouse dtagged on image , for touch devices*/
		private static function mouseDragStopd(e:MouseEvent):void
		{
			var dx:Number = myStage.mouseX - mouseFirstX ;
			var dy:Number = myStage.mouseY - mouseFirstY ;
			dragTime = getTimer()-dragTime;
			if(Math.abs(dx/dragTime)<mouseDragDelta || Math.abs(dy)>Math.abs(dx))
			{
				//SaffronLogger.log("▬ Mouse is not dragging")
				return 
			}
			for(var i:int= 0 ; i<myRect.length ; i++)
			{
				//SaffronLogger.log("▬ Checking Rectangles");
				if(myRect[i]==null || myRect[i].contains(myStage.mouseX,myStage.mouseY))
				{
					//SaffronLogger.log("▬ This is it");
					if((dx/dragTime)>mouseDragDelta)
					{
						//SaffronLogger.log("▬ preve");
						prevFunc[i]();
					}
					else if((dx/dragTime)<mouseDragDelta*-1)
					{
						//SaffronLogger.log("▬ next");
						nextFunc[i]();
					}
				}
			}
		}
	}
}