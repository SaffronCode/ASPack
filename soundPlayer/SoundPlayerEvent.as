// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package soundPlayer
{
	import flash.events.Event;

	/**Contains a SoundID*/
	public class SoundPlayerEvent extends Event
	{
		public static const	PAUSED:String = "soundPasued",
							STOPED:String = "soundStoped",
							PLAYED:String = "soundPlayed",
							LOADED:String = "LOADED";
		
		/**Dispatches when the end position reached*/
		public static const WORD_COMPLETED:String = "WORD_COMPLETED";
							
		/**acted sound ID*/
		public var 	SoundID:uint;
		/**class ID that is caused of this event*/
		public var 	CallerID:Number;
		
		public function SoundPlayerEvent(type:String,ID,callerID)
		{
			CallerID = callerID ;
			SoundID = ID ;
			super(type,true);
		}
	}
}