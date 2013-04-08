package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import net.psykosoft.utils.loaders.BitmapLoader;
	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;

	public class Room extends ObjectContainer3D
	{
		private var _loader:BitmapLoader;

		private var _wall:Mesh;
		private var _floor:Mesh;
		private var _shadowMesh:Mesh;
		private var _shadows:Vector.<Mesh>;
		private var _wallTexture:BitmapTexture;
		private var _shadowTexture:BitmapTexture;

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 2000;
		private const WALL_BASE_Y:Number = -500;

		private const WALL_Z:Number = 400;

		private const FLOOR_DEPTH:Number = 1500;

		private const SHADOW_INFLATION_X:Number = 1.075;
		private const SHADOW_INFLATION_Y:Number = 1.1;
		private const SHADOW_OFFSET_Y:Number = -50;

		private var _shadowMaterial:TextureMaterial;

		private var _floorMaterial:TextureMaterial;

		private var _wallMaterial:TextureMaterial;

		public function Room() {
			super();

			// Initialize bitmap loader.
			_loader = new BitmapLoader();

			// Start async scene construction.
			loadWall();
		}

		// -----------------------
		// Wall.
		// -----------------------

		private function loadWall():void {

			// Geometry.
			var wallGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			wallGeometry.scaleUV( WALL_WIDTH / wallGeometry.width, 2 );

			// Mesh.
			_wall = new Mesh( wallGeometry, null );
			changeWallpaper( new BitmapData( 512, 512, false, 0x999999 ) );
			_wall.scaleX = WALL_WIDTH / wallGeometry.width;
			_wall.scaleZ = WALL_HEIGHT / wallGeometry.height;
			_wall.rotationX = -90;
			_wall.y = WALL_BASE_Y + WALL_HEIGHT / 2;
			_wall.z = WALL_Z;
			addChild( _wall );

			// Continue.
			loadShadow();
		}

		// -----------------------
		// Shadow.
		// -----------------------

		private function loadShadow():void {
			_loader.loadAsset( "/assets-packaged/away3d/frames/frame-shadow.png", onShadowBitmapReady );
		}

		private function onShadowBitmapReady( bmd:BitmapData ):void {

			// Texture.
			_shadowTexture = new BitmapTexture( bmd );
			_shadowTexture.getTextureForStage3D( DisplayContextManager.stage3dProxy );
			_shadowTexture.name = "shadowTexture";
			bmd.dispose();

			// Material.
			_shadowMaterial = new TextureMaterial( _shadowTexture );
			_shadowMaterial.smooth = true;
			_shadowMaterial.mipmap = false;
			_shadowMaterial.alpha = 0.9;
			_shadowMaterial.alphaBlending = true;

			// Mesh.
			_shadowMesh = new Mesh( new PlaneGeometry( 512, 512 ), _shadowMaterial );
			_shadowMesh.rotationX = -90;

			// Clone holder.
			_shadows = new Vector.<Mesh>();

			// Continue.
			loadFloor();
		}

		// -----------------------
		// Floor.
		// -----------------------

		private function loadFloor():void {
			_loader.loadAsset( "/assets-packaged/away3d/floorpapers/wood.jpg", onFloorBitmapReady );
		}

		private function onFloorBitmapReady( bmd:BitmapData ):void {

			// Geometry.
			var floorGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			floorGeometry.scaleUV( WALL_WIDTH / floorGeometry.width, 1 );

			// Texture.
			var floorTexture:BitmapTexture = new BitmapTexture( bmd );
			floorTexture.getTextureForStage3D( DisplayContextManager.stage3dProxy );
			floorTexture.name = "floorTexture";
			bmd.dispose();

			// Material.
			_floorMaterial = new TextureMaterial( floorTexture );
			_floorMaterial.repeat = true;
			_floorMaterial.smooth = true;
			_floorMaterial.mipmap = false;

			// Mesh.
			_floor = new Mesh( floorGeometry, _floorMaterial );
			_floor.scaleX = WALL_WIDTH / floorGeometry.width;
			_floor.scaleZ = FLOOR_DEPTH / floorGeometry.height;
			_floor.y = _wall.y - WALL_HEIGHT / 2 - 5; // Literal offsets kind of slide the floor under the home
			_floor.z = WALL_Z - FLOOR_DEPTH / 2 + 190;
			addChild( _floor );

			// No further loading.
			_loader.dispose();
			_loader = null;
		}

		// -----------------------
		// Overrides.
		// -----------------------

		override public function dispose():void {

			trace( this, "dispose()" );

			if( _loader ) {
			 	_loader.dispose();
				_loader = null;
			}

			_floor.dispose();
			_floorMaterial.texture.dispose();
			_floorMaterial.dispose();
			_floor = null;

			_wall.dispose();
			_wallTexture.dispose();
			_wallMaterial.dispose();
			_wall = null;

			for( var i:uint; i < _shadows.length; i++ ) {
				var shadow:Mesh = _shadows[ i ];
				shadow.dispose();
				shadow = null;
			}
			_shadows = null;

			_shadowMesh.dispose();
			_shadowMesh = null;

			_shadowTexture.dispose();
			_shadowMaterial.dispose();
			_shadowMaterial = null;
		}

		// -----------------------
		// Public.
		// -----------------------

		public function addShadow( x:Number, y:Number, width:Number, height:Number ):void {
			var shadow:Mesh = _shadowMesh.clone() as Mesh;
			shadow.x = x;
			shadow.y = y + SHADOW_OFFSET_Y;
			shadow.z = WALL_Z - 1;
			shadow.scaleX = SHADOW_INFLATION_X * width / 512;
			shadow.scaleZ = SHADOW_INFLATION_Y * height / 512;
			_shadows.push( shadow );
			addChild( shadow );
		}

		public function changeWallpaper( bmd:BitmapData ):void {

			// Texture.
			_wallTexture = new BitmapTexture( bmd );
			_wallTexture.getTextureForStage3D( DisplayContextManager.stage3dProxy );
			_wallTexture.name = "wallTexture";
			bmd.dispose();

			// Material.
			_wallMaterial = new TextureMaterial(  );
			_wallMaterial.mipmap = false;
			_wallMaterial.smooth = true;
			_wallMaterial.repeat = true;
			_wall.material = _wallMaterial;
		}

		// -----------------------
		// Getters.
		// -----------------------

		public function get wall():Mesh {
			return _wall;
		}
	}
}
