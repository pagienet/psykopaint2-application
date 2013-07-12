package net.psykosoft.psykopaint2.home.views.home.objects
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;


	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	public class Easel extends GalleryPainting
	{
		private var _painting : ObjectContainer3D;
		private var _frame : ObjectContainer3D;
		private var _easel : Mesh;
		private var _view : View3D;

		public function Easel(view : View3D)
		{
			super();
			_view = view;
			createEasel();
		}

		private function createEasel() : void
		{
			var easelMaterial : TextureMaterial = TextureUtil.getAtfMaterial(HomeView.HOME_BUNDLE_ID, "easelImage", _view);
			easelMaterial.alphaBlending = true;
			easelMaterial.mipmap = false;

			_easel = new Mesh(new PlaneGeometry(1024, 1024), easelMaterial);
			_easel.z = 10;
			_easel.y = -210;

			_easel.scale(1.575);
			_easel.rotationX = -90;
			addChild(_easel);
		}

		public function set easelVisible(visible : Boolean) : void
		{
			_easel.visible = visible;
		}

		override public function dispose() : void
		{
			disposePainting();
			disposeFrame();
			super.dispose();
		}

		public function setPainting(value : ObjectContainer3D) : void
		{
			disposePainting();
			if (value) {
				_painting = value;
				addChild(_painting);
			}
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function disposePainting() : void
		{
			if (_painting) {
				removeChild(_painting);
				_painting.dispose();
				_painting = null;
			}
		}

		private function disposeFrame() : void
		{
			if (_frame) {
				removeChild(_frame);
			}
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		override public function get painting() : Mesh
		{
			return Mesh(_painting);
		}

		public function get frame() : ObjectContainer3D
		{
			return _frame;
		}
	}
}
