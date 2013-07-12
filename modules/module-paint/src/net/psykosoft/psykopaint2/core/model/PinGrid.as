package net.psykosoft.psykopaint2.core.model
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class PinGrid
	{
		private var _width:Number;
		private var _height:Number;
		private var _minX:Number;
		private var _minY:Number;
		
		private var _cellSize:Number;
		private var _inverseCellSize:Number;
		
		private var _cells:Vector.<Vector.<Pin>>;
		private var _cols:int;
		private var _rows:int;
		private var _pinToCellIndex:Dictionary;
		private var _cellRect:Rectangle
		private var _bounds:Rectangle
		private var _lookupMap:BitmapData;
		private var _helperShape:Shape;
		
		
		public function PinGrid(minX:Number, maxX:Number, minY:Number, maxY:Number, cellSize:Number)
		{
			init(minX, maxX, minY, maxY, cellSize);
		}
		
		public function init(minX:Number, maxX:Number, minY:Number, maxY:Number, cellSize:Number):void
		{
			_width = maxX - minX;
			_height = maxY - minY;
			_minX = minX;
			_minY = minY;
			_cellSize = cellSize;
			_inverseCellSize = 1 / cellSize;
			_cellRect = new Rectangle(0,0, cellSize, cellSize );
			_bounds = new Rectangle( minX, minY, _width, _height );
			_cols = Math.ceil( _width * _inverseCellSize ) + 1;
			_rows = Math.ceil( _height * _inverseCellSize ) + 1;
			_cells = new Vector.<Vector.<Pin>>(_cols * _rows,true );
			_pinToCellIndex = new Dictionary();
			_lookupMap = new TrackedBitmapData( _cols, _rows, false );
			_helperShape =  new Shape();
			
			clearCells();
		}
		
		public function clearCells():void
		{
			for ( var i:int = 0; i < _cells.length;- i++ )
			{
				_cells[i] = new Vector.<Pin>();
			}
		}
		
		public function addPin( pin:Pin ):void
		{
			var col:int = (pin.x - _minX) * _inverseCellSize;
			var row:int = (pin.y - _minY) * _inverseCellSize;
			var index:int = col + row * _cols;
			_cells[index].push(pin);
			_pinToCellIndex[pin] = index;
		}
		
		public function updatePin( pin:Pin ):void
		{
			var col:int = (pin.x - _minX) * _inverseCellSize;
			var row:int = (pin.y - _minY) * _inverseCellSize;
			if ( col < 0 ) col = 0;
			else if ( col >= _cols ) col = _cols-1;
			
			if ( row < 0 ) row = 0;
			else if ( row >= _rows ) row = _rows-1;
			
			var index:int = col + row * _cols;
			var oldIndex:int = _pinToCellIndex[pin];
			if ( oldIndex != index )
			{
				_cells[index].push(pin);
				_cells[oldIndex].splice( _cells[oldIndex].indexOf(pin),1);
				_pinToCellIndex[pin] = index;
			}
		}
		
		public function getPinsInRect( rect:Rectangle ):Vector.<Pin>
		{
			
			var result:Vector.<Pin> = new Vector.<Pin>();
			
			rect = rect.intersection( _bounds );
			if ( rect.width > 0 )
			{
			
				var minCol:int = (rect.x - _minX) * _inverseCellSize;
				var minRow:int = (rect.y - _minY) * _inverseCellSize;
				var colSpan:int = Math.ceil( rect.width * _inverseCellSize );
				var rowSpan:int = Math.ceil( rect.height * _inverseCellSize );
				_cellRect.x = rect.x - rect.x % _cellSize;
				_cellRect.y = rect.y - rect.y % _cellSize;
				for ( var col:int = 0; col <= colSpan; col++ )
				{
					for ( var row:int = 0; row <= rowSpan; row++ )
					{
						var cell:Vector.<Pin> = _cells[minCol + col + ( minRow + row ) * _cols];
						if ( cell.length > 0 )
						{
							if ( rect.containsRect( _cellRect ) )
							{
								result = result.concat( cell );
							} else {
								for ( var i:int = cell.length; --i > -1; )
								{
									if ( rect.contains( cell[i].x,cell[i].y ))
									{
										result.push( cell[i] );	
									}
								}
							}
						}
					}
				}
			}
			return result;
		}
		
		public function getPinsAroundLine( x1:Number, y1:Number, x2:Number, y2:Number, radius:Number  ):Vector.<Pin>
		{
			var result:Vector.<Pin> = new Vector.<Pin>();
			
			var g:Graphics = _helperShape.graphics;
			g.clear();
			g.beginFill(0xffffff);
			g.drawRect(0,0,_cols,_rows);
			g.endFill()
			g.lineStyle( radius*_inverseCellSize,0 );
			g.moveTo((x1 - _minX)* _inverseCellSize, (y1 - _minY) * _inverseCellSize );
			g.lineTo((x2 - _minX )  * _inverseCellSize, (y2 - _minY ) * _inverseCellSize );
			_lookupMap.draw(_helperShape,null,null,"normal",null,true);
			var rect:Rectangle = _lookupMap.getColorBoundsRect(0xffffffff,0xffffffff,false );
			var cellCheck:Vector.<uint> = _lookupMap.getVector(rect);
				
			var minCol:int = rect.x;
			var minRow:int = rect.y;
			var colSpan:int = rect.width;
			var rowSpan:int = rect.height;
			var i:int = 0;
			for ( var col:int = 0; col <colSpan; col++ )
			{
				for ( var row:int = 0; row < rowSpan; row++ )
				{
					if ( cellCheck[i++] != 0xffffffff )
					{
						result = result.concat(  _cells[minCol + col + ( minRow + row ) * _cols] );
					}
					
				}
			}
			
			return result;
		}
		
		public function getPinsInCircle( x:Number, y:Number,radius:Number  ):Vector.<Pin>
		{
			var result:Vector.<Pin> = new Vector.<Pin>();
			
			var g:Graphics = _helperShape.graphics;
			g.clear();
			g.beginFill(0xffffff);
			g.drawRect(0,0,_cols,_rows);
			g.endFill()
			g.beginFill(0x000000);
			g.drawCircle((x - _minX)* _inverseCellSize, (y - _minY) * _inverseCellSize, radius * _inverseCellSize );
			g.endFill();
				
			_lookupMap.draw(_helperShape,null,null,"normal",null,true);
			var rect:Rectangle = _lookupMap.getColorBoundsRect(0xffffffff,0xffffffff,false );
			var cellCheck:Vector.<uint> = _lookupMap.getVector(rect);
			
			var minCol:int = rect.x;
			var minRow:int = rect.y;
			var colSpan:int = rect.width;
			var rowSpan:int = rect.height;
			var i:int = 0;
			for ( var col:int = 0; col <colSpan; col++ )
			{
				for ( var row:int = 0; row < rowSpan; row++ )
				{
					if ( cellCheck[i++] != 0xffffffff )
					{
						result = result.concat(  _cells[minCol + col + ( minRow + row ) * _cols] );
					}
					
				}
			}
			
			return result;
		}
		
		
	}
}