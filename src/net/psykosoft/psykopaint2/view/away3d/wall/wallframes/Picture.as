package net.psykosoft.psykopaint2.view.away3d.wall.wallframes
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.util.TextureUtil;

	public class Picture extends ObjectContainer3D
	{
		// Painting diffuse texture.
		[Embed(source="../../../../../../../../assets/images/paintings/painting4/painting4.jpg")]
		private var PaintingDiffuseAsset:Class;
		// Painting normal texture.
		[Embed(source="../../../../../../../../assets/images/paintings/painting4/painting4_normals.png")]
		private var PaintingNormalAsset:Class;

		private var _width:Number;
		private var _height:Number;

		public function Picture( lightPicker:StaticLightPicker ) {

			super();

			// TODO: be able to receive textures
			// TODO: account for different painting sizes and aspect ratios

			var originalDiffuseBitmapData:BitmapData = new PaintingDiffuseAsset().bitmapData;
			var originalNormalBitmapData:BitmapData = new PaintingNormalAsset().bitmapData;

			_width = originalDiffuseBitmapData.width;
			_height = originalDiffuseBitmapData.height;

			var diffuseBitmapData:BitmapData = TextureUtil.ensurePowerOf2( originalDiffuseBitmapData );
			var normalBitmapData:BitmapData = TextureUtil.ensurePowerOf2( originalNormalBitmapData );

			var diffuseTexture:BitmapTexture = new BitmapTexture( diffuseBitmapData );
			var normalTexture:BitmapTexture = new BitmapTexture( normalBitmapData );

			var material:TextureMaterial = new TextureMaterial( diffuseTexture );
			material.smooth = true;
			if( originalDiffuseBitmapData.width != diffuseBitmapData.width || originalDiffuseBitmapData.height != diffuseBitmapData.height ) {
				material.alphaBlending = true;
			}
			material.lightPicker = lightPicker;
			if( Settings.USE_COMPLEX_ILLUMINATION_ON_PAINTINGS ) {
				material.normalMap = normalTexture;
			}
			material.gloss = 10;
			material.ambient = 0.75;
			material.specular = 0.2;

			var plane:Mesh = new Mesh( new PlaneGeometry( diffuseBitmapData.width, diffuseBitmapData.height ), material );
			plane.rotationX = -90;
			addChild( plane );
		}

		public function get width():Number {
		 	return _width;
		}

		public function get height():Number {
			return _height;
		}
	}
}
