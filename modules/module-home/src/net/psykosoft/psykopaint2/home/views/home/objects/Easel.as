package net.psykosoft.psykopaint2.home.views.home.objects
{
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.primitives.PlaneGeometry;


	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	public class Easel extends GalleryPainting
	{
		private var _painting : EaselPainting;
		private var _easel : Mesh;
		private var _view : View3D;
		private var _lightPicker : LightPickerBase;

		public function Easel(view : View3D, lightPicker : LightPickerBase)
		{
			super();
			_view = view;
			_lightPicker = lightPicker;
			initPainting();
		}

		private function initPainting() : void
		{
			_painting = new EaselPainting(_lightPicker, _view.stage3DProxy);
			_painting.visible = false;
			addChild(_painting);

			if (CoreSettings.RUNNING_ON_RETINA_DISPLAY)
				_painting.scaleX = _painting.scaleY = 0.5;
		}

		public function set easelVisible(visible : Boolean) : void
		{
			if (!_easel) {
				var easelMaterial : TextureMaterial = TextureUtil.getAtfMaterial(HomeView.HOME_BUNDLE_ID, "easelImage", _view);
				easelMaterial.alphaBlending = true;
				easelMaterial.mipmap = false;

				_easel = new Mesh(new PlaneGeometry(1024, 1024), easelMaterial);
				_easel.z = 10;
				_easel.y = -210;

				_easel.scale( 1.575 );
				_easel.rotationX = -90;
				addChild(_easel);
			}
			_easel.visible = visible;
		}

		override public function dispose() : void
		{
			removeChild(_painting);
			_painting.dispose();
			_painting = null;
			super.dispose();
		}

		public function setContent(vo : PaintingInfoVO) : void
		{
			_painting.setContent(vo, _view.stage3DProxy);
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		override public function get painting() : Mesh
		{
			return _painting;
		}
	}
}
