package
{
	import flash.events.Event;
	import flash.text.TextField;
	
	public class FarsiInputCorrectionEvent extends Event
	{
		public static const TEXT_FIELD_SELECTED:String = "TEXT_FIELD_SELECTED" ;
		public static const TEXT_FIELD_CLOSED:String = "TEXT_FIELD_CLOSED" ;
		
		
		public var textField:TextField ;


		public function FarsiInputCorrectionEvent(type:String,textField:TextField)
		{
			super(type,true);
			this.textField = textField ;
		}
	}
}