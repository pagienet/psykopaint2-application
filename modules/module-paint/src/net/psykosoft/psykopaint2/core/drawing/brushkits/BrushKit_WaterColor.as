package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;

	public class BrushKit_WaterColor extends BrushKit
	{
		
		private static const definitionXML:XML = <brush engine={BrushType.WATER_COLOR} name="Water Color">
			<!--<parameter id={WaterColorBrush.PARAMETER_N_SURFACE_INFLUENCE} path="brush" value="0.75" showInUI="0"/>-->
			<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_STAINING} type={PsykoParameter.NumberParameter} path="brush" value=".4" />
			<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_DENSITY} type={PsykoParameter.NumberParameter} path="brush" value=".4" />
			<!--<parameter id={WaterColorBrush.PARAMETER_N_PIGMENT_GRANULATION} path="brush" value="1.5" />-->
			<parameter id={AbstractBrush.PARAMETER_IL_SHAPES}  path="brush" index="0" list="basic,wet" showInUI="0"/>

						<parameterMapping>
							<parameter id="WaterColorSize" showInUI="1" minValue={.03} maxValue="1" value=".77"/>
							<proxy 	type={PsykoParameterProxy.TYPE_VALUE_MAP} src="WaterColorSize"
							target={"brush."+AbstractBrush.PARAMETER_NR_SIZE_FACTOR}
							targetProperties="lowerRangeValue,upperRangeValue"
							targetOffsets="0.0,0.0"
							targetFactors="1.0,1.0"/>

							<parameter id="WaterColorOpacity" showInUI="2" minValue="0" maxValue="1" value=".33"/>
							<proxy 	type={PsykoParameterProxy.TYPE_VALUE_MAP} src="WaterColorOpacity"
							target={"brush."+WaterColorBrush.PARAMETER_N_PIGMENT_DENSITY}
							targetOffsets="0"
							targetFactors="0.25"/>
							<proxy 	type={PsykoParameterProxy.TYPE_VALUE_MAP} src="WaterColorOpacity"
							target={"brush."+WaterColorBrush.PARAMETER_N_PIGMENT_STAINING}
							targetOffsets="0.1"
							targetFactors="0.6"/>
						</parameterMapping>

					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}/>
				</brush>

				
		
		public function BrushKit_WaterColor()
		{
			init(definitionXML);
		}
	}
}