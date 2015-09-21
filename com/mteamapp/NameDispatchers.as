// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package com.mteamapp
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class NameDispatchers extends MovieClip
	{	
		public function NameDispatchers()
		{
			super();
			
			this.buttonMode = true ;
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.CLICK,itemCliecked);
		}
		
		/**item is selected*/
		private function itemCliecked(e)
		{
			this.dispatchEvent(new Event(this.name,true));
		}
	}
}