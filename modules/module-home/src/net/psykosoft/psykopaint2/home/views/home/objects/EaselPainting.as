package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.ByteArrayTexture;
	import away3d.textures.Texture2DBase;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.materials.PaintingDiffuseMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingNormalMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingSpecularMethod;

	use namespace arcane;

	/*
	 * Represents just the "paper" rectangle of a painting with no frame or glass.
	 * */
	public class EaselPainting extends Mesh
	{
		private var _width:Number;

		public function EaselPainting( paintingVO:PaintingInfoVO, lightPicker:LightPickerBase, stage3DProxy : Stage3DProxy ) {

			super(null);

			createPlane( paintingVO, lightPicker, stage3DProxy );
			_width = paintingVO.width;
			rotationX = -90;
		}

		private function createPlane(paintingVO : PaintingInfoVO, lightPicker : LightPickerBase, stage3DProxy : Stage3DProxy) : void
		{
			var width : int = paintingVO.width;
			var height : int = paintingVO.height;
			var textureWidth : int = paintingVO.textureWidth;
			var textureHeight : int = paintingVO.textureHeight;
			var diffuseTexture : Texture2DBase;
			if (paintingVO.colorPreviewData)
				diffuseTexture = new ByteArrayTexture(paintingVO.colorPreviewData, textureWidth, textureHeight);
			else
				diffuseTexture = new BitmapTexture(paintingVO.colorPreviewBitmap);

			var normalSpecularTexture : ByteArrayTexture = new ByteArrayTexture(paintingVO.normalSpecularPreviewData, textureWidth, textureHeight);
			diffuseTexture.getTextureForStage3D(stage3DProxy);
			normalSpecularTexture.getTextureForStage3D(stage3DProxy);

			// Create material.
			var textureMaterial : TextureMaterial = new TextureMaterial( diffuseTexture, true, false, false );
			textureMaterial.diffuseMethod = new PaintingDiffuseMethod();
			textureMaterial.normalMethod = new PaintingNormalMethod();
			textureMaterial.specularMethod = new PaintingSpecularMethod();
			textureMaterial.lightPicker = lightPicker;
			textureMaterial.ambientColor = 0xffffff;
			textureMaterial.ambient = 1;
			textureMaterial.specular = .5;
			textureMaterial.gloss = 200;
			textureMaterial.normalMap = normalSpecularTexture;

			// Build geometry.
			// easel always contains something scene-sized
			var planeGeometry:PlaneGeometry = new PlaneGeometry( CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT );
			var subGeometry:CompactSubGeometry = CompactSubGeometry( planeGeometry.subGeometries[0] );
			subGeometry.scaleUV( width / textureWidth, height / textureHeight );

			geometry = planeGeometry;
			material = textureMaterial;
		}

		override public function dispose():void
		{
			var textureMaterial : TextureMaterial = TextureMaterial(material);
			textureMaterial.texture.dispose();
			if( textureMaterial.normalMap ) textureMaterial.normalMap.dispose();
			textureMaterial.dispose();
			super.dispose();
		}

		public function get width():Number {
			return _width;
		}
	}
}
