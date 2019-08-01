package 

{

	import flash.utils.ByteArray;

	/*

	

	License

	

	This program is free software; you can redistribute it and/or modify it

	under the terms of the GNU General Public License as published by the Free

	Software Foundation; either version 2 of the License, or (at your option)

	any later version.

	

	This program is distributed in the hope that it will be useful,

	but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

	or FITNESS FOR A PARTICULAR PURPOSE. See the

	GNU General Public License (http://www.gnu.org/copyleft/gpl.html) for more details.

	

	Original JavaScript Encoding/Decoding

	Written by Stephen Ostermiller

	Copyright (C) 2003-2005 Stephen Ostermiller (http://ostermiller.org/contact.pl?regarding=JavaScript+Encoding)

	

	Actionscript 2.0 Port:

	Jason Nussbaum, September 2005

	Copyright (C) 2005 Jason Nussbaum (http://www.jasonnussbaum.com)

	*/

	public class Base64 extends Object

	{

		

		// Aaccess to this class is through static Encode and Decode methods.

		public function Base64() {}

		

		public static function Encode( str:String ) : String

		{

			var encoder:Base64 = new Base64();

			return encoder.encodeBase64( str );

		}

		

		public static function Decode( str:String ) : String

		{

			var decoder:Base64 = new Base64();

			return decoder.decodeBase64( str );

		}

		

		public static function StringReplaceAll( source:String, find:String, replacement:String ) : String

		{

			return source.split( find ).join( replacement );

		}

		

		private static var _EndOfInput:int = -1;

		

		private static var _Chars:Array = new Array(

			'A','B','C','D','E','F','G','H',

			'I','J','K','L','M','N','O','P',

			'Q','R','S','T','U','V','W','X',

			'Y','Z','a','b','c','d','e','f',

			'g','h','i','j','k','l','m','n',

			'o','p','q','r','s','t','u','v',

			'w','x','y','z','0','1','2','3',

			'4','5','6','7','8','9','+','/'

		);

		

		private static var _CharsReverseLookup:Array; 

		private static var _CharsReverseLookupInited:Boolean = InitReverseChars();

		private static var _Digits:Array = new Array( '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' );

		

		private var _base64Str:String;

		private var _base64Count:Number;

		

		private static function InitReverseChars() : Boolean

		{

			_CharsReverseLookup = new Array();

			

			for ( var i:int=0; i < _Chars.length; i++ )

			{

				_CharsReverseLookup[ _Chars[i] ] = i;

			}

			

			return true;

		}

		

		private static function UrlDecode( str:String ) : String

		{

			str = StringReplaceAll( str, "\+", " " );

			str = unescape( str );

			return str;

		}

		

		private static function UrlEncode( str:String ) : String

		{

			str = escape( str );

			str = StringReplaceAll( str, "\+", "%2B" );

			str = StringReplaceAll( str, "%20", "+" );

			return str;

		}

		

		private function setBase64Str( str:String ):void

		{

			_base64Str = str;

			_base64Count = 0;

		}

		

		private function readBase64() : Number

		{

			if( !_base64Str )

			{

				return _EndOfInput;

			}

			

			if( _base64Count >= _base64Str.length )

			{

				return _EndOfInput;

			}

			

			var c:Number = _base64Str.charCodeAt( _base64Count ) & 0xff;

			_base64Count++;

			

			return c;

		}

		

		private function encodeBase64( str:String ):String

		{

			setBase64Str( str );

			var result:String = "";

			var inBuffer:Array = new Array(3);

			var lineCount:int = 0;

			var done:Boolean = false;

			

			while( !done && ( inBuffer[0] = readBase64() ) != _EndOfInput )

			{

				inBuffer[1] = readBase64();

				inBuffer[2] = readBase64();

				

				result += ( _Chars[ inBuffer[0] >> 2 ] );

				

				if( inBuffer[1] != _EndOfInput )

				{

					result += ( _Chars[ ( ( inBuffer[ 0 ] << 4 ) & 0x30 ) | ( inBuffer[ 1 ] >> 4 ) ] );

					if( inBuffer[ 2 ] != _EndOfInput )

					{

						result += ( _Chars[ ( ( inBuffer[ 1 ] << 2 ) & 0x3c ) | ( inBuffer[ 2 ] >> 6 ) ] );

						result += ( _Chars[ inBuffer[ 2 ] & 0x3F ] );

					}

					else

					{

						result += ( _Chars[ ( ( inBuffer[ 1 ] << 2 ) & 0x3c ) ] );

						result += ( "=" );

						done = true;

					}

				}

				else

				{

					result += ( _Chars[ ( ( inBuffer[ 0 ] << 4 ) & 0x30 ) ] );

					result += "=";

					result += "=";

					done = true;

				}

				

				lineCount += 4;

				

				if(lineCount >= 76)

				{

					result += ('\n');

					lineCount = 0;

				}

			}

			return result;

		}

		

		private function readReverseBase64():int

		{

			if( !_base64Str )

			{ return _EndOfInput; }

			

			while( true )

			{

				if( _base64Count >= _base64Str.length )

				{ return _EndOfInput; }

				

				var nextCharacter:String = _base64Str.charAt( _base64Count );

				

				_base64Count++;

				

				if( _CharsReverseLookup[ nextCharacter ] )

				{

					return _CharsReverseLookup[nextCharacter];

				}

				

				if( nextCharacter == 'A' )

				{ return 0; }

			}

			

			return _EndOfInput;

		}

		

		private function ntos( n:Number ) : String

		{

			var str:String = n.toString( 16 ); 

			

			if( str.length == 1 ) str = "0" + str;

			str = "%" + str;

			

			return unescape( str );

		}

		

		private function decodeBase64( str:String ) : String

		{

			setBase64Str(str);

			var result:String = "";

			var inBuffer:Array = new Array( 4 );

			var done:Boolean = false;

			

			while( !done && ( inBuffer[ 0 ] = readReverseBase64() ) != _EndOfInput

				&& ( inBuffer[ 1 ] = readReverseBase64() ) != _EndOfInput )

			{

				inBuffer[ 2 ] = readReverseBase64();

				inBuffer[ 3 ] = readReverseBase64();

				

				result += ntos( ( ( ( inBuffer[ 0 ] << 2 ) & 0xff ) | inBuffer[ 1 ] >> 4 ) );

				

				if( inBuffer[ 2 ] != _EndOfInput )

				{

					result += ntos( ( ( ( inBuffer[ 1 ] << 4 ) & 0xff ) | inBuffer[ 2 ] >> 2 ) );

					if(inBuffer[3] != _EndOfInput)

					{

						result +=  ntos((((inBuffer[2] << 6)  & 0xff) | inBuffer[3]));

					}

					else

					{

						done = true;

					}

				}

				else

				{

					done = true;

				}

			}

			

			return result;

		}

		

		private function toHex( n:Number ) : String

		{

			var result:String = "";

			var start:Boolean = true;

			for( var i:Number=32; i>0; )

			{

				i-=4;

				var digit:uint = (n>>i) & 0xf;

				if(!start || digit != 0)

				{

					start = false;

					result += _Digits[digit];

				}

			}

			return ( result=="" ? "0" : result );

		}

		

		private function pad( str:String, len:Number, pad:String ) : String

		{

			var result:String = str;

			for (var i:Number=str.length; i<len; i++){

				result = pad + result;

			}

			return result;

		}

		

		private function encodeHex( str:String ) : String

		{

			var result:String = "";

			for( var i:Number=0; i<str.length; i++)

			{

				result += pad( toHex( str.charCodeAt( i ) & 0xff ), 2, '0' );

			}

			return result;

		}

		

		private function decodeHex( str:String ) : String

		{			

			var result:String = "";

			var nextchar:String = "";

			

			for( var i:int=0; i<str.length; i++ )

			{

				nextchar += str.charAt(i);

				

				if(nextchar.length == 2)

				{

					result += ntos( parseInt( "0x" + nextchar) );

					nextchar = "";

				}

			}

			return result;

		}
		
		private static const _encodeChars:Vector.<int> = InitEncoreChar();  
        private static const _decodeChars:Vector.<int> = InitDecodeChar();  
          
        public static function encodeByte(data:ByteArray):String  
        {  
            var out:ByteArray = new ByteArray();  
            //Presetting the length keep the memory smaller and optimize speed since there is no "grow" needed  
            out.length = (2 + data.length - ((data.length + 2) % 3)) * 4 / 3; //Preset length //1.6 to 1.5 ms  
            var i:int = 0;  
            var r:int = data.length % 3;  
            var len:int = data.length - r;  
            var c:uint; //read (3) character AND write (4) characters  
            var outPos:int = 0;  
            while (i < len)  
            {  
                //Read 3 Characters (8bit * 3 = 24 bits)  
                c = data[int(i++)] << 16 | data[int(i++)] << 8 | data[int(i++)];  
                  
                out[int(outPos++)] = _encodeChars[int(c >>> 18)];  
                out[int(outPos++)] = _encodeChars[int(c >>> 12 & 0x3f)];  
                out[int(outPos++)] = _encodeChars[int(c >>> 6 & 0x3f)];  
                out[int(outPos++)] = _encodeChars[int(c & 0x3f)];  
            }  
              
            if (r == 1) //Need two "=" padding  
            {  
                //Read one char, write two chars, write padding  
                c = data[int(i)];  
                  
                out[int(outPos++)] = _encodeChars[int(c >>> 2)];  
                out[int(outPos++)] = _encodeChars[int((c & 0x03) << 4)];  
                out[int(outPos++)] = 61;  
                out[int(outPos++)] = 61;  
            }  
            else if (r == 2) //Need one "=" padding  
            {  
                c = data[int(i++)] << 8 | data[int(i)];  
                  
                out[int(outPos++)] = _encodeChars[int(c >>> 10)];  
                out[int(outPos++)] = _encodeChars[int(c >>> 4 & 0x3f)];  
                out[int(outPos++)] = _encodeChars[int((c & 0x0f) << 2)];  
                out[int(outPos++)] = 61;  
            }  
              
            return out.readUTFBytes(out.length);  
        }  
          
        public static function decodeToByte(str:String):ByteArray  
        {  
            var c1:int;  
            var c2:int;  
            var c3:int;  
            var c4:int;  
            var i:int = 0;  
            var len:int = str.length;  
              
            var byteString:ByteArray = new ByteArray();  
            byteString.writeUTFBytes(str);  
            var outPos:int = 0;  
            while (i < len)  
            {  
                //c1  
                c1 = _decodeChars[int(byteString[i++])];  
                if (c1 == -1)  
                    break;  
                  
                //c2  
                c2 = _decodeChars[int(byteString[i++])];  
                if (c2 == -1)  
                    break;  
                  
                byteString[int(outPos++)] = (c1 << 2) | ((c2 & 0x30) >> 4);  
                  
                //c3  
                c3 = byteString[int(i++)];  
                if (c3 == 61)  
                {  
                    byteString.length = outPos  
                    return byteString;  
                }  
                  
                c3 = _decodeChars[int(c3)];  
                if (c3 == -1)  
                    break;  
                  
                byteString[int(outPos++)] = ((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2);  
                  
                //c4  
                c4 = byteString[int(i++)];  
                if (c4 == 61)  
                {  
                    byteString.length = outPos  
                    return byteString;  
                }  
                  
                c4 = _decodeChars[int(c4)];  
                if (c4 == -1)  
                    break;  
                  
                byteString[int(outPos++)] = ((c3 & 0x03) << 6) | c4;  
            }  
            byteString.length = outPos  
            return byteString;  
        }  
          
        public static function InitEncoreChar():Vector.<int>  
        {  
            var encodeChars:Vector.<int> = new Vector.<int>(64, true);  
              
            // We could push the number directly  
            // but I think it's nice to see the characters (with no overhead on encode/decode)  
            var chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";  
            for (var i:int = 0; i < 64; i++)  
            {  
                encodeChars[i] = chars.charCodeAt(i);  
            }  
              
            return encodeChars;  
        }  
          
        public static function InitDecodeChar():Vector.<int>  
        {  
              
            var decodeChars:Vector.<int> = new <int>[  
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,   
                52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,   
                -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,   
                15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,   
                -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,   
                41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];  
              
            return decodeChars;  
        }  


    }
}