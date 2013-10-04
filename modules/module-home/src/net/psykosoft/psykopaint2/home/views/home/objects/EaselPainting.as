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
		private var _diffuseTexture:Texture2DBase;
		private var _normalSpecularTexture:ByteArrayTexture;
		private var _textureMaterial:TextureMaterial;

		override public function dispose():void {
			var geometry:Geometry = this.geometry;
			super.dispose();
			geometry.dispose();
			_textureMaterial.dispose();
			disposeTextures();
		}

		public function EaselPainting( lightPicker:LightPickerBase ) {

			super( null );

			geometry = new PlaneGeometry( CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 1, 1, false );
			initMaterial( lightPicker );
		}

		private function initMaterial( lightPicker:LightPickerBase ):void {
			// Create material.
			_textureMaterial = new TextureMaterial( null, true, false, false );
			_textureMaterial.animateUVs = true;
			_textureMaterial.diffuseMethod = new PaintingDiffuseMethod();
			_textureMaterial.normalMethod = new PaintingNormalMethod();
			_textureMaterial.specularMethod = new PaintingSpecularMethod();
			_textureMaterial.lightPicker = lightPicker;
			_textureMaterial.ambientColor = 0xffffff;
			_textureMaterial.ambient = 1;
			_textureMaterial.specular = 2;
			_textureMaterial.gloss = 200;
			material = _textureMaterial;
		}

		public function setContent( paintingVO:PaintingInfoVO, stage3DProxy:Stage3DProxy ):void {
			disposeTextures();

			if( paintingVO ) {
				visible = true;
				initTextures( paintingVO, stage3DProxy );
				_width = paintingVO.width;
			}
			else {
				visible = false;
			}

		}

		private function disposeTextures():void {
			if( _diffuseTexture ) _diffuseTexture.dispose();
			if( _normalSpecularTexture ) _normalSpecularTexture.dispose();
		}

		private function initTextures( paintingVO:PaintingInfoVO, stage3DProxy:Stage3DProxy ):void {
			var textureWidth:int = paintingVO.textureWidth;
			var textureHeight:int = paintingVO.textureHeight;

			if( paintingVO.colorPreviewData )
				_diffuseTexture = new ByteArrayTexture( paintingVO.colorPreviewData, textureWidth, textureHeight );
			else
				_diffuseTexture = new BitmapTexture( paintingVO.colorPreviewBitmap );

			_normalSpecularTexture = new ByteArrayTexture( paintingVO.normalSpecularPreviewData, textureWidth, textureHeight );
			_diffuseTexture.getTextureForStage3D( stage3DProxy );
			_normalSpecularTexture.getTextureForStage3D( stage3DProxy );

			_textureMaterial.texture = _diffuseTexture;
			_textureMaterial.normalMap = _normalSpecularTexture;
			_textureMaterial.specularMap = _normalSpecularTexture;

			subMeshes[0].scaleU = paintingVO.width / _diffuseTexture.width;
			subMeshes[0].scaleV = paintingVO.height / _diffuseTexture.height;
		}

		public function get width():Number {
			return _width;
		}
	}
}
