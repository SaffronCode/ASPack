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

	public class ScrollMT extends EventDispatcher
	{
		public static const LOCK_SCROLL_TILL_MOUSE_UP:String = "LOCK_SCROLL_TILL_MOUSE_UP";
		
		public static const UN_LOCK_SCROLL:String = "UN_LOCK_SCROLL";
		
		public static const THEMP_LOCK:String = "THEMP_LOCK" ;
		
		private static const KILL_OLD_SCROLLER:String = "KILL_OLD_SCROLLER" ;
		
		private const 	cursolCollor:Number = 0x000000,
						cursolAlpha:Number = 0.1;
		
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
					stepBack:Boolean = false ;
		
		
	//animate controllers ↓
		/**speed reduocers <br>
		 * mu : is for the target is in the scroll rectangle range<br>
		 * mu2 : is for hard speed down*/
		private var mu:Number = 0.94,
					mu2:Number = 0.4;
		
		/**this number is the minimom scrolling speed that start to protect mouse events to the scrollable object*/
		private var minAvailableScroll:Number = 2,
					mouseWheelSpeed:Number = 8;
		
		/**speed of floating back for the scrollers*/
		private var floatBackSpeed_on_touch:Number = 20,
					floatBackSpeed_free:Number = 10;
		
		private var fadeOutSpeed:Number = 0.1,
					fadeInSpeed:Number = 0.25;
		
		
		
		
		
		
		
	//display objects ↓
		/**scroller mask*/
		private var scrollerMask:Sprite;
		
		/**this object will visible on the scrollable object to prevent its mouse click*/
		private var mouseLocker:Sprite;
		
		/**main scrollable object*/
		private var targ:DisplayObject,
					targStage:Stage,
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
		private var mousePose:Point ;
		
		
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
	
		
		/**this class will automaticly sets target position to targetArea .x and .y position<br>
		 * freeScrollOnTarget will make the targetArea rectangle to listen to the size of the scrollble object<br>
		 * <br>
		 * You can only lock t_d or r_l scroll when you didn't enter targetAreaRectangle.(Why???)*/
		public function ScrollMT(target:DisplayObject,maskArea:Rectangle,targetArea:Rectangle=null,FreeScrollOnTarget_TD:Boolean=false,FreeScrollOnTarget_LR:Boolean=false,activeEffect:Boolean=true,
				RevertY:Boolean=false,RevertX:Boolean=false,stepSize:Number=0)
		{
			revertY = RevertY ;
			stepSizes = stepSize ;
			
			//remember target
			targ = target ;
			
			trace("This is the new scroller.");
			
			acceptSetEfectOnMe = activeEffect ;
			
			targ.addEventListener(LOCK_SCROLL_TILL_MOUSE_UP,lockTheScrollThillMouseUp);
			targ.addEventListener(THEMP_LOCK,lockTheScrollThempurarily);
			
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
			
			scrollerMask = new Sprite();
			scrollerMask.graphics.beginFill(0,1);
			scrollerMask.graphics.drawRect(0,0,maskRect.width,maskRect.height);
			
			//scroller locker is generated from now↓
			mouseLocker = new Sprite();
			mouseLocker.graphics.copyFrom(scrollerMask.graphics);
			
			//comment this line for debuging the museLocker displayObject ↓
			mouseLocker.alpha = 0 ;
			
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
			
			
			targ.mask = scrollerMask;
			
			
			onAdded();
		}
		
		
		
		
		/**lock the scroller till the next mouse up event from the stage*/
		private function lockTheScrollThillMouseUp(e:Event)
		{
			targStage.addEventListener(MouseEvent.MOUSE_UP,unLock);
			lock();
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
		
		/**set up the scroller variables and event listeners from now*/
		private function setUpTheScroller()
		{
			//1.3.1 to ask to delete old scrolleers
			targ.dispatchEvent(new Event(KILL_OLD_SCROLLER));
			
			//trace("♠ now im added");
			
			reset() ;
			
			targStage = targ.stage;
			
			targParent = targ.parent ;
			
			targ.parent.addChild(scrollerMask);
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
			trace("**locked");
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
			targStage.removeEventListener(MouseEvent.MOUSE_UP,unLock);
			targStage.removeEventListener(UN_LOCK_SCROLL,unLock);
			scrollLock = false ;
		}
		
		/**reset the floating and position*/
		public function reset()
		{
			//trace('reset the scroller position');
			
			stopFloat();
			targ.x = targetRect.x =  maskRect.x+imageFirstPose.x ;
			
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
				
				isScrolling = true ;
				mousePose = new Point(targStage.mouseX,targStage.mouseY);
				//Added on version 1.2 ↓
					//Removed on version 1.4.3 to prevent lock scroll when scroll is not started yet.
					//targ.parent.dispatchEvent(new Event(LOCK_SCROLL_TILL_MOUSE_UP,true));
				//scrolling starts
			}
		}
		
		private function stopScroll(e:MouseEvent=null)
		{
			if(isScrolling)
			{
				isScrolling = false;
				MouseUnLock();
				//scrolling is stoped
			}
		}
		
		/**prevent scroller to catch mosueEvents*/
		private function MouseLock()
		{
			//trace('mouse s are locked');
			mouseLocker.visible = true ;
			
			//Added on version 1.4.3 to make this event dispatches when all buttons locked
			targ.parent.dispatchEvent(new Event(LOCK_SCROLL_TILL_MOUSE_UP,true));
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
		
		private function scrollAnim(e:Event)
		{
			/*if(e==null)
			{
				trace("Scroller debugger : "+targetRect);
				targ.x = targetRect.x ;
				targ.y = targetRect.y ;
			}*/
			if(scrollLock)
			{
				//trace('scroll is lock')
				return ;
			}
			var temp:Number ;
			
			if(freeScrollOnTarget_TD)
			{
				targetRect.height = targ.height;
				if(maskRect.height>=targetRect.height)
				{
					//unLockTopDown = false ;
					stopScroll();
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
			
			if(freeScrollOnTarget_LR)
			{
				targetRect.width = targ.width;
				if(maskRect.width>=targetRect.width)
				{
					//unLockLeftRight = false ;
					stopScroll();
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
				stepBack = false ;
				if(!Obj.isAccesibleByMouse(targParent,false,new Point(targStage.mouseX,targStage.mouseY)))
				{
					stopScroll();
					unLock();
					return;
				}
				var absScale:Number = absoluteScale();
				//trace('absScale : '+absScale);
				if(unLockLeftRight)
				{
					if(!MouseLockAvailable() && curselLeftRight.alpha<1)
					{
						curselLeftRight.alpha+=fadeInSpeed;
					}
					Vx=(targStage.mouseX-mousePose.x)/absScale;
					//lock the mosue↓
					if(MouseLockAvailable() && Math.abs(Vx)>minAvailableScroll)
					{
						MouseLock();
					}
				}
				if(unLockTopDown)
				{
					if(!MouseLockAvailable() && curselTopDown.alpha<1)
					{
						curselTopDown.alpha+=fadeInSpeed;
					}
					Vy=(targStage.mouseY-mousePose.y)/absScale;
					//lock the mosue↓
					//trace('check to lock the container : '+MouseLockAvailable()+' && '+Math.abs(Vy)+' > '+minAvailableScroll+' = '+(Math.abs(Vy)>minAvailableScroll));
					if(MouseLockAvailable() && Math.abs(Vy)>minAvailableScroll)
					{
						//this function was replaced with MouseUnLock() by mistake
						MouseLock();
					}
				}
				
				slowDownFloat(floatBackSpeed_on_touch,1);

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
				var precentX:Number = Math.min(1,Math.max(0,(maskRect.x-targetRect.x)/(targetRect.width-maskRect.width)));
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
		
		
		
		/**this function will slow down the floating speeds if targRectangle was got out from the mask rectangle*/
		private function slowDownFloat(slowDownSpeed:Number,slowDownMu:Number)
		{
			
			
			if(unLockTopDown)
			{
				var y0:Number = targetRect.y,
					Y0:Number = targetRect.bottom ,
					y1:Number = maskRect.y ,
					Y1:Number = maskRect.bottom ;
				if(revertY)
				{
					if(y0<Y1)
					{
						Vy*=slowDownMu ;
						Vy+=(Y1-y0)/slowDownSpeed;
					}
					else if(y0-targetRect.height>y1 && y0!=Y1)
					{
						Vy*=slowDownMu ;
						Vy+=(y1-(y0-targetRect.height))/slowDownSpeed;
					}
				}
				else
				{
					if(y0>y1)//↑
					{
						Vy*=slowDownMu ;
						Vy+=(y1-y0)/slowDownSpeed;
					}
					else if(Y0<Y1 && y0!=y1)//↓
					{
						Vy*=slowDownMu ;
						Vy+=(Y1-Y0)/slowDownSpeed;
					}
				}
			}
			
			if(unLockLeftRight)
			{
				var x0:Number = targetRect.x,
					X0:Number = targetRect.right,
					x1:Number = maskRect.x ,
					X1:Number = maskRect.right;
				
				if(x0>x1)//→
				{
					Vx*=slowDownMu ;
					Vx+=(x1-x0)/slowDownSpeed;
				}else if(X0<X1)//←
				{
					Vx*=slowDownMu ;
					Vx+=(X1-X0)/slowDownSpeed;
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
			// TODO Auto Generated method stub
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
			// TODO Auto Generated method stub
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
		public static function showScrollEfect():void
		{
			// TODO Auto Generated method stub
			ScrollEffect = true ;
		}
	}
}