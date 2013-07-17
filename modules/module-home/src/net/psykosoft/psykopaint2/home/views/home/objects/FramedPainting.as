package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

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
		private var _paintingBmdScaleFactor:Number = 1;

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
			_frameMesh.zOffset = 1000;
			_frameMesh.z = -2;
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
			_paintingBmdScaleFactor = bitmapData.width / 1024;
			setBitmapDataForMesh(bitmapData, _paintingMesh, _paintingTexture, stage3DProxy);
		}

		private function setBitmapDataForMesh(bitmapData:BitmapData, mesh : Mesh, texture : BitmapTexture, stage3DProxy:Stage3DProxy, scaleFactor:Number = 1 ) : void
		{
			mesh.scaleX = bitmapData.width * scaleFactor;
			mesh.scaleY = bitmapData.height * scaleFactor;

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

		public function setFrameBitmapData( bitmapData:BitmapData, stage3DProxy:Stage3DProxy, frameOffsetX:Number, frameOffsetY:Number ):void {

			// Position frame so that top left corner of it's hole matches top left corner of the painting.
			// Requires the xy coordinates of the hole's top left corner in image space.
			_frameMesh.x = _paintingBmdScaleFactor * ( -1024 + bitmapData.width - 2 * frameOffsetX ) / 2;
			_frameMesh.y = _paintingBmdScaleFactor * ( 768 - bitmapData.height + 2 * frameOffsetY ) / 2;

			setBitmapDataForMesh(bitmapData, _frameMesh, _frameTexture, stage3DProxy, _paintingBmdScaleFactor);
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		override public function get painting():Mesh {
			return _paintingMesh;
		}
	}
}
