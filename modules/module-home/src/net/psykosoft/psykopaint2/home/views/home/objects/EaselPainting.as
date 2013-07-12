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
	public class EaselPainting extends ObjectContainer3D
	{
		private var _width:Number;

		private var _plane:Mesh;
		private var _material:TextureMaterial;

		public function EaselPainting( paintingVO:PaintingInfoVO, lightPicker:LightPickerBase, view : View3D ) {

			super();

			_width = paintingVO.width;

			_plane = createPlane( paintingVO, lightPicker, view );
//			_plane = new Mesh( new PlaneGeometry( _width, _height ), new TextureMaterial( new BitmapTexture( diffuseBitmap ) ) ); // TODO: test non power of 2 textures with air 3.8
			_plane.rotationX = -90;
//			_material.lightPicker = lightPicker;
			addChild( _plane );
		}

		private function createPlane(paintingVO : PaintingInfoVO, lightPicker : LightPickerBase, view : View3D) : Mesh
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
			diffuseTexture.getTextureForStage3D(view.stage3DProxy);
			normalSpecularTexture.getTextureForStage3D(view.stage3DProxy);

			// Create material.
			_material = new TextureMaterial( diffuseTexture, true, false, false );
			_material.diffuseMethod = new PaintingDiffuseMethod();
			_material.normalMethod = new PaintingNormalMethod();
			_material.specularMethod = new PaintingSpecularMethod();
			_material.lightPicker = lightPicker;
			_material.ambientColor = 0xffffff;
			_material.ambient = 1;
			_material.specular = .5;
			_material.gloss = 200;
			_material.normalMap = normalSpecularTexture;

			// Build geometry.
			// easel always contains something scene-sized
			var planeGeometry:PlaneGeometry = new PlaneGeometry( CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT );
			var subGeometry:CompactSubGeometry = CompactSubGeometry( planeGeometry.subGeometries[0] );
			subGeometry.scaleUV( width / textureWidth, height / textureHeight );

			return new Mesh( planeGeometry, _material );
		}

		override public function dispose():void {

			_plane.dispose();
			_material.texture.dispose();
			if( _material.normalMap ) _material.normalMap.dispose();
			_material.dispose();

			_plane = null;
			_material = null;

			super.dispose();
		}

		public function get width():Number {
			return _width;
		}

		public function get plane():Mesh {
			return _plane;
		}
	}
}
