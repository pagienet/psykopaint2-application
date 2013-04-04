package net.psykosoft.psykopaint2.app.view.renderers
{

	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;

	import flash.geom.Rectangle;

	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	public class ImageListItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private var _image:Image;

		public function ImageListItemRenderer() {
			super();
			addEventListener( TouchEvent.TOUCH, onTouch );
		}

		private function onTriggered( event:Event ):void {
			trace( this, "triggered" );
			isSelected = true;
		}

		private function initializeImage( texture:Texture ):void {
			_image = new Image( texture );
			setSizeInternal( _image.width, _image.height, false );
			addChild( _image );
		}

		override protected function draw():void {

			const dataInvalid:Boolean = this.isInvalid( INVALIDATION_FLAG_DATA );

			if( dataInvalid ) {
				initializeImage( data.texture );
			}

			super.draw();
		}

		private var _isSelected:Boolean;

		public function set isSelected( value:Boolean ):void {
			if( _isSelected == value ) {
				return;
			}
			_isSelected = value;
			invalidate( INVALIDATION_FLAG_SELECTED );
			dispatchEventWith( Event.CHANGE );
		}

		public function get isSelected():Boolean {
			return _isSelected;
		}

		private var _data:Object;

		public function set data( value:Object ):void {
			if( _data == value ) {
				return;
			}
			_data = value;
			invalidate( INVALIDATION_FLAG_DATA );
		}

		public function get data():Object {
			return _data;
		}

		private var _index:int = -1;

		public function set index( value:int ):void {
			if( _index == value ) return;
			_index = value;
			invalidate( INVALIDATION_FLAG_DATA );
		}

		public function get index():int {
			return _index;
		}

		private var _owner:List;

		public function set owner( value:List ):void {
			if( _owner == value ) return;
			_owner = value;
			invalidate( INVALIDATION_FLAG_DATA );
		}

		public function get owner():List {
			return _owner;
		}

		private var mIsDown:Boolean;
		private static const MAX_DRAG_DIST:Number = 50;

		private function onTouch( event:TouchEvent ):void {

			var touch:Touch = event.getTouch( this );
			if( touch == null ) return;

			if( touch.phase == TouchPhase.BEGAN && !mIsDown ) {
				mIsDown = true;
			}
			else if( touch.phase == TouchPhase.MOVED && mIsDown ) {
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds( stage );
				if( touch.globalX < buttonRect.x - MAX_DRAG_DIST ||
						touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
						touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
						touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST ) {
					mIsDown = false;
				}
			}
			else if( touch.phase == TouchPhase.ENDED && mIsDown ) {
				mIsDown = false;
				isSelected = !_isSelected;
			}
		}
	}
}
