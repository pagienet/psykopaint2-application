package net.psykosoft.psykopaint2.core.model
{
	import com.quasimondo.color.colorspace.HSV;
	import com.quasimondo.color.utils.ColorConverter;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransfer;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.paint.configuration.ColorStylePresets;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModeChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	
	public class UserPaintSettingsModel
	{
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;
		
		[Inject]
		public var notifyPaintModeChangedSignal:NotifyPaintModeChangedSignal;
		
		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;
		
		
		[Inject]
		public var canvasModel:CanvasModel;
		
		
		public var hasSourceImage:Boolean;
		public var current_r:Number;
		public var current_g:Number;
		public var current_b:Number;
		public var selectedSwatchIndex:int;
		
		public var pipetteIsEmpty:Boolean;
		public var colorStyleParameter:PsykoParameter;
		public var styleBlendParameter:PsykoParameter;
		public var previewMixtureParameter:PsykoParameter;
		public var styleMatrices:Vector.<Vector.<Number>>;
		
		public var isContinuedPainting:Boolean;
		
		
		private var initialized:Boolean;
		private var _colorPalettes:Vector.<Vector.<uint>>;
		private var _currentColor:uint;
		private var _colorMode:int;
		private var _eraserMode:Boolean;
		private var _currentHSV:HSV;
		private var _hasLoadedPalette:Boolean;
		
		public function UserPaintSettingsModel()
		{
			initialized = false;
		}
		
		public function dispose():void
		{
			if ( initialized )
			{
				initialized = false;
				_colorPalettes.length = 0;
				_colorPalettes = null;
				styleMatrices.length = 0;
				styleMatrices = null;
				colorStyleParameter = null;
				styleBlendParameter = null;
				previewMixtureParameter = null;
				_hasLoadedPalette = false;
			}
		}
		
		public function setDefaultValues():void
		{
			if ( !initialized )
			{
				pipetteIsEmpty = true;
				
				if ( !_hasLoadedPalette) _colorPalettes = new Vector.<Vector.<uint>>();
				
				if ( hasSourceImage )
				{
					if ( !_hasLoadedPalette)
					{
						_colorPalettes.push( canvasModel.getColorPaletteFromSource(8));
						_colorPalettes[0].unshift(0x0b0b0b);
						_colorPalettes[0].push(0xdedddb);
						while(_colorPalettes[0].length < 10 ) _colorPalettes[0].push( int(Math.random() * 0xffffff));
					}
					selectedSwatchIndex = 4;
					_colorMode = PaintMode.PHOTO_MODE;
				} else {
					selectedSwatchIndex = 0;
					_colorMode = PaintMode.COLOR_MODE;
				}
				styleBlendParameter = new PsykoParameter(PsykoParameter.NumberParameter,"Style Blend Factor",0,0,1);
				previewMixtureParameter = new PsykoParameter(PsykoParameter.NumberParameter,"Preview Blending",0.5,0,1);
				setupColorTransfer(0);
				
				//DEFAULT PALETTE COLORS
				if ( !_hasLoadedPalette)
					_colorPalettes.push( Vector.<uint>([0x07070a/*BLACK*/,0x00aeef/*CYAN BLUE*/,0xf4202f/*RED*/,0xfaf716/*YELLOW*/,0x84e626/*GREEN*/,
						0x88fb19/*UNUSED, USERD FOR ERASER*/,0xfbcfac/* SKIN COLOR */,0x583520/* DARK BROWN */,0xfafafa/*WHITE*/,0xffffff/*SAMPLE SWATCH*/]));
				
				
				
				_currentHSV = new HSV(0,0,0);
				//colorMode = PaintMode.PHOTO_MODE;
				//0x062750,0x04396c,
				//,0xd94300
				
				initialized = true;
			} else {
				colorStyleParameter.index = 0;
				styleBlendParameter.numberValue = 0;
				previewMixtureParameter.numberValue = 0.5;
				
			}
		}
		
		
		private function setupColorTransfer(step:int, parameterList:Array = null):void
		{
			if ( step == 0 )
			{
				styleMatrices = new Vector.<Vector.<Number>>();
				 parameterList = [];
				 colorStyleParameter = new PsykoParameter( PsykoParameter.IconListParameter,"Color Style",0,parameterList);
			}
			
			var colorTransfer:ColorTransfer = canvasModel.colorTransfer;
			var presets:Vector.<String> = ColorStylePresets.getAvailableColorStylePresets();
			var cm1:ColorMatrix;
			var cm2:ColorMatrix;
			var i:int = step;
			//for ( var i:int = 0; i < presets.length; i++ )
			//{
				
				var preset:XML = ColorStylePresets.getPreset(presets[i]);
				parameterList.push(preset.@name);
				if ( !preset.hasOwnProperty("@colorMatrix") )
				{
					colorTransfer.setFactors(0, preset );
					colorTransfer.calculateColorMatrices();
					cm1 = colorTransfer.getColorMatrix(0);
					cm2 = colorTransfer.getColorMatrix(1);
					/*
					if ( threshold < 0 )
					{
						cm1.adjustSaturation(-1)
						cm1.invert();
						cm2.adjustSaturation(-1)
						cm2.invert();
					}
					*/
					
					var v:Vector.<Number> = Vector.<Number>([cm1.matrix[0],cm1.matrix[1],cm1.matrix[2],cm1.matrix[4] / 255,cm1.matrix[5],cm1.matrix[6],cm1.matrix[7],cm1.matrix[9]/ 255,cm1.matrix[10],cm1.matrix[11],cm1.matrix[12],cm1.matrix[14]/ 255,
						cm2.matrix[0],cm2.matrix[1],cm2.matrix[2],cm2.matrix[4] / 255,cm2.matrix[5],cm2.matrix[6],cm2.matrix[7],cm2.matrix[9]/ 255,cm2.matrix[10],cm2.matrix[11],cm2.matrix[12],cm2.matrix[14]/ 255]);
					
					var blendIn:Number = preset.@blend_in;
					var blendOut:Number =  preset.@blend_out;
					var blendRange:Number = blendIn + blendOut;
					var threshold:Number = colorTransfer.getThreshold(blendIn,blendOut);
					v.push((threshold - blendRange *0.5 )/ 255.0 ,  255 / blendRange );
				} else {
					var colorMatrixData:Array = preset.@colorMatrix.toString().split(",");
					v = Vector.<Number>([colorMatrixData[0],colorMatrixData[1],colorMatrixData[2],colorMatrixData[4] / 255,colorMatrixData[5],colorMatrixData[6],colorMatrixData[7],colorMatrixData[9]/ 255,colorMatrixData[10],colorMatrixData[11],colorMatrixData[12],colorMatrixData[14]/ 255,
						colorMatrixData[0],colorMatrixData[1],colorMatrixData[2],colorMatrixData[4] / 255,colorMatrixData[5],colorMatrixData[6],colorMatrixData[7],colorMatrixData[9]/ 255,colorMatrixData[10],colorMatrixData[11],colorMatrixData[12],colorMatrixData[14]/ 255,0.5,0]);
					
				}
				styleMatrices.push( v );
				
				if ( step == 0 )
				{
					notifyColorStyleChangedSignal.dispatch( styleMatrices[0],styleBlendParameter.numberValue);
					
				}
			//}
			step++;
			colorStyleParameter.stringList = Vector.<String>(parameterList);
			if ( step < presets.length ) setTimeout(setupColorTransfer,50,step,parameterList);
			
			
			
			/*
			cm.adjustContrast(10);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4] / 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.reset();
			cm.desaturate();
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.reset();
			cm.adjustSaturation(4);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.reset();
			cm.randomize(100);
			cm.fitRange();
			cm.adjustContrast(2);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.randomize(100);
			cm.fitRange();
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.randomize(100);
			cm.fitRange();
			cm.adjustContrast(2);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			cm.randomize(100);
			cm.fitRange();
			cm.adjustContrast(2);
			styleMatrices.push( Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4]/ 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]));
			*/
			
		}
		
		
		public function set colorPalettes( value:Vector.<Vector.<uint>> ):void
		{
			_colorPalettes = value;
		}
		
		public function get colorPalettes():Vector.<Vector.<uint>>
		{
			return _colorPalettes;
		}
		
		public function get currentHSV():HSV
		{
			return _currentHSV;
		}
		
		public function setCurrentColor( value:uint, dispatchSignal:Boolean = true ):void
		{
			if ( _currentColor != value )
			{
				_currentColor = value;
				var f:Number = 1 / 255;
				current_r = ((value >> 16) & 0xff) * f;
				current_g = ((value >> 8) & 0xff) * f;
				current_b = (value & 0xff) * f;
				_currentHSV = ColorConverter.UINTtoHSV( value );
				if ( dispatchSignal ) notifyPickedColorChangedSignal.dispatch( _currentColor, _colorMode, false);
			}
		}
		
		public function updateCurrentColorFromHSV():void
		{
			_currentColor = ColorConverter.HSVtoUINT(_currentHSV);
			var f:Number = 1 / 255;
			current_r = ((_currentColor >> 16) & 0xff) * f;
			current_g = ((_currentColor >> 8) & 0xff) * f;
			current_b = (_currentColor & 0xff) * f;
			notifyPickedColorChangedSignal.dispatch( _currentColor, _colorMode, true);
		}
		
		public function get currentColor():uint
		{
			return _currentColor;
		}
		
		public function setColorMode( value:int, forceSignalDispatch:Boolean = false):void
		{
			if ( forceSignalDispatch || _colorMode != value )
			{
				_colorMode = value;
				notifyPaintModeChangedSignal.dispatch( _colorMode );
				if ( _colorMode != PaintMode.COSMETIC_MODE ) notifyPickedColorChangedSignal.dispatch( _currentColor, _colorMode, false);
			}
		}
		
		public function get colorMode():int
		{
			return _colorMode;
		}
		
		public function set eraserMode( value:Boolean ):void
		{
			if ( _eraserMode != value )
			{
				_eraserMode = value;
				if ( _eraserMode ) setColorMode(PaintMode.ERASER_MODE);
			//	setColorMode( _eraserMode ? PaintMode.ERASER_MODE : PaintMode.COLOR_MODE  )
			}
		}
		
		public function get eraserMode():Boolean
		{
			return _eraserMode;
		}
		
		public function set hue( value:Number ):void
		{
			_currentHSV.hue = value;
		}
		
		public function get hue():Number
		{
			return _currentHSV.hue;
		}
		
		public function set saturation( value:Number ):void
		{
			_currentHSV.saturation = value;
		}
		
		public function get saturation():Number
		{
			return _currentHSV.saturation;
		}
		
		public function set lightness( value:Number ):void
		{
			_currentHSV.value = value;
		}
		
		public function get lightness():Number
		{
			return _currentHSV.value;
		}
		
		public function setPalettes(colorPalettes:Vector.<Vector.<uint>>):void
		{
			if ( _colorPalettes == null )
			{
				_colorPalettes = new Vector.<Vector.<uint>>();
			}
			for ( var i:int = 0; i < colorPalettes.length; i++ )
			{
				_colorPalettes[i] = colorPalettes[i].concat();
			}
			_hasLoadedPalette = true;
		}
	}
}