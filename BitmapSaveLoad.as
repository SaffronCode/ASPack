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
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	public class BitmapSaveLoad
	{
		/**convert bitmap to ByteArray*/
		public static function BitmapToByteArray(bitmap:Bitmap):ByteArray
		{
			
			var byt:ByteArray = new ByteArray();
			var rect:Rectangle = new Rectangle(0,0,bitmap.width,bitmap.height);
			
			byt.writeFloat(bitmap.bitmapData.width);
			byt.writeFloat(bitmap.bitmapData.height);
			byt.writeBoolean(bitmap.bitmapData.transparent);
			
			byt.writeBytes(bitmap.bitmapData.getPixels(rect));
			byt.position = 0 ;
			return byt;
		}
		
		/**convert bitmap data to byte array*/
		public static function BitmapDataToByteArray(bitmapData:BitmapData):ByteArray
		{
			var byt:ByteArray = new ByteArray();
			var rect:Rectangle = new Rectangle(0,0,bitmapData.width,bitmapData.height);
			
			byt.writeFloat(bitmapData.width);
			byt.writeFloat(bitmapData.height);
			byt.writeBoolean(bitmapData.transparent);
			
			byt.writeBytes(bitmapData.getPixels(rect));
			byt.position = 0 ;
			return byt;
		}
		
		/**convert the convertet byte array to bitmap*/
		public static function ByteArrayToBitmap(byte:ByteArray):Bitmap
		{
			try{
				byte.position = 0 ;
			}catch(e){};
			if(byte == null || byte.bytesAvailable<9)
			{
				trace('NO image available!');
				return new Bitmap();
			}
			var W:Number = byte.readFloat();
			var H:Number = byte.readFloat();
			var trans:Boolean = byte.readBoolean();
			
			var rect = new Rectangle(0,0,W,H);
			
			var bitData:BitmapData = new BitmapData(W,H,trans);
			bitData.setPixels(rect,byte);
			var bit:Bitmap = new Bitmap(bitData);
			
			return bit;				
		}
		
		/**convert the convertet byte array to bitmap*/
		public static function ByteArrayToBitmapData(byte:ByteArray,doNotChangePose:Boolean=false):BitmapData
		{
			if(!doNotChangePose)
			{
				try{
					byte.position = 0 ;
				}catch(e){};
			}
			if(byte == null || byte.bytesAvailable<9)
			{
				trace('NO image available!');
				return new BitmapData(1,1,false,0);
			}
			var W:Number = byte.readFloat();
			var H:Number = byte.readFloat();
			var trans:Boolean = byte.readBoolean();
			
			var rect = new Rectangle(0,0,W,H);
			
			trace('founded area : '+rect);
			
			var bitData:BitmapData = new BitmapData(W,H,trans);
			bitData.setPixels(rect,byte);
			
			return bitData;				
		}
	}
}