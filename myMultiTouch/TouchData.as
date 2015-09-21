// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package myMultiTouch
{
	import flash.display.MovieClip;

	public class TouchData
	{
		/**touch ID*/
		public var ID:int;
		
		/**touch positions */
		public var x,y;
		
		/**can you update it?*/
		public var updatePermition:Boolean;
		
		public var debugTarget:MovieClip;
		
		public function TouchData(id:int,X:Number,Y:Number,DebugTarget:MovieClip=null)
		{
			ID = id ;
			x = X ;
			y = Y ;
			debugTarget = DebugTarget ;
		}
	}
}