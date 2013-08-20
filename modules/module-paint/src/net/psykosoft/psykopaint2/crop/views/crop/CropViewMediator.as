package net.psykosoft.psykopaint2.crop.views.crop
{

	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;

	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;

	import net.psykosoft.psykopaint2.core.models.EaselRectModel;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFinalizeCropSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;

	public class CropViewMediator extends MediatorBase
	{
		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var view:CropView;

		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		[Inject]
		public var requestUpdateCropImageSignal:RequestUpdateCropImageSignal;

		[Inject]
		public var requestOpenCroppedBitmapDataSignal:RequestOpenCroppedBitmapDataSignal;

		[Inject]
		public var notifyCropConfirmSignal:RequestFinalizeCropSignal;

		[Inject]
		public var easelRectModel : EaselRectModel;

		[Inject]
		public var requestDestroyCropModuleSignal : RequestDestroyCropModuleSignal;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.CROP );

			// From app.
			requestUpdateCropImageSignal.add( updateCropSourceImage );
			notifyCropConfirmSignal.add( onRequestFinalizeCrop );
			requestSetCropBackgroundSignal.add( onSetCropBackgroundSignal );
			requestDestroyCropModuleSignal.add( onRequestDestroyCropModule );

			view.enabledSignal.add( onEnabled );
			view.disabledSignal.add( onDisabled );
		}

		private function onEnabled() : void
		{
			GpuRenderManager.addRenderingStep(render, GpuRenderingStepType.NORMAL,0);
		}

		private function onDisabled() : void
		{
			GpuRenderManager.removeRenderingStep(render, GpuRenderingStepType.NORMAL);
			view.background = null;
		}

		private function render(target:Texture) : void
		{
			view.render(stage3D.context3D);
		}

		private function onRequestDestroyCropModule() : void
		{
			view.disposeCropData();
		}

		private function onSetCropBackgroundSignal(texture : RefCountedTexture) : void
		{
			view.background = texture;
		}

		// -----------------------
		// From app.
		// -----------------------

		public function onRequestFinalizeCrop():void {
			requestOpenCroppedBitmapDataSignal.dispatch( view.getCroppedImage() );
			view.disposeCropData();
		}

		private function updateCropSourceImage( bitmapData:BitmapData ):void {
			trace( this, "updateCropSourceImage" );
			view.easelRect = easelRectModel.localScreenRect;
			view.sourceMap = bitmapData;
		}
	}
}
