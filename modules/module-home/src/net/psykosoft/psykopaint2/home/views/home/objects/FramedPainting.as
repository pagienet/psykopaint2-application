package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;

	/*
	 * Contains a painting within a frame.
	 * */
	public class FramedPainting extends GalleryPainting
	{
		private var _paintingMesh:Mesh;
		private var _frameMesh:Mesh;
		private var _paintingGeometry : Geometry;
		private var _frameGeometry : Geometry;
		private var _paintingMaterial:TextureMaterial;
		private var _frameMaterial:TextureMaterial;
		private var _paintingTexture:BitmapTexture;
		private var _frameTexture:BitmapTexture;
		private var _view:View3D;

		public function FramedPainting( view:View3D, hasFrame : Boolean, transparent : Boolean ) {
			super();
			_view = view;

			initPainting(transparent);

			if (hasFrame)
				initFrame();
		}

		private function initFrame() : void
		{
			_frameTexture = new BitmapTexture(null);
			_frameMaterial = createMaterial(_frameTexture, true);
			_frameGeometry = new PlaneGeometry(1, 1, 1, 1, false);
			_frameMesh = new Mesh(_frameGeometry, _frameMaterial);
			addChild(_frameMesh);
		}

		private function initPainting(transparent : Boolean) : void
		{
			_paintingTexture = new BitmapTexture(null);
			_paintingMaterial = createMaterial(_paintingTexture, transparent);
			_paintingGeometry = new PlaneGeometry(1, 1, 1, 1, false);
			_paintingMesh = new Mesh(_paintingGeometry, _paintingMaterial);
			addChild(_paintingMesh);
		}

		private function createMaterial(texture : BitmapTexture, transparent : Boolean) : TextureMaterial
		{
			var material : TextureMaterial = new TextureMaterial(texture);
			material.alphaBlending = transparent;
			material.animateUVs = true;
			return material;
		}

		override public function dispose():void {
			_paintingGeometry.dispose();
			_frameGeometry.dispose();
			_paintingMaterial.dispose();
			_frameMaterial.dispose();
			_frameTexture.dispose();
			_paintingTexture.dispose();
			super.dispose();
		}

		public function setPaintingBitmapData( bitmapData:BitmapData, stage3DProxy:Stage3DProxy ):void {
			setBitmapDataForMesh(bitmapData, _paintingMesh, _paintingTexture, stage3DProxy)
		}

		private function setBitmapDataForMesh(bitmapData:BitmapData, mesh : Mesh, texture : BitmapTexture, stage3DProxy:Stage3DProxy ) : void
		{
			mesh.scaleX = bitmapData.width;
			mesh.scaleY = bitmapData.height;

			var pow2BitmapData : BitmapData = TextureUtil.ensurePowerOf2TopLeft(bitmapData);
			var scaleU:Number = bitmapData.width / pow2BitmapData.width;
			var scaleV:Number = bitmapData.height / pow2BitmapData.height;

			mesh.subMeshes[0].scaleU = scaleU;
			mesh.subMeshes[0].scaleV = scaleV;

			bitmapData.dispose();

			texture.bitmapData = pow2BitmapData;
			texture.getTextureForStage3D(stage3DProxy);
			pow2BitmapData.dispose();
		}

		public function setFrameBitmapData( bitmapData:BitmapData, stage3DProxy:Stage3DProxy ):void {
			setBitmapDataForMesh(bitmapData, _frameMesh, _frameTexture, stage3DProxy)
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		override public function get painting():Mesh {
			return _paintingMesh;
		}
	}
}
