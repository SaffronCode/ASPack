package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.alivepdf.display.Display;
	
	public class sync  extends MovieClip
	{
		private const 	mouthName:String = 'm',
						syncerName:String = 's',
						
						cameraName:String = 'cam',
						
						debug:Boolean=false;
						
		private var		mouths:Vector.<MovieClip>,
						syncer:Vector.<MovieClip>,
						
						camera:MovieClip,
						
						stageMoved:Boolean = false;

		public function sync() 
		{
			super();
			stage.addEventListener(Event.ADDED,someThingAdded);
			stage.addEventListener(Event.ENTER_FRAME,anim);
			
			mouths = new Vector.<MovieClip>();
			syncer = new Vector.<MovieClip>();
			addAll(this);
		}

		
		/**add these objects*/
		private function addAll(Disp:*)
		{
			if(Disp is MovieClip)
			{
				MovieClip(Disp).dispatchEvent(new Event(Event.ADDED,true));
			}
			
			if(Disp is DisplayObjectContainer)
			{
				for(var i=0 ; i<Disp.numChildren ; i++)
				{
					addAll(Disp.getChildAt(i));
				}
			}
		}
		
		/**manage mouth s and syncers and camera*/
		private function anim(e=null)
		{
			if(camera!=null)
			{
				root.rotation = camera.rotation*-1 ;
				root.x = 0 ;
				root.y = 0 ;
				root.scaleX = root.scaleY = 1 ;
				
				var W:Number = camera.width,
					H:Number = camera.height;
				
				/*if(camera.rotation!=0)
				{
					var r:Number = camera.rotation/3.14;
					W = Math.abs(Math.sin(r)) * H + Math.abs(Math.cos(r)) * W;
					H = Math.abs(Math.sin(r)) * W + Math.abs(Math.cos(r)) * H;
				}*/
				
				var Xscale = 1024/camera.width;
				var Yscale = 768/camera.height;
				root.scaleX = Xscale ;
				root.scaleY = Yscale ;
				
				var po:Point = camera.localToGlobal(new Point());
				root.x = po.x*-1;
				root.y = po.y*-1;
				
				stageMoved = true ;
			}
			else if(stageMoved)
			{
				root.x = 0 ;
				root.y = 0 ;
				root.scaleX = root.scaleY = 1 ;
				root.rotation = 0 ;
				
				stageMoved = false;
			}
			
			for(var i= 0 ; i<mouths.length ; i++)
			{
				for(var j = 0 ; j<syncer.length ; j++)
				{
					//trace(mouths[i].hitTestObject(syncer[j])+" : "+mouths[i]+' to '+syncer[j]);
					if(mouths[i].hitTestObject(syncer[j]))
					{
						if(!mouths[i].isPlaying)
						{
							mouths[i].play();
						}
					}
					else
					{
						if(mouths[i].isPlaying)
						{
							mouths[i].gotoAndStop(1);
						}
					}
				}
			}
		}
		
		/**check waht is added to stage*/
		private function someThingAdded(e:Event)
		{
			var targ:MovieClip ;
			
			if(String(e.target.name).toLowerCase() == mouthName)
			{
				targ = MovieClip(e.target);
				targ.addEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
				targ.stop();
				mouths.push(targ);
				anim();
			}
			
			if(String(e.target.name).toLowerCase() == syncerName)
			{
				//trace('s added !');
				targ = MovieClip(e.target);
				targ.addEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
				if(!debug)
				{
					targ.visible = false;
				}
				syncer.push(targ);
				anim();
			}
			
			if(String(e.target.name).toLowerCase() == cameraName)
			{
				targ = MovieClip(e.target);
				targ.addEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
				if(!debug)
				{
					targ.visible = false ;
				}
				camera = targ ;
				anim();
			}
		}
		
		/**this object is removed from stage*/
		private function unLoaded(e:Event)
		{
			var targ:MovieClip = MovieClip(e.currentTarget);
			var ind:int = mouths.indexOf(targ);
			if(ind != -1)
			{
				mouths.splice(ind,1);
				return ;
			}
			ind = syncer.indexOf(targ);
			if(ind != -1)
			{
				syncer.splice(ind,1);
				return ;
			}
			
			if(camera == targ)
			{
				camera = null ;
			}
		}

	}
	
}
