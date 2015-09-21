// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package preLoader
{
	import flash.display.AVM1Movie;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**this class starts to load any swf files on the array and afer all loaded , it will send feedback to provider
		that all swfs was loaded once . it is use full for multimedias on cds*/
	public class PreLoad
	{
		private static var loadList:Array,
					finished:Function,
					
					loading:Boolean = false,
						
					determinTime:Boolean=false,
						
					loader:Loader,
					
					totalObjects:int=0,
					
					listOfFailSWFs:Array,
					
					animationTime:Number=0;
							
		/**enter the array list of url targets to load<br>
		 * it had to set every thing silent to prevent loaded object sondunds to play - 
		 * there is no whay to stop loaded swf s sounds but to call SounMixer.stopAllSounds()*/
		public static function preLoadThese(targets:Array,loadComplete:Function)
		{
			animationTime = 0 ;
			
			listOfFailSWFs = new Array();
			SoundMixer.soundTransform = new SoundTransform(0);
			if(loadList == null)
			{
				loadList = new Array();
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaded);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadFaild);
			}
			finished = loadComplete ;
			loadList = loadList.concat(targets);
			totalObjects = loadList.length;
			startLoad();
		}
		
		/**loading percent*/
		public static function get loadingPercent():Number
		{
			return Math.ceil(((totalObjects-loadList.length)/totalObjects)*100);
		}
		
		
		/**reset the total lenght of requested to load objects - percent will back to 0%*/
		public static function resetPercent()
		{
			totalObjects = 0 ;
		}
		
		/**check the loading situation and star to load next target or finishing the job*/
		private static function startLoad()
		{
			/**if the class is not in the middle of loading some object*/
			if(!loading)
			{
				//loader.unloadAndStop(true);
				
				loader.unloadAndStop();
				
				if(loadList.length==0)
				{
					//add this line to stop all playing sounds
					SoundMixer.stopAll();
					if(determinTime)
					{
						var sec = Math.ceil(animationTime) ;
						var min:Number = Math.floor(sec/60);
						sec -= min*60;
						var h:Number = Math.floor(min/60);
						min -= h*60;
						
						trace('animation time is : '+h+':'+min+':'+sec);
					}
					if(listOfFailSWFs.length==0)
					{
						trace('☺ NO loading failds');
					}
					else
					{
						trace("☻ faild list: "+listOfFailSWFs);
					}
					SoundMixer.soundTransform = new SoundTransform(1);
					finished();
				}
				else
				{
					//start to load next object
					//trace('try to load : '+loadList[loadList.length-1]);
					//loader.close();
					//loader.stopAllMovieClips();
					//loader.removeChildren();
					
					//new loader useing ↓
					//trace('try to load : '+loadList[loadList.length-1]);
					loading = true ;
						//loader = new Loader();
						//loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaded);
						//loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadFaild);
					loader.load(new URLRequest(loadList[loadList.length-1]),new LoaderContext(false,ApplicationDomain.currentDomain));
				}
				
			}
		}
		
		/**loading complete*/
		private static function loaded(e)
		{
			//loader.stopAllMovieClips();
			var cash:String = loadList.pop() ;
			if(!(loader.content is MovieClip))
			{
				//trace('‼‼‼'+loader.content);
				listOfFailSWFs.push(cash);
			}
			else
			{
				var index:int = listOfFailSWFs.indexOf(loader.content);
				if(index!=-1)
				{
					listOfFailSWFs.splice(index);
				}
			}
			if(determinTime)
			{
				animationTime+= (MovieClip(loader.content).totalFrames/24);
			}
			stopWithChilds(loader.content);
			//trace('☺'+cash+' loaded'+e);
			loading = false ;
			startLoad();
		}
		
		/**it can not load*/
		private static function loadFaild(e:IOErrorEvent)
		{
			var cash:String = loadList[loadList.length-1] ;
			var err:String = e.toString().split('/').join('');
			if(cash == null || err.indexOf(cash.split('/').join(''))==-1)
			{
				//trace('♣'+err+' vs '+cash.split('/').join(''));
				return ;
			}
			//trace('☻ '+cash+' loads faild.'+e.toString());
			loadList.pop();
			listOfFailSWFs.push(cash);
			loading = false ;
			startLoad()
		}
		
		
		private static function stopWithChilds(targ){
			if(!(targ is MovieClip)){
				return ;
			}
			targ.stop();
			for(var i=0;i<targ.numChildren;i++){
				stopWithChilds(targ.getChildAt(i));
			}
		}
	}
}