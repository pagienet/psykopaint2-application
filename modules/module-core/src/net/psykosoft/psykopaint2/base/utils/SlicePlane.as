package net.psykosoft.psykopaint2.base.utils
{

	import away3d.core.base.CompactSubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.GeomUtil;

	public class SlicePlane extends Mesh
	{
		private var _sliceLeft:Number; // Always distances from edges.
		private var _sliceRight:Number;
		private var _sliceTop:Number;
		private var _sliceBottom:Number;
		private var _originalWidth:Number;
		private var _originalHeight:Number;

		public function SlicePlane( bmd:BitmapData ) {
			var material:TextureMaterial = new TextureMaterial( new BitmapTexture( bmd ) );
			var geometry:PlaneGeometry = new PlaneGeometry( bmd.width, bmd.height, 3, 3 );
			_sliceLeft = 0; _sliceRight = _originalWidth = bmd.width;
			_sliceTop = 0; _sliceBottom = _originalHeight = bmd.height;
			super( geometry, material );
		}

		public function setSlices( left:Number, right:Number, top:Number, bottom:Number ):void {
			_sliceLeft = left;
			_sliceRight = right;
			_sliceTop = top;
			_sliceBottom = bottom;
			// Adjust column uvs.
			setVertexColumnU( 1, _sliceLeft / _originalWidth );
			setVertexColumnU( 2, 1 - _sliceLeft / _originalWidth );
			// Adjust row uvs.
			setVertexRowV( 1, 1 - _sliceBottom / _originalHeight );
			setVertexRowV( 2, _sliceTop / _originalHeight );
		}

		public function set width( value:Number ):void {
			var hw:Number = value / 2;
			setVertexColumnPosition( 0, -hw ); // Column 0 to ratio 0.
			setVertexColumnPosition( 1, -hw + _sliceLeft ); // Column 1 to sliceMinX.
			setVertexColumnPosition( 2,  hw - _sliceRight ); // Column 2 to sliceMaxX.
			setVertexColumnPosition( 3,  hw ); // Column 3 to 1.
		}

		public function set height( value:Number ):void {
			var hh:Number = value / 2;
			setVertexRowPosition( 0, -hh ); // Column 0 to ratio 0.
			setVertexRowPosition( 1, -hh + _sliceTop ); // Column 1 to sliceMinX.
			setVertexRowPosition( 2,  hh - _sliceBottom ); // Column 2 to sliceMaxX.
			setVertexRowPosition( 3,  hh ); // Column 3 to 1.
		}

		// -----------------------
		// Rows.
		// -----------------------

		private function setVertexRowPosition( rowIndex:uint, yPosition:Number ):void {
			var subGeom:CompactSubGeometry = _geometry.subGeometries[ 0 ] as CompactSubGeometry;
			var buffer:Vector.<Number> = subGeom.vertexData;
			for( var i:uint; i < 4; ++i ) {
				var vertIndex:uint = rowIndex * 4 + i;
				var compIndex:uint = vertIndex * 13;
				buffer[ compIndex + 2 ] = yPosition;
			}
		}

		private function setVertexRowV( rowIndex:uint, vValue:Number ):void {
			var subGeom:CompactSubGeometry = _geometry.subGeometries[ 0 ] as CompactSubGeometry;
			var buffer:Vector.<Number> = subGeom.vertexData;
			for( var i:uint; i < 4; ++i ) {
				var vertIndex:uint = rowIndex * 4 + i;
				var compIndex:uint = vertIndex * 13 + 9;
				buffer[ compIndex + 1 ] = vValue;
			}
		}

		// -----------------------
		// Columns.
		// -----------------------

		private function setVertexColumnPosition( columnIndex:uint, xPosition:Number ):void {
			var subGeom:CompactSubGeometry = _geometry.subGeometries[ 0 ] as CompactSubGeometry;
			var buffer:Vector.<Number> = subGeom.vertexData;
			for( var i:uint; i < 4; ++i ) {
				var vertIndex:uint = i * 4 + columnIndex;
				var compIndex:uint = vertIndex * 13;
				buffer[ compIndex ] = xPosition;
			}
		}

		private function setVertexColumnU( columnIndex:uint, uValue:Number ):void {
			var subGeom:CompactSubGeometry = _geometry.subGeometries[ 0 ] as CompactSubGeometry;
			var buffer:Vector.<Number> = subGeom.vertexData;
			for( var i:uint; i < 4; ++i ) {
				var vertIndex:uint = i * 4 + columnIndex;
				var compIndex:uint = vertIndex * 13 + 9;
				buffer[ compIndex ] = uValue;
			}
		}

		public function traceVertices():void {
			var subGeom:CompactSubGeometry = _geometry.subGeometries[ 0 ] as CompactSubGeometry;
			var buffer:Vector.<Number> = subGeom.vertexData;
			var numVertices:uint = buffer.length / 13;
			var vx:Number, vy:Number, vz:Number;
			for( var i:uint; i < numVertices; ++i ) {
				var compIndex:uint = i * 13;
				vx = buffer[ compIndex     ];
				vy = buffer[ compIndex + 1 ];
				vz = buffer[ compIndex + 2 ];
				GeomUtil.traceVertex( this, i, vx, vy, vz );
			}
		}
	}
}
