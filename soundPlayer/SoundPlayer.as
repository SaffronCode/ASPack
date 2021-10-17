// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/***var sion log
 * version  1.2 : dispatch stop after sound is finished
 * 			1.3 : soundEventDispatcher added with eventsDispatch Object name
 * 			1.4 : you can play sound with one id over each other with doNotStopLastPlayedSound boolean to true , then onl played 
 * 					sound continues to play and in the same time , that sound will start to play over it self again
 * 			1.4.1 : from now , this class will check the setup function to skip if it was seted up befor
 */

package soundPlayer
{
	import flash.desktop.NativeApplication;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	/**SetUp() activate class<br>
	 * playSound(ID,boolean,number) playe the sound , whit ID , Loopable or not (Loop Abale Sounds will not remove Automaticliy from que)<br>
	 * Pause(ID)<br>
	 * stop(ID)<br>
	 * each play and pause and ... will dispatched on Events on Stage<br>
	 * SoundStatuse_()<br>
	 * volumeControl()
	 * <br>
	 * getLoadedSoundPrecent(ID) will returns precent of loaded file<br>
	 * getPlayedPrecent(ID) returns the precent of loaded sound*/
	public class SoundPlayer
	{
		public static var eventsDispatch:SoundEventDispatcher = new SoundEventDispatcher();

		private static var cacheBeforSwtUp:Array = [] ;
		
		
		public static var volSpeed:Number=0.1;
		private static const timSpeed:Number=100;
		/**ایا نرم افزار فعال است یا خیر*/
		private static var isActive:Boolean
		private static var 	mySound:Vector.<Sound>,
							myTrans:Vector.<SoundTransform>,
							myChan:Vector.<SoundChannel>,
							myID:Vector.<uint>,
							myCallerID:Vector.<Number>,
							silentOnBack:Vector.<Boolean>,
							myMaxVolume:Vector.<Number>,
							myLoop:Vector.<Boolean>,
							myPaused:Vector.<Boolean>,
							myStop:Vector.<Boolean>,
							myPosition:Vector.<Number>,
							endPosition:Vector.<Number>,
							myLength:Vector.<Number>;
							
		private static var 	myAll:Array,
							tim:Timer,
							myStage:Stage,
							
							diactiveAllOnBack:Boolean,
							
							deactivated:Boolean=false;
							
		private static var _preventExitHandler:Boolean = false ;
							
		public static function setUp(MyStage:Stage,dicativeAllOnBackGround:Boolean = false,handleBackBTNOnAndroid:Boolean=true):void
		{
			if(myStage!=null)
			{
				return ;
			}
			SaffronLogger.log('setUp !')
			myStage = MyStage ;
			
			diactiveAllOnBack = dicativeAllOnBackGround ;
			
			isActive = true ;
			
			handleBackBTNOnAndroid = !_preventExitHandler && handleBackBTNOnAndroid ;
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE,activate);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE,deActivate);
			if(handleBackBTNOnAndroid)
			{
				NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN,checkExit);
			}
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,activate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,deActivate);
			if(handleBackBTNOnAndroid)
			{
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN,checkExit);
			}
			
			mySound = new Vector.<Sound>();
			myTrans = new Vector.<SoundTransform>();
			
			myChan = new Vector.<SoundChannel>();
			myID = new Vector.<uint>();
			myMaxVolume = new Vector.<Number>();
			myLoop = new Vector.<Boolean>();
			myPaused = new Vector.<Boolean>();
			silentOnBack = new Vector.<Boolean>();
			myStop = new Vector.<Boolean>();
			myPosition = new Vector.<Number>();
			endPosition = new Vector.<Number>();
			myLength = new Vector.<Number>();
			myCallerID = new Vector.<Number>();
			
			myAll = new Array();
			myAll.push(mySound);myAll.push(myTrans);myAll.push(myChan);myAll.push(myID);
			myAll.push(myMaxVolume);myAll.push(myLoop);myAll.push(myPaused);
			myAll.push(silentOnBack);myAll.push(myStop);myAll.push(myPosition);myAll.push(myCallerID);myAll.push(myLength);
			
			tim = new Timer(timSpeed);
			tim.addEventListener(TimerEvent.TIMER,timing);
			tim.start();

			setTimeout(addCachedSounds,0);
		}

			private static function addCachedSounds():void
			{
				for(var i:int = 0 ; i<cacheBeforSwtUp.length ; i++)
				{
					addSound.apply(null,cacheBeforSwtUp[i]);
				}
				cacheBeforSwtUp = [] ;
			}
		
		public static function preventExitHandler():void
		{
			_preventExitHandler = true ;
			NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN,checkExit);
		}
		
		
		private static function timing(e:TimerEvent):void
		{
			for(var i:int=0;i<mySound.length;i++)
			{
				var vol:Number = myTrans[i].volume;
				if(myPaused[i] || (!isActive && silentOnBack[i]))
				{
					if(vol>0)
					{
						myTrans[i].volume = vol-volSpeed;
						if(myTrans[i].volume<0)
						{
							myTrans[i].volume = 0 ;
						}
						try{
							myChan[i].soundTransform = myTrans[i] ;
						}catch(e){};
					}else
					{
						deactiveSound(i,!isActive)
					}
				}
				else
				{
					playSound(i);
					if(vol<myMaxVolume[i])
					{
						myTrans[i].volume = vol+volSpeed;
						if(myTrans[i].volume>myMaxVolume[i])
						{
							myTrans[i].volume = myMaxVolume[i];
						}
						try{
							myChan[i].soundTransform = myTrans[i] ;
						}
						catch(e){}
					}
					else if(vol>myMaxVolume[i])
					{
						myTrans[i].volume = vol-volSpeed;
						try{
							myChan[i].soundTransform = myTrans[i] ;
						}
						catch(e){}
					}
					if(endPosition[i]!=0)
					{
						if(getPlayedPrecent(myID[i])>=endPosition[i])
						{
							pause(myID[i],true);
							dispathcEvent(SoundPlayerEvent.WORD_COMPLETED,myID[i]);
						}
					}
				}
			}
		}
		
		private static function activate(e:*):void
		{
			isActive = true ;
			if(diactiveAllOnBack && !deactivated)
			{
				SoundMixer.soundTransform = new SoundTransform(1);
			}
		}
		
		private static function deActivate(e:*):void
		{
			if(diactiveAllOnBack)
			{
				isActive = false ;
				SoundMixer.soundTransform = new SoundTransform(0);
			}
		}
		
		/**deactive all sounds. you can activate theme again with activateAll() function*/
		public static function deactiveAll():void
		{
			deactivated = true ;
			SoundMixer.soundTransform = new SoundTransform(0);
		}
		
		/**activate all sounds that diactivate by deactiveAll function*/
		public static function activateAll():void
		{
			deactivated = false ;
			SoundMixer.soundTransform = new SoundTransform(1);
		}
		
		private static function checkExit(e:*):void
		{
			if(e.keyCode == Keyboard.BACK)
				NativeApplication.nativeApplication.exit();
		}
		
		/**return true if this sound is paused*/
		public static function getStatuse_pause(ID:uint):Boolean
		{
			var I:* = gI(ID);
			if(I!=-1)
			{
				return myPaused[I];
			}
			return true ;
		}
		
		
		
		/**play immediately and play if from begin option<br>
		 * you can set the starting volume<br>
		 * if you whant to reset Position , you can enter the newPosition in Presetn (0 - 1.0)*/
		public static function play(soundID:uint,withOutFadeIn:Boolean=false,resetPosition:Boolean=false,newPosition:Number=0,stopLastPlayedSound:Boolean = false,endAtPosition:Number=0):void
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				if(resetPosition)
				{
					deactiveSound(I,false,stopLastPlayedSound);
					var myPose:Number = Math.min(myLength[I],Math.max(0,newPosition*myLength[I]));
					myPosition[I] = myPose ;
				}
				else
				{
					myPosition[I] = myPosition[I]%myLength[I];
				}
				myPaused[I] = false ;
				endPosition[I] = endAtPosition ;
				if(withOutFadeIn)
				{
					playSound(I,myMaxVolume[I]);
				}
				dispathcEvent(SoundPlayerEvent.PLAYED,myID[I]);
			}
		}
		
		/**returns the currentMusic totalTime in mili seconds*/
		public static function getMusicTime(soundID:uint):Number
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				return myLength[I];
			}
			return 0 ;
		}
		
		/**this function will tells you how much of the current sound is played.<br>
		 * returnd Number is between 0 and 1.0*/
		public static function getPlayedPrecent(soundID:uint):Number
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				if(myLength[I]==0)
				{
					return 0;
				}
				else if(myStop[I])
				{
					return myPosition[I]/myLength[I];
				}
				else if(myChan[I]==null)
				{
					return 0 ;
				}
				else
				{
					return myChan[I].position/myLength[I];
				}
			}
			else
			{
				return 0 ;
			}
		}
		
		/**it will returns the current sound channle for using pans , and etc..*/
		public static function getSoundChannle(soundID:uint):SoundChannel
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				return myChan[I];
			}
			else
			{
				return null;
			}
		}
		
		/**you can stp the sound with the fadeOut or withOutFade*/
		public static function pause(soundID:uint,withOutFadeOut:Boolean=false):void
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				myPaused[I] = true ;
				if(withOutFadeOut)
				{
					deactiveSound(I,false);
				}
				dispathcEvent(SoundPlayerEvent.PAUSED,myID[I]);
			}
		}
		
		/**remove sound with special ID*/
		public static function removeSound(soundID:uint):void
		{
			var I:* = gI(soundID);
			var index:int = gI(soundID);
			if(index != -1)
			{
				pause(soundID,true);
				
				mySound[index].removeEventListener(Event.COMPLETE,SoundLoadCompleted);
				
				mySound.splice(index,1);
				myChan.splice(index,1);
				myTrans.splice(index,1);
				myID.splice(index,1);
				myMaxVolume.splice(index,1);
				myLoop.splice(index,1);
				myPaused.splice(index,1);
				silentOnBack.splice(index,1);
				myStop.splice(index,1);
				myPosition.splice(index,1);
				endPosition.splice(index,1);
				myLength.splice(index,1);
				myCallerID.splice(index,1);
			}
		}
		
		/**add a sound to sound list , but you have too call Play after thiss<br>
		 * you can set an callerID to listen to your oun class sounds<br>
		 * you can tell the class that this sound should be silent on app diactivated or not*/
		public static function addSound(TargetURL:String,ID:uint,Loop:Boolean,maxVolume:Number,callerID:Number=Infinity,silentONBackGorund:Boolean=true,initSoundPosition:Number=0):void
		{
			if(myStage==null)
			{
				SaffronLogger.log("soundPlayer Class , addSound : "+new Error('SetUp this Class First'));
				cacheBeforSwtUp.push([TargetURL,ID,Loop,maxVolume,callerID,silentONBackGorund,initSoundPosition])
				return;
			}
			
			removeSound(ID);
			
			var I:* = mySound.length;
			mySound[I] = new Sound(new URLRequest(URLCorrector.correct(TargetURL)));
			mySound[I].addEventListener(Event.COMPLETE,SoundLoadCompleted);
			mySound[I].addEventListener(IOErrorEvent.IO_ERROR,soundNOtFounded);
			myChan[I] = new SoundChannel();
			myTrans[I] = new SoundTransform(maxVolume);
			myID[I] = ID ;
			myMaxVolume[I] = maxVolume;
			myLoop[I] = Loop ;
			myPaused[I] = true ;
			silentOnBack[I] = silentONBackGorund ;
			myStop[I] = true ;
			myPosition[I] = initSoundPosition ;
			endPosition[I] = 0 ;
			myLength[I] = 0 ;
			myCallerID[I] = callerID ;
		}
		
		/**returns how much of the sound file is loaded<br>
		 * returnd number is between 0 and 1.0*/
		public static function getLoadedSoundPrecent(soundID:uint):Number
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				if(mySound[I].bytesTotal>0)
				{
					return mySound[I].bytesLoaded/mySound[I].bytesTotal;
				}
				else
				{
					return 0 ;
				}
			}
			else
			{
				return 0 ;
			}
		}
		
		
		
		/**sound target is not refer correctly*/
		private static function soundNOtFounded(e:*):void
		{
			SaffronLogger.log('Sound error : '+e);
		}
		
		
		
		/**clntroll the volume<br>
		 * volumes have to be a number between 0 and 1*/
		public static function volumeContril(soundID:uint,newVolume:Number):void
		{
			newVolume = Math.max(0,Math.min(newVolume,1));
			var I:* = gI(soundID);
			if(I!=-1)
			{
				myMaxVolume[I] = newVolume ;
			}
		}
		
		/**get current sound volume*/
		public static function getVolume(soundID:uint):Number
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				return myMaxVolume[I];
			}
			else
			{
				return -1;
			}
		}
		
		
		/**returns my music target*/
		public static function getMusicTarget(soundID:uint):String
		{
			var I:* = gI(soundID);
			if(I!=-1)
			{
				return mySound[I].url;
			}
			else
			{
				return '';
			}
		}
		
		
		
		private static function deactiveSound(I:uint,isDeactivatedBecauseAppDeactived:Boolean,stopPlayingSound:Boolean=true):void
		{
			if(!myStop[I])
			{
				if(!isDeactivatedBecauseAppDeactived)
				{
					myPaused[I] = true ;
				}
				myStop[I] = true ;
				try{
					myPosition[I]=myChan[I].position;
					if(stopPlayingSound)
					{
						myChan[I].stop();
					}
				}catch(e){};
				
				dispathcEvent(SoundPlayerEvent.STOPED,myID[I]);
			}
		}
		
		
		/**صدا لود شد*/
		private static function SoundLoadCompleted(e:Event):void
		{
			var I:* = gI(e.currentTarget);
			
			myLength[I] = mySound[I].length ;
			
			mySound[I].removeEventListener(Event.COMPLETE,SoundLoadCompleted);
			
			if(myPaused[I]!=true)
			{
				playSound(I);
			}
			dispathcEvent(SoundPlayerEvent.LOADED,myID[I]);
		}
		
		/**start playing sound<br>
		 * set sound chanel*/
		private static function playSound(I:uint,beginVolume:Number=0):void
		{
			if(myStop[I])
			{
				//SaffronLogger.log('sounde played');
				myPaused[I] = false ;
				myStop[I] = false ;
				myTrans[I].volume = Math.min(myMaxVolume[I],beginVolume);
				try{
					myChan[I] = mySound[I].play(myPosition[I]) ;
					myChan[I].soundTransform = myTrans[I];
					myChan[I].addEventListener(Event.SOUND_COMPLETE,mySoundIsCompleted);
				}catch(e){};
				
				dispathcEvent(SoundPlayerEvent.PLAYED,myID[I]);
			}
		}
		
		private static function mySoundIsCompleted(e:Event):void
		{
			var I:* = gI(e.currentTarget);
			if(I==-1)
			{
				return ;
			}
			var lastPauseStatus:Boolean = myPaused[I] ;
			myPaused[I] = true ;
			myStop[I] = true ;
			if(myLoop[I] && lastPauseStatus==false)
			{
				myPosition[I]=0;
				playSound(I,myTrans[I].volume);
			}
			else
			{
				myPosition[I]=myLength[I];
				//new on 93-4-7 ↓ add to dispatch whenever sound is stop
				dispathcEvent(SoundPlayerEvent.STOPED,myID[I]);
				//why did i delete it ? i have to delete it manualy
				//deletThisSound(I);
			}
		}
		
		
		private static function deletThisSound(I:*):void
		{
			myChan[I].stop();
			myChan[I].removeEventListener(Event.SOUND_COMPLETE,mySoundIsCompleted);
			mySound[I].removeEventListener(Event.COMPLETE,SoundLoadCompleted);
			
			for(var i:int=0;i<myAll.length;i++)
			{
				myAll[i].splice(I,1);
			}
			
		}
		
		/**Returns Sounds Index*/
		private static function gI(snd:*):int
		{
			if(myID == null)
			{
				return -1;
			}
			
			if(snd is Sound)
			{
				return mySound.indexOf(snd);
			}
			else if(snd is SoundChannel)
			{
				return myChan.indexOf(snd);
			}
			else if(snd is uint)
			{
				return myID.indexOf(snd);
			}
			
			return -1 ;
		}
		
		private static function dispathcEvent(soundEvent:String,ID:uint):void
		{
			var callerID:Number = gI(ID);
			myStage.dispatchEvent(new SoundPlayerEvent(soundEvent,ID,myCallerID[callerID]));
			eventsDispatch.dispatchEvent(new SoundPlayerEvent(soundEvent,ID,myCallerID[callerID]));
		}

		public static function lastCallerIdForThisSoundId(soundId:uint):Number
		{
			var callerID:Number = gI(soundId);
			if(callerID<myCallerID.length && callerID>=0)
				return myCallerID[callerID];
			return -1 ;
		}
		
		/**Extract the sound to byte array*/
		public static function getExtractedData(ID:uint, extractedBytes:ByteArray):void
		{
			
			var callerID:Number = gI(ID);
			mySound[callerID].extract(extractedBytes,Math.floor((mySound[callerID].length/1000)*44100));
			extractedBytes.position = 0 ;
		}
		
		/**Step the current sound forward as much as you whant*/
		public static function stepForward(soundId:uint,howMuchMiliseconds:uint=10000):void
		{
			var totalLength:uint = getMusicTime(soundId);
			var currentPrecent:Number = getPlayedPrecent(soundId) ;
			var currentTime:uint = uint(totalLength*currentPrecent);
			SaffronLogger.log("currentTime : "+currentTime)
			SaffronLogger.log("totalLength : "+totalLength);
			var newTime:uint = Math.min(totalLength,currentTime+howMuchMiliseconds);
			SoundPlayer.pause(soundId,true);
			play(soundId,true,true,newTime/totalLength);
		}
		
		/**Step the current sound backward as much as you whant*/
		public static function stepBackward(soundId:uint,howMuchMiliseconds:uint=10000):void
		{
			var totalLength:uint = getMusicTime(soundId);
			var currentPrecent:Number = getPlayedPrecent(soundId) ;
			var currentTime:uint = uint(totalLength*currentPrecent);
			SaffronLogger.log("currentTime : "+currentTime)
			SaffronLogger.log("totalLength : "+totalLength);
			var newTime:uint = Math.max(0,currentTime-howMuchMiliseconds);
			SoundPlayer.pause(soundId,true);
			play(soundId,true,true,newTime/totalLength);
		}
	}
}