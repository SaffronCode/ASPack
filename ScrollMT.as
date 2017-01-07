// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/**version log
 * version 1.1 : lockTheScrollThillMouseUp() and its event added
 * 			1.2 : scroll classes will dispatch LICK_SCROLL_TILL_MOUSE_UP to lock parents scrollers
 * 			1.3 : Scroll hit controll debuged and old codes are commented in canScroll() function .
 * 			1.3.1 : From now , new scrollers will cause to remove old scrollers on one target
 * 			1.4 :	Solved problems : new Scroller have to unload older Scroller for one item
 * 					dynamic scrollSize will not add sliders to the scroller
 * 					set unload function public to handle manual unload
 * 			1.4.1   Deleting scrollers controlling befor it is delete. on line 300+
 * 			1.4.2 : Scroller direction locker debugged.
 * 			1.4.3 : Scroller EventDispatcher debugged to prevent dispatches events when scroll is not started yet.
 * 			1.5		: revert scroll activated on Y direction to make lists like viber dialogs
 * 			1.5.1 : cursol Y debugged.
 * 			1.5.2 : Scroller will controll the visibality of the scrollable object now
 * 
 * 
 * 
 * 
 * 
 * 
 */

package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class ScrollMT extends EventDispatcher
	{
		
		public static const LOCK_SCROLL_TILL_MOUSE_UP:String = "LOCK_SCROLL_TILL_MOUSE_UP";
		
		public static const UN_LOCK_SCROLL:String = "UN_LOCK_SCROLL";
		
		public static const THEMP_LOCK:String = "THEMP_LOCK" ;
		
		private static const KILL_OLD_SCROLLER:String = "KILL_OLD_SCROLLER" ;
		
		/**This event dispatches to parent. the container scrollers must listen to this to stop their scroll controlling
		private static var TRY_TO_SCROLL:String = "TRY_TO_SCROLL" ;*///This event moved to ScrollMTEvent class
		
		private const 	cursolCollor:Number = 0x000000,
						cursolAlpha:Number = 0.1;
		
		/**This is the range that the IsRange function will return true if the scroller was out side of*/
		private const acceptableDelta:Number = 1 ;
		
		/**This will make 0,0 position stay on button or top*/
		private var revertY:Boolean = false ,
					revertX:Boolean = false ;
		
		private var stepSizes:Number = 0,
					stepMinSpeed:Number = 5,
					stepV:Number=0,
					stepVMu:Number=0.7,
					stepVF:Number=10,
					stepVF2:Number=10,
					stepVMu2:Number=0.9,
					
					slowDownToStopMu:Number = 0.8,
					
					stepBack:Boolean = false ;
		
		private var minV:Number = 4 ;
		
		
	//animate controllers ↓
		/**speed reduocers <br>
		 * mu : is for the target is in the scroll rectangle range<br>
		 * mu2 : is for hard speed down*/
		private var mu:Number = 0.94,
					mu2:Number = 0.4;
		
		/**this number is the minimom scrolling speed that start to protect mouse events to the scrollable object*/
		private var minAvailableScroll:Number = 20,
					minScrollToLock:Number=20,
					mouseWheelSpeed:Number = 8;
		
		/**speed of floating back for the scrollers*/
		private var floatBackSpeed_on_touch:Number = 20,
					floatBackSpeed_free:Number = 10;
		
		private var fadeOutSpeed:Number = 0.1,
					fadeInSpeed:Number = 0.25;
		
		
		
		private var mouseDownTime:Number,
					maxDelayToSave:uint=100,//This means the last Vs on this time will save
					VxRound:Number=0,
					VxHistory:Vector.<Number>,
					VyHistory:Vector.<Number>,
					VDates:Vector.<Number >,
					VyRound:Number=0;
		
		
		
	//display objects ↓
		/**scroller mask*/
		private var scrollerMask:Sprite;
		
		/**this object will visible on the scrollable object to prevent its mouse click*/
		private var mouseLocker:Sprite;
		
		
		private static var targStage:Stage;
		
		/**main scrollable object*/
		private var targ:DisplayObject,
					targParent:DisplayObjectContainer;
					
		private var curselLeftRight:Sprite,
					curselTopDown:Sprite;
		
		
	//recatngles ↓
		/**scroll area*/
		private var targetRect:Rectangle,
					imageFirstPose:Point,
					maskRect:Rectangle;
					
	//subsidary variables ↓
					
		private var currselW:Number=4,
					currselRound:Number=4,
					currselMargin:Number = 1,
					
					currselXArea:Number,
					currselYArea:Number;
		
	
		
		private var Vx:Number = 0 ,
					Vy:Number = 0 ;
		
		/**mouses first position */
		private var mousePose:Point,
					mousePose0:Point;
		
		
		private var scrollLock:Boolean = false,
					isScrolling:Boolean = false,
					unLockTopDown:Boolean = true ,
					unLockLeftRight:Boolean = true ;
		
		/**this will cause the targetRect to resize when the main target is resizing*/
		private var freeScrollOnTarget_TD:Boolean,
					freeScrollOnTarget_LR:Boolean;
					
					
					
					
		private static var ScrollEffect:Boolean = false ;
		
		private var scrollEffectDelta:Number = 100 ;
					
					
		private var acceptSetEfectOnMe:Boolean = true ;
		private var UnlockOnFirstClick:Boolean;

		private var absScale:Number;
		private var myTimeOutId:uint;
		private var autoScrollSpeedX:Number=0,
					autoScrollSpeedY:Number=0;
		
		private var minAreaToAutoScroll:Number = 100 ;
	
		
		/**this class will automaticly sets target position to targetArea .x and .y position<br>
		 * freeScrollOnTarget will make the targetArea rectangle to listen to the size of the scrollble object<br>
		 * <br>
		 * You can only lock t_d or r_l scroll when you didn't enter targetAreaRectangle.(Why???)*/
		public function ScrollMT(target:DisplayObject,maskArea:Rectangle,targetArea:Rectangle=null,FreeScrollOnTarget_TD:Boolean=false,FreeScrollOnTarget_LR:Boolean=false,activeEffect:Boolean=true,
				RevertY:Boolean=false,RevertX:Boolean=false,stepSize:Number=0)
		{
			revertY = RevertY ;
			revertX = RevertX ;
			stepSizes = stepSize ;
			
			//remember target
			targ = target ;
			
			trace("This is the new scroller.");
			
			acceptSetEfectOnMe = activeEffect ;
			
			targ.addEventListener(LOCK_SCROLL_TILL_MOUSE_UP,lockTheScrollThillMouseUp);
			targ.addEventListener(THEMP_LOCK,lockTheScrollThempurarily);
			targ.addEventListener(ScrollMTEvent.YOU_ARE_SCROLLING_FROM_YOUR_PARENT,lockTheScrollThillMouseUp);
			
			freeScrollOnTarget_TD = FreeScrollOnTarget_TD ;
			freeScrollOnTarget_LR = FreeScrollOnTarget_LR ;
			
			var userDidntEnterRect:Boolean = false ;
			
			//set up the targetRectange
			if(targetArea == null)
			{
				userDidntEnterRect = true ;
				targetArea = new Rectangle(0,0,targ.width,targ.height);
			}
			
			//save target and mask rectangles
			maskRect = maskArea.clone() ;
			targetRect = targetArea.clone() ;
			
			
			imageFirstPose = new Point(-targetRect.x,-targetRect.y);
			
			//checking the scroll area to lock efution floats↓
			if(!freeScrollOnTarget_TD && (maskRect.height>=targetRect.height || userDidntEnterRect))
			{
				unLockTopDown = false ;
			}
			
			//trace("maskRect : "+maskRect+' vs targetArea:'+targetArea);
			
			//trace("unLockTopDown : "+unLockTopDown);
			
			
			if(!freeScrollOnTarget_LR && (maskRect.width>=targetRect.width || userDidntEnterRect))
			{
				unLockLeftRight = false ;
			}
			
			//trace("unLockTopDown : "+unLockLeftRight);
			
			scrollerMask = new Sprite() ;
			
			//scroller locker is generated from now↓
			mouseLocker = new Sprite();
			mouseLocker.graphics.beginFill(0xff0000,0.5) ;
			mouseLocker.graphics.drawRect(0,0,maskRect.width,maskRect.height) ;
			
			//comment this line for debuging the museLocker displayObject ↓
			mouseLocker.alpha = 0;
			
			//trace('mous lock checker');
			
			mouseLocker.x = scrollerMask.x = maskRect.x;
			mouseLocker.y = scrollerMask.y = maskRect.y;
			
			//cursels manager↓
			curselLeftRight = new Sprite();
			curselTopDown = new Sprite();
			curselTopDown.alpha = curselLeftRight.alpha = 0 ;
			
			curselLeftRight.graphics.beginFill(cursolCollor,cursolAlpha);
			var temp:Number = (maskRect.width/targetRect.width)*maskRect.width ;
			curselLeftRight.graphics.drawRoundRect(0,0,temp,currselW,currselRound,currselRound);
			currselXArea = maskRect.width-temp - currselMargin*2 - currselW*2 ;
			
			curselLeftRight.x = maskRect.x+currselMargin+currselW;
			curselLeftRight.y = maskRect.y+currselMargin;
			
			curselTopDown.graphics.beginFill(cursolCollor,cursolAlpha);
			temp = (maskRect.height/targetRect.height)*maskRect.height ;
			curselTopDown.graphics.drawRoundRect(0,0,currselW,temp,currselRound,currselRound);
			currselYArea = maskRect.height-temp - currselMargin*2 - currselW*2 ;
			
			curselTopDown.x = maskRect.right-currselMargin-currselW ;
			curselTopDown.y = maskRect.y+currselMargin+currselW ;
			
			//trace("Cursel generated");
			
			
			
			
			onAdded();
		}
		
		/**Set scrolling item y*/
		public function set y(value:Number):void
		{
			mouseLocker.y = value ;
			scrollerMask.y = value ;
			curselLeftRight.y = value ;
			maskRect.y = value ;
			targetRect.y = value ;
			targ.y = value ;
			Vy = 0 ;
		}
		
		/**Set scrollng*/
		public function set x(value:Number):void
		{
			mouseLocker.x = value ;
			scrollerMask.x = value ;
			curselLeftRight.x = value ;
			maskRect.x = value ;
			targetRect.x = value ;
			targ.x = value ;
			Vx = 0 ;
		}
		
		/**Activate scroller auto scrolling*/
		public function activateAutoScroll(scrollSpeedX:Number = 0,scrollSpeedY:Number = 0):void
		{
			autoScrollSpeedX = scrollSpeedX ;
			autoScrollSpeedY = scrollSpeedY ;
		}
		
		
		
		
		/**lock the scroller till the next mouse up event from the stage*/
		private function lockTheScrollThillMouseUp(e:Event)
		{
			if(!scrollLock)
			{
				targStage.addEventListener(MouseEvent.MOUSE_UP,unLock);
				lock();
			}
		}
		
		/**lock the scroller till the next mouse up event from the stage or UN_LOCK_SCROLL dispatches*/
		private function lockTheScrollThempurarily(e:Event)
		{
			targStage.addEventListener(MouseEvent.MOUSE_UP,unLock);
			targStage.addEventListener(UN_LOCK_SCROLL,unLock);
			thempLock();
		}
		
		
		
		
		private function onAdded(e:Event=null)
		{
			if(targ.stage!=null)
			{
				targ.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
				setUpTheScroller();
			}
			else
			{
				//trace("♠ im not added yet");
				targ.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			}
		}
		
	///////////////////////////////////////intialize the scroller class↓
		
		/**Debugg function*/
		private function setMask():void
		{
			if(targ!=null && targ.parent!=null && scrollerMask!=null)
			{
				targ.parent.addChild(scrollerMask);
				scrollerMask.graphics.beginFill(0x00ff00,0.0) ;
				scrollerMask.graphics.drawRect(0,0,maskRect.width,maskRect.height) ;
				targ.mask = scrollerMask;
			}
		}
		
		/**set up the scroller variables and event listeners from now*/
		private function setUpTheScroller()
		{
			absScale = absoluteScale();
			//1.3.1 to ask to delete old scrolleers
			targ.dispatchEvent(new Event(KILL_OLD_SCROLLER,false,false));
			
			myTimeOutId = setTimeout(setMask,0);
			
			//trace("♠ now im added");
			
			reset() ;
			
			targStage = targ.stage;
			
			targParent = targ.parent ;
			
			targ.parent.addChild(mouseLocker);
			
			targStage.addEventListener(MouseEvent.MOUSE_WHEEL,manageMouseWheel);
			
			//add currsels if can
			if(unLockLeftRight)
			{
				targ.parent.addChild(curselLeftRight);
			}
			//add currsels if can
			if(unLockTopDown)
			{
				targ.parent.addChild(curselTopDown);
				//trace("Cursel added to : "+targ.parent);
			}
			/*else
			{
				trace("Top down scroll is lock");
			}*/
			
			targParent.addEventListener(MouseEvent.MOUSE_DOWN,startScroll);
			targStage.addEventListener(MouseEvent.MOUSE_UP,stopScroll);
			
			targ.addEventListener(Event.ENTER_FRAME,scrollAnim);
			
			targ.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			//1.3.1
			//to listent to delete if new scroller added
			targ.addEventListener(KILL_OLD_SCROLLER,unLoad);
			
			if(ScrollEffect && acceptSetEfectOnMe)
			{
				Vx += scrollEffectDelta ;
				Vy += scrollEffectDelta ;
			}
			scrollAnim(null);
		}
		
		/**unload the scroller functions*/
		public function unLoad(e:Event=null)
		{
			try
			{
				targ.parent.removeChild(scrollerMask);
			}catch(e){};
			
			try
			{
				targ.parent.removeChild(mouseLocker);
			}catch(e){};
			
			clearTimeout(myTimeOutId);
			
			targ.removeEventListener(ScrollMTEvent.TRY_TO_SCROLL,stopScroll);
			targStage.removeEventListener(MouseEvent.MOUSE_WHEEL,manageMouseWheel);
			
			//remove currsels if can
			if(unLockLeftRight && curselLeftRight!=null && curselLeftRight.parent!=null)
			{
				curselLeftRight.parent.removeChild(curselLeftRight);
			}
			
			//remove currsels if can
			if(unLockTopDown && curselTopDown != null && curselTopDown.parent!=null)
			{
				curselTopDown.parent.removeChild(curselTopDown);
			}
			
			targStage.removeEventListener(MouseEvent.MOUSE_MOVE,updateAnimation);
			targStage.removeEventListener(MouseEvent.MOUSE_UP,unLock);
			
			targParent.removeEventListener(MouseEvent.MOUSE_DOWN,startScroll);
			targStage.removeEventListener(MouseEvent.MOUSE_UP,stopScroll);
			
			targ.removeEventListener(Event.ENTER_FRAME,scrollAnim);
			
			targ.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		/**mouse will event*/
		private function manageMouseWheel(e:MouseEvent)
		{
			if( canScroll())
			{
				if(e.delta>0)
				{
					Vy+=mouseWheelSpeed;
				}
				else
				{
					Vy-=mouseWheelSpeed;
				}
			}
		}
		
	/////////////////////////////controller function s ↓
		
		/**This lock will not clear current activities*/
		public function thempLock():void
		{
			scrollLock = true ;
		}
		
		/**lock the scroller and stop floating*/
		public function lock(unlockOnFirstClick:Boolean=false):void
		{
			//trace("**locked");
			UnlockOnFirstClick = unlockOnFirstClick ;
			MouseUnLock();
			scrollLock = true ;
			stopFloat();
			
			if(curselLeftRight)
			{
				curselLeftRight.alpha = 0 ;
			}
			if(curselTopDown)
			{
				curselTopDown.alpha = 0 ;
			}
		}
		
		/**unlock the scroller*/
		public function unLock(e:*=null)
		{
			trace("**unlocked");
			if(targStage)
			{
				targStage.removeEventListener(MouseEvent.MOUSE_MOVE,updateAnimation);
				targStage.removeEventListener(MouseEvent.MOUSE_UP,unLock);
				targStage.removeEventListener(UN_LOCK_SCROLL,unLock);
			}
			scrollLock = false ;
		}
		
		/**reset the floating and position*/
		public function reset()
		{
			//trace('reset the scroller position');
			
			stopFloat();
			if(revertX)
			{
				targ.x = targetRect.x =  maskRect.x+imageFirstPose.x+maskRect.width ;
			}
			else
			{
				targ.x = targetRect.x =  maskRect.x+imageFirstPose.x ;
			}
			
			if(revertY)
			{
				targ.y = targetRect.y = maskRect.y+imageFirstPose.y+maskRect.height ;
			}
			else
			{
				targ.y = targetRect.y = maskRect.y+imageFirstPose.y ;
			}
			MouseUnLock();
		}
		
		/**stop floating the targ*/
		public function stopFloat()
		{
			Vx = 0 ;
			Vy = 0 ;
			
			isScrolling = false;
		}
		
		public function stepSlide(VX:Number=0,VY:Number=0):void
		{
			Vx+=VX;
			Vy+=VY;
		}
		
	////////////////////////scrolling funcitons ↓
		/**check if scroll available*/
		private function canScroll()
		{
			//Debug line ↓
				//trace("Scroll controll : "+targStage.mouseX,targStage.mouseY+' vs '+scrollerMask.getBounds(targStage)+" > "+(scrollerMask.hitTestPoint(targStage.mouseX,targStage.mouseY))+' and '+(scrollerMask.getBounds(targStage).contains(targStage.mouseX,targStage.mouseY)));
				return !scrollLock && scrollerMask.getBounds(targStage).contains(targStage.mouseX,targStage.mouseY) && ((maskRect.height<targetRect.height && unLockTopDown) || (maskRect.width<targetRect.width && unLockLeftRight)) && Obj.getVisible(targ);
			//return !scrollLock && scrollerMask.hitTestPoint(targStage.mouseX,targStage.mouseY) ;
		}
		
		
		private function startScroll(e:MouseEvent)
		{
			if(UnlockOnFirstClick)
			{
				unLock();
			}
			if(canScroll())
			{
				//Lock the parent scoller imediatly
				//targ.parent.dispatchEvent(new Event(LOCK_SCROLL_TILL_MOUSE_UP,true));
				mouseDownTime = getTimer();
				VxRound = VyRound = 0 ;
				VxHistory = new Vector.<Number>();
				VyHistory = new Vector.<Number>();
				VDates = new Vector.<Number>();
				
				isScrolling = true ;
				mousePose = new Point(targStage.mouseX,targStage.mouseY);
				mousePose0 = new Point(targStage.mouseX,targStage.mouseY);
				//Added on version 1.2 ↓
					//Removed on version 1.4.3 to prevent lock scroll when scroll is not started yet.
					//targ.parent.dispatchEvent(new Event(LOCK_SCROLL_TILL_MOUSE_UP,true));
				//scrolling starts
				targStage.addEventListener(MouseEvent.MOUSE_MOVE,updateAnimation);
				targ.addEventListener(ScrollMTEvent.TRY_TO_SCROLL,stopScroll);
			}
		}
		
		/**Update the animation instantly after mouseMove Event*/
		private function updateAnimation(e:MouseEvent):void
		{
			scrollAnim(null);
			e.updateAfterEvent();
		}
		
		private function stopScroll(e:*=null)
		{
			if(e is ScrollMTEvent && ((e as ScrollMTEvent).freeScrollOnTarget_LR != freeScrollOnTarget_LR && (e as ScrollMTEvent).freeScrollOnTarget_TD != freeScrollOnTarget_TD))
			{
				return ;
			}
			targ.removeEventListener(ScrollMTEvent.TRY_TO_SCROLL,stopScroll);
			if(isScrolling)
			{
				scrollAnim(null,true);
				
				var deltaFrame:uint = Math.min(maxDelayToSave,(getTimer()-mouseDownTime))/(1000/targStage.frameRate);
				var lastAcceptableTime:uint = getTimer()-maxDelayToSave ;
				VxRound = VyRound = 0 ;
				for(var i = VDates.length-1 ; i>=0 ; i--)
				{
					if(VDates[i]>lastAcceptableTime)
					{
						VxRound+=VxHistory[i];
						VyRound+=VyHistory[i];
					}
					else
					{
						break ;
					}
				}
				
				var vmaxDeltaFrame:Number = Math.max(1,deltaFrame) ;
				
				if(Math.abs(VxRound/vmaxDeltaFrame)>minAvailableScroll)
				{
					Vx+=(VxRound)/vmaxDeltaFrame;
					if(Vx>0)
					{
						autoScrollSpeedX = Math.abs(autoScrollSpeedX);
					}
					else
					{
						autoScrollSpeedX = -Math.abs(autoScrollSpeedX);
					}
				}
				if(Math.abs(VyRound/vmaxDeltaFrame)>minAvailableScroll)
				{
					Vy+=(VyRound)/vmaxDeltaFrame;
					if(Vy>0)
					{
						autoScrollSpeedY = Math.abs(autoScrollSpeedY);
					}
					else
					{
						autoScrollSpeedY = -Math.abs(autoScrollSpeedY);
					}
				}
				isScrolling = false;
				MouseUnLock();
				targStage.removeEventListener(MouseEvent.MOUSE_MOVE,updateAnimation);
				//scrolling is stoped
			}
		}
		
		/**prevent scroller to catch mosueEvents*/
		private function MouseLock()
		{
			//trace('mouse s are locked');
			if(!mouseLocker.visible)
			{
				dispatchChildScrollLockerOn(targ as Sprite);
			}
			mouseLocker.visible = true ;
			
			//Added on version 1.4.3 to make this event dispatches when all buttons locked
			targ.parent.dispatchEvent(new Event(LOCK_SCROLL_TILL_MOUSE_UP,true,false));
		}
		
		/**This will dispatches YOU_ARE_SCROLLING_FROM_YOUR_PARENT event to all children*/
		private function dispatchChildScrollLockerOn(target:Sprite):void
		{
			//trace("Dispatch events on : "+target)
			for(var i = 0 ; i<target.numChildren ; i++)
			{
				if(target.getChildAt(i) is Sprite)
				{
					(target.getChildAt(i) as Sprite).dispatchEvent(new ScrollMTEvent(ScrollMTEvent.YOU_ARE_SCROLLING_FROM_YOUR_PARENT,false,false,freeScrollOnTarget_TD,freeScrollOnTarget_LR));
					dispatchChildScrollLockerOn((target.getChildAt(i) as Sprite));
				}
			}
		}
		
		/**disable mouseEvent*/
		private function MouseUnLock()
		{
			mouseLocker.visible = false ;
		}
		
		/**tells if mouse lock is avaailable on this class*/
		private function MouseLockAvailable():Boolean
		{
			return !mouseLocker.visible;
		}
		
		
	//////////////////////////////////////scroll animation↓
		
		private function scrollAnim(e:Event,imCalledFromStopScrollFunction:Boolean=false)
		{
			/*if(e==null)
			{
				trace("Scroller debugger : "+targetRect);
				targ.x = targetRect.x ;
				targ.y = targetRect.y ;
			}*/
			var calledByMouseDrag:Boolean = false  ; 
			if(e==null)
			{
				calledByMouseDrag = true ;
			}
			
			if(scrollLock)
			{
				//trace('scroll is lock')
				return ;
			}
			var temp:Number ;
			
			if(!calledByMouseDrag && freeScrollOnTarget_TD)
			{
				targetRect.height = targ.height;
				if(maskRect.height>=targetRect.height)
				{
					//unLockTopDown = false ;
					if(!imCalledFromStopScrollFunction)
					{
						stopScroll();
					}
				}
				else
				{
					curselTopDown.graphics.clear();
					curselTopDown.graphics.beginFill(cursolCollor,cursolAlpha);
					temp = (maskRect.height/targetRect.height)*maskRect.height ;
					curselTopDown.graphics.drawRoundRect(0,0,currselW,temp,currselRound,currselRound);
					currselYArea = maskRect.height-temp - currselMargin*2 - currselW*2 ;
					
					curselTopDown.x = maskRect.right-currselMargin-currselW ;
					curselTopDown.y = maskRect.y+currselMargin+currselW ;
					if(unLockTopDown == false)
					{
						targ.parent.addChild(curselLeftRight);
					}
					unLockTopDown = true ;
				}
			}
			
			if(!calledByMouseDrag && freeScrollOnTarget_LR)
			{
				targetRect.width = targ.width;
				if(maskRect.width>=targetRect.width)
				{
					//unLockLeftRight = false ;
					if(!imCalledFromStopScrollFunction)
					{
						stopScroll();
					}
				}
				else
				{
					curselLeftRight.graphics.clear();
					curselLeftRight.graphics.beginFill(cursolCollor,cursolAlpha);
					temp = (maskRect.width/targetRect.width)*maskRect.width ;
					curselLeftRight.graphics.drawRoundRect(0,0,temp,currselW,currselRound,currselRound);
					currselXArea = maskRect.width-temp - currselMargin*2 - currselW*2 ;
					
					curselLeftRight.x = maskRect.x+currselMargin+currselW;
					curselLeftRight.y = maskRect.y+currselMargin;
					
					if(unLockLeftRight == false)
					{
						targ.parent.addChild(curselLeftRight);
					}
					unLockLeftRight = true ;
				}
			}
			
			
			if(isScrolling)
			{
				var vxHist:Number=Vx;
				var vyHist:Number=Vy;
				stepBack = false ;
				if(false && !Obj.isAccesibleByMouse(targParent,false,new Point(targStage.mouseX,targStage.mouseY)))
				{
					if(!imCalledFromStopScrollFunction)
					{
						stopScroll();
					}
					unLock();
					return;
				}
				//trace('absScale : '+absScale);
				if(unLockLeftRight)
				{
					if(MouseLockAvailable() && Math.abs(mousePose0.x-mousePose.x)>minScrollToLock)
					{
						vxHist =(targStage.mouseX-mousePose0.x)/absScale;
						mousePose0 = null ;
						MouseLock();
					}
					else if(mousePose0!=null)
					{
						vxHist = Vx = 0 ;
						//trace("Canseling");
						targParent.dispatchEvent(new ScrollMTEvent(ScrollMTEvent.TRY_TO_SCROLL,true,false,freeScrollOnTarget_TD,freeScrollOnTarget_LR));
					}
					else
					{
						if(!MouseLockAvailable() && curselLeftRight.alpha<1)
						{
							curselLeftRight.alpha+=fadeInSpeed;
						}
						vxHist = Vx=(targStage.mouseX-mousePose.x)/absScale;
					}
					//lock the mosue↓
				}
				if(unLockTopDown)
				{
					if(MouseLockAvailable() && Math.abs(mousePose0.y-mousePose.y)>minScrollToLock)
					{
						//this function was replaced with MouseUnLock() by mistake
						vyHist=(targStage.mouseY-mousePose0.y)/absScale;
						//trace("Extra vy : "+Vy);
						mousePose0 = null ;
						MouseLock();
					}
					else if(mousePose0!=null)
					{
						//trace("Canseling");
						vyHist = Vy = 0 ;
						targParent.dispatchEvent(new ScrollMTEvent(ScrollMTEvent.TRY_TO_SCROLL,true,false,freeScrollOnTarget_TD,freeScrollOnTarget_LR));
					}
					else
					{
						if(!MouseLockAvailable() && curselTopDown.alpha<1)
						{
							curselTopDown.alpha+=fadeInSpeed;
						}
						vyHist = Vy=(targStage.mouseY-mousePose.y)/absScale;
					}
					//lock the mosue↓
					//trace('check to lock the container : '+MouseLockAvailable()+' && '+Math.abs(Vy)+' > '+minAvailableScroll+' = '+(Math.abs(Vy)>minAvailableScroll));
				}
				
				if(!calledByMouseDrag)
				{
					//slowDownFloat(floatBackSpeed_on_touch,1);
				}
				
				VxHistory.push(vxHist);
				VyHistory.push(vyHist);
				VDates.push(getTimer());
				
				mousePose = new Point(targStage.mouseX,targStage.mouseY);
			}
			else
			{
				if(unLockLeftRight)
				{
					if(Math.abs(Vx)<minAvailableScroll)
					{
						if(curselLeftRight.alpha>0)
						{
							curselLeftRight.alpha-=fadeOutSpeed;
						}
					}
					else if(curselLeftRight.alpha<1)
					{
						curselLeftRight.alpha+=fadeInSpeed;
					}
					Vx*=mu ;
				}
				if(unLockTopDown)
				{
					if(Math.abs(Vy)<minAvailableScroll)
					{
						if(curselTopDown.alpha>0)
						{
							curselTopDown.alpha-=fadeOutSpeed;
						}
					}
					else if(curselTopDown.alpha<1)
					{
						curselTopDown.alpha+=fadeInSpeed;
					}
					Vy*=mu ;
				}
				
				slowDownFloat(floatBackSpeed_free,mu2);
			}
			//manage cursel s place to
			
			if(unLockLeftRight)
			{
				//trace('move left to right');
				targetRect.x+=Vx;
				targ.x = targetRect.x+imageFirstPose.x;
				var precentX:Number;
				var precentXRaw:Number;
				
				
				if(revertX)
				{
					precentXRaw = 1+((maskRect.x-(targetRect.x-maskRect.width))/(targetRect.width-maskRect.width));
					//trace("precentYRaw : "+precentYRaw);
				}
				else
				{
					precentXRaw = (maskRect.x-targetRect.x)/(targetRect.width-maskRect.width);
				}
				
				precentX = Math.min(1,Math.max(0,precentXRaw));
				curselLeftRight.x = currselXArea*precentX+maskRect.x+currselMargin+currselW ;
			}
			
			if(unLockTopDown)
			{
				//trace('move top down '+Vy);
				targetRect.y+=Vy;
				targ.y = targetRect.y+imageFirstPose.y;
				var precentY:Number;
				var precentYRaw:Number ;
				if(revertY)
				{
					precentYRaw = 1+((maskRect.y-(targetRect.y-maskRect.height))/(targetRect.height-maskRect.height));
					//trace("precentYRaw : "+precentYRaw);
				}
				else
				{
					precentYRaw = (maskRect.y-targetRect.y)/(targetRect.height-maskRect.height);
				}
				//precentYRaw = Math.abs(precentYRaw);
				/*if(precentYRaw>1)
				{
					precentYRaw = 1-(precentYRaw-Math.floor(precentYRaw))
				}*/
				precentY = Math.min(1,Math.max(0,precentYRaw));
				/*if(revertY)
				{
					precentY = 1-precentY;
				}*/
				curselTopDown.y = currselYArea*precentY+maskRect.y+currselMargin+currselW ;
			}
			
			
		}
		
		
		/**This will returns true if the scroller is in the correct ragne and there is no need to wait till scroller back to the page*/
		public function isInRange():Boolean
		{
			if(
				(
					targetRect.width<maskRect.width 
					|| 
					(
						targetRect.left<=maskRect.left+acceptableDelta
						&& 
						targetRect.right>=maskRect.right-acceptableDelta
					)
				)
				&&
				(
					targetRect.height<maskRect.height
					||
					(
						targetRect.top<=maskRect.top+acceptableDelta
						&&
						targetRect.bottom>=maskRect.bottom-acceptableDelta
					)
				)
			)
			{
				//trace("It is in range");
				return true ;
			}
			//trace("It is not in the range");
			return false ;
		}
		
		
		/**this function will slow down the floating speeds if targRectangle was got out from the mask rectangle*/
		private function slowDownFloat(slowDownSpeed:Number,slowDownMu:Number)
		{
			if(Math.abs(Vx)<minV)
			{
				Vx*=slowDownToStopMu ;
			}
			if(Math.abs(Vy)<minV)
			{
				Vy*=slowDownToStopMu ;
			}
			if(unLockTopDown)
			{
				if(maskRect.height<targetRect.height-minAreaToAutoScroll)
					Vy+=autoScrollSpeedY;
				var y0:Number = targetRect.y,
					Y0:Number = targetRect.bottom ,
					y1:Number = maskRect.y ,
					Y1:Number = maskRect.bottom ;
				
				if(revertY)
				{
					if(y0<Y1)
					{
						autoScrollSpeedY = Math.abs(autoScrollSpeedY);
						Vy*=slowDownMu ;
						Vy+=(Y1-y0)/slowDownSpeed;
					}
					else if(y0-targetRect.height>y1 && y0!=Y1)
					{
						autoScrollSpeedY = -Math.abs(autoScrollSpeedY);
						Vy*=slowDownMu ;
						Vy+=(y1-(y0-targetRect.height))/slowDownSpeed;
					}
				}
				else
				{
					if(y0>y1)//↑
					{
						autoScrollSpeedY = -Math.abs(autoScrollSpeedY);
						Vy*=slowDownMu ;
						Vy+=(y1-y0)/slowDownSpeed;
					}
					else if(Y0<Y1 && y0!=y1)//↓
					{
						autoScrollSpeedY = Math.abs(autoScrollSpeedY);
						Vy*=slowDownMu ;
						Vy+=(Y1-Y0)/slowDownSpeed;
					}
				}
				
				//Step controll on Y is missed here
			}
			
			if(unLockLeftRight)
			{
				if(maskRect.width<targetRect.width-minAreaToAutoScroll)
					Vx+=autoScrollSpeedX;
				var x0:Number = targetRect.x,
					X0:Number = targetRect.right,
					x1:Number = maskRect.x ,
					X1:Number = maskRect.right;
				
				if(revertX)
				{
					if(x0<X1)//→
					{
						autoScrollSpeedX = Math.abs(autoScrollSpeedX)
						Vx*=slowDownMu ;
						Vx+=(X1-x0)/slowDownSpeed;
					}
					else if(x0-targetRect.width>x1 && x0!=X1)//←
					{
						autoScrollSpeedX = -Math.abs(autoScrollSpeedX)
						Vx*=slowDownMu ;
						Vx+=(x1-(x0-targetRect.width))/slowDownSpeed;//Vy+=(y1-(y0-targetRect.height))/slowDownSpeed;
					}
				}
				else
				{
					if(x0>x1)//→
					{
						autoScrollSpeedX = -Math.abs(autoScrollSpeedX)
						Vx*=slowDownMu ;
						Vx+=(x1-x0)/slowDownSpeed;
					}
					else if(X0<X1)//←
					{
						autoScrollSpeedX = Math.abs(autoScrollSpeedX)
						Vx*=slowDownMu ;
						Vx+=(X1-X0)/slowDownSpeed;
					}
				}
				
				if(stepSizes!=0 && targetRect.width>maskRect.width)
				{
					if(!isScrolling && (stepBack || Math.abs(Vx)<stepMinSpeed))
					{
						stepBack = true ;
						//trace(" targetRect.x : "+targetRect.x);
						//trace(" stepSizes : "+stepSizes);
						//trace(" Math.round(targetRect.x/stepSizes) : "+Math.round(targetRect.x/stepSizes));
						var bestPlace:Number = Math.min(0,Math.round(Math.max(maskRect.width-targetRect.width,targetRect.x)/stepSizes)*stepSizes) ;
						//trace("NOW : "+bestPlace);
						stepV += (bestPlace-targetRect.x)/stepVF; 
						stepV*=stepVMu ;
						
						Vx+=stepV/stepVF2;
						Vx*=stepVMu2;
						//trace("Vx : "+Vx);
					}
				}
			}
		}
		
		
		/**return the absolute scale of the draggingg object from the stage*/
		private function absoluteScale():Number
		{
			var scale:Number = 1;
			var checkedTarg:DisplayObject = targ.parent ;
			while(checkedTarg!=null)
			{
				scale = scale*checkedTarg.scaleX;
				try
				{
					checkedTarg = checkedTarg.parent ;
				}
				catch(e)
				{
					break ;
				}
			}
			return scale ;
		}
		
		public function setPose(X:Number = NaN, Y:Number = NaN):void
		{
			stopFloat();
			
			if(!isNaN(X))
			{
				targetRect.x = maskRect.x+X ;
			}
			if(!isNaN(Y))
			{
				targetRect.y = maskRect.y+Y ;
			}
				//scrollAnim(null);
			//Debugged
				targ.x = targetRect.x ;
				targ.y = targetRect.y ;
		}
		
		/**This position is not depend on the maskRectangle*/
		public function setAbsolutePose(X:Number = NaN, Y:Number = NaN):void
		{
			stopFloat();
			
			if(!isNaN(X))
			{
				targetRect.x = X ;
			}
			if(!isNaN(Y))
			{
				targetRect.y = Y ;
			}
				//scrollAnim(null);
			//Debugged
				targ.x = targetRect.x ;
				targ.y = targetRect.y ;
		}
		
		
		
			/////////////////////////////////////////////////////
		
		/**This function will cause to scroll the page befor its starts to work*/
		public static function showScrollEfect(value:Boolean=true):void
		{
			
			ScrollEffect = value ;
		}
		
		/**Returns the last scroll effect*/
		public static function lastScrollEffect():Boolean
		{
			return ScrollEffect ;
		}
	}
}