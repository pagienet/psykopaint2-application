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

	import net.psykosoft.psykopaint2.view.away3d.wall.wallframes.frames.FrameTextureDescriptorVO;

	public class Frame extends ObjectContainer3D
	{
		private var _edgeMesh:Mesh;
		private var _frontMesh:Mesh;
		private var _lightPicker:StaticLightPicker;
		private var _paintingDimensions:Point;
		private var _frontTexture:BitmapTexture;
		private var _frontTextureDescription:FrameTextureDescriptorVO;
		private var _frameWidth:Number;
		private var _frameHeight:Number;
		private var _frameColor:uint;

		private const GEOMETRY_SIZE:uint = 1024;
		private const FRAME_DEPTH:Number = 50;

		public function Frame( lightPicker:StaticLightPicker, frameColor:uint, frontTexture:BitmapTexture, frontTextureDescription:FrameTextureDescriptorVO ) {
			super();

			_lightPicker = lightPicker;
			_frameColor = frameColor;
			_frontTexture = frontTexture;
			_frontTextureDescription = frontTextureDescription;

			initializeEdge();
			initializeFront();
		}

		private function initializeEdge():void {

			var edgeMaterial:ColorMaterial = new ColorMaterial( _frameColor );
			edgeMaterial.ambient = 0.7;
			edgeMaterial.specular = 0;
			edgeMaterial.gloss = 100;
			edgeMaterial.lightPicker = _lightPicker;

			_edgeMesh = new Mesh( new CubeGeometry( GEOMETRY_SIZE, GEOMETRY_SIZE, FRAME_DEPTH ), edgeMaterial );
			addChild( _edgeMesh );

		}

		private function initializeFront():void {

			var frontMaterial:TextureMaterial = new TextureMaterial( _frontTexture );
			frontMaterial.smooth = true;
			frontMaterial.alphaBlending = true;

			_frontMesh = new Mesh( new PlaneGeometry( GEOMETRY_SIZE, GEOMETRY_SIZE ), frontMaterial );
			_frontMesh.rotationX = -90;
			addChild( _frontMesh );

		}

		// TODO: give frames the ability to adjust to image, to adjust to image with a margin and to keep or not keep aspect ratio.
		public function fitToPainting( paintingWidth:Number, paintingHeight:Number ):void {
			trace( this, " - fitting frame to painting of dimensions: " + paintingWidth + ", " + paintingWidth );

			_paintingDimensions = new Point( paintingWidth, paintingHeight );

			trace( this, "fitFront() --------------------------" );

			trace( "frame descriptor: " + _frontTextureDescription );
			trace( "painting content dimensions: " + _paintingDimensions.x + ", " + _paintingDimensions.y );

			// -----------------------
			// Fit front geometry.
			// -----------------------

			var ratio:Number;
			var tolerance:Number = 1.01;

			// Determine portrait or landscape nature of painting.
			var landscape:Boolean = _paintingDimensions.x > _paintingDimensions.y;
			if( landscape ) {

				trace( "fitting landscape painting" );

				// The painting's width needs to fit into the frame's painting area width.
				// Compare their sizes.
				ratio = tolerance * _paintingDimensions.x / _frontTextureDescription.paintingAreaWidth;
				trace( "image width to painting area width ratio: " + ratio );

				// Calculate the frame's altered image dimensions.
				_frameWidth = _frontTextureDescription.imageWidth * ratio;
				_frameHeight = _frontTextureDescription.imageHeight * ratio;

				// Use ratio to calculate the frame texture's width.
				var alteredTextureWidth:Number = _frontTextureDescription.textureWidth * ratio;
				var alteredTextureHeight:Number = _frontTextureDescription.textureHeight * ratio;
				trace( "frame texture width should be: " + alteredTextureWidth + ", " + alteredTextureHeight );

				// Fit front geometry to front texture dimensions.
				scaleFrontToFit( alteredTextureWidth, alteredTextureHeight );

			}
			else {
				trace( "fitting portrait painting" );
				// TODO.
				throw new Error( "Frame.as cannot handle portrait paintings yet." );
			}

			// -----------------------
			// Fit edge geometry.
			// -----------------------

			scaleEdgeToFit( _frameWidth, _frameHeight );
		}

		private function scaleFrontToFit( width:Number, height:Number ):void {
			_frontMesh.scaleX = width / GEOMETRY_SIZE;
			_frontMesh.scaleZ = height / GEOMETRY_SIZE;
		}

		private function scaleEdgeToFit( width:Number, height:Number ):void {
			_edgeMesh.scaleX = width / GEOMETRY_SIZE;
			_edgeMesh.scaleY = height / GEOMETRY_SIZE;
			_edgeMesh.scaleZ = _edgeMesh.scaleX;
			_frontMesh.z = -_edgeMesh.scaleZ * FRAME_DEPTH / 2 - 2;
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
