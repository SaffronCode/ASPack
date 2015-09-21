package videoShow
{
	public class VideoClient extends Object
	{
		public var	OnCuePoint:Function,
					OnImageData:Function,
					OnMetaData:Function,
					OnPlayStatus:Function,
					OnSeekPoint:Function,
					OnTextData:Function,
					OnXMPData:Function;
					
		
		public function VideoClient()
		{
			super();
		}
		
		public function onCuePoint(e=null)
		{
			trace("onCuePoint : " +e);
			if(OnCuePoint!=null)
			{
				OnCuePoint(e);
			}
		}
		public function onImageData(e=null)
		{
			trace("onImageData : " +e);
			if(OnImageData!=null)
			{
				OnImageData(e);
			}
		}
		public function onMetaData(e=null)
		{
			trace("onMetaData : " +e);
			if(OnMetaData!=null)
			{
				OnMetaData(e);
			}
		}
		public function onPlayStatus(e=null)
		{
			trace("onPlayStatus : " +e);
			if(OnPlayStatus!=null)
			{
				OnPlayStatus(e);
			}
		}
		public function onSeekPoint(e=null)
		{
			trace("onSeekPoint : " +e);
			if(OnSeekPoint!=null)
			{
				OnSeekPoint(e);
			}
		}
		public function onTextData(e=null)
		{
			trace("onTextData : " +e);
			if(OnTextData!=null)
			{
				OnTextData(e);
			}
		}
		public function onXMPData(e=null)
		{
			trace("onXMPData : " +e);
			if(OnXMPData!=null)
			{
				OnXMPData(e);
			}
		}

	}
}