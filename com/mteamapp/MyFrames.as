// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package com.mteamapp
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;

	public class MyFrames
	{
		/**get the frame number of thi lable from selected movieClip<br>
		 * if the class returns 0 , it means the frame with this lable is not detected*/
		public static function getFrameOf(frameLable:String,target:MovieClip):uint
		{
			var arr = target.currentLabels;
			for each(var i in arr){
				if(FrameLabel(i).name == frameLable){
					return FrameLabel(i).frame ;
				}
			}
			return 0 ;
		}
	}
}