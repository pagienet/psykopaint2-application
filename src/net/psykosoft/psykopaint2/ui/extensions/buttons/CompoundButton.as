package net.psykosoft.psykopaint2.ui.extensions.buttons
{

	import feathers.controls.Button;
	
	import net.psykosoft.psykopaint2.app.view.navigation.NavigationPaperButton;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;
	import net.psykosoft.psykopaint2.utils.decorators.MoveButtonDecorator;
	
	import starling.animation.Transitions;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	public class CompoundButton extends Sprite
	{
		private var _texture:Texture;
		private var _label:String;
		private var _labelType:String;
		private var _labelGap:Number;
		private var _mainButton:NavigationPaperButton;
		private var _labelButton:Button;
		private var _width:Number = 125;


		public var placementFunction:Function;


		public function CompoundButton( texture:Texture,label:String, labelType:String, verticalGap:Number = 0 ) {
			super();
			
			if(texture==null){
				throw new Error("[CompoundButton] Hey buddy The texture is null ");
			}
			_texture = texture;
			_label = label;
			_labelType = labelType;
			_labelGap = verticalGap;
			
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			_mainButton = new NavigationPaperButton(_texture,"");
			_mainButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			addChild( _mainButton );
			new MoveButtonDecorator(_mainButton,0.2,{scaleX:0.98,scaleY:0.98,transition:Transitions.EASE_OUT});


			_labelButton = new Button();
			_labelButton.nameList.add( _labelType );
			_labelButton.label = label;
			_labelButton.isEnabled = false;
			_labelButton.addEventListener( Event.RESIZE, onLabelResized );
			_labelButton.addEventListener( Event.ADDED_TO_STAGE, onBtnAddedToStage );
			addChild( _labelButton );

			_labelButton.y = height + _labelGap;
		}

		override public function dispose():void {

			removeChild( _mainButton );
			_mainButton.removeEventListener( Event.TRIGGERED, onButtonTriggered );
			_mainButton.removeEventListener( Event.ADDED_TO_STAGE, onBtnAddedToStage );
			_mainButton.dispose();
			_mainButton = null;

			removeChild( _labelButton );
			_labelButton.removeEventListener( Event.TRIGGERED, onButtonTriggered );
			_labelButton.removeEventListener( Event.RESIZE, onLabelResized );
			_labelButton.dispose();
			_labelButton = null;

			super.dispose();
		}

		private function onBtnAddedToStage( event:Event ):void {
			var button:Button = event.target as Button;
			button.removeEventListener( Event.ADDED_TO_STAGE, onBtnAddedToStage );
			button.autoFlatten = true;
		}

		private function onLabelResized( event:Event ):void {
			// Aligns the lower button according to its width.
			var w:Number = _labelButton.width;
			if( placementFunction == null) {
				_labelButton.x = width / 2 - w / 2;
				if( w > _width ) {
					_width = w;
				}
			}
			else {
				placementFunction();
			}
		}

		private function onButtonTriggered( event:Event ):void {
			dispatchEvent( event );
		}

		override public function get width():Number {
			return 125;
		}

		override public function get height():Number {
			return 125;
		}

		public function set label( value:String ):void {
			_labelButton.label = _label = value;
		}

		public function get label():String {
			return _label;
		}

		public function get labelButton():Button {
			return _labelButton;
		}

		public function get mainButton():NavigationPaperButton {
			return _mainButton;
		}
		
		public function get texture():Texture
		{
			return _texture;
		}
		
		public function set texture(value:Texture):void
		{
			_texture = value;
			_mainButton.upState=value;
		}
		
	}
}
