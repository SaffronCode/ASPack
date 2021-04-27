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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import nativeClasses.distriqtApplication.DistriqtApplication;

	public class StageManager
	{
		/**Resize event dispatches on this value*/
		public static var eventDispatcher:StageEventDispatcher = new StageEventDispatcher();
		
		public static var DebugIPhoneX:Boolean = false ;
		
		/**Main stage object*/
		public static var 	myStage:Stage,
							myRoot:DisplayObject;
							//debugTF:TextField ;
							
		/**Current stage Width and height*/
		private static var 	stageWidth:Number=0,
							stageHeight:Number=0;
		
		/**The page margin that should be to show the time on that area*/
		private static var TopPageMargin:Number;
							
		/**The real size for the stage*/
		private static var	stageWidth0:Number,
							stageHeight0:Number;
							
		private static var debugW:Number,debugH:Number;
		
		private static var deltaStageWidth:Number=0,deltaStageHeight:Number=0,
							stageScaleWidth:Number,stageScaleHeight:Number;
		
		private static var lastStageFW:Number,lastStageFH:Number;
		
		private static var lastStageWidth:Number,lastStageHeight:Number ;

		private static var _lastKeyboardStatus:Number ;
		
		/**Activate resolution controll*/
		private static var resolutionControll:Boolean,
							scaleFactor:Number=1;
							
		/**I store the stage size like this : "1024,768"*/
		private static var lastStageSize:String = '';
		
		/**IPhone jingle margins*/
		private static const margin:Number = 10 ;
		
		/**If this was true, it means that the stage.fullScreen sizes are not correct so the application should controll the stage.stageWidth*/
		private static var haveToCheckStageSize:Boolean = false ;
		
	///
		private static var OptionsList:Vector.<StageOption>,
							Items:Vector.<StageItem>;
							
		private static var listenToStageRotation:Boolean ;

		
							
							
							
		private static var controlleLocked:Boolean = false ;
		
		private static var scl:Number=1;
		/**The iPhoneXJingleBarSize should be bigger tah iPhoneXJingleBarSizeDown!!*/
		private static const 	iPhoneXJingleBarSize:Number = 65,
								iPhoneXJingleBarSizeDown:Number = (iPhoneXJingleBarSize*2)/3,
								iPhoneTopBarSize:Number=40;
		/**iPhoneX masks*/
		private static var 	iPhoneXJingleAreaMask1:Sprite,
							iPhoneXJingleAreaMask2:Sprite;

		/**It will set automativaly*/
		private static var stageUpdateInterval:Number = 0,
							colorUpdateInterval:Number = 0 ;

		private static var enterFramer:MovieClip = new MovieClip();
		
		private static var needToControllStagePosition:Boolean = true ;
		private static var lastTopColor:uint;
		private static var lastBottomColor:uint;

		public static var showJingleBarOnApp:Boolean = false;

		public static var _isIphoneX:Boolean = false;

		/**It will create base on the iPhone type */
		private static var _iphoneTopSize:Number = 0 ;

		private static var targetColor:uint,currentColor:int=-1,lastChangedColor:uint;

		public static var defaultTopColorArea:Number=15;

				
							
		 public static function isIphoneX():Boolean
		{
			return _isIphoneX ;
		} 

		private static var _staticTopColor:int = -1 ;

		/**Pass -1 for dynamic color */
		public static function setStaticTopColor(color:int=-1):void
		{
			_staticTopColor = color ;
		}
		
		/**Stop controlling stage size*/
		public static function StopControllStageSize(status:Boolean=true):void
		{
			trace("Stop controlling stage size");
			needToControllStagePosition = !status ;
		}
		
		/**Height*/
		public static function iPhoneXExtra():Number
		{
			if(showJingleBarOnApp)
			{
				return 0;
			}
			if(_isIphoneX)
			{
				return iPhoneXJingleBarSize ;
			}
			else
			{
				return 0 ;
			}
		}

		

				
		/**This will returns stage retangle*/
		public static function get stageRect():Rectangle
		{
			return new Rectangle(0,TopPageMargin,stageWidth,stageHeight);
		}
		
		/**This will returns stage retangle*/
		public static function get stageVisibleArea():Rectangle
		{
			return new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2+TopPageMargin,stageWidth,stageHeight);
		}
		
		/**This will returns stage old Rectangle*/
		public static function get stageOldRect():Rectangle
		{
			return new Rectangle(0,0,stageWidth0,stageHeight0);
		}
		
		/**returns the difrences between original size stage's size and current stage size*/
		public static function get stageDelta():Rectangle
		{
			return new Rectangle(0,TopPageMargin/2,deltaStageWidth,deltaStageHeight);
		}
		
		/**Returns true if the StageManager was seted up*/
		public static function isSatUp():Boolean
		{
			return myStage!=null ;
		}
		
		/**The debug values cannot be smaller than the actual size of the screen. it will never happend.*/
		public static function setUp(yourStage:Stage,debugWidth:Number = 0 ,debugHeight:Number=0,listenToStageRotation:Boolean=false,activateResolutionControll:Boolean = false ,yourRoot:DisplayObject=null):void
		{
			colorUpdateInterval = 5000 ;
			if(DevicePrefrence.isItPC)
			{
				stageUpdateInterval = 30 ;
			}
			else
			{
				stageUpdateInterval = 4000 ;//1000
			}
			myStage = yourStage ;
			myRoot = yourRoot ;
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
			StageManager.listenToStageRotation = listenToStageRotation ;
			controllStageSizes(null,true);
			
			myStage.addEventListener(Event.ADDED,controllFromMe,false,1);
			setTimeout(controlStageIntervalOnFrames,0);
			enterFramer.addEventListener(Event.ENTER_FRAME,controlStageIntervalOnFrames);
		}

		private static var 	lastTimeThatChecked:int = -10000,
							lastTimeThatColorChecked:int = -10000 ;

		private static function controlStageIntervalOnFrames(e:Event=null):void
		{
			var currentTime:int = getTimer();
			if(currentTime-lastTimeThatChecked>stageUpdateInterval || currentTime-lastTimeThatChecked<0)
			{
				setTimeout(controllStageSizesOnFullScreen,0);
				lastTimeThatChecked = currentTime;
			}
			if(currentTime-lastTimeThatColorChecked>colorUpdateInterval || currentTime-lastTimeThatColorChecked<0)
			{
				setTimeout(colorUpdate,0);
				lastTimeThatColorChecked = currentTime;
			}

			if(currentColor!=targetColor
				&& 
				(
					(
						DevicePrefrence.isAndroid() 
						&& 
						DistriqtApplication.isSupported()
					)
					||
					(
						iPhoneXJingleAreaMask1 != null
					)
				)
			)
			{
				var redc:uint = (currentColor&0xff0000)/0x010000;
				var greenc:uint = (currentColor&0xff00)/0x0100;
				var bluec:uint = (currentColor&0xff);

				var redt:uint = (targetColor&0xff0000)/0x010000;
				var greent:uint = (targetColor&0xff00)/0x0100;
				var bluet:uint = (targetColor&0xff);

				redc = makeTwoColorCloseTogather(redc,redt);
				greenc = makeTwoColorCloseTogather(greenc,greent);
				bluec = makeTwoColorCloseTogather(bluec,bluet);


				currentColor =redc*0x010000+greenc*0x0100+bluec;
				
				if(lastChangedColor!=currentColor)
				{
					lastChangedColor = currentColor ;
					if (iPhoneXJingleAreaMask1 != null)
					{
						//var h:uint = iPhoneTopBarSize ;
						iPhoneXJingleAreaMask1.graphics.clear();
						iPhoneXJingleAreaMask1.graphics.beginFill(currentColor,1);
						iPhoneXJingleAreaMask1.graphics.drawRect( -margin, -margin, StageManager.stageWidth + margin * 2, _iphoneTopSize);
					}
					if(DevicePrefrence.isAndroid() && DistriqtApplication.isSupported())
					{
						DistriqtApplication.setStatusBarColor(currentColor);
					}
				}
			}
		}

		private static function makeTwoColorCloseTogather(c1:uint,c2:uint):uint
		{
			if(Math.abs(c2-c1)<=colorChangeSpeed)
			{
				c1 = c2 ;
			}
			else
			{
				c1+=(c2-c1)/10 ;
			}
			return c1;
			//mode 2
			const colorChangeSpeed:uint = 5;
			if(Math.abs(c2-c1)<=colorChangeSpeed)
			{
				c1 = c2 ;
			}
			else if(c1<c2)
			{
				c1=Math.min(0xff,c1+colorChangeSpeed) ;
			}
			else
			{
				c1=Math.max(0,c1-colorChangeSpeed) ;
			}
			return c1 ;
		}
		
		private static function controllStageSizesOnFullScreen(e:*=null):void
		{
			//lastStageFW = NaN ;
			if(!DevicePrefrence.isApplicationActive)
			{
				return ;
			}
			if(listenToStageRotation)
				controllStageSizes()
				
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE,controllStageSizesOnFullScreen);
			controllStageSizes(null,needToControllStagePosition);
		}
		
		public static function deactiveRotationListening():void
		{
			myStage.removeEventListener(Event.ENTER_FRAME,controllStageSizes);
		}
		
		/**Controll the stage each frame*/
		public static function controllStageSizes(event:Event=null,testTheStageSizeTo:Boolean=false,forceToCheckSize:Boolean=false):void
		{
			if(!DevicePrefrence.isApplicationActive)
				return ;
			//trace("testTheStageSizeTo : "+testTheStageSizeTo);
			if(forceToCheckSize || (lastStageFW!=myStage.fullScreenWidth || lastStageFH != myStage.fullScreenHeight) || testTheStageSizeTo)
			{
				var stageWidth:Number;
				var stageHeight:Number;


				var currentKeyboardStatus:Number = myStage.softKeyboardRect.height ;
				var changeTheStageSizeToReCheck:Boolean = (false || (deltaStageHeight==0 && deltaStageWidth==0) || getTimer()<5000) || DevicePrefrence.isItPC || (currentKeyboardStatus!=_lastKeyboardStatus);
				_lastKeyboardStatus = currentKeyboardStatus ;

				
				if(forceToCheckSize || (changeTheStageSizeToReCheck&&(!DevicePrefrence.isFullScreen() || testTheStageSizeTo || haveToCheckStageSize)))
				{
					eventDispatcher.dispatchEvent(new StageManagerEvent(StageManagerEvent.STAGE_RESIZING,new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2,stageWidth,stageHeight)));
					lastStageFW = myStage.fullScreenWidth ;
					lastStageFH = myStage.fullScreenHeight ;
					
					myStage.scaleMode = StageScaleMode.NO_SCALE ;
					stageWidth = myStage.stageWidth ;
					stageHeight = myStage.stageHeight ;
					//trace("♠**  myStage.stageWidth : "+ myStage.stageWidth +' => '+(myStage.stageWidth==0));
					//trace("♣**  myStage.stageHeight : "+ myStage.stageHeight+' => '+(myStage.stageHeight==0));
					
					if((myStage.stageWidth == 0) || (myStage.stageHeight == 0) )
					{
						//trace("•••••• Air problem on myStage.stageHeight!");
						
						myStage.scaleMode = StageScaleMode.SHOW_ALL ;
						
						return ;
					}
					
					myStage.scaleMode = StageScaleMode.SHOW_ALL ;
					
					if(testTheStageSizeTo)
					{
						if(stageWidth != lastStageFW || stageHeight != lastStageFH)
						{
							//trace("The stage.fullScreen size is not trustable");
							haveToCheckStageSize = true ;
						}
					}
				}
				else
				{
					stageWidth = lastStageWidth ;
					stageHeight = lastStageHeight ;
				}
				
				lastStageWidth = stageWidth ;
				lastStageHeight = stageHeight ;
				
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
				
				//trace("All managed");
				var isStageChanged:Boolean = lastStageSize!=(stageWidth+','+stageHeight);
				lastStageSize = stageWidth+','+stageHeight;
				if(isStageChanged)
				{
					ManageAllPositions();
					eventDispatcher.dispatchEvent(new StageManagerEvent(StageManagerEvent.STAGE_RESIZED,new Rectangle(deltaStageWidth/-2,deltaStageHeight/-2,stageWidth,stageHeight)));
				}
			}
		}	

		private static function updateTopColor(newColor:uint):void
		{
			targetColor = newColor ;
		}	

		private static function colorUpdate():void
		{
			var h:Number ;
			//controlStageProperties();
			var cColor:uint ;
			cColor = TopColor(defaultTopColorArea) ;
			if(lastTopColor!=cColor)
			{
				updateTopColor(cColor);
				//trace(cColor.toString(16))
				lastTopColor = cColor ;
			}
			
			if (iPhoneXJingleAreaMask2 != null)
			{
				cColor = BottomColor() ;
				if(lastBottomColor!=cColor)
				{
					h = iPhoneXJingleAreaMask2.height ;
					iPhoneXJingleAreaMask2.graphics.clear();
					iPhoneXJingleAreaMask2.graphics.beginFill(cColor,1);
					iPhoneXJingleAreaMask2.graphics.drawRect( -margin, -2, StageManager.stageWidth + margin * 2, iPhoneXJingleBarSizeDown + margin);
				}
				lastBottomColor = cColor ;
			}
		}
		
		/**Stage status is new*/
		protected static function controlStageProperties(fullScreenWidth:Number=NaN,fullScreenHeight:Number=NaN,resizedForIPhoneXOnce:Boolean=false,topAreaMargin:Number=0):void
		{
			TopPageMargin = topAreaMargin;
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

			if(resizedForIPhoneXOnce == false && (DebugIPhoneX || DevicePrefrence.isIOS()))
			{
					
				//var cashedStageHeight:Number ;
				if(stageWidth/stageHeight>2)
				{
					//trace(" ♣ You have iPhoneX, nice...");
					//trace("It is landscape...not supporting now");
					
					//controlStageProperties(stageWidth-iPhoneXJingleBarSize*2,stageHeight,true);
					_isIphoneX = true;

					
				}
				else if(stageHeight/stageWidth>2)//Its IphoneX I guess...
				{
					//trace(" • You have iPhoneX, nice...");
					//trace("It is portrate");
					_isIphoneX = true;

					if(showJingleBarOnApp==true)
						return;
					
					if(iPhoneXJingleAreaMask1==null)
						iPhoneXJingleAreaMask1 = new Sprite();
					//iPhoneXJingleAreaMask1.graphics.clear();
					//iPhoneXJingleAreaMask1.graphics.beginFill(TopColor(),1);
					//iPhoneXJingleAreaMask1.graphics.drawRect(-margin,-margin,stageWidth+margin*2,iPhoneXJingleBarSize+margin+2);
					_iphoneTopSize = iPhoneXJingleBarSize+margin+2;
					iPhoneXJingleAreaMask1.y = stageVisibleArea.y;
					
					if(iPhoneXJingleAreaMask2==null)
						iPhoneXJingleAreaMask2 = new Sprite();
					//iPhoneXJingleAreaMask2.graphics.clear();
					//iPhoneXJingleAreaMask2.graphics.beginFill(BottomColor(),1);
					//iPhoneXJingleAreaMask2.graphics.drawRect(-margin,-2,stageWidth+margin*2,iPhoneXJingleBarSizeDown+margin);
					iPhoneXJingleAreaMask2.y = stageVisibleArea.bottom-iPhoneXJingleBarSizeDown ;
					
					
					myStage.addChild(iPhoneXJingleAreaMask1);
					myStage.addChild(iPhoneXJingleAreaMask2);
					
					//The iPhoneXJingleBarSize should be bigger tah iPhoneXJingleBarSizeDown!!
					var menuDeltaSizes:Number = iPhoneXJingleBarSize-iPhoneXJingleBarSizeDown ;
					//cashedStageHeight = stageHeight ;
					//var cashedDeltaStageWidth:Number = deltaStageWidth ;
					//var cashedStageScaleWidth:Number = stageScaleWidth ;
					controlStageProperties(stageWidth,stageHeight-iPhoneXJingleBarSize*2+menuDeltaSizes,true,menuDeltaSizes);
					//stageHeight = cashedStageHeight ;
					//deltaStageWidth = cashedDeltaStageWidth ;
					//stageScaleWidth = cashedStageScaleWidth ;
				}
				else if(DebugIPhoneX || deltaStageHeight>iPhoneTopBarSize && !DevicePrefrence.isFullScreen())
				{
					if(showJingleBarOnApp==true)
						return;
					if(iPhoneXJingleAreaMask1==null)
						iPhoneXJingleAreaMask1 = new Sprite();
					/*iPhoneXJingleAreaMask1.graphics.clear();
					iPhoneXJingleAreaMask1.graphics.beginFill(TopColor(iPhoneTopBarSize),1);
					iPhoneXJingleAreaMask1.graphics.drawRect(-margin,-margin,stageWidth+margin*2,iPhoneTopBarSize+margin+2);*/
					_iphoneTopSize = iPhoneTopBarSize+margin+2;
					iPhoneXJingleAreaMask1.y = stageVisibleArea.y;
					
					//cashedStageHeight = stageHeight ;
					//var cashedDeltaStageHeight:Number = deltaStageHeight ;
					//var cashedStageScaleHeight:Number = stageScaleHeight ;
					controlStageProperties(stageWidth,stageHeight-iPhoneTopBarSize,true,iPhoneTopBarSize);
					//stageHeight = cashedStageHeight ;
					//deltaStageHeight = cashedDeltaStageHeight ;
					//stageScaleHeight = cashedStageScaleHeight ;
				}
				else
				{
					if(iPhoneXJingleAreaMask1)
					{
						Obj.remove(iPhoneXJingleAreaMask1) ;
						iPhoneXJingleAreaMask1 = null ;
					}
					if(iPhoneXJingleAreaMask2)
					{
						Obj.remove(iPhoneXJingleAreaMask2) ;
						iPhoneXJingleAreaMask2 = null ;
					}
				}
			}
		}
		
		/**Return the color for the top*/
		private static function TopColor(areaHeight:Number = iPhoneXJingleBarSize/3):uint
		{
			return _staticTopColor!=-1?_staticTopColor:getColorOfPartOfStage(deltaStageWidth/-2,-(deltaStageHeight/2-areaHeight)-(iPhoneXJingleAreaMask1!=null?iPhoneXJingleAreaMask1.height:0),stageWidth,areaHeight) ;
		}
		
		private static function BottomColor():uint
		{
			return getColorOfPartOfStage(deltaStageWidth/-2,stageHeight0+(deltaStageHeight/2-iPhoneXJingleBarSizeDown*2),stageWidth,iPhoneXJingleBarSizeDown) ;
		}
		
		/**Get color of this area*/
		public static function getColorOfPartOfStage(x:Number,y:Number,w:Number,h:Number):uint
		{
			var cappix:uint = 1 ;
			var cappiy:uint = 1 ;
			var captureScaleW:Number = cappix/w ;
			var captureScaleH:Number = cappiy/h ;
			var caputerdBitmap:BitmapData = new BitmapData(cappix,cappiy,false,myStage.color);
			var matrix:Matrix = new Matrix();
			matrix.scale(captureScaleW,captureScaleH);
			matrix.tx = (-x)*captureScaleW;
			matrix.ty = (-y)*captureScaleH;
			try
			{
				caputerdBitmap.draw(myStage,matrix,null,null,new Rectangle(0,0,w,h));
			}
			catch(e:Error)
			{
				trace(e.message+'\n'+e.getStackTrace());
				return 0;
			}
			
			var myColor:uint = caputerdBitmap.getPixel(0,0) ;
			
			var red:uint = myColor&0xff0000;
			var green:uint = myColor&0x00ff00;
			var blue:uint = myColor&0x0000ff;
			
			if(red<0x330000 && green<0x003300 && blue<0x000033)
			{
				myColor = myColor+0x222222 ;
			}
			
			return myColor;
		}
		
	//////////////////////////////////////////////Place manager
		
		private static function manageItemPlace(item:StageItem):void
		{
			item.resetPose(deltaStageWidth,deltaStageHeight,stageScaleWidth,stageScaleHeight,TopPageMargin);
		}
		
		
	////////////////////////////////////////////////////
		
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
		private static function controllAllOptions():void
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
		private static function controllOptionForThis(target:DisplayObject):void
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
			for(var i:Number = 0 ; i<Items.length ; i++)
			{
				manageItemPlace(Items[i]);
			}
		}
		
		
	}
}