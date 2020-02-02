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
	import flash.geom.Point;

	public class Anim_jump
	{
		public static var reset_event:String = 'resetAnimaton';
		
		/**pause all animations*/
		public static var pause:Boolean = false;
		
		
		private static const stepsD:Number=15,
							stepHeightD:Number=-15,
							maxRotD:Number=40;
		
		private var steps:Number=stepsD,
			stepHeight:Number=stepHeightD,
			maxRot:Number=maxRotD;
		
		private var myTarget:MovieClip;
		
		private var X,Y;
		
		private var onJumped:Function;
		
		private var rout:Vector.<Point>;
		private var rot:Vector.<Number>;
		
		private var currentI:uint = 0 ;
		private var L:uint ;
		
		public static function setUp(target:MovieClip,newX:Number,newY:Number,OnJumped:Function,stepsParam:Number=stepsD,stepHeightParam:Number=stepHeightD,maxRotParam:Number=maxRotD)
		{
			new Anim_jump(target,newX,newY,OnJumped,stepsParam,stepHeightParam,maxRotParam);
		}
		
		public function Anim_jump(target:MovieClip,newX:Number,newY:Number,OnJumped:Function,stepsParam:Number=stepsD,stepHeightParam:Number=stepHeightD,maxRotParam:Number=maxRotD)
		{
			steps=stepsParam;
			stepHeight=stepHeightParam;
			maxRot=maxRotParam;
			
			
			target.dispatchEvent(new Event(reset_event,false));

			myTarget = target;
			rout = new Vector.<Point>();
			rot = new Vector.<Number>();
			
			X = target.x;
			Y = target.y;
			
			onJumped = OnJumped ;
			
			currentI = 0 ;
			
			var dist:Point = new Point(newX-target.x,newY-target.y);
			L = Math.ceil((dist.length/steps));
			
			var dx = (newX-X)/L ;
			var dy = (newY-Y)/L ;
			
			var rotat:Number = maxRot*Math.min(Math.pow(dx/10,4)+Math.pow(dy/10,4),1)
			
			var direction=1;
			if(dx<0)
			{
				direction=-1;
			}
			
			var high:Number = stepHeight*(L/2)
			
			for(var i = 0 ; i<L ; i++)
			{
				var sin:Number = Math.sin((i/L)*3.141);
				var sin2:Number = Math.sin((i/L)*6.282);
				rout[i] = new Point(X+dx*i,Y+dy*i+sin*high);
				rot[i] = sin2*rotat*direction;
			}
			rout[i] = new Point(newX,newY);
			rot[i] = 0;
			
			target.addEventListener(Event.ENTER_FRAME,anim);
			target.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			target.addEventListener(reset_event,unLoad);
		}
		
		private function anim(e)
		{
			if(pause)
			{
				return ;
			}
			
			var targ:MovieClip = e.target ;
			targ.x = rout[currentI].x;
			targ.y = rout[currentI].y;
			targ.rotation = rot[currentI];
			currentI++;
			if(currentI>L)
			{
				unLoad(e);
			}
		}
		
		private function unLoad(e)
		{
			onJumped();
			onJumped = new Function();
			e.target.removeEventListener(Event.ENTER_FRAME,anim);
			e.target.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			e.target.removeEventListener(reset_event,unLoad);
		}
	}
}