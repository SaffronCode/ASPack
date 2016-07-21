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
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	

	public class BitmapEffects
	{
		
		public static var backGroundColor:uint = 0x00000000 ;
		
		
		public static function setGrayScale( obj:BitmapData ) : BitmapData
		{
			var rLum : Number = 0.2225;
			var gLum : Number = 0.7169;
			var bLum : Number = 0.0606;
			
			var matrix:Array = [ rLum, gLum, bLum, 0, 0,
				rLum, gLum, bLum, 0, 0,
				rLum, gLum, bLum, 0, 0,
				0, 0, 0, 1, 0 ];
			
			var filter:ColorMatrixFilter = new ColorMatrixFilter( matrix );
			obj.applyFilter( obj, new Rectangle( 0,0,obj.width,obj.height ), new Point(0,0), filter );
			
			return obj;
		}
		
		
		
		
		
	//Imgage processing
		public static function changeSize(bitmapData:BitmapData,newWidth:Number,newHeight:Number,keepRatio:Boolean=true,keepAllImageInFrame:Boolean=false,changePhotoDymention:Boolean=true):flash.display.BitmapData
		{
			// TODO Auto Generated method stub
			var imageW:Number = bitmapData.width;
			var imageH:Number = bitmapData.height;
			
			var scaleX:Number = newWidth/imageW ;
			var scaleY:Number = newHeight/imageH ;
			
			var dx:Number = 0 ;
			var dy:Number = 0 ;
			
			if(keepRatio)
			{
				if(keepAllImageInFrame)
				{
					scaleX = scaleY = Math.min(scaleX,scaleY);
				}
				else
				{
					scaleX = scaleY = Math.max(scaleX,scaleY);
				}
				
				imageH = scaleX*imageH ;
				imageW = scaleY*imageW ;
				
				dx = (newWidth-imageW)/2;
				dy = (newHeight-imageH)/2;
			}
			var newBitmapData:BitmapData;
			if(changePhotoDymention)
			{
				newBitmapData = new BitmapData(newWidth,newHeight,true,backGroundColor);
				newBitmapData.draw(bitmapData,new Matrix(scaleX,0,0,scaleY,dx,dy),null,null,null,true);
			}
			else
			{
				trace("Change image size to : "+scaleX);
				newBitmapData = new BitmapData(bitmapData.width*scaleX,bitmapData.height*scaleY,true,backGroundColor);
				newBitmapData.draw(bitmapData,new Matrix(scaleX,0,0,scaleY,0,0),null,null,null,true);
			}
			return newBitmapData;
		}
		
		
		
		public static function createJPG(bitmapData:BitmapData,quality:Number = 100 ):ByteArray
		{
			var jpeg:JPEGEncoderOptions = new JPEGEncoderOptions(quality);
			return bitmapData.encode(bitmapData.rect,jpeg) ;
		}
		
		
		public static function createPNG(bitmapData:BitmapData):ByteArray
		{
			var png:PNGEncoderOptions = new PNGEncoderOptions(true);
			return bitmapData.encode(bitmapData.rect,png);
		}
		
		/**This function will rotate current bitmap to 90 degrees*/
		public static function rotateBitmapData(bitmapData:BitmapData,rad:Number=90):BitmapData
		{
			// TODO Auto Generated method stub
			var r:Number = rad/180*Math.PI;
			/*var W:Number = Math.abs(bitmapData.width*Math.cos(r)+bitmapData.height*Math.sin(r));
			var H:Number = Math.abs(bitmapData.height*Math.cos(r)+bitmapData.width*Math.sin(r));*/
			
			var sin:Number = Math.sin(r) ;
			var cos:Number = Math.cos(r) ;
			
			var W:Number = Math.abs(bitmapData.width*cos)+Math.abs(bitmapData.height*sin);
			var H:Number = Math.abs(bitmapData.width*sin)+Math.abs(bitmapData.height*cos);
			
			var rotatedBitmap:BitmapData = new BitmapData(W,H,bitmapData.transparent,0x00ffffff);
			var matrix:Matrix = new Matrix(1,0,0,1,0);
			matrix.rotate(r);
			
			if(sin>0)
			{
				matrix.tx = sin*bitmapData.height;
			}
			else
			{
				matrix.ty = Math.abs(sin*bitmapData.width) ;
			}
			if(cos<0)
			{
				matrix.ty += Math.abs(cos*bitmapData.height);
				matrix.tx += Math.abs(cos*bitmapData.width);
			}
			
			//matrix.rotate(rad);
			rotatedBitmap.draw(bitmapData,matrix,null,null,null,true);
			return rotatedBitmap ;
		}
		public static function createBase64(bitmapData:BitmapData,quality:int=100):String
		{

			var jpg:JPEGEncoderOptions = new JPEGEncoderOptions(quality);	
			bitmapData.encode(bitmapData.rect,jpg)
			var toBase46Encoder:Base64Encoder = new Base64Encoder()
			toBase46Encoder.encodeBytes(bitmapData.encode(bitmapData.rect,jpg));				
			return toBase46Encoder.toString().split('\n').join('')				
		}
		
	}
}