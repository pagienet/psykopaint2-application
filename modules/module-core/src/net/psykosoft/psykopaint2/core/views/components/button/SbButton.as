package net.psykosoft.psykopaint2.core.views.components.button
{

	import com.greensock.TweenLite;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TweenPlugin;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class SbButton extends Sprite
	{
		// Declared in Flash.
		public var tf:TextField;
		public var labelBg:Sprite;
		public var btnSelected:Sprite;
		public var icon:MovieClip;
		public var pin1:Sprite;
		public var pin2:Sprite;

		//private var _mouseIsDown:Boolean;
		private var _btnLblPos:Point;
		private var _autoCenter:Boolean = true;
		private var _snapToRight:Boolean = false;
		private var _isSelected:Boolean = false;

		private var _id : String;

		public function SbButton() {
			super();

			TweenPlugin.activate([ ColorMatrixFilterPlugin ]);//TODO: activate this just once?
            btnSelected.visible = false;

			tf.mouseEnabled = false;
			tf.selectable = false;

			cacheAsBitmap = true;

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			icon.stop();
			pin1.visible = pin2.visible = false;

			_btnLblPos = new Point( labelBg.x, labelBg.y );
		}

		/**
		 * Used by data-based buttons
		 */
		public function get id() : String
		{
			return _id;
		}

		public function set id(value : String) : void
		{
			_id = value;
		}

		public function set iconBitmap( image:Bitmap ):void {
			// TODO: account for possibility of previously set icon
			if( icon.currentFrameLabel == ButtonIconType.POLAROID ){
				image.width = image.height = 105;
				image.x = 15;
				image.y = 31;
			}
			else{
				image.width = 128;
				image.height = 96;
				image.x = 5;
				image.y = 32;

				// Rotates image and places pin //TODO: move somewhere else so that other button types have pins and rotation
				var random:Number = -2 + Math.random() * 4;
				image.rotation = random;
				if ( Math.round( random ) == 0 ){
					pin2.visible = pin1.visible = true;
				}
				else{
					pin1.visible = true;
					pin1.x = - random * ( image.width/5 );
				}
			}

			icon.addChild( image );
		}

		public function set iconType( type:String ):void {
			//todo: add shape icon, temporary patch added to avoid error:
			if ( type == "param12" ||  type == "param13" ) type = "param7";
			icon.gotoAndStop( type );
			icon.x = -icon.width / 2;
			icon.y = -icon.height / 2;
		}

		public function set labelType( labelType:String ):void {

			if( labelType == ButtonLabelType.CENTER ){
				labelBg.y = _btnLblPos.y - 133;
				tf.y = _btnLblPos.y - 121;
				adjustLabelColor( labelBg );
			}

			var currentName:String = getQualifiedClassName( labelBg );
			if( labelType == currentName ) return;

			removeChild( labelBg );
			labelBg = null;

			tf.visible = true;
			if( labelType != ButtonLabelType.NONE && labelType != ButtonLabelType.NO_BACKGROUND ) {
				var newClipClass:Class = Class( getDefinitionByName( labelType ) );
				labelBg = new newClipClass();
				labelBg.x = _btnLblPos.x;
				labelBg.y = _btnLblPos.y;
				addChildAt( labelBg, 2 );
			}
			else {
				tf.visible = labelType == ButtonLabelType.NO_BACKGROUND;
			}
		}

		function adjustLabelColor( labelBg:Sprite ):void{
			var randomHue:int =  Math.random() * 360;
			var randomSat:Number =  Math.random() + 1;
			TweenLite.to( labelBg, 0, { colorMatrixFilter:{ hue:randomHue, saturation:randomSat }});
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );
			
			invalidateLayout();
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			//if( !_mouseIsDown ) return;
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			icon.scaleX = icon.scaleY = 1;
			icon.x = -icon.width / 2;
			icon.y = -icon.height / 2;
			//_mouseIsDown = false;
		}

		private function onThisMouseDown( event:MouseEvent ):void {
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			icon.scaleX = icon.scaleY = 0.98; // TODO: scaling causes redraw - scroller needs better logic - can we use cacheAsBitmapMatrix or something?
			icon.x = -icon.width / 2;
			icon.y = -icon.height / 2;
			//_mouseIsDown = true;
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
			if( labelBg ) {
				labelBg.width = Math.max( tf.width + 30, 100 );
			}
			if( _autoCenter ) {
				tf.x = -tf.width / 2;
				if( labelBg ) {
					labelBg.x = -labelBg.width / 2;
				}
			}
			if( labelBg ) {
				if( _snapToRight ) tf.x = labelBg.x - labelBg.width + 3;
			}
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
			btnSelected.visible = selected;
			if( visible ) {
				var random = -1 + Math.random()*2;
				btnSelected.x = - random * ( icon.width/3 );
			}
			mouseEnabled = mouseChildren = !selected;
			_isSelected = selected;
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
