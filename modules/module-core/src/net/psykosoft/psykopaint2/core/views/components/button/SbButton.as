package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;

	public class SbButton extends Sprite
	{
		// Declared in Flash.
		public var tf:TextField;
		public var labelBg:Sprite;
		public var btnSelected:Sprite;
		public var icon:MovieClip;

		private var _mouseIsDown:Boolean;
		private var _btnLblPos:Point;
        private var _isSelectable:Boolean = false;
		private var _autoCenter:Boolean = true;
		private var _snapToRight:Boolean = false;
		private var _parentOnMouseDownX:Number;
		private var _isSelected:Boolean;

		public function SbButton() {
			super();

            btnSelected.visible = false;

			tf.mouseEnabled = false;
			tf.selectable = false;

			cacheAsBitmap = true;

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			icon.stop();

			_btnLblPos = new Point( labelBg.x, labelBg.y );
		}

		public function setIcon( image:Bitmap ):void {
			// TODO: account for possibility of previously set icon
			image.width = image.height = 100;
			image.x = icon.width / 2 - 50;
			image.y = icon.height / 2 - 50;
			icon.addChild( image );
		}

		public function setIconType( type:String ):void {
			//todo: add shape icon, temporary patch added to avoid error:
			if ( type == "param12" ) type = "param7";
			icon.gotoAndStop( type );
			icon.x = -icon.width / 2;
			icon.y = -icon.height / 2;
		}

		public function setLabelType( labelType:String ):void {
			var currentName:String = getQualifiedClassName( labelBg );
			if( labelType == currentName ) return;
			removeChild( labelBg );
			labelBg = null;
			var newClipClass:Class = Class( getDefinitionByName( labelType ) );
			labelBg = new newClipClass();
			tf.visible = true;
			labelBg.visible = true;
			labelBg.x = _btnLblPos.x;
			labelBg.y = _btnLblPos.y;
			addChildAt(labelBg, 2);

			if ( labelType == ButtonLabelType.NONE ) {
				tf.visible = false;
				labelBg.visible = false;
			}
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );
			addEventListener( MouseEvent.CLICK, onThisMouseClick );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			invalidateLayout();
		}

		private function onThisMouseClick( event:MouseEvent ):void {
			if( isSelectable && parent && parent.x == _parentOnMouseDownX ) toggleSelect( true );
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			if( !_mouseIsDown ) return;
			icon.scaleX = icon.scaleY = 1;
			icon.x = -icon.width / 2;
			icon.y = -icon.height / 2;
			_mouseIsDown = false;
		}

		private function onThisMouseDown( event:MouseEvent ):void {
			_parentOnMouseDownX = parent.x;
			icon.scaleX = icon.scaleY = 0.98; // TODO: scaling causes redraw - scroller needs better logic - can we use cacheAsBitmapMatrix or something?
			icon.x = -icon.width / 2;
			icon.y = -icon.height / 2;
			_mouseIsDown = true;
		}

		public function set labelText( value:String ):void {
			tf.text = value;
			invalidateLayout();
		}

		public function get labelText():String {
			return tf.text;
		}

		public function dispose():void {
			removeChild( tf );
			tf = null;
		}

		private function invalidateLayout():void {
			// Update label.
			tf.width = tf.textWidth + 10;
			tf.height = 1.25 * tf.textHeight;
            labelBg.width = Math.max ( tf.width + 30, 100 );
			if( _autoCenter ) {
				tf.x = -tf.width / 2;
				labelBg.x = -labelBg.width / 2;
			}
			if( _snapToRight ) tf.x = labelBg.x - labelBg.width + 3;
		}

		public function displaceLabelBg( dx:Number, dy:Number ):void {
			labelBg.x += dx;
			labelBg.y += dy;
		}

		public function displaceLabelTf( dx:Number, dy:Number ):void {
			tf.x += dx;
			tf.y += dy;
		}

		public function setTextAlign( value:String ):void {
			tf.defaultTextFormat.align = value;
		}

		public function autoCenterLabel( value:Boolean ):void {
			_autoCenter = value;
		}

		public function snapLabelToRight( value:Boolean ):void {
			_snapToRight = value;
		}

		public function useLabelBg( value:Boolean ):void {
			tf.background = value;
			tf.backgroundColor = 0xFF0000;
		}

		public function toggleSelect( selected:Boolean ):void {
			if( !_isSelectable ) return;
			btnSelected.visible = selected;
			if( visible ) {
				btnSelected.scaleX = Math.random() > 0.5 ? 1 : -1;
				btnSelected.scaleY = Math.random() > 0.5 ? 1 : -1;
			}
			mouseEnabled = mouseChildren = !selected;
			_isSelected = selected;
		}

		public function get isSelectable():Boolean {
			return _isSelectable;
		}

		public function set isSelectable( value:Boolean ):void {
			_isSelectable = value;
			if( !value && btnSelected.visible ) {
				btnSelected.visible = false;
			}
		}

		public function get isSelected():Boolean {
			return _isSelected;
		}

		override public function get width():Number {
			return 115;
		}

		override public function get height():Number {
			return 105;
		}
	}
}
