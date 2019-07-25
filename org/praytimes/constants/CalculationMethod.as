package org.praytimes.constants
{
	public class CalculationMethod
	{
		/**Muslim World League*/
		public static const MWL:CalculationMethod =		new CalculationMethod("MWL",	 18,		17);
		
		/**Islamic Society of North America (ISNA)*/
		public static const ISNA:CalculationMethod =	new CalculationMethod("ISNA",	 15,		15);
		
		/**gyptian General Authority of Survey*/ 
		public static const EGYPT:CalculationMethod =	new CalculationMethod("Egypt",	 19.5,		17.5);
		
		/**Umm Al-Qura University, Makkah<br>Fajr was 19 degrees before 1430 hijri*/
		public static const MAKKAH:CalculationMethod =	new CalculationMethod("Makkah",	 18.5,		0);//90 min
		
		/**University of Islamic Sciences, Karachi*/
		public static const KARACHI:CalculationMethod =	new CalculationMethod("Karachi", 18,		18);
		
		/**Institute of Geophysics, University of Tehran<br>Isha is not explicitly specified in this method*/
		public static const TEHRAN:CalculationMethod =	new CalculationMethod("Tehran",	 17.7,		14,		4.5,	"Jafari");
		
		/**Shia Ithna-Ashari, Leva Institute, Qum*/
		public static const JAFARI:CalculationMethod =	new CalculationMethod("Jafari",	 16,		14,		4,		"Jafari");

		
		public var name:String;
		public var fajrAngle:Number;
		public var ishaAngle:Number;
		public var ishaOffset:Number = 0;
		public var maghribAngle:Number = 0;
		public var maghribOffset:Number = 0;
		public var imsakOffset:Number = 10;
		public var dhuhrOffset:Number = 0;
		public var asrMethod:String = "Standard";
		public var midnightMethod:String = "Standard";
		
		public function CalculationMethod(name:String, fajrAngle:Number, ishaAngle:Number, maghribAngle:Number=0, midnightMethod:String="Standard")
		{
			this.name = name;
			this.fajrAngle = fajrAngle;
			this.ishaAngle = ishaAngle;
			this.maghribAngle = maghribAngle;
			this.midnightMethod = midnightMethod;
			
			if(ishaAngle!=0)
				ishaOffset = NaN;
			
			if(maghribAngle!=0)
				maghribOffset = NaN;
			
			if(name=="Makkah")
				ishaOffset = 90;
		}
	}
}