package net.psykosoft.psykopaint2.core.drawing.modules
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransfer;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestColorStyleMatrixChangedSignal;
	import net.psykosoft.psykopaint2.paint.configuration.ColorStylePresets;

	public class ColorStyleModule implements IModule
	{
		
		[Inject]
		public var notifyColorStylePresetsAvailableSignal : NotifyColorStylePresetsAvailableSignal;
		
		[Inject]
		public var requestColorStyleMatrixChangedSignal : RequestColorStyleMatrixChangedSignal;

		private var _active : Boolean;
		private var _sourceMap : BitmapData;
		//private var _resultMap : BitmapData;
		private var _colorTransfer:ColorTransfer;
		
		private var _maxAnalysePixelCount:int = 256 * 256;
		private var _blendRange:int = 32;
		private var _blendIn:int = 0;
		private var _blendOut:int = 0;
		

		private var _renderNeeded : Boolean = true;
		
		
		public function ColorStyleModule()
		{
			super();
		}

		public function type():String {
			return ModuleType.COLOR_STYLE;
		}
	/*	
		private function initPresets():void
		{
			_presetLabels = ["Original"];
			_presetData = {};
			for ( var i:int = 0; i < presets.factors.length(); i++ )
			{
				_presetLabels.push( presets.factors[i].@name.toString() );
				_presetData[_presetLabels[i+1]] = presets.factors[i];
			}
			
			notifyColorStylePresetsAvailableSignal.dispatch(_presetLabels);
		}
*/
		public function activate(bitmapData : BitmapData) : void
		{
			_sourceMap = bitmapData;//BitmapDataUtils.getLegalBitmapData(bitmapData);
		//	_resultMap = _sourceMap.clone();
			
			_colorTransfer = new ColorTransfer();
			_colorTransfer.setTarget(_sourceMap, _maxAnalysePixelCount );
			_active = true;
		
			//if ( _presetData == null ) initPresets();

			_renderNeeded = true;
			if ( _colorTransfer.hasSource ) render();
			
		}
		
		public function render():void
		{
			if (_renderNeeded && _colorTransfer.hasSource) {
				_colorTransfer.calculateColorMatrices();
				requestColorStyleMatrixChangedSignal.dispatch(  _colorTransfer.getColorMatrix(0),  _colorTransfer.getColorMatrix(1), _colorTransfer.getThreshold(_blendIn,_blendOut), _blendRange);
				//_colorTransfer.applyMatrices(_resultMap, _blendRange * 0.5, _blendRange * 0.5);
				_renderNeeded = false;
			}
		}
		
		/*
		public function get resultMap():BitmapData
		{
			return _resultMap;
		}
		*/
		
		public function get sourceMap():BitmapData
		{
			return _sourceMap;
		}

		public function deactivate() : void
		{
			_colorTransfer.dispose();
			_colorTransfer = null;
			
			//_presetData = null;
			
			_active = false;
			/*
			if ( _sourceMap ) {
				_sourceMap.dispose();
				//we cannot dispose _result here since it is used by the next module!
			}
			*/
		}


		public function setColorStyle( styleName:String ):void
		{
			var presetData:XML = ColorStylePresets.getPreset(styleName);
			if (presetData )
			{
				_colorTransfer.setFactors(0,presetData );
				_blendIn = presetData.@blend_in;
				_blendOut =  presetData.@blend_out;
				_blendRange = _blendIn + _blendOut;
				_renderNeeded = true;
				render();
			} else {
				requestColorStyleMatrixChangedSignal.dispatch( new ColorMatrix(), new ColorMatrix(), 0, 255);
				
				//_resultMap.copyPixels( _sourceMap, _sourceMap.rect, _sourceMap.rect.topLeft );
			}
		}


		

		public function get stateType() : String
		{
			return NavigationStateType.COLOR_STYLE;
		}
	}
}