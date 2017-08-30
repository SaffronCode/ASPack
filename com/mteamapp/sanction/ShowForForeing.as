package com.mteamapp.sanction
{
	import flash.display.MovieClip;
	
	public class ShowForForeing extends MovieClip
	{
		public function ShowForForeing()
		{
			super();
			this.visible = SanctionControl.isForeign() ;
		}
	}
}