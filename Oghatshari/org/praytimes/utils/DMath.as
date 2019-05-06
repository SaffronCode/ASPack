package org.praytimes.utils
{
	public class DMath
	{
		//---------------------- Degree-Based Math Class -----------------------
		
		public static function dtr(d:Number):Number { return (d * Math.PI) / 180.0; }
		public static function rtd(r:Number):Number { return (r * 180.0) / Math.PI; }
		
		public static function sin(d:Number):Number { return Math.sin(dtr(d)); }
		public static function cos(d:Number):Number { return Math.cos(dtr(d)); }
		public static function tan(d:Number):Number { return Math.tan(dtr(d)); }
		
		public static function arcsin(d:Number):Number { return rtd(Math.asin(d)); }
		public static function arccos(d:Number):Number { return rtd(Math.acos(d)); }
		public static function arctan(d:Number):Number { return rtd(Math.atan(d)); }
		
		public static function arccot(x:Number):Number { return rtd(Math.atan(1/x)); }
		public static function arctan2(y:Number, x:Number):Number { return rtd(Math.atan2(y, x)); }
		
		public static function fixAngle(a:Number):Number { return fix(a, 360); }
		public static function fixHour(a:Number):Number { return fix(a, 24 ); }
		
		public static function fix(a:Number, b:Number):Number { a = a - b * Math.floor(a/b); return (a < 0) ? a+b : a;}
	}
}