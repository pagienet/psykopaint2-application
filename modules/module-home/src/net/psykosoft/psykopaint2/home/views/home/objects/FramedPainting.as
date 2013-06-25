package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;

	/*
	* Contains a painting within a frame.
	* */
	public class FramedPainting extends ObjectContainer3D
	{
		private var _painting:Painting;
		private var _frame:Frame;

		public function FramedPainting() {
			super();
		}

		override public function dispose():void {
			if( _painting ) {
				_painting.dispose();
				_painting = null;
			}
			if( _frame ) {
				_frame.dispose();
				_frame = null;
			}
			super.dispose();
		}

		public function setPainting( value:Painting ):void {
			if( _painting ) {
				removeChild( _painting );
			}
			_painting = value;
			addChild( _painting );
		}

		public function setFrame( frame:Frame ):void {
			if( _frame ) {
				removeChild( _frame );
			}
			_frame = frame;
			addChild( _frame );
		}

		public function get width():Number {
			return _frame.width;
		}

		public function get height():Number {
			return _frame.height;
		}

		public function get depth():Number {
			return _frame.depth;
		}
	}
}
