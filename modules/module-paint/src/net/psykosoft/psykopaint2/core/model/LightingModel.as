package net.psykosoft.psykopaint2.core.model
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.textures.Texture;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.core.rendering.AOShadowModel;

	import net.psykosoft.psykopaint2.core.rendering.AmbientConstantModel;
	import net.psykosoft.psykopaint2.core.rendering.AmbientEnvMapModel;
	import net.psykosoft.psykopaint2.core.rendering.AmbientOccludedModel;
	import net.psykosoft.psykopaint2.core.rendering.CameraEnvMap;

	import net.psykosoft.psykopaint2.core.rendering.DiffuseLambertModel;
	import net.psykosoft.psykopaint2.core.rendering.BDRFModel;
	import net.psykosoft.psykopaint2.core.rendering.SpecularBlinnModel;

	import org.osflash.signals.Signal;

	public class LightingModel
	{
		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var stage : Stage;

		public var onChange : Signal;

		// light properties
		private var _lightColor : uint;
		private var _ambientColor : uint;
		private var _lightPosition : Vector3D = new Vector3D(1, 1, -2);	// NORMALIZED TO CANVAS x, y in [-1, 1]
		private var _eyePosition : Vector3D = new Vector3D(0, 0, -2);	// NORMALIZED TO CANVAS x, y in [-1, 1]

		// surface properties
		private var _diffuseStrength : Number = 1;
		private var _specularStrength : Number = 2;
		private var _glossiness : Number = 200;		// Maximum gloss setting
		private var _surfaceBumpiness : Number = 20;

		private var _lightColorR : Number;
		private var _lightColorG : Number;
		private var _lightColorB : Number;
		private var _ambientColorR : Number;
		private var _ambientColorG : Number;
		private var _ambientColorB : Number;

		private var _diffuseModel : BDRFModel;
		private var _ambientModel : BDRFModel;
		private var _specularModel : BDRFModel;
		private var _shadowModel : BDRFModel;

		private var _lightEnabled : Boolean = true;
		private var _environmentMap : Texture;

		private var _useCamera : Boolean;
		private var _cameraEnvMap : CameraEnvMap;

		public function LightingModel()
		{
			onChange = new Signal();
		// example for non-camera based lighting
			_ambientModel = new AmbientConstantModel();
//			_ambientModel = new AmbientEnvMapModel();
//			_ambientModel = new AmbientOccludedModel();
//			_shadowModel = new AOShadowModel();
//			_shadowModel = new SoftShadowModel();
			ambientColor = 0x808088;
//			ambientColor = 0xffffff;

			_diffuseModel = new DiffuseLambertModel();
			_specularModel = new SpecularBlinnModel();
			lightColor = 0x989589;

			// to use camera based ambient:
//			_ambientModel = new AmbientOffsetEnvMapModel();
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			// TEMPORARY, FOR TESTING PURPOSES
//			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);
//			useCamera = true;
		}

		private function onKeyPress(event : KeyboardEvent) : void
		{
			if (event.shiftKey && event.keyCode == Keyboard.C)
				useCamera = !useCamera;
		}

		public function get lightEnabled() : Boolean
		{
			return _lightEnabled;
		}


		public function set lightEnabled(value : Boolean) : void
		{
			_lightEnabled = value;
			onChange.dispatch();
		}

		public function get diffuseModel() : BDRFModel
		{
			return _diffuseModel;
		}

		public function set diffuseModel(value : BDRFModel) : void
		{
			_diffuseModel = value;
			onChange.dispatch();
		}

		public function get ambientModel() : BDRFModel
		{
			return _ambientModel;
		}

		public function set ambientModel(value : BDRFModel) : void
		{
			_ambientModel = value;
			onChange.dispatch();
		}

		public function get specularModel() : BDRFModel
		{
			return _specularModel;
		}

		public function set specularModel(value : BDRFModel) : void
		{
			_specularModel = value;
			onChange.dispatch();
		}

		public function get shadowModel() : BDRFModel
		{
			return _shadowModel;
		}

		public function set shadowModel(value : BDRFModel) : void
		{
			_shadowModel = value;
			onChange.dispatch();
		}

		public function get lightColor() : uint
		{
			return _lightColor;
		}

		public function set lightColor(value : uint) : void
		{
			_lightColor = value;
			_lightColorR = ((value >> 16) & 0xff)/0xff;
			_lightColorG = ((value >> 8) & 0xff)/0xff;
			_lightColorB = (value & 0xff)/0xff;
			onChange.dispatch();
		}

		public function get ambientColor() : uint
		{
			return _ambientColor;
		}

		public function set ambientColor(value : uint) : void
		{
			_ambientColor = value;
			_ambientColorR = ((value >> 16) & 0xff)/0xff;
			_ambientColorG = ((value >> 8) & 0xff)/0xff;
			_ambientColorB = (value & 0xff)/0xff;
			onChange.dispatch();
		}

		public function get lightPosition() : Vector3D
		{
			return _lightPosition;
		}

		public function set lightPosition(value : Vector3D) : void
		{
			_lightPosition = value;
			onChange.dispatch();
		}

		public function get eyePosition() : Vector3D
		{
			return _eyePosition;
		}

		public function set eyePosition(value : Vector3D) : void
		{
			_eyePosition = value;
			onChange.dispatch();
		}

		public function get specularStrength() : Number
		{
			return _specularStrength;
		}

		public function set specularStrength(value : Number) : void
		{
			_specularStrength = value;
			onChange.dispatch();
		}

		public function get diffuseStrength() : Number
		{
			return _diffuseStrength;
		}

		public function set diffuseStrength(value : Number) : void
		{
			_diffuseStrength = value;
			onChange.dispatch();
		}

		public function get glossiness() : Number
		{
			return _glossiness;
		}

		public function set glossiness(value : Number) : void
		{
			_glossiness = value;
			onChange.dispatch();
		}

		public function get surfaceBumpiness() : Number
		{
			return _surfaceBumpiness;
		}

		public function set surfaceBumpiness(value : Number) : void
		{
			_surfaceBumpiness = value;
			onChange.dispatch();
		}

		public function get diffuseColorR() : Number
		{
			return _lightColorR * _diffuseStrength;
		}

		public function get diffuseColorG() : Number
		{
			return _lightColorG * _diffuseStrength;
		}

		public function get diffuseColorB() : Number
		{
			return _lightColorB * _diffuseStrength;
		}

		public function get specularColorR() : Number
		{
			return Math.min(_lightColorR * _specularStrength, 1.0);
		}

		public function get specularColorG() : Number
		{
			return Math.min(_lightColorG * _specularStrength, 1.0);
		}

		public function get specularColorB() : Number
		{
			return Math.min(_lightColorB * _specularStrength, 1.0);
		}

		public function get ambientColorR() : Number
		{
			return _ambientColorR;
		}

		public function get ambientColorG() : Number
		{
			return _ambientColorG;
		}

		public function get ambientColorB() : Number
		{
			return _ambientColorB;
		}

		public function get environmentMap() : Texture
		{
			return _useCamera? _cameraEnvMap.envMap : _environmentMap;
		}

		public function set environmentMap(value : Texture) : void
		{
			_environmentMap = value;
			onChange.dispatch();
		}

		public function get useCamera() : Boolean
		{
			return _useCamera;
		}

		public function set useCamera(value : Boolean) : void
		{
			_useCamera = value;

			if (_useCamera) {
				if (!_cameraEnvMap)
				initCameraEnvMap();
			}
			else if (_cameraEnvMap) {
				_cameraEnvMap.dispose();
				_cameraEnvMap = null;
			}

			onChange.dispatch();
		}

		private function initCameraEnvMap() : void
		{
			_cameraEnvMap = new CameraEnvMap(stage3D.context3D);
//			_cameraEnvMap.timeLERPFactor = 3 / 255;
			_cameraEnvMap.sampleRange = .25;
			_cameraEnvMap.numSamplesPerFrame = 12;
			_cameraEnvMap.brightnessScale = .1;
		}

		public function update() : void
		{
			if (_useCamera) {
				_cameraEnvMap.update();
			}
		}
	}
}
