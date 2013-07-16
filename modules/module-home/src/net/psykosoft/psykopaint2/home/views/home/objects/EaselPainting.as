package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
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
		private var _diffuseTexture : Texture2DBase;
		private var _normalSpecularTexture : ByteArrayTexture;

		public function EaselPainting( paintingVO:PaintingInfoVO, lightPicker:LightPickerBase, stage3DProxy : Stage3DProxy ) {

			super(null);

			createPlane( paintingVO, lightPicker, stage3DProxy );
			_width = paintingVO.width;
		}

		private function createPlane(paintingVO : PaintingInfoVO, lightPicker : LightPickerBase, stage3DProxy : Stage3DProxy) : void
		{
			initTextures(paintingVO, stage3DProxy);
			initMaterial(lightPicker);
			initGeometry(paintingVO);
		}

		private function initGeometry(paintingVO : PaintingInfoVO) : void
		{
			// easel always contains something scene-sized
			var planeGeometry : PlaneGeometry = new PlaneGeometry(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 1, 1, false);
			var subGeometry : CompactSubGeometry = CompactSubGeometry(planeGeometry.subGeometries[0]);
			subGeometry.scaleUV(paintingVO.width / _diffuseTexture.width, paintingVO.height / _diffuseTexture.height);

			geometry = planeGeometry;
		}

		private function initMaterial(lightPicker : LightPickerBase) : void
		{
			// Create material.
			var textureMaterial : TextureMaterial = new TextureMaterial(_diffuseTexture, true, false, false);
			textureMaterial.diffuseMethod = new PaintingDiffuseMethod();
			textureMaterial.normalMethod = new PaintingNormalMethod();
			textureMaterial.specularMethod = new PaintingSpecularMethod();
			textureMaterial.lightPicker = lightPicker;
			textureMaterial.ambientColor = 0xffffff;
			textureMaterial.ambient = 1;
			textureMaterial.specular = .5;
			textureMaterial.gloss = 200;
			textureMaterial.normalMap = _normalSpecularTexture;
			material = textureMaterial;
		}

		private function initTextures(paintingVO : PaintingInfoVO, stage3DProxy : Stage3DProxy) : void
		{
			var textureWidth : int = paintingVO.textureWidth;
			var textureHeight : int = paintingVO.textureHeight;

			if (paintingVO.colorPreviewData)
				_diffuseTexture = new ByteArrayTexture(paintingVO.colorPreviewData, textureWidth, textureHeight);
			else
				_diffuseTexture = new BitmapTexture(paintingVO.colorPreviewBitmap);

			_normalSpecularTexture = new ByteArrayTexture(paintingVO.normalSpecularPreviewData, textureWidth, textureHeight);
			_diffuseTexture.getTextureForStage3D(stage3DProxy);
			_normalSpecularTexture.getTextureForStage3D(stage3DProxy);
		}

		override public function dispose():void
		{
			var geometry : Geometry = this.geometry;
			var material : MaterialBase = this.material;
			super.dispose();
			geometry.dispose();
			material.dispose();
			_diffuseTexture.dispose();
			_normalSpecularTexture.dispose();
		}

		public function get width():Number {
			return _width;
		}
	}
}
