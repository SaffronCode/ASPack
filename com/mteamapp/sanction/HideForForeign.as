package com.mteamapp.sanction
{
	import flash.display.MovieClip;
	
	public class HideForForeign extends MovieClip
	{
		public function HideForForeign()
		{
			super();
			this.visible = !SanctionControl.isForeign() ;
		}
	}
}