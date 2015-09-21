package
{
	import flash.utils.ByteArray;

	/**Contains Everything that you need to create,read and have an edit on Binarys Data<br><br>
	 * every binary Numbers have to be on Stream format*/
	public class Binarys
	{
		/**Binary String Temp - clear it after use it;*/
		private static var BinaryString:String='';
		/**this function counts number of 0s or 1s on the called Binary String<br>
		 * sample : countBits('100110000',1);//returns 3 for number of ones.*/
		public static function countBits(binaryString:String,countTheseBits:uint):uint
		{
			var CNT:uint = 0 ;
			for(var i:uint=0;i<binaryString.length;i++)
			{
				var bit:int = int(binaryString.charAt(i));
				if(!isNaN(bit))
				{
					CNT+= bit ;
				}
			}
			if(countTheseBits==0)
			{
				return binaryString.length-CNT;
			}else{
				return CNT;
			}
		}
		
		
		/*public static function countBits(binaryString:*,countTheseBits:uint):uint
		{
			if(binaryString is String)
			{
			//do Nothing - every other thing have to Convert to String to
			}
			else if(binaryString is int)
			{
			
			}
			else if(binaryString is ByteArray)
			{
			binaryString = ByteArrayToBinary(binaryString);
			}
			if(binaryString.lenght<2000)
			{
				BinaryString = binaryString ;
				return nextIndex(0,countTheseBits.toString(2));
			}
		}
		
		private static function nextIndex(baseIndex:uint,searchFor:String):int
		{
			var index:int = BinaryString.indexOf(searchFor,baseIndex);
			if(index<0)
			{
				return 0 ;
			}else{
				return nextIndex(1+index,searchFor)+1;
			}
		}*/
		
		
		/**complete bits to multiple of 8 to complete Bytes<br>
		 * sample : 101 > 00000101 <br>
		 * you can defined custom sized byte by second value*/
		public static function completBits(binaryString:String,ByteLength:uint=8):String
		{
			var zeros:String = '';
			for(var i:uint=ByteLength-(binaryString.length%8) ; i>0 && i!=ByteLength ;i--)
			{
				zeros+='0';
			}
			binaryString = zeros+binaryString ;
			return binaryString;
		}
		
		
		/**converting a Binary String made from 01 to sendable Bytea Array */
		public static function BinaryToByteArray(binaryString:String='01010101'):ByteArray
		{
			binaryString = completBits(binaryString);
			
			var myByteArray:ByteArray = new ByteArray();
			
			var	bytes:uint = binaryString.length/8 ;
			for(var i:uint=0 ; i<bytes ; i++)
			{
				myByteArray.writeByte(convert_BinaryToHex(binaryString.substr(i*8,8)));
			}
			//trace(ByteArrayToBinary(myByteArray));
			return myByteArray;
		}
		
		
		
		
		
		
		
		/**convering a ByteArray To Binary String*/
		public static function ByteArrayToBinary(byteArr:ByteArray):String
		{
			var cashdPosition:uint = byteArr.position ;
			var binaryString:String = '';
			byteArr.position = 0 ;
			while(byteArr.bytesAvailable)
			{
				var cash:String = byteArr.readUnsignedByte().toString(2);
				cash = completBits(cash);
				binaryString += cash ;
			}
			byteArr.position = cashdPosition ;
			return binaryString ;
		}
		
		
		
		
		
		
		/**convert 0 to 4,294,967,295 number to 0 1 based 8 char string*/
		public static function convert_hexToBinary(num:uint):String
		{
			return completBits(num.toString(2));
		}
		
		/**convert binary String to unsigned hexa Number up to 4,294,967,295*/
		public static function convert_BinaryToHex(binaryString:String):uint
		{
			return parseInt(binaryString,2);
		}
		
		/**Shift Bynary string and multyply it by 2 in Steps reseved.<br>
		 * sample : shiftBinaryString(0110101,-2);  //returns >> 0001101<br>
		 * 			shiftBinaryString(0110101,3);  //returns <<< 0101000*/
		public static function shiftBinaryString(bunaryString:String,Steps:int):String
		{
			var Lng:uint = bunaryString.length ;
			var zeros:String = '' ;
			for(var i:uint = Math.abs(Steps);i>0;i--)
			{
				zeros+='0';
			}
			if(Steps>0)
			{
				bunaryString = bunaryString.substring(Steps)+zeros;
			}
			else if(Steps<0)
			{
				bunaryString = zeros+bunaryString.substring(0,Lng+Steps);
			}
			return bunaryString ;
		}
		
		public static function combineBytes(byte1:String,byte2:String):String
		{
			var var1:uint = convert_BinaryToHex(byte1);
			var var2:uint = convert_BinaryToHex(byte2);
			
			return convert_hexToBinary(var1+var2);
		}
		
		/**split the binary array to 8 bit for easy reading*/
		public static function binaryTracer(binaryString:String,NumberBase:uint=2):String
		{
			//return String(binaryString.length/8) ;
			
			var newString:String = '' ;
			var len:uint = 8 ;
			if(NumberBase==16)
			{
				len = 2
			}
			for(var i:uint=0;i<binaryString.length/8;i++)
			{
				newString += completBits(parseInt(binaryString.substr(i*8,8),2).toString(NumberBase),len)+' ';
			}
			return newString ;
		}
		
		/**return string of boolean in byte Array*/
		public static function traceBA(ba:ByteArray):String
		{
			return binaryTracer(ByteArrayToBinary(ba),16);
		}
	}
}