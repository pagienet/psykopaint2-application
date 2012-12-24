package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;

	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.assets.away3d.textures.Away3dAtlasTextureDescriptorVO;

	public class PictureFrame extends ObjectContainer3D
	{
		private var _anchorPoints:Vector.<Vector3D>;
		private var _vertexPositions:Vector.<Number>;
		private var _vertexUvs:Vector.<Number>;
		private var _triangleIndices:Vector.<uint>;
		private var _currentVertexIndex:uint;

		private var _picture:Picture;

		private var _frameMesh:Mesh;
		private var _frameSubGeometry:SubGeometry;

		private var _frameMargin:Number;
		private var _frameDepth:Number;

		private var _textureDescriptor:Away3dAtlasTextureDescriptorVO;

		public function PictureFrame( picture:Picture, material:TextureMaterial, textureDescriptor:Away3dAtlasTextureDescriptorVO ) {
			super();

			_frameMargin = 150;
			_frameDepth = 50;

			_picture = picture;
			addChild( _picture );

			material.bothSides = true;

			_textureDescriptor = textureDescriptor;

			// Init mesh.
			_frameSubGeometry = new SubGeometry();
			var frameGeometry:Geometry = new Geometry();
			frameGeometry.addSubGeometry( _frameSubGeometry );
			_frameMesh = new Mesh( frameGeometry, material );
			addChild( _frameMesh );
			invalidateGeometry();

		}

		public function get width():Number {
			return _picture.width + 2 * _frameMargin;
		}

		public function set frameDepth( value:Number ):void {
			_frameDepth = value;
			invalidateGeometry();
		}

		public function get depth():Number {
			return _frameDepth;
		}

		public function set frameMargin( value:Number ):void {
			_frameMargin = value;
			invalidateGeometry();
		}

		public function setPicture( value:Picture ):void {
			if( _picture ) {
				removeChild( _picture );
			}
			_picture = value;
			addChild( _picture );
			invalidateGeometry();
		}

		private function invalidateGeometry():void {

			calculateAnchorPoints();

			// Reset raw buffers.
			_currentVertexIndex = 0;
			_vertexPositions = new Vector.<Number>();
			_vertexUvs = new Vector.<Number>();
			_triangleIndices = new Vector.<uint>();

			// -----------------------
			// Build geometry.
			// -----------------------

			var edgeUvFactor:Number = 1;

			// TL.
			addQuad( 0, 1, 2, 3, getUvRect( _textureDescriptor.tl ) ); // Front
			addQuad( 0, 16, 2, 18, getUvRect( _textureDescriptor.tl, edgeUvFactor, 1 ) ); // Left
			addQuad( 0, 1, 16, 17, getUvRect( _textureDescriptor.tl, 1, edgeUvFactor ) ); // Top
			// TR.
			addQuad( 4, 5, 6, 7, getUvRect( _textureDescriptor.tr ) ); // Front
			addQuad( 21, 5, 23, 7, getUvRect( _textureDescriptor.tr, edgeUvFactor, 1 ) ); // Right
			addQuad( 4, 5, 20, 21, getUvRect( _textureDescriptor.tr, 1, edgeUvFactor ) ); // Top
			// BL.
			addQuad( 8, 9, 10, 11, getUvRect( _textureDescriptor.bl ) ); // Front
			addQuad( 8, 24, 10, 26, getUvRect( _textureDescriptor.bl, edgeUvFactor, 1 ) ); // Left
			addQuad( 26, 27, 10, 11, getUvRect( _textureDescriptor.bl, 1, edgeUvFactor ) ); // Bottom
			// BR.
			addQuad( 12, 13, 14, 15, getUvRect( _textureDescriptor.br ) ); // Front
			addQuad( 29, 13, 31, 15, getUvRect( _textureDescriptor.br, edgeUvFactor, 1 ) ); // Right
			addQuad( 30, 31, 14, 15, getUvRect( _textureDescriptor.br, 1, edgeUvFactor ) ); // Bottom
			// TL-TR.
			addQuad( 1, 4, 3, 6, getUvRect( _textureDescriptor.t ) ); // Front
			addQuad( 1, 4, 17, 20, getUvRect( _textureDescriptor.t, edgeUvFactor, 1 ) ); // Top
			addQuad( 19, 22, 3, 6, getUvRect( _textureDescriptor.t, 1, edgeUvFactor ) ); // Bottom
			// BL-BR.
			addQuad( 9, 12, 11, 14, getUvRect( _textureDescriptor.b ) ); // Front
			addQuad( 9, 12, 25, 28, getUvRect( _textureDescriptor.b, edgeUvFactor, 1 ) ); // Top
			addQuad( 27, 30, 11, 14, getUvRect( _textureDescriptor.b, 1, edgeUvFactor ) ); // Bottom
			// TL-BL.
			addQuad( 3, 9, 2, 8, getUvRect( _textureDescriptor.l ) ); // Front
			addQuad( 18, 24, 2, 8, getUvRect( _textureDescriptor.l, edgeUvFactor, 1 ) ); // Left
			addQuad( 9, 3, 25, 19, getUvRect( _textureDescriptor.l, 1, edgeUvFactor ) ); // Right
			// TR-BR.
			addQuad( 7, 13, 6, 12, getUvRect( _textureDescriptor.r ) ); // Front
			addQuad( 22, 28, 6, 12, getUvRect( _textureDescriptor.r, edgeUvFactor, 1 ) ); // Left
			addQuad( 7, 13, 23, 29, getUvRect( _textureDescriptor.r, 1, edgeUvFactor ) ); // Right

			// Raw buffers -> GPU buffers.
			_frameSubGeometry.updateVertexData( _vertexPositions );
			_frameSubGeometry.updateUVData( _vertexUvs );
			_frameSubGeometry.updateIndexData( _triangleIndices );

		}

		private function addQuad( i0:uint, i1:uint, i2:uint, i3:uint, uvRect:Rectangle ):void {
			var p0:Vector3D = _anchorPoints[ i0 ];
			var p1:Vector3D = _anchorPoints[ i1 ];
			var p2:Vector3D = _anchorPoints[ i2 ];
			var p3:Vector3D = _anchorPoints[ i3 ];
			_vertexPositions.push( p0.x, p0.y, p0.z );
			_vertexPositions.push( p1.x, p1.y, p1.z );
			_vertexPositions.push( p2.x, p2.y, p2.z );
			_vertexPositions.push( p3.x, p3.y, p3.z );
			_vertexUvs.push( uvRect.x, uvRect.y );
			_vertexUvs.push( uvRect.x + uvRect.width, uvRect.y );
			_vertexUvs.push( uvRect.x, uvRect.y + uvRect.height );
			_vertexUvs.push( uvRect.x + uvRect.width, uvRect.y + uvRect.height );
			_triangleIndices.push( _currentVertexIndex, _currentVertexIndex + 1, _currentVertexIndex + 2 );
			_triangleIndices.push( _currentVertexIndex + 1, _currentVertexIndex + 3, _currentVertexIndex + 2 );
			_currentVertexIndex += 4;
		}

		private function getUvRect( rawRect:Rectangle, widthFactor:Number = 1, heightFactor:Number = 1 ):Rectangle {
			var x:Number = rawRect.x / _textureDescriptor.width;
			var y:Number = rawRect.y / _textureDescriptor.height;
			var w:Number = widthFactor * rawRect.width / _textureDescriptor.width;
			var h:Number = heightFactor * rawRect.height / _textureDescriptor.height;
			return new Rectangle( x, y, w, h );
		}

		private function calculateAnchorPoints():void {

			_anchorPoints = new Vector.<Vector3D>();

			var dw:Number = _picture.width / 2;
			var dh:Number = _picture.height / 2;
			var df:Number = _frameMargin;
			var dd:Number = _frameDepth / 2;

			/*

			Point structure ( 32 points ):

			Front:
			0--1----------4--5
			|  |          |  |
			2--3----------6--7
			|  |          |  |
			|  |          |  |
			8--9---------12-13
			|  |          |  |
			10-11--------14-15

			Back: Likewise, from point 16 to 31.

			*/

			// -----------------------
			// Front.
			// -----------------------

			// TL.
			_anchorPoints.push( new Vector3D( -dw - df, dh + df, -dd ) ); // 0
			_anchorPoints.push( new Vector3D( -dw, dh + df, -dd ) ); // 1
			_anchorPoints.push( new Vector3D( -dw - df, dh, -dd ) ); // 2
			_anchorPoints.push( new Vector3D( -dw, dh, -dd ) ); // 3
			// TR.
			_anchorPoints.push( new Vector3D( dw, dh + df, -dd ) ); // 4
			_anchorPoints.push( new Vector3D( dw + df, dh + df, -dd ) ); // 5
			_anchorPoints.push( new Vector3D( dw, dh, -dd ) ); // 6
			_anchorPoints.push( new Vector3D( dw + df, dh, -dd ) ); // 7
			// BL.
			_anchorPoints.push( new Vector3D( -dw - df, -dh, -dd ) ); // 8
			_anchorPoints.push( new Vector3D( -dw, -dh, -dd ) ); // 9
			_anchorPoints.push( new Vector3D( -dw - df, -dh - df, -dd ) ); // 10
			_anchorPoints.push( new Vector3D( -dw, -dh - df, -dd ) ); // 11
			// BR.
			_anchorPoints.push( new Vector3D( dw, -dh, -dd ) ); // 12
			_anchorPoints.push( new Vector3D( dw + df, -dh, -dd ) ); // 13
			_anchorPoints.push( new Vector3D( dw, -dh - df, -dd ) ); // 14
			_anchorPoints.push( new Vector3D( dw + df, -dh - df, -dd ) ); // 15

			// -----------------------
			// Back.
			// -----------------------

			// TL.
			_anchorPoints.push( new Vector3D( -dw - df, dh + df, dd ) ); // 16
			_anchorPoints.push( new Vector3D( -dw, dh + df, dd ) ); // 17
			_anchorPoints.push( new Vector3D( -dw - df, dh, dd ) ); // 18
			_anchorPoints.push( new Vector3D( -dw, dh, dd ) ); // 19
			// TR.
			_anchorPoints.push( new Vector3D( dw, dh + df, dd ) ); // 20
			_anchorPoints.push( new Vector3D( dw + df, dh + df, dd ) ); // 21
			_anchorPoints.push( new Vector3D( dw, dh, dd ) ); // 22
			_anchorPoints.push( new Vector3D( dw + df, dh, dd ) ); // 23
			// BL.
			_anchorPoints.push( new Vector3D( -dw - df, -dh, dd ) ); // 24
			_anchorPoints.push( new Vector3D( -dw, -dh, dd ) ); // 25
			_anchorPoints.push( new Vector3D( -dw - df, -dh - df, dd ) ); // 26
			_anchorPoints.push( new Vector3D( -dw, -dh - df, dd ) ); // 27
			// BR.
			_anchorPoints.push( new Vector3D( dw, -dh, dd ) ); // 28
			_anchorPoints.push( new Vector3D( dw + df, -dh, dd ) ); // 29
			_anchorPoints.push( new Vector3D( dw, -dh - df, dd ) ); // 30
			_anchorPoints.push( new Vector3D( dw + df, -dh - df, dd ) ); // 31

		}
	}
}
