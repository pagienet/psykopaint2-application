package net.psykosoft.psykopaint2.book.views.book.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	public class Page extends ObjectContainer3D
	{
		private var _frontMesh:Mesh;
		private var _backMesh:Mesh;
		private var _frontMaterial:TextureMaterial;
		private var _backMaterial:TextureMaterial;
		private var _width:uint;
		private var _height:uint;
		private var _flipAngle:Number = 0;

		public function Page( width:uint, height:Number ) {
			_width = width;
			_height = height;
			initialize();
		}

		private function initialize():void {
			initializeMeshes();
		}

		private function initializeMeshes():void {

			// Same type of geometry for the front and back faces.
			var geometry:PlaneGeometry = new PlaneGeometry( _width, _height );

			// Front face.
			var frontMaterial:ColorMaterial = new ColorMaterial( 0x666666, 1 );
			_frontMesh = new Mesh( geometry, frontMaterial );
			_frontMesh.x = _width / 2;
			addChild( _frontMesh );

			// Back face.
			var backMaterial:ColorMaterial = new ColorMaterial( 0xFF0000, 1 );
			_backMesh = new Mesh( geometry.clone(), backMaterial );
			_backMesh.x = _width / 2;
			_backMesh.rotationZ = 180;
			addChild( _backMesh );
		}

		public function setImages( frontTexture:BitmapTexture, backTexture:BitmapTexture ):void {

			if( frontTexture ) {
				if( !_frontMaterial ) {
					_frontMaterial = new TextureMaterial( frontTexture, true, false, false );
					_frontMesh.material = _frontMaterial;
				}
				else _frontMaterial.texture = frontTexture;
			}

			if( backTexture ) {
				if( !_backMaterial ) {
					_backMaterial = new TextureMaterial( backTexture, true, false, false );
					_backMesh.material = _backMaterial;
				}
				else _backMaterial.texture = backTexture;
			}
		}

		public function set flipAngle( angleDegrees:Number ):void {
			this.rotationZ = _flipAngle = angleDegrees;
		}

		public function get flipAngle():Number {
			return _flipAngle;
		}
	}
}
