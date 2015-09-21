package
{
	public class URLCorrector
	{
		/**remove spaces and correct / es*/
		public static function correct(url:String):String
		{
			while(url.charAt(0)==' ')
			{
				url = url.substring(1);
			}
			
			while(url.charAt(url.length-1)==' ')
			{
				url = url.substring(0,url.length-1);
			}
			
			url = url.split('\\').join('/');
			
			return url ;
		}
	}
}