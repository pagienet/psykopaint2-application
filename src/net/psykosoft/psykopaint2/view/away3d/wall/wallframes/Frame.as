package net.psykosoft.psykopaint2.view.away3d.wall.wallframes
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Frame extends ObjectContainer3D
	{
		private var _edgeMesh:Mesh;
		private var _frontMesh:Mesh;
		private var _lightPicker:StaticLightPicker;
		private var _frontTexture:BitmapTexture;
		private var _paintingDimensions:Point;
		private var _frameTextureDimensions:Point;
		private var _frameTextureContentArea:Rectangle;

		private const GEOMETRY_SIZE:uint = 1024;
		private const FRAME_DEPTH:Number = 25;

		public function Frame( lightPicker:StaticLightPicker, frontTexture:BitmapTexture, frameTextureDimensions:Point, frameTextureContentArea:Rectangle ) {
			super();

			_lightPicker = lightPicker;
			_frontTexture = frontTexture;
			_frameTextureDimensions = frameTextureDimensions;
			_frameTextureContentArea = frameTextureContentArea;

			initializeEdge();
			initializeFront();
		}

		private function initializeEdge():void {

			var edgeMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			edgeMaterial.ambient = 0.1;
			edgeMaterial.specular = 0.05;
			edgeMaterial.gloss = 1;
			edgeMaterial.lightPicker = _lightPicker;

			_edgeMesh = new Mesh( new CubeGeometry( GEOMETRY_SIZE, GEOMETRY_SIZE, FRAME_DEPTH ), edgeMaterial );
			addChild( _edgeMesh );

		}

		private function initializeFront():void {

			var frontMaterial:TextureMaterial = new TextureMaterial( _frontTexture );
//			frontMaterial.alphaBlending = true;
			frontMaterial.ambient = 0.1;
			frontMaterial.specular = 0.05;
			frontMaterial.gloss = 1;
			frontMaterial.lightPicker = _lightPicker;

			_frontMesh = new Mesh( new PlaneGeometry( GEOMETRY_SIZE, GEOMETRY_SIZE ), frontMaterial );
			_frontMesh.z = -FRAME_DEPTH / 2 - 200;
			_frontMesh.rotationX = -90;
			addChild( _frontMesh );

		}

		// TODO: give frames the ability to adjust to image, to adjust to image with a margin and to keep or not keep aspect ratio.
		public function fitToPainting( paintingWidth:Number, paintingHeight:Number ):void {
			trace( this, " - fitting frame to painting of dimensions: " + paintingWidth + ", " + paintingWidth );
			_paintingDimensions = new Point( paintingWidth, paintingHeight );
			fitFront();
			fitEdge();
		}

		private function fitFront():void {
			var pantingLargestSide:Number = Math.max( _paintingDimensions.x, _paintingDimensions.y );
			// frame content area must accommodate this side
			_frontMesh.scaleX = ( pantingLargestSide / _frameTextureContentArea.x ) / GEOMETRY_SIZE;
			_frontMesh.scaleZ = _frontMesh.scaleX;
		}

		private function fitEdge():void {

			// Identify original frame dimensions.
			var originalFrameWidth:Number = _edgeMesh.maxX - _edgeMesh.minX;
			var originalFrameHeight:Number = _edgeMesh.maxY - _edgeMesh.minY;

			// Scale frame edge.
			var marginFactor:Number = 1.2;
			_edgeMesh.scaleX = marginFactor * _paintingDimensions.x / originalFrameWidth;
			_edgeMesh.scaleY = marginFactor * _paintingDimensions.y / originalFrameHeight;
			_edgeMesh.scaleZ = _edgeMesh.scaleX;
		}

		public function get width():Number {
			return ( _edgeMesh.maxX - _edgeMesh.minX ) * _edgeMesh.scaleX;
		}

		public function get height():Number {
			return ( _edgeMesh.maxY - _edgeMesh.minY ) * _edgeMesh.scaleY;
		}

		public function get depth():Number {
			return ( _edgeMesh.maxZ - _edgeMesh.minZ ) * _edgeMesh.scaleZ;
		}
	}
}
