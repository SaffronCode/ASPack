// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/**version log
 * 1.1 : 93-3-21 : detectSizes on any fullManage function removed to prevent ignoring the debug with and heigh manging
 * 1.2 : 93-7-19 : From now , you can tell if you neads to refence sizes on X or Y
 * 1.3 : 93-9-6  : Absolut positioning with ClipToTop & ClipToButtom added to managePlace function
 * 1.3.1 : 	93-11-21 : Absolute positions extends. From now if you pass 0, it will clip your object to the center of the page insteadof Top or Left.
 */

package myAsCSS {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;

	/**مرتب کردن آبجکت های صفحه بر اساس رزولوشن
	 * be soorate pish farz faghat jaaye object raa taghir midahad
	 * be soorate ezafe , mishe begim ke sizesham nesbat be size e safhe escale kone*/
	public class MyAsCSS {
		private static var myStage:Stage ;
		private static var 	sXm,sYm,
							SW,SH,FW,FH,
							targets:Vector.<String>,
							sizeRefence:Vector.<Boolean>,
							sizeRefenceX:Vector.<Boolean>,
							sizeRefenceY:Vector.<Boolean>,
							
							clipTop:Vector.<Number>,
							clipLeft:Vector.<Number>,
							
							positionRefrence:Vector.<Boolean>,
							editedTargets:Vector.<Sprite>,
							
							maxHS:Number,
							maxWS:Number;
							
		/**absolute size of new stage*/
		public static var stageWidth:Number,stageHeight:Number;
		
		/**scale of each x and y direction of stage*/
		public static var stageScaleX:Number,stageScaleY:Number;
		
		
		private static var ratioX:Number;
		private static var ratioY:Number;
		
		/**return the original stage size */
		public static function get stageOrgWidth():Number
		{
			return SW ;
		}
		
		/**return the original stage size */
		public static function get stageOrgHeight():Number
		{
			return SH ;
		}
		
		/**تنظیم و شروع نرم افزار
		 * می توان طول و عرض دیباگ را وارد کرد<br>
		 * Isn't rationX and Y just same as debugWidth and debugHeight??*/
		public static function beginCSSWorks(myStage_v:Stage,maxWidthSupport:Number=-1,maxHeightSupport:Number=-1,debugWidth:Number=-1,debugHeight:Number=-1,myRationX:Number=-1,myRationY:Number=-1){
			
			//trace("version : 1.3");
			maxHS = maxHeightSupport ;
			maxWS = maxWidthSupport ;
			
			myStage = myStage_v ;
			
			if(myRationX!=-1)
			{
				ratioX = myRationX ;
			}
			else
			{
				ratioX = myStage_v.fullScreenWidth ;
			}
			
			if(myRationY!=-1)
			{
				ratioY = myRationY ;
			}
			else
			{
				ratioY = myStage_v.fullScreenHeight ;
			}
			
			//var tex:TextField = new TextField();
			//myStage.addChild(tex);
			myStage.scaleMode = StageScaleMode.SHOW_ALL ;
			
			detectSizes(debugWidth,debugHeight);
			
			targets = new Vector.<String> ;
			sizeRefence = new Vector.<Boolean>();
			sizeRefenceX = new Vector.<Boolean>();
			sizeRefenceY = new Vector.<Boolean>();
			
			clipTop = new Vector.<Number>();
			clipLeft = new Vector.<Number>();
			
			positionRefrence = new Vector.<Boolean>();
			editedTargets = new Vector.<Sprite>();
			
			myStage.addEventListener(Event.ADDED,someThingAdded);
			myStage.addEventListener(Event.REMOVED,someThingRemoved);
			
		}
		
		/**detect resolution size*/
		private static function detectSizes(debugWidth:Number=-1,debugHeight:Number=-1)
		{
			
				var temFullScreenWidth,temFullScreenHeight;
				
				if(debugWidth!=-1){
					temFullScreenWidth = debugWidth ;
				}else{
					temFullScreenWidth = ratioX ;
				}
				
				if(debugHeight!=-1){
					temFullScreenHeight = debugHeight ;
				}else{
					temFullScreenHeight = ratioY ;
				}
				
				
				var scaleX = temFullScreenWidth/myStage.stageWidth;
				var scaleY = temFullScreenHeight/myStage.stageHeight;
				
				var scl = Math.min(scaleX,scaleY);
				
				FW = Math.round(temFullScreenWidth/scl);
				FH = Math.round(temFullScreenHeight/scl);
				
				if(maxWS!=-1){
					FW = Math.min(Math.max(maxWS,myStage.stageWidth),FW);
				}
				if(maxHS!=-1){
					FH = Math.min(Math.max(maxHS,myStage.stageHeight),FH);
				}
				
				stageWidth = FW;
				stageHeight = FH;
				//trace("stageWidth : "+stageWidth);
				//tex.width = 1000;
				//tex.text = "stageWidth : "+stageWidth+'\nfullScreenWidth'+myStage.fullScreenWidth;
				
				SW = myStage.stageWidth ;
				SH = myStage.stageHeight ;
				
				stageScaleX = FW/SW ;
				stageScaleY = FH/SH ;
				
				sXm = (SW-FW)/2;
				sYm = (SH-FH)/2;
				
				//trace("stageWidth : "+stageWidth);
		}
		
		private static function someThingRemoved(e:*){
			var targ;
			if(e is Event){
				targ = e.target;
			}else{
				targ = e ;
			}
			if(targ is Sprite){
				var loc = editedTargets.indexOf(targ);
				if(loc!=-1){
					editedTargets.splice(loc,1);
				}
				for(var i=0;i<Sprite(targ).numChildren;i++){
					if(Sprite(targ).getChildAt(i) is Sprite){
						someThingRemoved(Sprite(targ).getChildAt(i))
					}
				}
			}
		}
		
		/**search in ful child list*/
		private static function someThingAdded(e:Event){
			var targ = e.target;
			if(targ is Sprite){
				addMyChildes(Sprite(targ));
			}
		}
		
		private static function addMyChildes(Targ:Sprite){
			var myIndex
			if(editedTargets.indexOf(Targ)==-1){
				myIndex = targets.indexOf(Targ.name);
				var i,tempTarg;
				//trace(targets)
				if(myIndex!=-1){
					editedTargets.push(Targ);
					if(positionRefrence[myIndex]){
						var itsParent = Targ.parent;
						
						
						var po:Point ;
						po = Targ.localToGlobal(new Point()) ;
						
						
						if(clipLeft[myIndex] == 1)
						{
							po.x = sXm;
						}
						else if(clipLeft[myIndex] == -1)
						{
							po.x = stageWidth+sXm;
						}
						else if(clipLeft[myIndex] == 0)
						{
							po.x = stageWidth/2+sXm;
						}
						else
						{
							po.x = po.x*stageScaleX+sXm;
						}
						
						if(clipTop[myIndex] == 1)
						{
							po.y = sYm;
						}
						else if(clipTop[myIndex] == -1)
						{
							po.y = stageHeight+sYm;
						}
						else if(clipTop[myIndex] == 0)
						{
							po.y = stageHeight/2+sYm;
						}
						else
						{
							po.y = po.y*stageScaleY+sYm;
						}
						
						var po2:Point = itsParent.globalToLocal(po);
						Targ.x = po2.x;
						Targ.y = po2.y;
					}
					
					//trace(Targ.name+' : '+sizeRefence[myIndex])
					if(sizeRefence[myIndex]){//you whant to resize it to stageWidth
						/*andazeye vaghei , andazeye majazi dar stage = nesbate roshd,
						andazeye majazi , nesbat be scale dar width va height narm afzar = andazeye roshd
						andazeye roshd zabdar nesbate roshd(nesbate andazeye vaghei be andazeye majazi dar stage) = andazeye jadid*/
						var realWidth = Targ.width,
							realHeight = Targ.height ;
						
						var virtualSim:Rectangle = Targ.getBounds(myStage);
						var virtualWidth = virtualSim.width,
							virtualHeight = virtualSim.height ;
						
						var scaleX = realWidth/virtualWidth,//nesbat roshd haa
							scaleY = realHeight/virtualHeight;
						if(sizeRefenceX[myIndex])
						{
							Targ.width = (virtualWidth*stageScaleX)*scaleX;
						}
						if(sizeRefenceY[myIndex])
						{
							Targ.height = (virtualHeight*stageScaleY)*scaleY;
						}
						
						
					}
				}
				
				for(i=0;i<Targ.numChildren;i++){
					tempTarg = Targ.getChildAt(i);
					if(tempTarg is Sprite){
						addMyChildes(Sprite(tempTarg));
					}
				}
			}
		}
		
		/**مشخص کردن نام آبجکتی که بهید نسبت به اندازه ی صفحه تغییر جا و یا تغییر اندازه دهد<br>*
		 * you can clip item to top , down , left or right with out checking its original position . you have to set 1 for true, -1 for false , 0 for not check */
		public static function managePlace(targetName:String,refrencePosition:Boolean=true, refrenceSize:Boolean=false,resizeX:Boolean=true,resizeY:Boolean = true , clipToTop:Number = Infinity ,clipToLeft:Number = Infinity){
			if(myStage==null){
				trace(new Error("First, You Have To Manage <<beginCSSWorks()>> "))
				return
			}
			
			//trace(targetName)
			
			targets.push(targetName);
			sizeRefence.push(refrenceSize);
			sizeRefenceX.push(resizeX);
			sizeRefenceY.push(resizeY);
			
			clipTop.push(clipToTop);
			clipLeft.push(clipToLeft);
			
			positionRefrence.push(refrencePosition);
			
			fullManage()
		}
		
		/**it is not working now , the x and y s are not saved befor first move . so it will over ride second position for init pose.*/
		public static function fullManage(resolutionX:Number=-1,resolutionY:Number=-1){
			/**i remove this line at 93-3-21 , it was caus the app bug*/
			//detectSizes(resolutionX,resolutionY);
			//editedTargets = new Vector.<Sprite>();
				//before objects position not saved , it could not re size edited objects
			for(var i =0 ; i <myStage.numChildren ; i++){
				if(myStage.getChildAt(i) is Sprite){
					addMyChildes(Sprite(myStage.getChildAt(i)));
				}
			}
		}
		
		
		private static function pointRedeucer(po:Point):Point{
			po.x = Math.round(po.x);
			po.y = Math.round(po.y);
			return  po;
		}
		
	}
	
}
