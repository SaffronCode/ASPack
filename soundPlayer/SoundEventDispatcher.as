package soundPlayer
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="soundPasued", type="soundPlayer.SoundPlayerEvent")]
	[Event(name="soundStoped", type="soundPlayer.SoundPlayerEvent")]
	[Event(name="soundPlayed", type="soundPlayer.SoundPlayerEvent")]
	[Event(name="LOADED", type="soundPlayer.SoundPlayerEvent")]
	
	public class SoundEventDispatcher extends EventDispatcher
	{
		public function SoundEventDispatcher()
		{
			super();
		}
	}
}