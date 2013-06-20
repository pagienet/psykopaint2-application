package net.psykosoft.psykopaint2.base.utils.gpu
{

	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;

	import net.psykosoft.psykopaint2.base.utils.gpu.GeomUtil;

	public class SlicePlane extends Mesh
	{
		private var _sliceLeft:Number; // Always distances from edges.
		private var _sliceRight:Number;
		private var _sliceTop:Number;
		private var _sliceBottom:Number;
		private var _originalWidth:Number;
		private var _originalHeight:Number;
		private var _material:TextureMaterial;
		private var _width:Number;
		private var _height:Number;

		public function SlicePlane( material:TextureMaterial, textureWidth:Number, textureHeight:Number ) {
			var geometry:PlaneGeometry = new PlaneGeometry( textureWidth, textureHeight, 3, 3 );
			_sliceLeft = 0; _sliceRight = _originalWidth = _width = textureWidth;
			_sliceTop = 0; _sliceBottom = _originalHeight = _height = textureHeight;
			super( geometry, material/*new ColorMaterial( 0xFF0000 )*/ );
		}

		public function setSlices( left:Number, right:Number, top:Number, bottom:Number ):void {
			_sliceLeft = left;
			_sliceRight = right;
			_sliceTop = top;
			_sliceBottom = bottom;
			// Adjust column uvs.
			setVertexColumnU( 1, _sliceLeft / _originalWidth );
			setVertexColumnU( 2, 1 - _sliceRight / _originalWidth );
			// Adjust row uvs.
			setVertexRowV( 1, 1 - _sliceBottom / _originalHeight );
			setVertexRowV( 2, _sliceTop / _originalHeight );
		}

		public function set width( value:Number ):void {
			_width = value;
			var hw:Number = value / 2;
			setVertexColumnPosition( 0, -hw ); // Column 0 to ratio 0.
			setVertexColumnPosition( 1, -hw + _sliceLeft ); // Column 1 to sliceMinX.
			setVertexColumnPosition( 2,  hw - _sliceRight ); // Column 2 to sliceMaxX.
			setVertexColumnPosition( 3,  hw ); // Column 3 to 1.
		}

		public function set height( value:Number ):void {
			_height = value;
			var hh:Number = value / 2;
			setVertexRowPosition( 0, -hh ); // Column 0 to ratio 0.
			setVertexRowPosition( 1, -hh + _sliceBottom ); // Column 1 to sliceMinX.
			setVertexRowPosition( 2,  hh - _sliceTop ); // Column 2 to sliceMaxX.
			setVertexRowPosition( 3,  hh ); // Column 3 to 1.
		}

		override public function clone():Object3D {
			var clone:SlicePlane = new SlicePlane( _material, _originalWidth, _originalHeight );
			clone.setSlices( _sliceLeft, _sliceRight, _sliceTop, _sliceBottom );
			clone.transform = transform.clone();
			return  clone;
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

		public function get width():Number {
			return _width;
		}

		public function get height():Number {
			return _height;
		}
	}
}
