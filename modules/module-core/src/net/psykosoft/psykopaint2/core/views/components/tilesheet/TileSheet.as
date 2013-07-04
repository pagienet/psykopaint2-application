package net.psykosoft.psykopaint2.core.views.components.tilesheet
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.components.HPageScroller;

	public class TileSheet extends HPageScroller
	{
		protected var _tileSize:uint;

		private var _cellSize:uint;
		private var _thumbX:Number;
		private var _thumbY:Number;
		private var _creatingPageNum:uint;
		private var _bitmaps:Vector.<Bitmap>;
		private var _numberOfItemsPerPage:uint;

		protected var _activePageIndex:uint;

		public function TileSheet() {
			super();
			addEventListener( MouseEvent.CLICK, onClick );
			_positionManager.closestSnapPointChangedSignal.add( onClosestSnapPointChanged );
		}

		protected function onClosestSnapPointChanged( snapPointIndex:uint ):void {
			_activePageIndex = snapPointIndex;
		}

		private function onClick( event:MouseEvent ):void {
			var column:int = mouseX / _cellSize;
			var row:int = mouseY / _cellSize;
			var thumbIndex:uint = _numberOfItemsPerPage * _activePageIndex + row * int( _visibleWidth / _cellSize ) + column;
			onTileClicked( thumbIndex );
		}

		protected function onTileClicked( tileIndex:uint ):void {
			// Override.
		}

		override public function reset():void {
			super.reset();
			_thumbX = _thumbY = 0;
			_creatingPageNum = 1;
			_bitmaps = new Vector.<Bitmap>();
		}

		public function initializeWithProperties( numTiles:uint, tileSize:uint ):void {
			reset();

			var gap:Number = 20;
			_tileSize = tileSize;
			_cellSize = tileSize + gap;
			_numberOfItemsPerPage = Math.floor( _visibleWidth / _cellSize ) * Math.floor( _visibleHeight / _cellSize );

			var bmd:BitmapData = new BitmapData( tileSize, tileSize, false, 0xFFFFFF );

			for( var i:uint; i < numTiles; ++i ) {

				// Display bitmap ( window ).
				var bitmap:Bitmap = new Bitmap( bmd );
				bitmap.x = _thumbX;
				bitmap.y = _thumbY;
				addChild( bitmap );
				_bitmaps.push( bitmap );

				// Advance in scroller space.
				_thumbX += _cellSize;
				// Next x is off the right edge of the page?
				if( _thumbX + _cellSize > _creatingPageNum * _visibleWidth ) {
					_thumbX = ( _creatingPageNum - 1 ) * _visibleWidth;
					_thumbY += tileSize + gap;
				}
				// Next y is off the bottom edge of the page?
				if( _thumbY + _cellSize > _visibleHeight ) {
					_creatingPageNum++;
					_thumbX = ( _creatingPageNum - 1 ) * _visibleWidth;
					_thumbY = 0;
				}
			}

			invalidateContent();
		}

		public function setTileContentFromSpriteSheet( bmd:BitmapData, bmdX:Number, bmdY:Number, tileIndex:uint ):void {
			var bitmap:Bitmap = _bitmaps[ tileIndex ];
			bitmap.bitmapData = bmd;
			bitmap.scrollRect = new Rectangle( bmdX, bmdY, _tileSize, _tileSize );
		}

		public function get numberOfItemsPerPage():uint {
			return _numberOfItemsPerPage;
		}
	}
}
