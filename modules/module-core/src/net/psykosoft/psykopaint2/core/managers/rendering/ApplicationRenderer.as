package net.psykosoft.psykopaint2.core.managers.rendering
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class ApplicationRenderer
	{
		public static var renderTime : Number = 0;

		[Inject]
		public var stage3DProxy : Stage3DProxy;

		[Inject]
		public var stage : Stage;

		private var _promises : Vector.<SnapshotPromise>;

		public function ApplicationRenderer()
		{
			_promises = new <SnapshotPromise>[];
		}

		public function requestSnapshot() : SnapshotPromise
		{
			var promise : SnapshotPromise = new SnapshotPromise();
			_promises.push(promise);
			return promise;
		}

		public function render() : void
		{
			var needsSnapshot : Boolean = _promises.length > 0;
			var context : Context3D = stage3DProxy.context3D;

			if (!context ) return;

			if ( context.driverInfo == "Disposed" )
			{
				trace("###################### WARNING: context loss! ###################### ");
				return;
			}
			
			if (CoreSettings.DEBUG_RENDER_SEQUENCE) {
				trace(this, "gpu render ------------------------");
			}

			var preTime : Number = getTimer();

			executeSteps(GpuRenderManager.preRenderingSteps);

			// Clear.
			if (CoreSettings.DEBUG_RENDER_SEQUENCE) {
				trace(this, "clear context");
			}

			context.setRenderToBackBuffer();
			stage3DProxy.clear();

			executeTargetedSteps(GpuRenderManager.renderingSteps);

			// Present.
			if (CoreSettings.DEBUG_RENDER_SEQUENCE) {
				trace(this, "present proxy");
			}

			if (needsSnapshot)
				createSnapshot();

			stage3DProxy.present();

			executeSteps(GpuRenderManager.postRenderingSteps);

			renderTime = getTimer() - preTime;
		}

		private function createSnapshot() : void
		{
			// TODO: Go back to render to texture approach, this is allocating a lot of memory
			var croppedBitmapData : BitmapData = new TrackedBitmapData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, false, 0);
			stage3DProxy.context3D.drawToBitmapData(croppedBitmapData);

			var texture : RectangleTexture = stage3DProxy.context3D.createRectangleTexture(croppedBitmapData.width, croppedBitmapData.height, Context3DTextureFormat.BGRA, false);
			var snapshot : RefCountedRectTexture = new RefCountedRectTexture(texture);
			snapshot.texture.uploadFromBitmapData(croppedBitmapData);
			croppedBitmapData.dispose();
			fulfillPromises(snapshot);
		}

		private function fulfillPromises(snapshot : RefCountedRectTexture) : void
		{
			var len : int = _promises.length;

			for (var i : int = 0; i < len; ++i)
				_promises[i].texture = snapshot;

			snapshot = null;
			_promises.length = 0;
		}

		private function executeTargetedSteps(steps : Vector.<Function>) : void
		{
			var numSteps : uint = steps.length;
			for (var i : uint = 0; i < numSteps; ++i)
				steps[ i ](null);
		}

		private function executeSteps(steps : Vector.<Function>) : void
		{
			var numSteps : uint = steps.length;
			for (var i : uint = 0; i < numSteps; ++i)
				steps[ i ]();
		}
	}
}
