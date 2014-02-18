package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import net.psykosoft.psykopaint2.core.drawing.brushes.SprayCanBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterMapping;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.PointDecoratorFactory;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKit_SprayCan extends BrushKit
	{
		
		private static const definitionXML:XML = <brush>
			<parameterMapping>
				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_FACTOR}
					targetProperties="value"
					targetOffsets="0.03"
					targetFactors="0.25"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_0."+SizeDecorator.PARAMETER_N_RANGE}
					targetProperties="value"
					targetOffsets="0.01"
					targetFactors="0.12"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_3."+SpawnDecorator.PARAMETER_N_MAXIMUM_SIZE}
					targetProperties="value"
					targetOffsets="0.05"
					targetFactors="0.36"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_3."+SpawnDecorator.PARAMETER_N_MAXIMUM_OFFSET}
					targetProperties="value"
					targetOffsets="16"
					targetFactors="40"
					targetMappings="1"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Precision"
					target={"pathengine.pointdecorator_3."+SpawnDecorator.PARAMETER_AR_OFFSET_ANGLE}
					targetProperties="lowerDegreesValue,upperDegreesValue"
					targetOffsets="-120,120"
					targetFactors="-60,60"
					targetMappings="1,1"
					/>
				
				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_4."+ColorDecorator.PARAMETER_N_OPACITY}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="1"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_BUMP_INFLUENCE}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="1"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_GLOSSINESS}
					targetProperties="value"
					targetOffsets="0.1"
					targetFactors="0.3"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_BUMPINESS}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="0.5"
					targetMappings="0"
					/>

				<proxy type={PsykoParameterProxy.TYPE_VALUE_MAP}
					src="Intensity"
					target={"pathengine.pointdecorator_2."+BumpDecorator.PARAMETER_N_BUMPINESS_RANGE}
					targetProperties="value"
					targetOffsets="0"
					targetFactors="0.5"
					targetMappings="0"
					/>
			</parameterMapping>
		</brush>
		
		public function BrushKit_SprayCan()
		{
			init(definitionXML);
		}
		
		override protected function init( xml:XML ):void
		{
			if (!_initialized ) BrushKit.init();
			
			name = "Spraycan";
			
			brushEngine = new SprayCanBrush();
			brushEngine.param_bumpiness.numberValue = 0;
			brushEngine.param_bumpInfluence.numberValue = 0.8;
			brushEngine.param_quadOffsetRatio.numberValue = 0.4;
			brushEngine.param_shapes.stringList = Vector.<String>(["paint1","basic","splat","line","sumi"]);
			brushEngine.param_shapes.index = 0;
			brushEngine.param_shapes.showInUI = 0;
			
			var pathManager:PathManager = new PathManager( PathManager.ENGINE_TYPE_EXPERIMENTAL );
			brushEngine.pathManager = pathManager;
			pathManager.pathEngine.speedSmoothing.numberValue = 0.02;
			
			var sizeDecorator:SizeDecorator = new SizeDecorator();
			sizeDecorator.param_mappingMode.index = SizeDecorator.INDEX_MODE_PRESSURE_SPEED;
			sizeDecorator.param_mappingFactor.numberValue = 0.08;
			sizeDecorator.param_mappingRange.numberValue = 0.04;
			sizeDecorator.param_mappingFunction.index = SizeDecorator.INDEX_MAPPING_CIRCQUAD;
			pathManager.addPointDecorator( sizeDecorator );
			
			var splatterDecorator:SplatterDecorator = new SplatterDecorator();
			splatterDecorator.param_mappingMode.index = SplatterDecorator.INDEX_MODE_SIZE_INV;
			splatterDecorator.param_mappingMode.numberValue = 1;
			splatterDecorator.param_mappingFunction.index = SplatterDecorator.INDEX_MAPPING_LINEAR;
			splatterDecorator.param_splatFactor.numberValue = 20;
			splatterDecorator.param_minOffset.numberValue = 0;
			splatterDecorator.param_offsetAngleRange.degrees = 360;
			splatterDecorator.param_sizeFactor.numberValue = 0;
			pathManager.addPointDecorator( splatterDecorator );
			
			var bumpDecorator:BumpDecorator = new BumpDecorator();
			bumpDecorator.param_mappingMode.index = BumpDecorator.INDEX_MODE_RANDOM2;
			bumpDecorator.param_invertMapping.booleanValue = true;
			bumpDecorator.param_bumpiness.numberValue = 0.5;
			bumpDecorator.param_bumpinessRange.numberValue = 0.5;
			bumpDecorator.param_bumpInfluence.numberValue = 0.8;
			bumpDecorator.param_noBumpProbability.numberValue = 0.8;
			pathManager.addPointDecorator( bumpDecorator );
					
			var spawnDecorator:SpawnDecorator = new SpawnDecorator();
			spawnDecorator.param_multiples.upperRangeValue = 16;
			spawnDecorator.param_multiplesMode.index = SpawnDecorator.INDEX_MODE_SIZE_INV;
			spawnDecorator.param_offsetMode.index = SpawnDecorator.INDEX_MODE_RANDOM;
			spawnDecorator.param_offsetAngleRange.lowerDegreesValue = -180;
			spawnDecorator.param_offsetAngleRange.upperDegreesValue = 180;
			spawnDecorator.param_maxSize.numberValue = 0.12;
			spawnDecorator.param_minOffset.numberValue = 0;
			spawnDecorator.param_maxOffset.numberValue = 16;
			pathManager.addPointDecorator( spawnDecorator );
			
			var colorDecorator:ColorDecorator = new ColorDecorator();
			colorDecorator.param_brushOpacity.numberValue = 0.9;
			colorDecorator.param_brushOpacityRange.numberValue = 0.2;
			colorDecorator.param_colorBlending.lowerRangeValue = 0.95;
			colorDecorator.param_pickRadius.lowerRangeValue = 0.25;
			colorDecorator.param_pickRadius.upperRangeValue = 0.33;
			colorDecorator.param_smoothFactor.lowerRangeValue = 0.8;
			pathManager.addPointDecorator( colorDecorator );
			
			_parameterMapping = new PsykoParameterMapping();
			
			var precision:PsykoParameter = new PsykoParameter( PsykoParameter.NumberParameter,"Precision",0.25,0,1);
			precision.showInUI = 1;
			_parameterMapping.addParameter(precision);
			
			var intensity:PsykoParameter = new PsykoParameter( PsykoParameter.NumberParameter,"Intensity",0.9,0,1);
			intensity.showInUI = 2;
			_parameterMapping.addParameter(intensity);
			
			//TODO: replace XML with direct instatiation
			for ( var i:int = 0; i < xml.parameterMapping[0].proxy.length(); i++ )
			{
				_parameterMapping.addProxy( PsykoParameterProxy.fromXML( xml.parameterMapping[0].proxy[i] ) );
			}
			
			linkParameterMappings();
			
		}
		
	}
}