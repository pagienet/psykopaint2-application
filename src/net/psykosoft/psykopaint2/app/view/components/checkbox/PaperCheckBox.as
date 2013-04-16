package net.psykosoft.psykopaint2.app.view.components.checkbox
{
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class PaperCheckBox extends Sprite
	{
		private var _checkboxView:MovieClip;
		private var _selected:Boolean=false;
		private var _initialTouchPosition:Number;
		
		
		public function PaperCheckBox()
		{
			super();
			
			
			 var frames:Vector.<Texture> = Psykopaint2Ui.instance.uiComponentsAtlas.getTextures("checkbox");
			_checkboxView = new MovieClip(frames,5);
			this.addChild(_checkboxView); 
			_checkboxView.useHandCursor=true;
			
			
			_checkboxView.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(e:TouchEvent):void
		{
			
			var touch:Touch = e.touches[0];
			var posX:Number = touch.getLocation(this).x;
			if (touch.phase == TouchPhase.BEGAN){
				_initialTouchPosition=posX; 
				selected =! selected;
				
			}else if (touch.phase == TouchPhase.MOVED){
				
				
				
				
			}else if (touch.phase == TouchPhase.ENDED){
				
			}
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;
			
			if (_selected==true){
				Starling.juggler.tween(_checkboxView,0.15,{currentFrame:4,onUpdate:function(){
					
					_checkboxView.readjustSize()
				}});
			}else {
				Starling.juggler.tween(_checkboxView,0.15,{currentFrame:0});
			}
			
		}

	}
}