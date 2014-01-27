package net.psykosoft.psykopaint2.core.model
{
	import com.quasimondo.color.colorspace.HSV;
	import com.quasimondo.color.utils.ColorConverter;
	import com.quasimondo.geom.ColorMatrix;
	
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransfer;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.paint.configuration.ColorStylePresets;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;

	public class UserPaintSettingsModel
	{
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;
		
		[Inject]
		public var canvasModel:CanvasModel;
		
		private var _colorPalettes:Vector.<Vector.<uint>>;
		private var _currentColor:uint;
		private var _colorMode:int;
		public var hasSourceImage:Boolean;
		public var current_r:Number;
		public var current_g:Number;
		public var current_b:Number;
		public var selectedSwatchIndex:int;
		private var _currentHSV:HSV;
		public var pipetteIsEmpty:Boolean;
		public var colorStyleParameter:PsykoParameter;
		public var styleBlendParameter:PsykoParameter;
		public var previewMixtureParameter:PsykoParameter;
		public var styleMatrices:Vector.<Vector.<Number>>;
		private var initialized:Boolean;
		
		public function UserPaintSettingsModel()
		{
			initialized = false;
		}
		
		
		public function setDefaultValues():void
		{
			if ( !initialized )
			{
				_colorPalettes = new Vector.<Vector.<uint>>();
				pipetteIsEmpty = true;
				if ( hasSourceImage )
				{
					_colorPalettes.push( canvasModel.getColorPaletteFromSource(8));
					_colorPalettes[0].unshift(0x0b0b0b);
					_colorPalettes[0].push(0xdedddb);
					while(_colorPalettes[0].length < 10 ) _colorPalettes[0].push( int(Math.random() * 0xffffff));
					selectedSwatchIndex = 4;
					_colorMode = PaintMode.PHOTO_MODE;
				} else {
					selectedSwatchIndex = 0;
					_colorMode = PaintMode.COLOR_MODE;
				}
				styleBlendParameter = new PsykoParameter(PsykoParameter.NumberParameter,"Style Blend Factor",1,0,1);
				previewMixtureParameter = new PsykoParameter(PsykoParameter.NumberParameter,"Preview Blending",0.5,0,1);
				setupColorTransfer();
				
				_colorPalettes.push( Vector.<uint>([0x0b0b0b,0x01315a,0x00353b,0x026d01,0x452204,
					0x7a1023,0xa91606,0xbd9c01,0x04396c,0xdedddb]));
				
				
				
				_currentHSV = new HSV(0,0,0);
				//colorMode = PaintMode.PHOTO_MODE;
				//0x062750,0x04396c,
				//,0xd94300
				
				initialized = true;
			}
		}
		
		
		private function setupColorTransfer():void
		{
			styleMatrices = new Vector.<Vector.<Number>>();
			//var cm:ColorMatrix = new ColorMatrix();
			styleMatrices.push(null);
			var colorTransfer:ColorTransfer = canvasModel.colorTransfer;
			var parameterList:Array = ["No Style"];
			
			var presets:Vector.<String> = ColorStylePresets.getAvailableColorStylePresets();
			var cm:ColorMatrix;
			for ( var i:int = 0; i < presets.length; i++ )
			{
				
				var preset:XML = ColorStylePresets.getPreset(presets[i]);
				parameterList.push(preset.@name);
				colorTransfer.setFactors(0, preset );
				colorTransfer.calculateColorMatrices();
				cm = colorTransfer.getColorMatrix(0);
				var v:Vector.<Number> = Vector.<Number>([cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4] / 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255]);
				cm = colorTransfer.getColorMatrix(1);
				v.push(cm.matrix[0],cm.matrix[1],cm.matrix[2],cm.matrix[4] / 255,cm.matrix[5],cm.matrix[6],cm.matrix[7],cm.matrix[9]/ 255,cm.matrix[10],cm.matrix[11],cm.matrix[12],cm.matrix[14]/ 255);
				var blendIn:Number = preset.@blend_in;
				var blendOut:Number =  preset.@blend_out;
				var blendRange:Number = blendIn + blendOut;
				var threshold:Number = colorTransfer.getThreshold(blendIn,blendOut);
				v.push((threshold - blendRange *0.5 )/ 255.0 ,  255 / blendRange );
				styleMatrices.push( v );
				
			}
			
			colorStyleParameter = new PsykoParameter( PsykoParameter.IconListParameter,"Color Style",0,parameterList);
			
			
			
			
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
		
		public function setColorMode( value:int, dispatchSignal:Boolean = true ):void
		{
			if ( _colorMode != value )
			{
				_colorMode = value;
				if ( dispatchSignal ) notifyPickedColorChangedSignal.dispatch( _currentColor, _colorMode, false);
			}
		}
		
		public function get colorMode():int
		{
			return _colorMode;
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
	}
}