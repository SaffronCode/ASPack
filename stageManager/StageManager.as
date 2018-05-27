/***Versions
 * 1.0.1 4/19/2015 : stageRect():Rectangle added to this class.
 * 
 * 
 * 
 * 
 * 
 */

package stageManager
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	public class StageManager
	{
		/**Resize event dispatches on this value*/
		public static var eventDispatcher:StageEventDispatcher = new StageEventDispatcher();
		
		/**Main stage object*/
		private static var 	myStage:Stage,
							myRoot:DisplayObject;
							//debugTF:TextField ;
							
		private static var 	TopColor:uint,
							BottomColor:uint;
							
		/**Current stage Width and height*/
		private static var 	stageWidth:Number=0,
							stageHeight:Number=0;
							
		/**The real size for the stage*/
		private static var	stageWidth0:Number,
							stageHeight0:Number;
							
		private static var debugW:Number,debugH:Number;
		
		private static var deltaStageWidth:Number=0,deltaStageHeight:Number=0,
							stageScaleWidth:Number,stageScaleHeight:Number;
		
		private static var lastStageFW:Number,lastStageFH:Number;
		
		/**Activate resolution controll*/
		private static var resolutionControll:Boolean,
							scaleFactor:Number=1;
							
		/**I store the stage size like this : "1024,768"*/
		private static var lastStageSize:String = '';
		
		/**If this was true, it means that the stage.fullScreen sizes are not correct so the application should controll the stage.stageWidth*/
		private static var haveToCheckStageSize:Boolean = false ;
		
	///
		private static var OptionsList:Vector.<StageOption>,
							Items:Vector.<StageItem>;
				
		/**This will returns stage retangle*/
		public static function get stageRect():Rectangle
		{
			return new Rectangle(0,0,stageWidth,stageHeight);
		}
		
		/**This will returns stage retangle*/
		public static function get stageVisibleArea():Rectangle
		{
			return new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2,stageWidth,stageHeight);
		}
		
		/**This will returns stage old Rectangle*/
		public static function get stageOldRect():Rectangle
		{
			return new Rectangle(0,0,stageWidth0,stageHeight0);
		}
		
		/**returns the difrences between original size stage's size and current stage size*/
		public static function get stageDelta():Rectangle
		{
			return new Rectangle(0,0,deltaStageWidth,deltaStageHeight);
		}
		
		/**The debug values cannot be smaller than the actual size of the screen. it will never happend.*/
		public static function setUp(yourStage:Stage,debugWidth:Number = 0 ,debugHeight:Number=0,listenToStageRotation:Boolean=false,activateResolutionControll:Boolean = false ,yourRoot:DisplayObject=null,topColor:uint=0,buttomColor:uint=0)
		{
			myStage = yourStage ;
			myRoot = yourRoot ;
			TopColor = topColor ;
			BottomColor = buttomColor ;
			OptionsList = new Vector.<StageOption>();
			Items = new Vector.<StageItem>();
			resolutionControll = activateResolutionControll ;
			
			if(activateResolutionControll)
			{
				throw "activateResolutionControll is not working yet.";
			}
			
			debugW = debugWidth ;
			debugH = debugHeight ;
			
			stageWidth0 = myStage.stageWidth;
			stageHeight0 = myStage.stageHeight;
			
			//debugTF = debuggerTF ;
			
			//myStage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING,controlStageProperties);
			if(listenToStageRotation)
			{
				myStage.addEventListener(Event.ENTER_FRAME,controllStageSizes);
			}
			controllStageSizes(null,true);
			
			myStage.addEventListener(Event.ADDED,controllFromMe,false,1);
			//myStage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE,controllStageSizesOnFullScreen);
			//NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,controllStageSizesOnFullScreen);
			setTimeout(controllStageSizesOnFullScreen,0);
			setInterval(controllStageSizesOnFullScreen,1000);
		}
		
		private static function controllStageSizesOnFullScreen(e:*=null):void
		{
			lastStageFW = NaN ;
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE,controllStageSizesOnFullScreen);
			controllStageSizes(null,true);
		}
		
		public static function deactiveRotationListening():void
		{
			myStage.removeEventListener(Event.ENTER_FRAME,controllStageSizes);
		}
		
		/**Controll the stage each frame*/
		protected static function controllStageSizes(event:Event=null,testTheStageSizeTo:Boolean=false):void
		{
			if((lastStageFW!=myStage.fullScreenWidth || lastStageFH != myStage.fullScreenHeight) || testTheStageSizeTo)
			{
				eventDispatcher.dispatchEvent(new StageManagerEvent(StageManagerEvent.STAGE_RESIZING,new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2,stageWidth,stageHeight)));
				lastStageFW = myStage.fullScreenWidth ;
				lastStageFH = myStage.fullScreenHeight ;
				
				var stageWidth:Number;
				var stageHeight:Number;
				
				if(!DevicePrefrence.isFullScreen() || testTheStageSizeTo || haveToCheckStageSize)
				{
					myStage.scaleMode = StageScaleMode.NO_SCALE ;
					stageWidth = myStage.stageWidth ;
					stageHeight = myStage.stageHeight ;
					myStage.scaleMode = StageScaleMode.SHOW_ALL ;
					
					if(testTheStageSizeTo)
					{
						if(stageWidth != lastStageFW || stageHeight != lastStageFH)
						{
							trace("The stage.fullScreen size is not trustable");
							haveToCheckStageSize = true ;
						}
					}
				}
				else
				{
					stageWidth = lastStageFW ;
					stageHeight = lastStageFH ;
				}
				
				if(debugW!=0 && debugH!=0)
				{
					controlStageProperties(debugW,debugH);
				}
				else
				{
					controlStageProperties(stageWidth,stageHeight);
				}
				
				
				if(resolutionControll)
				{
					if(myRoot==null)
					{
						throw "You have to pass the root to the stageManagager to"
					}
					scaleFactor = 0.5 ;
					myRoot.scaleX = myRoot.scaleY = scaleFactor ;
					myRoot.x = (stageWidth-stageWidth*scaleFactor)/2;
					myRoot.y = (stageHeight-stageHeight*scaleFactor)/2;
				}
				
				ManageAllPositions();
				//trace("All managed");
				var isStageChanged:Boolean = lastStageSize!=stageWidth+','+stageHeight;
				lastStageSize = stageWidth+','+stageHeight;
				if(isStageChanged)
					eventDispatcher.dispatchEvent(new StageManagerEvent(StageManagerEvent.STAGE_RESIZED,new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2,stageWidth,stageHeight)));
			}
		}		
		
		/**Stage status is new*/
		protected static function controlStageProperties(fullScreenWidth:Number,fullScreenHeight:Number,resizedForIPhoneXOnce:Boolean=false):void
		{
			var scaleX:Number = fullScreenWidth/stageWidth0 ;
			var scaleY:Number = fullScreenHeight/stageHeight0 ;
			
			//trace("fullScreenWidth/stageWidth0 : "+fullScreenWidth+'/'+stageWidth0)
			//trace("fullScreenHeight/stageHeight0 : "+fullScreenHeight+'/'+stageHeight0)
			//trace("scaleX : "+scaleX);
			//trace("scaleY : "+scaleY);
			
			
			
			
			scl = Math.min(scaleX,scaleY);
			//trace("scl : "+scl);
			
			stageWidth = Math.round(fullScreenWidth/scl);
			stageHeight = Math.round(fullScreenHeight/scl);
			
			//trace("stageWidth : "+stageWidth);
			//trace("stageHeight: "+stageHeight);
			
			var str:String = stageWidth+'/'+stageHeight;
			//debugTF.text = str ;
			
			deltaStageWidth = stageWidth-stageWidth0 ;
			deltaStageHeight = stageHeight-stageHeight0 ;
			stageScaleWidth = stageWidth/stageWidth0;
			stageScaleHeight = stageHeight/stageHeight0;
			//trace("stageScaleWidth: "+stageScaleWidth);
			
			if(resizedForIPhoneXOnce==false && (DevicePrefrence.isIOS()))
			{
				Obj.remove(iPhoneXJingleAreaMask1);
					iPhoneXJingleAreaMask1 = null ;
				Obj.remove(iPhoneXJingleAreaMask2);
					iPhoneXJingleAreaMask2 = null ;
					
				const margin:Number = 10 ;
					
				if(stageWidth/stageHeight>2)
				{
					trace("You have iPhoneX, nice...");
					trace("It is landscape...not supporting now");
					
					//controlStageProperties(stageWidth-iPhoneXJingleBarSize*2,stageHeight,true);
				}
				else if(stageHeight/stageWidth>2)
				{
					trace("You have iPhoneX, nice...");
					trace("It is portrate");
					
					iPhoneXJingleAreaMask1 = new Sprite();
					iPhoneXJingleAreaMask1.graphics.beginFill(TopColor,1);
					iPhoneXJingleAreaMask1.graphics.drawRect(-margin,-margin,stageWidth+margin*2,iPhoneXJingleBarSize+margin);
					iPhoneXJingleAreaMask1.y = stageVisibleArea.y;
					
					iPhoneXJingleAreaMask2 = new Sprite();
					iPhoneXJingleAreaMask2.graphics.beginFill(BottomColor,1);
					iPhoneXJingleAreaMask2.graphics.drawRect(-margin,0,stageWidth+margin*2,iPhoneXJingleBarSize+margin);
					iPhoneXJingleAreaMask2.y = stageVisibleArea.bottom-iPhoneXJingleBarSize ;
					
					
					myStage.addChild(iPhoneXJingleAreaMask1);
					myStage.addChild(iPhoneXJingleAreaMask2);
					controlStageProperties(stageWidth,stageHeight-iPhoneXJingleBarSize*2,true);
				}
			}
		}
		
		
	//////////////////////////////////////////////Place manager
		
		private static function manageItemPlace(item:StageItem):void
		{
			item.resetPose(deltaStageWidth,deltaStageHeight,stageScaleWidth,stageScaleHeight);
		}
		
		
	////////////////////////////////////////////////////
		
		private static var controlleLocked:Boolean = false ;

		private static var scl:Number=0;
		private static const iPhoneXJingleBarSize:Number = 67;
		/**iPhoneX masks*/
		private static var 	iPhoneXJingleAreaMask1:Sprite,
							iPhoneXJingleAreaMask2:Sprite;
		
		/**This function will lock the stage controller when you are adding items and you need to controll all stage once after all items are added.*/
		public static function lock():void
		{
			controlleLocked = true ;
		}
		
		/**Unlocking the controller then controll all options*/
		public static function unLock():void
		{
			controlleLocked = false ;
			controllAllOptions();
		}
		
		/**Returns the stage scale factor*/
		public static function stageScaleFactor():Number
		{
			return scl ;
		}
		
		/**Add stageManager item. <br>
		 * -1 for left or up, 1 for right or down. and 0 for ignore*/
		public static function add(itemName:String,xPosition:int=0,yPosition:int=0,resizeByX:Boolean=false,resizeByY:Boolean=false):void
		{
			var option:StageOption = new StageOption(itemName,xPosition,yPosition,resizeByX,resizeByY);
			OptionsList.push(option);
			
			if(!controlleLocked)
			{
				controllAllOptions();
			}
		}
		
		/**Controll stage from this element*/
		protected static function controllFromMe(ev:Event):void
		{
			
			//detectItemsIn(ev.target as DisplayObjectContainer);
			if(ev.target is MovieClip)
			{
				//trace("ev.target : "+ev.target);
				controllOptionForThis(ev.target as DisplayObjectContainer);
				//trace("Founded items are2 : "+Items.length);
				ManageAllPositions();
			}
			
			if(iPhoneXJingleAreaMask1!=null)
				myStage.addChild(iPhoneXJingleAreaMask1);
			if(iPhoneXJingleAreaMask2!=null)
				myStage.addChild(iPhoneXJingleAreaMask2);
		}
		
		/**All options will controll from the stage*/
		private static function controllAllOptions()
		{
			detectItemsIn(myStage as DisplayObjectContainer);
			//trace("Founded items are1 : "+Items.length);
			ManageAllPositions();
		}
		
		/**Controll*/
		private static function detectItemsIn(target:DisplayObjectContainer):void
		{
			var i:int ;
			controllOptionForThis(target);
			for(i = 0 ; i<target.numChildren ; i++)
			{
				if(target.getChildAt(i) is DisplayObjectContainer)
				{
					detectItemsIn(target.getChildAt(i) as DisplayObjectContainer);
				}
			}
		}
		
		/**Controll this item if it is on the stage*/
		private static function controllOptionForThis(target:DisplayObject)
		{
			var i:int ;
			if(target.name == null || target.name.indexOf('insta')==0)
			{
				return ;
			}
			if(StageItem.isNew(target))
			{
				for(i = 0 ; i<OptionsList.length ; i++)
				{
					if(OptionsList[i].name == target.name)
					{
						var newItem:StageItem = new StageItem(target,OptionsList[i]);
						Items.push(newItem);
						newItem.addEventListener(Event.REMOVED_FROM_STAGE,deleteItem);
					}
				}
			}
		}
		
		protected static function deleteItem(ev:Event):void
		{
			
			StageItem.remove(ev.currentTarget as StageItem);
			var I:int = Items.indexOf(ev.currentTarget as StageItem);
			if(I!=-1)
			{
				//trace("Something removed");
				Items.splice(I,1);
			}
		}	
		
	////////////////////////Position manager
		private static function ManageAllPositions():void
		{
			for(var i = 0 ; i<Items.length ; i++)
			{
				manageItemPlace(Items[i]);
			}
		}
		
		
	}
}