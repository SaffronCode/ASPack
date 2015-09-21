// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package mteam.animation
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class Waving_Object extends MovieClip
	{
		var filter:DisplacementMapFilter ;
		var matr:Matrix ;
		
		private var wave:BitmapData ;
		
		private var MainImage:Bitmap;
		
		var offset:Array;
		
		private var myImage:MovieClip;
		
		public function Waving_Object()
		{
			super();
			
			var pt1:Point = new Point(0,0);
			
			var pt2:Point = new Point(0,0);
			
			offset = [pt1];
			
			filter = new DisplacementMapFilter(wave, new Point(0,0), 1, 1, 50, 50 ,'clamp');
			
			this.addEventListener(Event.ENTER_FRAME,anim);
			
			myImage = Obj.get('myImage_mc',this);
			wave = new BitmapData(myImage.width,myImage.height,false);
			
			var bitData:BitmapData = new BitmapData(myImage.width,myImage.height,true,0x00000000);
			bitData.draw(myImage,null,null,null,null,true);
			MainImage = new Bitmap(bitData,'auto',true);
			
			this.addChild(MainImage);
			
			manageFilter();
		}
		
		/**managing the filter postition*/
		private function manageFilter()
		{
			offset[0].x+=5;
			
			wave.perlinNoise( 500, 500, 1, 50, true, false, 7, true, offset );
			
		//	filter = new DisplacementMapFilter(wave, new Point(0,0), 1, 1, 50, 50 ,'clamp');
			filter.mapBitmap = wave;
			MainImage.filters = [filter];
			/*this.removeChild(MainImage);
			MainImage = new Bitmap(wave);
			this.addChild(MainImage);*/
		}
		
		
		/**animate the waves */
		private function anim(e)
		{
			manageFilter();
		}
	}
}