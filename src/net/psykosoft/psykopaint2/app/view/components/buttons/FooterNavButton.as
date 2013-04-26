package net.psykosoft.psykopaint2.app.view.components.buttons
{

	import net.psykosoft.psykopaint2.app.view.components.label.PaperHeaderLabel;
	import net.psykosoft.psykopaint2.app.view.navigation.NavigationPaperButton;
	import net.psykosoft.psykopaint2.utils.decorators.buttons.MoveButtonDecorator;
	
	import starling.animation.Transitions;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	public class FooterNavButton extends Sprite
	{
		private var _texture:Texture;
		private var _label:String;
		private var _labelType:String;
		private var _labelGap:Number;
		private var _mainButton:NavigationPaperButton;
		private var _headerLabel:PaperHeaderLabel;
		private var _width:Number = 125;


		public var placementFunction:Function;


		public function FooterNavButton( texture:Texture,label:String, labelType:String, verticalGap:Number = 0 ) {
			super();
			
			if(texture==null){
				throw new Error("[FooterNavButton] Hey buddy The texture is null ");
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


			_headerLabel = new PaperHeaderLabel();
			addChild( _headerLabel );
			_headerLabel.setLabel(label);
			_headerLabel.x = _mainButton.width/2 - _headerLabel.width/2;
			//_labelButton.nameList.add( _labelType );
			//_labelButton.label = label;
			//_labelButton.isEnabled = false;
			_headerLabel.addEventListener( Event.RESIZE, onLabelResized );
			

			_headerLabel.y = height + _labelGap;
		}

		override public function dispose():void {

			removeChild( _mainButton );
			_mainButton.removeEventListener( Event.TRIGGERED, onButtonTriggered );
			_mainButton.dispose();
			_mainButton = null;

			removeChild( _headerLabel );
			_headerLabel.removeEventListener( Event.RESIZE, onLabelResized );
			_headerLabel.dispose();
			_headerLabel = null;

			super.dispose();
		}

	

		private function onLabelResized( event:Event ):void {
			// Aligns the lower button according to its width.
			var w:Number = _headerLabel.width;
			if( placementFunction == null) {
				_headerLabel.x = width / 2 - w / 2;
				if( w > _width ) {
					_width = w;
				}
			}
			else {
				placementFunction();
			}
		}

		// NOTE: disabled by Li because it causes nav buttons to trigger twice on click and ugly bugs on the app
		// TODO: clean up
		private function onButtonTriggered( event:Event ):void {
//			trace( this, "onButtonTriggered()" );
//			dispatchEvent( event );
		}

		override public function get width():Number {
			return 125;
		}

		override public function get height():Number {
			return 125;
		}

		public function set label( value:String ):void {
			_headerLabel.setLabel(value);
			_label = value;
		}

		public function get label():String {
			return _label;
		}

		public function get labelView():PaperHeaderLabel {
			return _headerLabel;
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
