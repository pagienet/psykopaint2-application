package net.psykosoft.psykopaint2.book.views.book.content
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class TilePageContent extends Sprite
	{
		private var _posOffsetX:Number;
		private var _posOffsetY:Number;

		public function TilePageContent() {
			super();
		}

		public function set images( bmds:Vector.<BitmapData> ):void {

			var i:uint;
			var len:uint = bmds.length;

			for( i = 0; i < len; ++i ) {

				var bitmap:Bitmap = new Bitmap( bmds[ i ] );
				bitmap.x = _posOffsetX;
				bitmap.y = _posOffsetY;
				addChild( bitmap );

				/*if( _posOffsetX + _cellSize > _creatingPageNum * _visibleWidth ) {
					_posOffsetX = ( _creatingPageNum - 1 ) * _visibleWidth;
					_posOffsetY += tileSize + gap;
				}*/

			}

		}
	}
}
