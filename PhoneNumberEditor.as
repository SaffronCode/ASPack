// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/***
 * 1.1 
 * Debugged on 94/01/31
 * 				4/20/2015
 * 
 * 
 * 
 */
package
{
	public class PhoneNumberEditor
	{
		/**this class will modify all numbers to standard style*/
		public static function clearPhoneNumber(num:String):String
		{
			var minNum:String = '9127785180';
			
			num = UnicodeStatic.numberCorrection(num);
			
			if(num.length<11)
			{
				trace("The number is to short");
				return 'false';
			}
			
			
			if(num.charAt(0)=='+')
			{
				num = '00'+num.substring(1);
			}
			
			if(isNaN(Number(num)))
			{
				trace('this is not a number');
				return 'false';
			}
					
			
			if(num.charAt(0) == '0')
			{
				if(num.charAt(1) == '0')
				{
					//sample 00-----------
					if(num.charAt(2) == '0')
					{
						//sample 000------
						return 'false';
					}
					//													↓ this was 00989127785180 but other countries numbers can be larger than this. so I have to check Iran code first
					else if(num.indexOf('0098')==0 && num.length<String('00989127785180').length)
					{
						//sample 00934
						return 'false'
					}
				}
				else if(num.charAt(1) == '9')
				{
					//sample 09----
					if(num.charAt(2) == '8')
					{
						if(num.charAt(3) != '9')	
						{
							//sample 00987----
							return 'false';
						}
						else
						{
							//sample 0989423
							num = '0'+num ;
						}
					}
					else
					{
						//sample 09127785180
						num = '0098'+num.substring(1);
					}
				}
				else
				{
					//sample 04127785180
					return 'false';//So the user must enter the 0 befor his number
				}
			}
			else if(num.charAt(0) == '9')
			{
				//9--------
				if(num.charAt(1) == '8')
				{
					//98-----
					num = '00'+num;
				}
				else
				{
					//9------
					num = '0098'+num ;
				}
			}
			else
			{
				return 'false';
			}
			
			if(num.length<minNum.length)
			{
				trace('number is to short');
				return 'false';
			}
			else if(num.length == minNum.length)
			{
				if(num.charAt(0) == '9')
				{
					num = '0098'+num;
				}
				else
				{
					trace('number is to short');
					return 'false';
				}
			}
			
			return num ;
		}
	}
}