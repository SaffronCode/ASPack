// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/**version log
 * version 1.2 : 92-3-1 : you can defing custom fade speed on each objects*/

package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**کلاس انیمیشن ها\r
	 * fadeIn : ظاهر کردن موی کلیپ\r
	 * fadeOut : محو کردن موی کلیپ*/
	public class AnimData
	{
		public static var alphaV=0.05;
		
		private static var functions:Vector.<Function>,
							targets:Vector.<MovieClip>,
							fadeSpeed:Vector.<Number>;
							
							
							
							
		private static function initialize()
		{
			if(functions == null)
			{
				functions = new Vector.<Function>();
				targets = new Vector.<MovieClip>();
				fadeSpeed = new Vector.<Number>();
			}
		}
		
		public static function cansel(target:MovieClip)
		{
			deleteDataAbout(target);
		}
		
		public static function deleteDataAbout(target:MovieClip)
		{
			initialize();
			var I:int = targets.indexOf(target);
			if(I!=-1)
			{
				targets[I].removeEventListener(Event.ENTER_FRAME,anim);
				targets[I].removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
				targets.splice(I,1);
				functions.splice(I,1);
				fadeSpeed.splice(I,1);
			}
		}
		
		/**ظاهر کردن موی کلیپ با انیمیشن*/
		public static function fadeIn(Target:MovieClip,afterFunc:Function=null,fadeTime:Number=0)
		{
			if(fadeTime == 0)
			{
				fadeTime = alphaV ;
			}
			fadeTime = Math.abs(fadeTime);
			act(Target,afterFunc,fadeTime);
		}
		
		/**مجو کردن موی کلیپ*/
		public static function fadeOut(Target:MovieClip,afterFunc:Function=null,fadeTime:Number=0)
		{
			if(fadeTime == 0)
			{
				fadeTime = alphaV ;
			}
			fadeTime = Math.abs(fadeTime)*-1;
			act(Target,afterFunc,fadeTime);
		}
		
		
		private static function act(Target:MovieClip,afterFunc:Function,fadeTime:Number)
		{
			initialize();
			deleteDataAbout(Target);
			
			targets.push(Target);
			functions.push(afterFunc);
			fadeSpeed.push(fadeTime);
			
			Target.addEventListener(Event.ENTER_FRAME,anim);
			Target.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		protected static function anim(ev:Event):void
		{
			// TODO Auto-generated method stub
			var targ:MovieClip = ev.target as MovieClip ;
			var I:int = targets.indexOf(targ);
			
			var mySpeed:Number = fadeSpeed[I] ;
			
			targ.alpha += mySpeed ;
			if(mySpeed>0 && targ.alpha>=1)
			{
				done(targ,functions[I],1);
			}
			else if(mySpeed<0 && targ.alpha<=0)
			{
				done(targ,functions[I],0);
			}
		}
		
		/**finish it*/
		private static function done(targ:MovieClip,func:Function,alpha:Number)
		{
			targ.alpha = alpha ;
			deleteDataAbout(targ);
			if(func != null)
			{
				func();
			}
		}
		
		protected static function unLoad(ev:Event):void
		{
			// TODO Auto-generated method stub
			deleteDataAbout(ev.target as MovieClip);
		}		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
/////////////////////////////////////////////////////////////////
		
		/**rewind the target till it get to its first position*/
		public static function rewind(target:MovieClip)
		{
			target.removeEventListener(Event.ENTER_FRAME,forwFunc);
			target.removeEventListener(Event.ENTER_FRAME,rewFunc);
			target.addEventListener(Event.ENTER_FRAME,rewFunc);
		}
		
			/**rewind the curren item til it gets to its first frame */
			private static function rewFunc(e:Event)
			{
				var targ:MovieClip = MovieClip(e.currentTarget);
				targ.prevFrame();
				if(targ.currentFrame == 1)
				{
					targ.removeEventListener(Event.ENTER_FRAME,rewFunc);
				}
			}
		
		/**forwarding the target til it gets to its last frame*/
		public static function forward(target:MovieClip)
		{
			target.removeEventListener(Event.ENTER_FRAME,rewFunc);
			target.removeEventListener(Event.ENTER_FRAME,forwFunc);
			target.addEventListener(Event.ENTER_FRAME,forwFunc);
		}
		
			/**forwarding the target*/
			private static function forwFunc(e:Event)
			{
				var targ:MovieClip = MovieClip(e.currentTarget);
				targ.nextFrame();
				if( targ.curentFrame == targ.totalFrames )
				{
					targ.removeEventListener(Event.ENTER_FRAME,forwFunc);
				}
			}
	}
}