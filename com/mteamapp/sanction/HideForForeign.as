package com.mteamapp.sanction
	//com.mteamapp.sanction.HideForForeign
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