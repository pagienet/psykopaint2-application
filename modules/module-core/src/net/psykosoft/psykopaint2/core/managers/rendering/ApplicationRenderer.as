/**
 * Created with IntelliJ IDEA.
 * User: David
 * Date: 12/07/13
 * Time: 12:31
 * To change this template use File | Settings | File Templates.
 */
package net.psykosoft.psykopaint2.core.managers.rendering
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display3D.Context3D;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class ApplicationRenderer
	{
		public static var renderTime : Number = 0;

		[Inject]
		public var stage3DProxy : Stage3DProxy;

		private var _promises : Vector.<SnapshotPromise>;

		public function ApplicationRenderer()
		{
			_promises = new <SnapshotPromise>[];
		}

		public function requestSnapshot(scale : Number = 1) : SnapshotPromise
		{
			var promise : SnapshotPromise = new SnapshotPromise(scale);
			_promises.push(promise);
			return promise;
		}

		public function render() : void
		{
			var context : Context3D = stage3DProxy.context3D;
			if (!context) return;

			if (CoreSettings.DEBUG_RENDER_SEQUENCE) {
				trace(this, "gpu render ------------------------");
			}

			var preTime : Number = getTimer();

			var i : uint;
			var len : uint;
			var steps : Vector.<Function>;

			// Pre-clear steps.
			steps = GpuRenderManager.preRenderingSteps;
			len = steps.length;
			for (i = 0; i < len; ++i) steps[ i ]();

			// Clear.
			if (CoreSettings.DEBUG_RENDER_SEQUENCE) {
				trace(this, "clear context");
			}
			stage3DProxy.context3D.setRenderToBackBuffer();
			stage3DProxy.clear();

			// Normal steps.
			steps = GpuRenderManager.renderingSteps;
			len = steps.length;
			for (i = 0; i < len; ++i) steps[ i ]();

			if (_promises.length > 0) {
				createSnapshots();
				_promises.length = 0;
			}

			// Present.
			if (CoreSettings.DEBUG_RENDER_SEQUENCE) {
				trace(this, "present proxy");
			}
			stage3DProxy.present();

			// Post-present steps.
			steps = GpuRenderManager.postRenderingSteps;
			len = steps.length;
			for (i = 0; i < len; ++i) steps[ i ]();

			renderTime = getTimer() - preTime;
		}

		private function createSnapshots() : void
		{
			var scaledBitmapDatas : Dictionary = new Dictionary();

			createFullsizeSnapshot(scaledBitmapDatas);

			for (var i : int = 0; i < _promises.length; ++i) {
				var promise : SnapshotPromise = _promises[i];
				var scale : Number = promise.scale;

				trace(this, "taking snapshot with scale: " + scale);

				promise.bitmapData = getOrCreateScaledBitmapData(scale, scaledBitmapDatas);
			}

			// we added a refcount to the scale 1 version, so free it again
			RefCountedBitmapData(scaledBitmapDatas[1.0]).dispose();
		}

		private function getOrCreateScaledBitmapData(scale : Number, scaled : Dictionary) : RefCountedBitmapData
		{
			if (!scaled[scale]) {
				var matrix : Matrix = new Matrix(scale, 0, 0, scale);
				var scaledDownBmd : RefCountedBitmapData = new RefCountedBitmapData(stage3DProxy.width * scale, stage3DProxy.height * scale, false, 0);
				scaledDownBmd.draw(scaled[1.0], matrix);
			}

			return scaled[scale];
		}

		private function createFullsizeSnapshot(scaledBitmapDatas : Dictionary) : void
		{
			var bmd : RefCountedBitmapData = new RefCountedBitmapData(stage3DProxy.width, stage3DProxy.height, true, 0);
			bmd.addRefCount();
			scaledBitmapDatas[1.0] = bmd;
			stage3DProxy.context3D.drawToBitmapData(bmd);
		}
	}
}
