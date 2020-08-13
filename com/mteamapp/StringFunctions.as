// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package com.mteamapp
{
	import flash.geom.Point;
	import contents.alert.Alert;

	public class StringFunctions
	{
		private static const EnglishEstesna:Array = ['’'];
		
		private static var 	arabicChars:String = 'ًٌٍَُِّْٰٜٕٖۣٞٝٓٔٗ٘ٙٚٛؕؔؓؐؑؒۖۘۗۙۚۛۜۢ‌ـ?',
							arabicSames:Array = ['ؤو','11','22','33','44','55','66','77','88','99','00',
							'0٠۰','1١۱','9٩۹','8٨۸','7٧۷','6٦۶','5٥۵','4٤۴','3٣۳','2٢۲'
							,'ييیىئ','اإأآ?','کك'],
							arabicWord:String = 'والي';
		
		
		/**returns true if there was to many arabic signes there<br>
		 * if the number of arabic sign was less than 1/4 , this function detect that the str is not arabic*/
		public static function isArabic(str:String)
		{
			var reg:RegExp = new RegExp('['+arabicChars+']','g');
			var founced:uint = 0 ;
			var L:uint = Math.min(50,str.length) ;
			
			var searchResult:Object = reg.exec(str);
			while(searchResult!=null && reg.lastIndex<L)
			{
				founced++ ;
				searchResult = reg.exec(str);
			}
			if(founced>L/4)
			{
				return true ;
			}
			else
			{
				return false ;
			}
		}
		
		/**Returns true if currenct string has at least one persian script.*/
		public static function isPersian(str:String,stringLength:Number=NaN):Boolean
		{
			if(str==null)
			{
				return false;
			}
			var max:uint;
			if(isNaN(stringLength))
			{
				max = Math.min(str.length , 200);
			}
			else
			{
				max = Math.min(str.length , stringLength) ;
			}
			for(var i = 0 ; i<max ; i++)
			{
				if(str.charCodeAt(i)>1000 && EnglishEstesna.indexOf(str.charAt(i))==-1)
				{
					//trace('This is arabic : '+str.charAt(i)+' at '+i+' the char code is : '+str.charCodeAt(i));
					return true ;
				}
			}
			return false;
		}
		
		/**it will returns list of points that shows index and ofsset of each word founded*/
		public static function search(str:String,searchedWord:String,fineAll:Boolean = true,arabic:Boolean=false, arabic2:Boolean=false):Vector.<Point>
		{
			var founded:Vector.<Point> = new Vector.<Point>();
			if(str == '' || str == ' ')
			{
				return founded ;
			}
			if(arabic)
			{
				//arabic search has problems
				var regularEx:String = '' ;
				var L:int = searchedWord.length ;
				var arabChars:String = arabicChars ;
				if(arabic2)
				{
					arabChars+= arabicWord ;
				}
				for(var i = 0 ; i<L ; i++)
				{
					var char:String = searchedWord.charAt(i); 
					for(var j = 0 ; j<arabicSames.length ; j++)
					{
						if(arabicSames[j].indexOf(char)!=-1)
						{
							char = '['+arabicSames[j]+']' ;
							break ;
						}
					}
					regularEx += char;
					if(i<L-1)
					{
						regularEx+='['+arabChars+']*';
					}
				}
				var reg:RegExp = new RegExp(regularEx,'g');
				var searchResult:Object = reg.exec(str);
				while(searchResult!=null)
				{
					founded.push(new Point(searchResult.index,reg.lastIndex));
					searchResult = reg.exec(str);
					if(!fineAll)
					{
						break ;
					}
				}
			}
			else
			{
				var f:int=-1 ;
				while((f=str.indexOf(searchedWord,f+1))!=-1)
				{
					founded.push(new Point(f,f+searchedWord.length));
					if(!fineAll)
					{
						break ;
					}
				}
			}
			
			return founded ;
		}
		
		
	//////////////////////////////////////////////////link generators↓
		
		/**generate link on the current string and it will returns html text*/
		public static function generateLinks(str:String,linkColors:int=-1):String
		{
			var colorTagStart:String = '';
			var colorTagEnd:String = '';
			if(linkColors!=-1)
			{
				colorTagStart = '<font color="#'+linkColors.toString(16)+'">';
				colorTagEnd = '</font>';
			}
			var str:String = str;
			//debug telephone
			if(true || !DevicePrefrence.isItPC)
			{
				//trace('phone enabled');
				var regNumberDetection:RegExp = /([\n\r\s\t,^])([\d-+]{7,})/gi;//([\n\r\s\t,])([\d-]{8,})([\t\n\r\s,])
				trace("Find the phone : "+str);
				str = str.replace(regNumberDetection,'$1'+colorTagStart+'<a href="tel:$2">$2</a>'+colorTagEnd);//
			}
			var regURLDetect:RegExp = /([^"]|^)(www|http[s]?:\/\/)([^\s^\n^\r^<^\]^\[^>^"^']*)/gi ;
			str = str.replace(/(http[s]?:\/\/)www\./gi,'$1');//Remove extra www
			str = str.replace(regURLDetect,'<a href="$2$3">$2$3</a>');
			//var regURLDetect2:RegExp = /http\S*\s/gi;
			//str = str.replace(regURLDetect2,'<font color="'+linkColors+'"><a href="$&">$&</a></font>');
			var regDetectEmail:RegExp = /[a-z\.\-1234567890_]*\@[a-z\.\-_]*/gi ;
			str = str.replace(regDetectEmail,colorTagStart+'<a href="mailto:$&">$&</a>'+colorTagEnd);
			
			var doubleHTTP:RegExp = /http:\/\/[ ]*http:\/\//gi;
			str = str.replace(doubleHTTP,'http://');
			
			return str ;
		}
		
		/***Clear in line "s in the json values:<br>
		 * {"data":"my name is "ali"."}<br>
		 * {"data":"my name is \"ali\"."}*/
		public static function clearDoubleQuartmarksOnJSON(str:String):String
		{
			//var str:String = '[{"IdNews":"585","DateNews":"1394\\/8\\/20 ","SubjectNews":"fdjsakl fjk\\"adsl jfkldsa ","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News585.jpg"},{"IdNews":"584","DateNews":"1394\\/8\\/20 ","SubjectNews":"fsjdkl klfsad jklfsjadk ljfklds","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News584.jpg"},{"IdNews":"583","DateNews":"1394\\/8\\/19 ","SubjectNews":"fdjks jkfjd skfkjdkslfj jkfd f","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News583.jpg"},{"IdNews":"582","DateNews":"1394\\/8\\/19 ","SubjectNews":"fdjfk kfjd lfdk lfkdsjkfkdfkls jkf","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News582.jpg"},{"IdNews":"581","DateNews":"1394\\/8\\/18 ","SubjectNews":"مjkf jkfdjsk jkfldjkfld kfdjkfdjk","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News581.jpg"},{"IdNews":"580","DateNews":"1394\\/8\\/18 ","SubjectNews":"fksjdf kfjds klfjkdlfkdsj f sf sfd","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News580.jpg"},{"IdNews":"579","DateNews":"1394\\/8\\/18 ","SubjectNews":"fdskl jfsdkj kfdsjk jkflfdks","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News579.jpg"},{"IdNews":"578","DateNews":"1394\\/8\\/18 ","SubjectNews":"fdsa fad" sfdsa"fdfsaf","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News578.jpg"},{"IdNews":"577","DateNews":"1394\\/8\\/17 ","SubjectNews":"jisfad jkfsdjakj lfasjfdjfsdj kfsdjkl jkf","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News577.jpg"},{"IdNews":"576","DateNews":"1394\\/8\\/17 ","SubjectNews":"fdf afd fsadfdsaf afs df asfsda fsda ","ImageNews":"http:\\/\\/www.melkban24.ir\\/Files\\/News576.jpg"}]';
			var regexp:RegExp = /(":"((?!"\},\{)(?!",")(?!"\}\])(?!"\})(.))*[^\\])"((?!\},\{)(?!,")(?!\}\])(?!\}))/gi
			var lastStr:String ;
			do
			{
				lastStr = str ;
				str = str.replace(regexp,'$1\\"')
			}while(str!=lastStr)
			return str ;
		}
		
		/**This function will remove all spaces and tabs and enters from a string*/
		public static function clearSpacesAndTabs(str:String):String
		{
			if(str==null)
				return '' ;
			return str.split('\n').join('').split('\r').join('').split('\t').join('').split(' ').join('');
		}
		
		
		/**This function will remove all spaces and tabs and enters from a string*/
		public static function clearSpacesAndTabsAndArrows(str:String):String
		{
			if(str==null)
				return '' ;
			return str.split('\n').join('').split('\r').join('').split('\t').join('').split(' ').join('').split('<').join('').split('>').join('');
		}
		
		
	
		
		
	///////////////////New Funciton on String funciont
		public static function utfToUnicode(utfString:String):String
		{
			
			var reg:RegExp = /u[0-9a-f][0-9a-f][0-9a-f][0-9a-f]/gi;
			
			var searchResult:Object = reg.exec(utfString);
			var correctedString:String = '' ;
			var index:uint = 0 ;
			var lastIndex:uint = Infinity ;
			var currentIndex:uint ;
			while(searchResult!=null)
			{
				lastIndex = reg.lastIndex ;
				currentIndex = searchResult.index;
				
				correctedString += utfString.substring(index,currentIndex)+correctUTF(utfString.substring(currentIndex,lastIndex));
				index = lastIndex ;
				searchResult = reg.exec(utfString);
			}
			correctedString+=utfString.substring(index);
			
			return correctedString ;
		}
		
		private static function correctUTF(utfWord:String):String
		{
			
			var num:String = utfWord.substring(1) ;
			return String.fromCharCode(parseInt(num,16)) ;
		}
		
	/////////////////////////////////////////////////Sumerize texts
		/**This function will shorten the senteces by the len vlaue*/
		public static function short(str:String,len:uint=10,removeEntersWith:String=''):String
		{
			if(str==null)
			{
				return '' ;
			}
			if(removeEntersWith!='')
			{
				str = str.split('\r').join('\n').split('\n\n').join('\n').split('\n').join(removeEntersWith);
			}
			var dotString:String = '...';
			var spaceIndex:int = str.indexOf(' ',len-dotString.length);
			if(spaceIndex == -1)
			{
				if(str.length>len)
				{
					return str.substring(0,len-dotString.length)+dotString;
				}
				else
				{
					return str ;
				}
			}
			else
			{
				if(spaceIndex>=str.length)
				{
					//remove donts from the end
					dotString='';
				}
				return str.substr(0,spaceIndex)+dotString;
			}
		}
		
		
		
	////////////////////////////////////////////////
		
		/**This function will make inserted html understandable for UnicodeConvertor*/
		public static function htmlCorrect(htm:String,linkColor:int=-1,replacePwithEnter:Boolean=false,fontSizeIs:Number=20):String
		{
			return Unicode.htmlCorrect(htm,linkColor,replacePwithEnter,fontSizeIs)
			//return Unicode.htmlCorrect(htm,linkColor);
			//I had to repeat this function here to prevent error on old projects
			/*var colorOpen:String= '';
			var colorClose:String = '';
			if(linkColor!=-1)
			{
				colorOpen = '<FONT COLOR="#'+linkColor.toString(16)+'">';
				colorClose = '</FONT>';
			}
			var divDeleter:RegExp = /<\/?div[^>]*>/gi;
			var brReplacer:RegExp = /<\/?br[^>]*>/gi;
			var str:String = htm.replace(divDeleter,'');//<font color="'+linkColors+'"><a href="tel:$&">$&</a></font>
			str = str.replace(brReplacer,'\n');
			str = str.split('<a').join(colorOpen+'<A')
			var linkCloser:RegExp = /<\/a[^>]*>/gi;
			str = str.replace(linkCloser,'</A>'+colorClose);
			var pTag:RegExp = /<\/?p[^>]*>/gi;
			str = str.replace(pTag,'');
			
			//trace(" str : "+str);
			
			return str ;*/
		}
		
	///////////////////////////////////////////////////////Time functions
		/**return the time from seconds to string 10:54*/
		public static function timeInString(seconds:Number):String
		{
			seconds = Math.ceil(seconds);
			var min:Number = Math.floor(seconds/60);
			seconds = seconds%60;
			var hour:Number = Math.floor(min/60);
			min = min%60;
			if(hour>0)
			{
				return numToString(hour)+':'+numToString(min)+':'+numToString(seconds);
			}
			else
			{
				return numToString(min)+':'+numToString(seconds);
			}
		}
		
		/**1 > 001*/
		public static function numToString(num:*,numberLenght:uint=2)
		{
			num = String(num);
			while(num.length<numberLenght)
			{
				num = '0'+num;
			}
			return num;
		}
		
		/**Remove all html tags from the text*/
		public static function clearHTMLTags(ReferText:String):String{return removeHTML(ReferText);}
		
		/**Remove all html tags from the text*/
		public static function removeHTML(ReferText:String):String
		{
			
			if(ReferText==null)
			{
				return '' ;
			}
			var htmlDeleter:RegExp = /<\/?[^>]*>/gi;
			return ReferText.replace(htmlDeleter,'');
		}
		
		
		/**Returns -1 if string1 < str2, 1 if str1>str2*/
		public static function compairFarsiString(str1:String,str2:String):int
		{
			str1 = str1.toLowerCase();
			str2 = str2.toLowerCase();
			
			if(str1 == null)
			{
				str1 = '';
			}
			if(str2 == null)
			{
				str2 = '' ;
			}
			
			if(str1=='' && str2=='')
			{
				return 0 ;
			}
			
			if(str1=='' || str1 ==null)
			{
				return -1 ;
			}
			if(str2=='' || str2==null)
			{
				return 1 ;
			}
			
			var alephba:String = "ابپتثجچهخدذرزژسشصضطظعغفقكگلمنوهیي";
			var farsiStr1:String = UnicodeStatic.KaafYe(str1);
			var farsiStr2:String = UnicodeStatic.KaafYe(str2);
			
			var index1:int = alephba.indexOf(farsiStr1.charAt(0));
			var index2:int = alephba.indexOf(farsiStr2.charAt(0));
			
			if(index1==-1 || index2 ==-1)
			{
				if(str1<str2)
				{
					return -1 ;
				}
				else if(str1>str2)
				{
					return 1 ;
				}
				else
				{
					return 0 ;
				}
			}
			
			if(index1<index2)
			{
				return -1 ;
			}
			else if(index1>index2)
			{
				return 1 ;
			}
			else
			{
				return 0 ;
			}
		}
		public static function htmlCharacterEncoder(str:String):String
		{
			
			var _htmlCar:Array = [{from:"&laquo;",to:"«"},{from:"&raquo;",to:"»"},{from:"&nbsp;",to:" "},{from:'&lt;',to:"<"},{from:"&gt;",to:">"},{from:"&amp;",to:"&"},{from:"&quot;",to:"\\\""},{from:"&apos;",to:"'"},{from:"&cent;",to:"¢"},{from:"&pound;",to:"£"},{from:"&yen;",to:"¥"},{from:"&euro;",to:"€"},{from:"&copy;",to:"©"},{from:"&reg;",to:"®"},{from:"&zwnj;",to:" "}]
			for(var i:int=0;i<_htmlCar.length;i++)
			{
				trace('from :',_htmlCar[i].from,'to :',_htmlCar[i].to)
				str = str.split(_htmlCar[i].from).join(_htmlCar[i].to)
			}
			return str		
		}
		public static function jsonCorrector(oldJson:String)
		{
			return oldJson.split('\n').join(' \\n').split('\r').join(' \\r').split('"').join('\"').split('\t').join('\\t')
		}

		/***0902-hello > hello . it will remove any number befor - sign. if there was a - sign<br>
		 * 0000helo > 0000helo<br>
		 * abs02-hello > abs02-hello*/
		
		public static function removeNumberFromBegining(str:String):String
		{
			var firstDashIndex:int = str.indexOf('-');
			if(firstDashIndex!=-1)
			{
				for(var i = 0 ; i<firstDashIndex ; i++)
				{
					if(isNaN(Number(str.charAt(i))))
					{
						trace("---there is no number befor - sign in : "+str);
						return str ;
					}
				}
				return str.substr(firstDashIndex+1);
			}
			return str ;
		}
		
	////////////////////////////String controll
		
		/**Returns true if this was an email*/
		public static function isEmail(email:String,canBeEmpty_p:Boolean=false):Boolean
		{
			if(canBeEmpty_p)
			{
				if(email==''|| email==null) return true
			}
			if(isPersian(email))
			{
				return false ;
			}
			var reg:RegExp = /^[\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			return reg.test(email);
		}
		
		/**Returns sized html text*/
		public static function makeHTMLWithSize(pureHML:String, defaultFontSize:uint):String
		{
			//<P ALIGN="LEFT"><FONT FACE="B Yekan Bold Bold" SIZE="38" COLOR="#000000" LETTERSPACING="0" KERNING="1">f<FONT SIZE="96">s</FONT>d</FONT></P>
			return '<FONT SIZE="'+defaultFontSize+'">'+pureHML+'</FONT>';
		}
		
	////////////////////////////////////////////////////////
		/**Returns a domain of an url : www.google.com/translage >> google.com*/
		public static function findMainDomain(url:String,removeHTTPPart:Boolean=true):String
		{
			var founded:Array = url.match(/^((http(s|):\/\/)|)[^\/^:^\r^\n]+/);
			if(founded==null || founded.length==0)
			{
				return '';
			}
			var theDomain:String = String(founded[0]).toLowerCase();
			if(removeHTTPPart)
			{
				theDomain = theDomain.split('https://').join('').split('http://').join('').split('www.').join('')
			}
			return theDomain ;
		}
		
		/**Return positive number if port founded*/
		public static function findPortOfURL(url:String):*
		{
			var founded:Array = url.match(/:[1234567890]+\//) ;
			var portPart:String ;
			if(founded==null || founded.length ==0 || (portPart = founded[0]).length<3)
			{
				return -1 ;
			}
			var portPartNumber:uint = uint(portPart.substring(1,portPart.length-1));
			if(portPartNumber==0)
			{
				return -1 ;
			}
			else
			{
				return portPartNumber ;
			}
		}
		
		/**Returns true if entered string was URL*/
		public static function isURL(str:String):Boolean
		{
			var reg:RegExp = /^(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])?$/i;
			return reg.test(str);
		}
		
		public static function isLocation(str:String):Boolean
		{
			var reg:RegExp = /^[\d]+\.[\d]+,[\d]+\.[\d]+$/i;
			return reg.test(str);
		}
		
		///////////////////////////////////////////////////////**********/////////////////////////
		/**2500>>>>>>>2,500  12.5654*/
		public static function currancyPrint(inputcurencynumber:*):String
		{
			inputcurencynumber=String(inputcurencynumber);
			
			var relPart:String = '' ;
			var floatPart:String = '' ;
			
			var splitedNumber:Array = String(inputcurencynumber).split('.') ;
			
			relPart = splitedNumber[0] ;
			
			if(splitedNumber.length>1)
			{
				floatPart = '.'+splitedNumber[1] ;
			}
			else
			{
				floatPart = '' ;
			}
			
			inputcurencynumber = relPart ;
			
			var s2:String;
			s2="";
			
			while (inputcurencynumber.length > 3) {
				
				s2 = ',' + inputcurencynumber.substring(inputcurencynumber.length - 3, inputcurencynumber.length) + s2;
				inputcurencynumber = inputcurencynumber.substring(0, inputcurencynumber.length - 3);
			}
			
			return inputcurencynumber+s2+floatPart
		
		}

		public static function removeCurrancyPrint(inputcurencynumber:*):String
		{
			var lengthCharchters:int = String(inputcurencynumber).length;
			inputcurencynumber=String(inputcurencynumber);
			for(var i:int = 0;i<lengthCharchters;i++)
			{
				if(String(inputcurencynumber).charAt(i)==',')
				{
					inputcurencynumber = String(inputcurencynumber).replace(",","");
				}
			}
			return inputcurencynumber;
		}
		
		
		
		/**http://www.google.com/342 >>> 342.  but it will returns 0 if no number found at the end of line*/
		public static function returnLasNumberPartInInteger(str:String):uint
		{
			var matched:Array = str.match(/[\d]+$/) ;
			if(matched == null || matched.length == 0)
			{
				return 0 ;
			}
			return uint(matched[0]) ;
		}
		
		
	//////////////////////////////////STring to color
		/**Creats color from a link*/
		public static function stringToColor(str:String):uint
		{
			var col:uint = 0 ;
			for(var i:int = 0 ; i<str.length ; i++)
			{
				col+=str.charCodeAt(i)*17.7589894;
			}
			//trace("col : "+col);
			var lastCol:uint = col%10 ;
			var maxRedColor:uint = (lastCol<=3)?0xac0:10 ;
			var maxGreenColor:uint = (lastCol>3 && lastCol<=6)?0xc0:10 ;
			var maxBlueColor:uint = (lastCol>6)?0xc0:10 ;
			//trace("maxRedColor : "+maxRedColor)
			//trace("maxGreenColor : "+maxGreenColor)
			//trace("maxBlueColor : "+maxBlueColor)
			
			var red:uint = (lastCol*87789.15484848)%maxRedColor+0x40;
			var gre:uint = (lastCol*55.15641498)%maxGreenColor+0x40;
			var blu:uint = (lastCol*99.3894516)%maxBlueColor+0x40;
			//trace("red : "+red.toString(16));
			//trace("gre : "+gre.toString(16));
			//trace("blu : "+blu.toString(16));
			
			return red*0x010000+gre*0x000100+blu ;
		}

		public static function stringToColor2(name:String,dynamicColor:uint=0x10):uint
		{
			var color0:uint = 0xf0f0f0;

			var randColor:uint = Math.floor(makeRandomNum(name,1)*dynamicColor)
			+Math.floor(makeRandomNum(name,2)*dynamicColor)*0x0100
			+Math.floor(makeRandomNum(name,3)*dynamicColor)*0x010000;
			//Alert.show(">>"+(makeRandomNum(name,1)*dynamicColor));
			return color0+randColor;
		}

			private static function makeRandomNum(str:String,seed:uint):Number
			{
				var randomSeed:Number = 0 ;
				for(var i:int=0; i<str.length ; i++)
				{
					randomSeed += str.charCodeAt(i) ;
				}
				var max:uint ;
				switch(seed)
				{
					case 1:
						max = 135;
						break;
					case 2:
						max = 456;
						break;
					case 3:
						max = 984;
						break;
					default:
						max = 844
						break;
				}
					randomSeed = (randomSeed%max)/max;
				return randomSeed;
			}
		
		
		
		
		/**Remove spaces from two side of the inputed string : "   hello world  " > "hello world" */
		public static function removeSpacesFromTwoSides(str:String):String
		{
			if(str==null)
			{
				return null ;
			}
			str = str.replace(/[\s]+$/g,'');
			str = str.replace(/^[\s]+/g,'');
			return str ;
		}
		
		public static function trim(str:String):String
		{
			return removeSpacesFromTwoSides(str);
		}
		
		/**Returning file size in String with lable*/
		public static function fileSizeInString(fileSizeInByte:Number):String
		{
			if(isNaN(fileSizeInByte))
			{
				return '' ;
			}
			if(fileSizeInByte<1000)
			{
				return Math.round(fileSizeInByte)+' B';
			}
			else if(fileSizeInByte<1000*1000)
			{
				return Math.round(fileSizeInByte/1000)+" K";
			}
			else if(fileSizeInByte<1000*1000*1000)
			{
				return Math.round(fileSizeInByte/(1000*1000))+" M";
			}
			else
			{
				return Math.round(fileSizeInByte/(1000*1000*1000))+' G';
			}
		}
		
		public static function isNullOrEmpty(str:String,ignoreSpaces:Boolean=false):Boolean
		{
			if(ignoreSpaces)
				str.split(' ').join('');
			return str==null || str=='';
		}
		
		public static function clearExtraSpaces(str:String):String
		{
			return str.replace(/[\s\t]{2,}/g,' ').replace(/([\t\s]$)|(^[\s\t])/g,'');
		}
		
		public static function isPhoneNumber(str:String):Boolean
		{
			return str.match(/((\+98|[0]{1,2}98)|0)[\d]{8,12}/)!= null;
		}
		public static function isMobileNumber(str:String):Boolean
		{
			trace('str.substr(0,1) :',str.substr(0,2));
			return !isNullOrEmpty(str) && !isNaN(Number(str)) && str.length == 11 && str.substr(0,2) == '09';
		}
		public static function IsValidNationalCode(nationalCode:String):Boolean
		{
			if(nationalCode==null)return false;
			if(nationalCode=='')return false;
			if(nationalCode.length !=10) return false;
			if(isNaN(Number(nationalCode))) return false;
			
			var allDigitEqual:Array = new Array("0000000000","1111111111","2222222222","3333333333","4444444444","5555555555","6666666666","7777777777","8888888888","9999999999");
			if (allDigitEqual.indexOf(nationalCode)!=-1) return false;
			
			var chArray = nationalCode.split('');
			var num0 = int(chArray[0].toString())*10;
			var num2 = int(chArray[1].toString())*9;
			var num3 = int(chArray[2].toString())*8;
			var num4 = int(chArray[3].toString())*7;
			var num5 = int(chArray[4].toString())*6;
			var num6 = int(chArray[5].toString())*5;
			var num7 = int(chArray[6].toString())*4;
			var num8 = int(chArray[7].toString())*3;
			var num9 = int(chArray[8].toString())*2;
			var a = int(chArray[9].toString());
			
			var b = (((((((num0 + num2) + num3) + num4) + num5) + num6) + num7) + num8) + num9;
			var c = b%11;
			
			return (((c < 2) && (a == c)) || ((c >= 2) && ((11 - c) == a)));
		}
		public static function isNotEmptyString(txt:String):Boolean
		{
			return txt!= null && StringFunctions.clearSpacesAndTabs(txt)!='';
		}
		
		
		
		/**Creates a random String like WebKitFormBoundaryWYIDHkbUgs0p7KUx*/
		public static function randomString(len:uint):String
		{
			var key:String = '' ;
			var keyvalues:String = '';
			keyvalues += "abcdefghijklmnopqrstuvwxyz";
			keyvalues += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			keyvalues += "1234567890";
			var keyvaluesLenght:uint = keyvalues.length ;
			for(var i:int = 0 ; i<len ; i++)
			{
				key += keyvalues.charAt(Math.floor(Math.random()*keyvaluesLenght));
			}
			return key;
		}
		public static function removeReservedChar(str:String,joinChar:String='_'):String
		{
			return str.split('?').join(joinChar).split('"').join(joinChar).split('|').join(joinChar).split(':').join(joinChar).split('*').join(joinChar).split('<').join(joinChar).split('>').join(joinChar).split('/').join(joinChar).split('\/').join(joinChar);
				
		}
	}
}