// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.printing.PrintJob;
	
	public class MEPrint
	{
		private static var resolution:uint = 2 ;
		/**you can name objects or just objects names that you need to remove befor print procces started<br>
		 * leave the list of objects or target that you need to be visible on printed page<br>
		 * set print mode from class MEPrintMode<br>
		 * <br>
		 * returns boolean that shows if the capture or print was sucssefull or not*/
		public static function start(myStage:Stage,mePrintMode:uint=1,removeTheseObjects:Array=null,removeTheseNames:Array=null
									 ,showTheseObjects:Array=null,showTheseNames:Array=null):Boolean
		{
			var printStarted:Boolean ;
			var captured:Boolean = false;
			
			var listOfObjects:Array = new Array();
			var listOfObjectsVisibelity:Array = new Array();
			
			var listOfWaterMarks:Array = new Array();
			var listOfWaterMarksVisibelity:Array = new Array();
			var i:int;
			//to hide list
				try{
					for(i =0 ; i < removeTheseNames.length ; i++)
					{
						listOfObjects = listOfObjects.concat(find(removeTheseNames[i],myStage));
					}
				}catch(e){};
				
				try{
					listOfObjects = listOfObjects.concat(removeTheseObjects);
					trace('removed objects added'+removeTheseObjects.length);
				}catch(e){};
				
				trace('DisplayObject : '+listOfObjects.length);
			//to hide list ended
					
			//to show list
				try{
					for(i=0 ; i < removeTheseNames.length ; i++)
					{
						listOfWaterMarks = listOfWaterMarks.concat(find(showTheseNames[i],myStage));
					}
				}catch(e){};
				
				try{
					listOfWaterMarks = listOfWaterMarks.concat(showTheseObjects);
				}catch(e){};
			//to show list ended
			
				
				
				//invisible all useless objects
				for(i=0 ; i<listOfObjects.length ; i++)
				{
					listOfObjectsVisibelity[i] = DisplayObject(listOfObjects[i]).visible ;
					DisplayObject(listOfObjects[i]).visible = false ;
				}
				//visible all useless objects
				for(i=0 ; i<listOfWaterMarks.length ; i++)
				{
					listOfWaterMarksVisibelity[i] = DisplayObject(listOfWaterMarks[i]).visible ;
					DisplayObject(listOfWaterMarks[i]).visible = true ;
				}
				
				
			//print all page with 1024 * 768 size
			var bd:BitmapData = new BitmapData(myStage.stageWidth*resolution,myStage.stageHeight*resolution,false,0xffffff);
			bd.draw(myStage,new Matrix(resolution,0,0,resolution));
			var bm:Bitmap = new Bitmap(bd,"auto",true);
			var page:Sprite = new Sprite();
			page.addChild(bm);
			//myStage.addChild(page);
			
			
			
			var printJ:PrintJob = new PrintJob();
			printJ.jobName = "SJEC";
			
			if(mePrintMode!=MEPrintMode.capture)
			{
				try{
					printStarted = printJ.start();
				}
				catch(e)
				{
					printStarted = false;
				}
			}
			else
			{
				printStarted = false;
			}
			
			
			
			
			
			if(printStarted)
			{
				page.graphics.lineStyle(1,0);
				page.graphics.beginFill(0xffffff);
				page.graphics.lineTo(printJ.paperWidth,0);
				page.graphics.lineTo(printJ.paperWidth,printJ.paperHeight);
				page.graphics.lineTo(0,printJ.paperHeight);
				
				if(printJ.orientation == "portrait")
				{
					
					bm.rotation = 90 ;
					
					bm.width = printJ.paperWidth ;
					bm.height = printJ.paperHeight ;
					
					bm.scaleX = bm.scaleY = Math.min(bm.scaleX,bm.scaleY);
					
					//if bitmap rotate , the real with and height will be switch
					bm.x = (printJ.paperWidth-bm.width)/2+bm.width ;
					bm.y = (printJ.paperHeight-bm.height)/2 ;
					//trace('♣ printJ.paperHeight:'+printJ.paperHeight+' , '+printJ.paperWidth+' - '+bm.width+","+bm.height);
					
					try{
						printJ.addPage( page );
					}
					catch(e)
					{
						printStarted= false;
					}
				}
				else //if(printJ.orientation == "landscape")
				{
					bm.width = printJ.paperWidth ;
					bm.height = printJ.paperHeight ;
					
					bm.scaleX = bm.scaleY = Math.min(bm.scaleX,bm.scaleY);
					bm.x = (printJ.paperWidth-bm.width)/2;
					bm.y = (printJ.paperHeight-bm.height)/2;
					
					try{
						printJ.addPage( page );
					}
					catch(e)
					{
						printStarted= false;
					}
				}
				
				printJ.send();
			}
			
			if(!printStarted && mePrintMode!=MEPrintMode.print)
			{
				trace('print not started');
				//save bitmap data on gallery
				
				if(CameraRoll.supportsAddBitmapData)
				{
					var cameraRoll:CameraRoll = new CameraRoll();
					cameraRoll.addBitmapData(bd);
					captured = true ;
				}
			}
			
			
			
			//return every thing to preveuse situation
			for(i=0 ; i<listOfObjects.length ; i++)
			{
				DisplayObject(listOfObjects[i]).visible = listOfObjectsVisibelity[i] ;
			}
			
			for(i=0 ; i<listOfWaterMarks.length ; i++)
			{
				DisplayObject(listOfWaterMarks[i]).visible = listOfWaterMarksVisibelity[i] ;
			}
			
			if(printStarted || captured)
			{
				return true ;
			}
			else
			{
				return false;
			}
		}
		
		private static function find(targetName:String,searchIn:DisplayObjectContainer):Array
		{
			var myList:Array = new Array();
			for(var i=0 ; i<searchIn.numChildren ; i++)
			{
				var targ:* = searchIn.getChildAt(i);
				if(targ.name == targetName)
				{
					myList.push(targ);
				}
				if(targ is DisplayObjectContainer)
				{
					myList = myList.concat(find(targetName,targ));
				}
			}
			return myList ;
		}
	}
}