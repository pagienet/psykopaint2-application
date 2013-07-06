package net.psykosoft.psykopaint2.book.views.book.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
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

		public var frontSheetIndex:uint;
		public var backSheetIndex:uint;

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

			var idleMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF, 1 );

			// Front face.
			_frontMesh = new Mesh( geometry, idleMaterial );
			_frontMesh.mouseEnabled = true;
			_frontMesh.x = _width / 2;
			_frontMesh.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			addChild( _frontMesh );

			// Back face.
			_backMesh = new Mesh( geometry.clone(), idleMaterial );
			_backMesh.x = _width / 2;
			_backMesh.rotationZ = 180;
			_backMesh.mouseEnabled = true;
			_backMesh.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			addChild( _backMesh );
		}

		public function set frontTexture( value:BitmapTexture ):void {
			if( !_frontMaterial ) {
				_frontMaterial = new TextureMaterial( value, true, false, false );
				_frontMesh.material = _frontMaterial;
			}
			else _frontMaterial.texture = value;
		}

		public function set backTexture( value:BitmapTexture ):void {
			if( !_backMaterial ) {
				_backMaterial = new TextureMaterial( value, true, false, false );
				_backMesh.material = _backMaterial;
			}
			else _backMaterial.texture = value;
		}

		public function set flipAngle( angleDegrees:Number ):void {
			this.rotationZ = _flipAngle = angleDegrees;
		}

		public function get flipAngle():Number {
			return _flipAngle;
		}
	}
}
