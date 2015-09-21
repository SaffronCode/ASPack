// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package mteam.animation
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Floating_Object extends MovieClip
	{
		private var child:Vector.<MovieClip>,
					X0:Vector.<Number>,
					Y0:Vector.<Number>,
					
					Vx:Number=0,
					Vy:Number=0,
					
					Xn:Number=0,
					Yn:Number=0,
					
					Xp:Number=0,
					Yp:Number=0,
					
					F:Number=200,
					Mu:Number=0.6,
					DMove:Number=10;
		
		public function Floating_Object()
		{
			super();
			
			child = new Vector.<MovieClip>();
			X0 = new Vector.<Number>();
			Y0 = new Vector.<Number>();
			
			for(var i=0;i<this.numChildren;i++)
			{
				var targ:MovieClip ;
				if(this.getChildAt(i) is MovieClip)
				{
					targ = MovieClip(this.getChildAt(i));
					child.push(targ);
					X0.push(targ.x);
					Y0.push(targ.y);
				}
			}
			
			this.addEventListener(Event.ENTER_FRAME,anim);
		}
		
		
		private function anim(e){
			
			if(Math.floor(Math.random()*10)==0)
			{
				Xp = Math.random()*DMove-DMove/2;
			}
			if(Math.floor(Math.random()*10)==0)
			{
				Yp = Math.random()*DMove-DMove/2;
			}
			
			Vx+=(Xp-Xn)/F;
			Vy+=(Yp-Yn)/F;
			
			Vx = manageLenghth(Vx);
			Vy = manageLenghth(Vy);
			
			Xn+=Vx;
			Yn+=Vy;
			
			
			for(var i=0;i<child.length;i++)
			{
				child[i].x = X0[i]+Xn/(i+2);
				child[i].y = Y0[i]+Yn/(i+2);
			}
		}
		
		/**dont let Number Increase or decreas from max and min*/
		private function manageLenghth(num:Number,min:Number=-2,max:Number=2):Number
		{
			if(num>max)
			{
				return max;
			}
			if(num<min)
			{
				return min ;
			}
			return num ;
		}
	}
}