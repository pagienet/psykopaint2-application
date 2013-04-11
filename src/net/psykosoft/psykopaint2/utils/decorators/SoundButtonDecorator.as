package net.psykosoft.psykopaint2.utils.decorators
{
	import flash.media.Sound;
	import flash.utils.getDefinitionByName;
	
	import starling.display.DisplayObject;
	
	public class SoundButtonDecorator extends AbstractButtonDecorator
	{
		
		private var _decorated : DisplayObject;
		private var _onBeginTouchSoundID : String;
		private var _onEndTouchSoundID : String;
		
		public function SoundButtonDecorator(decorated : DisplayObject,onBeginTouchSoundID : String=null,onEndTouchSoundID : String = null)
		{ 
			super(decorated);
			_onBeginTouchSoundID = onBeginTouchSoundID;
			_onEndTouchSoundID = onEndTouchSoundID; 
			
			_decorated = decorated;
			
		}
		
		
		override protected function onBeginTouch():void{
			var soundClass : Class = getDefinitionByName(_onBeginTouchSoundID) as Class;
			var newSound : Sound = new soundClass();
			newSound.play();
		}	
		
		override protected function onEndTouch():void {
			
			var soundClass : Class = getDefinitionByName(_onEndTouchSoundID) as Class;
			var newSound : Sound = new soundClass();
			newSound.play();
		}		
	
		
		
	
	}
}