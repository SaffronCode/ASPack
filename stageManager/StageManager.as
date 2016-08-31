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
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	public class StageManager
	{
		/**Resize event dispatches on this value*/
		public static var eventDispatcher:StageEventDispatcher = new StageEventDispatcher();
		
		/**Main stage object*/
		private static var 	myStage:Stage,
							myRoot:DisplayObject;
							//debugTF:TextField ;
							
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
		public static function setUp(yourStage:Stage,debugWidth:Number = 0 ,debugHeight:Number=0,listenToStageRotation:Boolean=true,activateResolutionControll:Boolean = false ,yourRoot:DisplayObject=null)
		{
			myStage = yourStage ;
			myRoot = yourRoot ;
			OptionsList = new Vector.<StageOption>();
			Items = new Vector.<StageItem>();
			resolutionControll = activateResolutionControll ;
			
			
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
			controllStageSizes();
			
			myStage.addEventListener(Event.ADDED,controllFromMe,false,1);
			//myStage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE,controllStageSizesOnFullScreen);
			//NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,controllStageSizesOnFullScreen);
			setTimeout(controllStageSizesOnFullScreen,0);
		}
		
		private static function controllStageSizesOnFullScreen(e:*=null):void
		{
			lastStageFW = NaN ;
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE,controllStageSizesOnFullScreen);
			controllStageSizes(null);
		}
		
		public static function deactiveRotationListening():void
		{
			myStage.removeEventListener(Event.ENTER_FRAME,controllStageSizes);
		}
		
		/**Controll the stage each frame*/
		protected static function controllStageSizes(event:Event=null):void
		{
			// TODO Auto-generated method stub
			//trace("Controll stage");
			if((lastStageFW!=myStage.fullScreenWidth || lastStageFH != myStage.fullScreenHeight) )
			{
				eventDispatcher.dispatchEvent(new StageManagerEvent(StageManagerEvent.STAGE_RESIZING,new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2,stageWidth,stageHeight)));
				lastStageFW = myStage.fullScreenWidth ;
				lastStageFH = myStage.fullScreenHeight ;
				
				var stageWidth:Number;
				var stageHeight:Number;
				
				if(!DevicePrefrence.isFullScreen())
				{
					myStage.scaleMode = StageScaleMode.NO_SCALE ;
					stageWidth = myStage.stageWidth ;
					stageHeight = myStage.stageHeight ;
					myStage.scaleMode = StageScaleMode.SHOW_ALL ;
				}
				else
				{
					stageWidth = lastStageFW ;
					stageHeight = lastStageFH ;
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
				
				if(debugW!=0 && debugH!=0)
				{
					controlStageProperties(debugW,debugH);
				}
				else
				{
					controlStageProperties(stageWidth,stageHeight);
				}
				ManageAllPositions();
				//trace("All managed");
				eventDispatcher.dispatchEvent(new StageManagerEvent(StageManagerEvent.STAGE_RESIZED,new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2,stageWidth,stageHeight)));
			}
		}		
		
		/**Stage status is new*/
		protected static function controlStageProperties(fullScreenWidth:Number,fullScreenHeight:Number):void
		{
			var scaleX:Number = fullScreenWidth/stageWidth0 ;
			var scaleY:Number = fullScreenHeight/stageHeight0 ;
			
			//trace("fullScreenWidth/stageWidth0 : "+fullScreenWidth+'/'+stageWidth0)
			//trace("fullScreenHeight/stageHeight0 : "+fullScreenHeight+'/'+stageHeight0)
			//trace("scaleX : "+scaleX);
			//trace("scaleY : "+scaleY);
			
			var scl:Number ;
			
			
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
		}
		
	//////////////////////////////////////////////Place manager
		
		private static function manageItemPlace(item:StageItem):void
		{
			item.resetPose(deltaStageWidth,deltaStageHeight,stageScaleWidth,stageScaleHeight);
		}
		
		
	////////////////////////////////////////////////////
		
		private static var controlleLocked:Boolean = false ;
		
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
			// TODO Auto-generated method stub
			//detectItemsIn(ev.target as DisplayObjectContainer);
			if(ev.target is MovieClip)
			{
				//trace("ev.target : "+ev.target);
				controllOptionForThis(ev.target as DisplayObjectContainer);
				//trace("Founded items are2 : "+Items.length);
				ManageAllPositions();
			}
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
			// TODO Auto-generated method stub
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