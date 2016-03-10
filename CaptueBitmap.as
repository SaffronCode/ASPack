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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class CaptueBitmap
	{
		
		private static const addedImageName:String = "addedImage_havetoremove_";
		
		
		/**returns lesoluted bitmap Object*/
		public static function capture(target:DisplayObject,resolution:Number = 1):Bitmap
		{
			var bitmapData:BitmapData = new BitmapData(target.width*resolution,target.height*resolution,true,0);
			bitmapData.draw(target,new Matrix(resolution,0,0,resolution),null,null,null,true);
			var bitmap:Bitmap = new Bitmap(bitmapData,'auto',true);
			bitmap.scaleX = bitmap.scaleY = 1/resolution;
			return bitmap;
		}
		
		/**this function will capture target from any where on stage<br>
		 * it is not supports rotation s*/
		public static function capture2(target:DisplayObject,resolution:Number = 1):Bitmap
		{
			var p1:Point = target.localToGlobal(new Point());
			var rect:Rectangle = target.getBounds(target.stage);
			var p2:Point = new Point(rect.x,rect.y);
			var dx:Number = p1.x-p2.x;
			var dy:Number = p1.y-p2.y;
			
			var bitmapData:BitmapData = new BitmapData(target.width*resolution,target.height*resolution,false,0);
			bitmapData.draw(target,new Matrix(resolution,0,0,resolution,dx,dy),null,null,null,true);
			var bitmap:Bitmap = new Bitmap(bitmapData,'auto',true);
			bitmap.scaleX = bitmap.scaleY = 1/resolution;
			var po3:Point = target.parent.globalToLocal(p2)
			bitmap.x = po3.x ;
			bitmap.y = po3.y ;
			return bitmap;
		}
		
		/***/
		public static function capture3(target:DisplayObject,resolution:Number = 1,moreWidth:Number = 0 )
		{
			var rot0:Number = target.rotation ;
			target.rotation = 0 ;
			var p1:Point = target.localToGlobal(new Point());
			var rect:Rectangle = target.getBounds(target.stage);
			var p2:Point = new Point(rect.x,rect.y);
			var dx:Number = (p1.x-p2.x)/target.scaleX;
			var dy:Number = (p1.y-p2.y)/target.scaleY;
			
			var bitmapData:BitmapData = new BitmapData(target.width*resolution/target.scaleX+moreWidth,target.height*resolution/target.scaleY+moreWidth,true,0);
			bitmapData.draw(target,new Matrix(resolution,0,0,resolution,dx,dy),null,null,null,true);
			var bitmap:Bitmap = new Bitmap(bitmapData,'auto',true);
			bitmap.scaleX = bitmap.scaleY = 1/resolution;
			target.rotation = rot0;
			return bitmap;
		}
		
		/**this function will capture image and put it in the parent of the text field . it may splitted to many many images. but 
		 * deleteCapturedBigText() can remove the images of selected text field<br>
		 * Returns the last captured bitmap*/
		public static function captureBigTextFields(CapturableArea:DisplayObject,resolution:Number=1):Bitmap
		{
			var textFieldContainer:DisplayObjectContainer = CapturableArea.parent;
			var cashedMask:DisplayObject = textFieldContainer.mask ;
			textFieldContainer.mask = null ;
			//remvoe old capture images of the textfield Container↓
			deleteCapturedBigText(CapturableArea);
			
			//intialize ↓
			var currentY:Number = 0,
				Y0:Number = CapturableArea.y,
				X0:Number = CapturableArea.x;
			
			var nameIndex:uint = 0;
			
			var textHeight:Number = CapturableArea.height,
				textWidth:Number = CapturableArea.width,
				textName:String = CapturableArea.name ;
			
			var maxHeight:Number = 4000/resolution;
			
			//bitmap variables↓
			
			var bitData:BitmapData,
				bitMap:Bitmap;
			
			do
			{
				nameIndex++ ;
				
				var currentImageHeight:Number = Math.ceil(Math.min(textHeight-currentY,maxHeight)) ;
				
				//trace("Math.min("+textHeight+"-"+currentY+","+maxHeight+") : "+Math.min(textHeight-currentY,maxHeight))
				
				bitData = new BitmapData(textWidth*resolution,currentImageHeight*resolution,true,0);//0x33ff0000
				trace("captured image height : "+bitData.height);
				bitData.draw(textFieldContainer,new Matrix(resolution,0,0,resolution,X0*resolution*-1,currentY*resolution*-1-Y0*resolution));
				bitMap = new Bitmap(bitData);
				bitMap.smoothing = true ;
				bitMap.name = addedImageName+textName+nameIndex;
				
				textFieldContainer.addChild(bitMap);
				bitMap.x = X0 ;
				bitMap.y = Y0+currentY ;
				bitMap.scaleX = bitMap.scaleY = 1/resolution ;
				
				currentY+= bitMap.height;
				
			}while(currentY<textHeight);
			
			textFieldContainer.mask = cashedMask ;
			CapturableArea.visible = false;
			
			return bitMap ;
		}
		
		/**remove all old captured images and restor text fild visible to true*/
		public static function deleteCapturedBigText(displayedObject:DisplayObject)
		{
			var textFieldContainer:DisplayObjectContainer = displayedObject.parent;
			
			//remove old images
			for(var i = textFieldContainer.numChildren-1 ; i>=0 ; i--)
			{
				var currentTarg:DisplayObject = textFieldContainer.getChildAt(i);
				if(currentTarg is Bitmap && currentTarg.name.indexOf(addedImageName+displayedObject.name)!=-1)
				{
					Obj.remove(currentTarg);
				}
			}
			
			displayedObject.visible = true ;
			
		}
	}
}