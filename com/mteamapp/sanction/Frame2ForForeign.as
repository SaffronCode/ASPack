package com.mteamapp.sanction
	//com.mteamapp.sanction.Frame2ForForeign
{
	import flash.display.MovieClip;
	
	public class Frame2ForForeign extends MovieClip
	{
		public function Frame2ForForeign()
		{
			super();
			if(SanctionControl.isForeign())
			{
				this.gotoAndStop(2);
			}
			else
			{
				this.gotoAndStop(1);
			}
		}
	}
}