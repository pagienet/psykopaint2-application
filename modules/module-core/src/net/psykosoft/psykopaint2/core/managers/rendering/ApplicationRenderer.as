package net.psykosoft.psykopaint2.core.managers.rendering
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	public class ApplicationRenderer
	{
		public static var renderTime : Number = 0;

		[Inject]
		public var stage3DProxy : Stage3DProxy;

		private var _promises : Vector.<SnapshotPromise>;
		private var _snapshot : Texture;

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

			if (!context) return;

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

			if (needsSnapshot) {
				createSnapshot();
				fulfillPromises();
			}

			stage3DProxy.present();
			executeSteps(GpuRenderManager.postRenderingSteps);

			renderTime = getTimer() - preTime;
		}

		private function createSnapshot() : void
		{
			// TODO: Go back to render to texture approach, this is allocating a lot of memory

			var snapshotWidth : int = TextureUtil.getNextPowerOfTwo(stage3DProxy.width);
			var snapshotHeight : int = TextureUtil.getNextPowerOfTwo(stage3DProxy.height);
			trace ("Generating snapshot with size: " + snapshotWidth + ", " + snapshotHeight);
			var croppedBitmapData : BitmapData = new TrackedBitmapData(stage3DProxy.width, stage3DProxy.height, false, 0);
			stage3DProxy.context3D.drawToBitmapData(croppedBitmapData);

			var largeBitmapData : BitmapData = new TrackedBitmapData(snapshotWidth, snapshotHeight, false, 0);
			largeBitmapData.copyPixels(croppedBitmapData, croppedBitmapData.rect, new Point());

			croppedBitmapData.dispose();

			_snapshot = stage3DProxy.context3D.createTexture(snapshotWidth, snapshotHeight, Context3DTextureFormat.BGRA, true);
			_snapshot.uploadFromBitmapData(largeBitmapData);
			largeBitmapData.dispose();
		}

		private function fulfillPromises() : void
		{
			var refCountedTexture : RefCountedTexture = new RefCountedTexture(_snapshot);
			var len : int = _promises.length;

			for (var i : int = 0; i < len; ++i)
				_promises[i].texture = refCountedTexture;

			_snapshot = null;
			_promises.length = 0;
		}

		private function executeTargetedSteps(steps : Vector.<Function>) : void
		{
			var numSteps : uint = steps.length;
			for (var i : uint = 0; i < numSteps; ++i)
				steps[ i ](_snapshot);
		}

		private function executeSteps(steps : Vector.<Function>) : void
		{
			var numSteps : uint = steps.length;
			for (var i : uint = 0; i < numSteps; ++i)
				steps[ i ]();
		}
	}
}
