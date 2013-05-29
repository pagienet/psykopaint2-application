package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Video;

	public class CameraEnvMap
	{
		private var _camera : Camera;
		private var _progressiveEnvMap : ProgressiveEnvMap;
		private var _video : Video;
		private var _matrix : Matrix;
		private var _camImage : BitmapData;

		public function CameraEnvMap(context : Context3D, mapSize : uint = 32)
		{
			_progressiveEnvMap = new ProgressiveEnvMap(context, mapSize);
			initCamera();
			initBitmapData(mapSize);
		}

		private function initCamera() : void
		{
			_camera = Camera.getCamera("1");	// get front camera
			if (!_camera) _camera = Camera.getCamera();	// get default one
			if (!_camera) throw "no camera found";

			_camera.setMode(160, 120, 12);
			_video = new Video(160, 120);
			_video.attachCamera(_camera);
		}

		private function initBitmapData(mapSize : uint) : void
		{
			_camImage = new BitmapData(mapSize, mapSize, false);
			// on iOS, front cam is already mirrorred. THIS IS NOT THE CASE ON ANDROID!
			_matrix = new Matrix(_camImage.width / _video.width, 0, 0, _camImage.height / _video.height);
		}

		public function update() : void
		{
			_camImage.draw(_video, _matrix);
			_progressiveEnvMap.update(_camImage);
		}

		public function get timeLERPFactor() : Number
		{
			return _progressiveEnvMap.timeLERPFactor;
		}

		public function set timeLERPFactor(value : Number) : void
		{
			_progressiveEnvMap.timeLERPFactor = value;
		}

		public function get sampleRange() : Number
		{
			return _progressiveEnvMap.sampleRange;
		}

		public function set sampleRange(value : Number) : void
		{
			_progressiveEnvMap.sampleRange = value;
		}

		public function get numSamplesPerFrame() : int
		{
			return _progressiveEnvMap.numSamplesPerFrame;
		}

		public function set numSamplesPerFrame(value : int) : void
		{
			_progressiveEnvMap.numSamplesPerFrame = value;
		}

		public function dispose() : void
		{
			_progressiveEnvMap.dispose();
			_video.attachCamera(null);
			_camImage.dispose();
		}

		public function get envMap() : Texture
		{
			return _progressiveEnvMap.envMap;
		}

		public function get brightnessScale() : Number
		{
			return _progressiveEnvMap.brightnessScale;
		}

		public function set brightnessScale(brightnessScale : Number) : void
		{
			_progressiveEnvMap.brightnessScale = brightnessScale;
		}
	}
}
