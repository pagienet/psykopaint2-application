package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;

	public class Painting extends ObjectContainer3D
	{
		// Painting diffuse texture.
		[Embed(source="../../../../../../../../assets/images/paintings/painting0.jpg")]
		private var PaintingDiffuseAsset:Class;
		// Painting normal texture.
		[Embed(source="../../../../../../../../assets/images/paintings/painting0-norm.png")]
		private var PaintingNormalAsset:Class;
		// Painting specular texture.
		[Embed(source="../../../../../../../../assets/images/paintings/painting0-spec.png")]
		private var PaintingSpecularAsset:Class;

		public function Painting( lightPicker:StaticLightPicker ) {

			super();

			// TODO: be able to receive textures
			// TODO: account for different painting sizes and aspect ratios

			var diffuseTexture:BitmapTexture = Cast.bitmapTexture( new PaintingDiffuseAsset() );
			var normalsTexture:BitmapTexture = Cast.bitmapTexture( new PaintingNormalAsset() );
			var specularTexture:BitmapTexture = Cast.bitmapTexture( new PaintingSpecularAsset() );

			var material:TextureMaterial = new TextureMaterial( diffuseTexture );
			material.lightPicker = lightPicker;
			material.normalMap = normalsTexture;
			material.specularMap = specularTexture;
			material.ambient = 0.25;
			material.specular = 0.2;

			var plane:Mesh = new Mesh( new PlaneGeometry( diffuseTexture.width, diffuseTexture.height ), material );
			plane.rotationX = -90;
			addChild( plane );
		}
	}
}
