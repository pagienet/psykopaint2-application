package net.psykosoft.psykopaint2.book.views.book.debug
{
	import flash.text.TextField;
	import flash.text.TextFormat;

     	public class DEBUG
     	{
		public static var active:Boolean = true;

		private static var _textLog:TextField;
		private static var _textLogShadow:TextField;

		public static function init(host:*, x:int = 5, y:int = 5, width:int =500 , height:int = 750):void
		{
			if(_textLog) return;
			
			generateTextField(x, y, width, height);

			host.addChild(_textLogShadow);
			host.addChild(_textLog);
		}

		public static function TRACE(data:*, clear:Boolean = false):void
		{
			if(active){
				//trace(data);
				if(_textLog) {
					if(clear) _textLog.text = _textLogShadow.text = "";
					_textLog.appendText("\n"+data);
					_textLogShadow.appendText("\n"+data);
					_textLog.scrollV = _textLogShadow.scrollV = _textLog.maxScrollV;
				}
			}
		}

		public static function updateFieldPosition(x:Number, y:Number):void
		{
			_textLog.x = x;
			_textLog.y = y;

			_textLogShadow.x = x+1;
			_textLogShadow.y = y+1;
		}
 
 		private static function generateTextField(x:int, y:int, width:int , height:int):void
		{
			_textLog = new TextField();
			_textLogShadow = new TextField();
			_textLog.width = _textLogShadow.width = width;
			_textLog.height = _textLogShadow.height = height;
			_textLog.x = _textLogShadow.x = x;
			_textLog.y = _textLogShadow.y = y;
			_textLog.wordWrap = _textLogShadow.wordWrap = true;

			var tf:TextFormat = new TextFormat();
			tf.font = "Verdana";
			tf.color = 0xFFFFFF;
			tf.align = "left";
			tf.bold = true;
			tf.size = 10;
			_textLog.defaultTextFormat = tf;
			_textLog.mouseEnabled = false;

			var tf2:TextFormat = new TextFormat();
			tf2.font = "Verdana";
			tf2.color = 0x333333;
			tf2.align = "left";
			tf2.bold = true;
			tf2.size = 10;
			_textLogShadow.x += 1;
			_textLogShadow.y += 1;
			_textLogShadow.defaultTextFormat = tf2;
			_textLogShadow.mouseEnabled = false;
		}

 	}
 } 