// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package myMultiTouch
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	/**my new zoomer class<br>
	 * you have to set 0,0 point of your zoomable object to top left*/
	public class zoomer
	{
		public static var 	EVENT_ZOOM_STARTS:String = 'zoomStarted',
							EVENT_ZOOM_STOPED:String = 'zoomingStoped';
							
		
		private static var 	zoomAbles:Vector.<MovieClip>,
							onZoomedFuncs:Vector.<Function>,
							onZoomEndedFuncs:Vector.<Function>,
		
							currentScale:Vector.<Number>,
							targetedScale:Vector.<Number>,
							
							//Y0s:Vector.<Number>,
							//X0s:Vector.<Number>,
							
							stageRectangle:Vector.<Rectangle>,
							
							firstPoint:Vector.<Point>,
							
							currentX:Vector.<Number>,
							currentY:Vector.<Number>,
							
							targetX:Vector.<Number>,
							targetY:Vector.<Number>,
							
							lock:Vector.<Boolean>,
							
							XmoveActive:Boolean = true,
							YmoveActive:Boolean = true,
							
							scaleActivate:Boolean = true;
							
		/**main class variables*/
		private static var	myStage:Stage,
							
							animV:Number=2,
							lastCenter:Point = new Point(-1,-1),
							lastWidth:Number=Infinity,
							lastTouches:int;
		/**zooming variables*/			
		public static var	maxZoom:Number=3,
							minZoom:Number=1;
							
		/**multy touch variables*/
		private static var touchPoints:Vector.<TouchData>;
		
		/**reset the position and scale of this object*/
		public static function resetZoom(target:MovieClip)
		{
			if(zoomAbles==null)
			{
				return;
			}
				
			var index:int = zoomAbles.indexOf(target);
			
			if(index == -1)
			{
				return ;
			}
			
			//zoomAbles.push(target) ;
			
			
			currentX[index] = 0;
			currentY[index] = 0;
			
			targetX[index] = 0;
			targetY[index] = 0;
			
			lock[index] = false;
			
			currentScale[index] = zoomAbles[index].scaleY = zoomAbles[index].scaleX = targetedScale[index] = 1 ;
		}
		
		/**return s if touch is not support*/
		public static function isSupport():Boolean
		{
			return Multitouch.supportsTouchEvents;
		}
		
		/**remove all touch points on app is deactivated*/
		private static function removeAllTouches(e)
		{
			touchPoints = new Vector.<TouchData>();
		}
		
		
		/**add zoom effect to thid object*/
		public static function zoomAct(target:MovieClip,monitorRectangle:Rectangle,onZoomed:Function=null,onZoomEnds:Function=null)
		{
			
			if(onZoomed == null)
			{
				onZoomed = new Function();
			}
			if(onZoomEnds == null)
			{
				onZoomEnds = new Function();
			}
			trace('Beta version of zoomer is activated');
			
			if(!Multitouch.supportsGestureEvents)
			{
				trace('gesture is not supporting');
				return ;
			}
			
			if(zoomAbles==null)
			{
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,removeAllTouches);
				
				zoomAbles = new Vector.<MovieClip>();
				onZoomedFuncs = new Vector.<Function>();
				onZoomEndedFuncs = new Vector.<Function>();
				currentScale = new Vector.<Number>();
				targetedScale = new Vector.<Number>();
				stageRectangle = new Vector.<Rectangle>();
				
				currentX = new Vector.<Number>();
				currentY = new Vector.<Number>();
				
				firstPoint = new Vector.<Point>();
				
				targetX = new Vector.<Number>();
				targetY = new Vector.<Number>();
				
				lock = new Vector.<Boolean>();
				
				touchPoints = new Vector.<TouchData>();
				
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT ;
				
				target.stage.addEventListener(TouchEvent.TOUCH_BEGIN,begined);
				
				target.stage.addEventListener(TouchEvent.TOUCH_END,ended);
				//target.stage.addEventListener(TouchEvent.TOUCH_ROLL_OUT,ended);
				
				target.stage.addEventListener(TouchEvent.TOUCH_MOVE,moved);
				
				target.stage.addEventListener(Event.ENTER_FRAME,anim);
				
				myStage = target.stage;
			}
			var index:int = zoomAbles.indexOf(target);
			
			if(index==-1)
			{
				index = zoomAbles.length;
			}
			zoomAbles[index] = target ;
			onZoomedFuncs[index] = onZoomed ;
			onZoomEndedFuncs[index] = onZoomEnds ;
			currentScale[index] = target.scaleX;
			targetedScale[index] = target.scaleX;
			
			lock[index] = false;
			
			stageRectangle[index] = monitorRectangle;
			
			firstPoint[index] = new Point(target.x,target.y);
			
			currentX[index] = 0;
			currentY[index] = 0;
			
			targetX[index] = 0;
			targetY[index] = 0;
			
			
			target.removeEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
			target.addEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
		}
		
		
		/**managing the app*/
		public static function anim(e:Event)
		{
			/**delta x y width*/
			var dx:Number=0,dy:Number=0,ds:Number=1;
			var i:int ; 
			var center:Point
			
			var hittedIndexes:Array = new Array() ;
			
			for( i=0 ; i<touchPoints.length ;i++)
			{
				touchPoints[i].updatePermition = true ;
			}
			
			//trace("lastTouches : "+lastTouches+" vs "+touchPoints.length);
			if(touchPoints.length>=2)
			{
				var p1:TouchData = touchPoints[0];
				var p2:TouchData = touchPoints[1];
				
				var CW:Point = new Point(p1.x-p2.x,p1.y-p2.y);
				if(lastWidth!=Infinity && lastTouches==touchPoints.length)
				{
					ds = (CW.length/lastWidth);
				}
				
				lastWidth = CW.length ;
				
				center = new Point((p2.x+p1.x)/2,(p2.y+p1.y)/2);
				if(lastCenter.x !=-1  && lastTouches==touchPoints.length)
				{
					dx = center.x-lastCenter.x ;
					dy = center.y-lastCenter.y ;
				}
				
				lastCenter = center ;
			}
			else if(touchPoints.length==1)
			{
				center = new Point(touchPoints[0].x,touchPoints[0].y);
				if(lastCenter.x !=-1 && lastTouches==touchPoints.length)
				{
					dx = touchPoints[0].x-lastCenter.x ;
					dy = touchPoints[0].y-lastCenter.y ;
				}
				
				lastCenter = center ;
			}
			else
			{
				lastWidth = Infinity ;
				lastCenter.x = -1 ;
			}
			
			lastTouches = touchPoints.length ;
			
			//make effects on each zoomable objects
			for(i=0;i<zoomAbles.length;i++)
			{
				if(lock[i] || !zoomAbles[i].hitTestPoint(lastCenter.x,lastCenter.y))
				{
					//do not action for outsided Objects
					continue ;
				}
				
				onZoomedFuncs[i]();
				
				if(XmoveActive)
				{
					//trace('x changed ');
					targetX[i] += dx ;
					trace('moved in x : '+dx);
				}
				
				if(YmoveActive)
				{
					targetY[i] += dy ;
					trace('moved');
				}
				
				if(YmoveActive && XmoveActive || scaleActivate)
				{
					targetedScale[i] = Math.max(minZoom,Math.min(maxZoom,targetedScale[i]*ds)) ;
					trace('scaled');
				}
				//trace('ds : '+ds);
				
				if(ds!=1 && targetedScale[i]!=currentScale[i])
				{
					
					var changedDs:Number = targetedScale[i]/currentScale[i] ;
					
					var pos:Point = DisplayObject(zoomAbles[i].parent).localToGlobal(new Point(targetX[i]+firstPoint[i].x,targetY[i]+firstPoint[i].y)) ;
					
					var DX:Number = (changedDs)*zoomAbles[i].width;
					var DY:Number = (changedDs)*zoomAbles[i].height;
					
					
					
					var cdx:Number = (pos.x-lastCenter.x)*(changedDs-1);//((pos.x-lastCenter.x)/zoomAbles[i].width)*DX ;
					var cdy:Number = (pos.y-lastCenter.y)*(changedDs-1);//((pos.y-lastCenter.y)/zoomAbles[i].height)*DY ;
					currentX[i] += cdx ;
					currentY[i] += cdy ;
					//trace('cdx : '+cdx);
					targetX[i] += cdx ;
					targetY[i] += cdy ;
					//trace('ds is '+ds);
				}
				
				var testRectangle:Rectangle = stageRectangle[i].clone() ;
				testRectangle.x -= firstPoint[i].x;
				testRectangle.y -= firstPoint[i].y;
				
				
				currentX[i] = manageDimentionsX(currentX[i],testRectangle,targetedScale[i]);
				targetX[i] = manageDimentionsX(targetX[i],testRectangle,targetedScale[i]);
				
				currentY[i] = manageDimentionsY(currentY[i],testRectangle,targetedScale[i]);
				targetY[i] = manageDimentionsY(targetY[i],testRectangle,targetedScale[i]);
				
				
				currentX[i] += (targetX[i]-currentX[i])/animV;
				currentY[i] += (targetY[i]-currentY[i])/animV;
				
				//targetedWidth[i] = currentWidth[i];
				
				if(Math.abs(Math.round(currentX[i])-zoomAbles[i].x)>1 || Math.abs(Math.round(currentY[i])-zoomAbles[i].y)>1)
				{
					zoomEvent(myStage);
				}
				
				
				zoomAbles[i].x = firstPoint[i].x + Math.round(currentX[i]) ;
				zoomAbles[i].y = firstPoint[i].y + Math.round(currentY[i]) ;
				
				
					
				//zoomAbles[i].width += ds;
				//zoomAbles[i].scaleY = zoomAbles[i].scaleX = Math.min(minZoom,Math.max(maxZoom,zoomAbles[i].scaleX)) ;
				//sacleing mode↓
				currentScale[i] = zoomAbles[i].scaleY = zoomAbles[i].scaleX = targetedScale[i] ;
			}
		}
		
		/**manage dimentions X*/
		private static function manageDimentionsX(num1:Number,rectangle:Rectangle,Xscale:Number):Number
		{
			if(num1>rectangle.x)
			{
				num1 = rectangle.x ;
			}
			
			if(num1<rectangle.x-(rectangle.width*Xscale)+rectangle.width)
			{
				num1 = rectangle.x-(rectangle.width*Xscale)+rectangle.width;
			}
			return num1 ;
		}
		
		/**manage dimentions Y*/
		private static function manageDimentionsY(num1:Number,rectangle:Rectangle,Yscale:Number):Number
		{
			if(num1>rectangle.y)
			{
				num1 = rectangle.y ;
			}
			
			if(num1<rectangle.y-(rectangle.height*Yscale)+rectangle.height)
			{
				num1 = rectangle.y-(rectangle.height*Yscale)+rectangle.height;
			}
			return num1 ;
		}
		
		
		/**touch begined*/
		private static function begined(e:TouchEvent)
		{
			/*debug purpose
			var targ:points = new points();
			
			targ.x = e.stageX ;
			targ.y = e.stageY ;*/
			
			var touch:TouchData = new TouchData(e.touchPointID,e.stageX,e.stageY/*,targ*/);
			
			touchPoints.push(touch);
			
			if(touchPoints.length>1)
			{
				zoomEvent(myStage);
			}
			
			/*myStage.addChild(targ);*/
		}
		
		/**touch ended*/
		private static function ended(e:TouchEvent)
		{
			//these lines will reset my all settings↓↓
				//deactiveXMoving(true);
				//deactiveYMoving(true);
			
			var index:int = findeTouch(e.touchPointID);
			if(index!=-1)
			{
				if(touchPoints[index].debugTarget!=null)
				{
					myStage.removeChild(touchPoints[index].debugTarget);
				}
				touchPoints.splice(index,1);
			}
			
			if(touchPoints.length<2)
			{
				zoomEndedEvent(myStage);
			}
		}
		
		/**touchePointMoved*/
		private static function moved(e:TouchEvent)
		{
			var index:int = findeTouch(e.touchPointID);
			if(index!=-1)
			{
				touchPoints[index].x = e.stageX ;
				touchPoints[index].y = e.stageY ;
				
				if(touchPoints[index].debugTarget!=null && touchPoints[index].updatePermition)
				{
					touchPoints[index].debugTarget.x = e.stageX;
					touchPoints[index].debugTarget.y = e.stageY;
				}
				
				touchPoints[index].updatePermition = false;
			}
		}
		
		/**target unloaded*/
		public static function unLoaded(e:*)
		{
			var index:int ;
			if(e is Event)
			{
				index = finedIndex(MovieClip(e.currentTarget));
			}
			else if(e is MovieClip)
			{
				index = finedIndex(MovieClip(e));
			}
			else
			{
				index = -1 ;
			}
			if(index==-1)
			{
				return ;
			}
			
			
			
			
			
			touchPoints = new Vector.<TouchData>();
			
			zoomAbles.splice(index,1);
			onZoomedFuncs.splice(index,1);
			onZoomEndedFuncs.splice(index,1);
			
			lock.splice(index,1);
			
			currentScale.splice(index,1);
			targetedScale.splice(index,1);
			
			stageRectangle.splice(index,1);
			firstPoint.splice(index,1);
			
			currentX.splice(index,1);
			currentY.splice(index,1);
			
			targetX.splice(index,1);
			targetY.splice(index,1);
		}
		
		/**index of target*/
		private static function finedIndex(target:MovieClip):int
		{
			if(zoomAbles==null)
			{
				return -1;
			}
			return zoomAbles.indexOf(target);
		}
		
		/**lock the zoom action of the specified target*/
		private static function lockTargetChange(target:MovieClip,isLock:Boolean )
		{
			var ind:int = finedIndex(target);
			if(ind!=-1)
			{	
				lock[ind] = isLock ;
			}
		}
		
		/**lock the zoomer activiti on specified target<br>
		 * unLock it with unLockTarget() function*/
		public static function LockTarget(target:MovieClip)
		{
			lockTargetChange(target,true);
		}
		
		/**ulock the zoom action of the specified target that had locked with lockTarget() befor*/
		public static function unLockTarget(target:MovieClip)
		{
			lockTargetChange(target,false);
		}
		
		
		private static function findeTouch(touchID:int):int
		{
			for(var i=0 ; i<touchPoints.length;i++)
			{
				if(touchPoints[i].ID == touchID)
				{
					return i ;
				}
			}
			return -1 ;
		}
		
		/**deactive horizontale moveings<br>
		 * false for deactivation<br>
		 * true for activation*/
		public static function deactiveXMoving(activation:Boolean= false,alowScale:Boolean = false)
		{
			scaleActivate = alowScale ;
			XmoveActive = activation ;
			//trace("XmoveActive is "+XmoveActive);
		}
		
		/**deactive vertival moveings*/
		public static function deactiveYMoving(activation:Boolean= false,alowScale:Boolean = false)
		{
			scaleActivate = alowScale ;
			YmoveActive = activation ;
		}
		
		
		/**zoomStarted*/
		private static function zoomEvent(target:Stage)
		{
			target.dispatchEvent(new Event(EVENT_ZOOM_STARTS,true));
		}
		
		/**zoom ended*/
		private static function zoomEndedEvent(target:Stage)
		{
			target.dispatchEvent(new Event(EVENT_ZOOM_STOPED,true));
			for(var i = 0 ; i<onZoomEndedFuncs.length ; i++)
			{
				onZoomEndedFuncs[i]();
			}
		}
	}
}