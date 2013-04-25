package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;

	import net.psykosoft.psykopaint2.app.utils.TextureUtil;

	public class Easel extends ObjectContainer3D
	{
		private var _height:Number;
		private var _width:Number;

		private var _easelMesh:Mesh;
		private var _pictureMesh:Mesh;
		private var _frameMesh:Mesh;

		public function Easel( image:BitmapData ) {
			super();

			_width = image.width;
			_height = image.height;

			var tri:Trident = new Trident( 250 );
			addChild( tri );

			// Init easel mesh.
			_easelMesh = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( image );
//			TextureMaterial( _easelMesh.material ).alphaThreshold = 0.0001; // Testing binary transparency, if it looks bad, use alphaBlending instead.material.smooth = true;
			TextureMaterial( _easelMesh.material ).alphaBlending = true;
			_easelMesh.rotationX = -90;
			addChild( _easelMesh );

			// Init frame mesh.
			var frameGeometry:CubeGeometry = new CubeGeometry( 1024, 768, 25 ); // TODO: must adapt to the size of the canvas
			var frameMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF, 1 );
			_frameMesh = new Mesh( frameGeometry, frameMaterial );
			_frameMesh.y = 768 / 2 - 155; // TODO: must adapt to the size of the canvas
			_frameMesh.z = -25;
			addChild( _frameMesh );

			// Init picture mesh.
			var pictureDummyImage:BitmapData = new BitmapData( frameGeometry.width, frameGeometry.height, false, 0 );
			pictureDummyImage.perlinNoise( 50, 50, 8, 1, false, true, 7, true );
			_pictureMesh = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( pictureDummyImage );
			_pictureMesh.rotationX = -90;
			_pictureMesh.y = _frameMesh.y;
			_pictureMesh.z = _frameMesh.z - frameGeometry.depth / 2 - 1;
			addChild( _pictureMesh );
		}

		override public function dispose():void {

			var material:TextureMaterial = _easelMesh.material as TextureMaterial;
			var texture:BitmapTexture = material.texture as BitmapTexture;
			texture.dispose();
			material.dispose();
			_easelMesh.dispose();
			_easelMesh = null;

			super.dispose();
		}

		public function get width():Number {
			return _width;
		}
	}
}
