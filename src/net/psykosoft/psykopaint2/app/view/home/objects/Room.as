package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.assets.away3d.textures.Away3dTextureManager;

	import net.psykosoft.psykopaint2.app.assets.away3d.textures.ManagedAway3DBitmapTexture;
	import net.psykosoft.psykopaint2.app.assets.away3d.textures.data.Away3dTextureType;

	public class Room extends ObjectContainer3D
	{
		// -----------------------
		// Shadow decal.
		// -----------------------
		// TODO: move to asset manager
		[Embed(source="../../../../../../../../assets-embedded/textures/misc/frame-shadow.png")]
		private var FrameShadowAsset:Class;

		private var _wall:Mesh;
		private var _floor:Mesh;
		private var _shadowMesh:Mesh;
		private var _shadows:Vector.<Mesh>;

		private const WALL_WIDTH:Number = 100000;
		private const WALL_HEIGHT:Number = 2000;
		private const WALL_BASE_Y:Number = -500;

		private const WALL_Z:Number = 400;

		private const FLOOR_DEPTH:Number = 1500;

		private const SHADOW_INFLATION_X:Number = 1.075;
		private const SHADOW_INFLATION_Y:Number = 1.1;
		private const SHADOW_OFFSET_Y:Number = -50;

		public function Room() {
			super();

			// Wall.
			var wallGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			wallGeometry.scaleUV( WALL_WIDTH / wallGeometry.width, 2 );
			_wall = new Mesh( wallGeometry, new ColorMaterial() );
			_wall.scaleX = WALL_WIDTH / wallGeometry.width;
			_wall.scaleZ = WALL_HEIGHT / wallGeometry.height;
			_wall.rotationX = -90;
			_wall.y = WALL_BASE_Y + WALL_HEIGHT / 2;
			_wall.z = WALL_Z;
			addChild( _wall );

			// Floor.
			var floorGeometry:PlaneGeometry = new PlaneGeometry( 1024, 1024 );
			floorGeometry.scaleUV( WALL_WIDTH / floorGeometry.width, 1 );
			var floorMaterial:TextureMaterial = new TextureMaterial( Away3dTextureManager.getTextureById( Away3dTextureType.FLOORPAPER_PLANKS, true ) );
			floorMaterial.repeat = true;
			floorMaterial.smooth = true;
			floorMaterial.mipmap = true; // Mipmapping is disabled by default for textures coming from Away3dTextureManager - see ManagedAway3DBitmapTexture.
			_floor = new Mesh( floorGeometry, floorMaterial );
			_floor.scaleX = WALL_WIDTH / floorGeometry.width;
			_floor.scaleZ = FLOOR_DEPTH / floorGeometry.height;
			_floor.y = _wall.y - WALL_HEIGHT / 2 - 5; // Literal offsets kind of slide the floor under the home
			_floor.z = WALL_Z - FLOOR_DEPTH / 2 + 190;
			addChild( _floor );

			// Shadows.
			var shadowMaterial:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( new FrameShadowAsset() ) );
			shadowMaterial.smooth = true;
			shadowMaterial.mipmap = false;
			shadowMaterial.alpha = 0.9;
			shadowMaterial.alphaBlending = true;
			_shadowMesh = new Mesh( new PlaneGeometry( 512, 512 ), shadowMaterial );
			_shadowMesh.rotationX = -90;
			_shadows = new Vector.<Mesh>();
		}

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
			var wallMaterial:TextureMaterial = new TextureMaterial( new ManagedAway3DBitmapTexture( bmd ) );
			wallMaterial.mipmap = false;
			wallMaterial.smooth = true;
			wallMaterial.repeat = true;
			_wall.material = wallMaterial;
		}

		// -----------------------
		// Getters.
		// -----------------------

		public function get wall():Mesh {
			return _wall;
		}
	}
}
