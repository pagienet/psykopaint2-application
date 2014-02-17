package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.SketchBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.WaterColorBrush;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameter;
	import net.psykosoft.psykopaint2.core.drawing.data.PsykoParameterProxy;
	import net.psykosoft.psykopaint2.core.drawing.paths.AbstractPathEngine;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SpawnDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SplatterDecorator;

	public class BrushKit_Cutout extends BrushKit
	{
		
		private static const definitionXML:XML = <brush engine={BrushType.BLOB} name="Cutout">
						<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="render" showInUI="0"/>

						<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
							
							<ColorDecorator>
								<parameter id={ColorDecorator.PARAMETER_N_OPACITY} label="Intensity" path="pathengine.pointdecorator_0" value="0.9" showInUI="2"/>
								<parameter id={ColorDecorator.PARAMETER_NR_COLOR_BLENDING} path="pathengine.pointdecorator_0" value1="1" value2="1" />
							</ColorDecorator>
						<SplatterDecorator >
							<parameter id={SplatterDecorator.PARAMETER_A_OFFSET_ANGLE_RANGE} value1="0" value2="0" path="pathengine.pointdecorator_1" />
							<parameter id={SplatterDecorator.PARAMETER_A_ANGLE_ADJUSTMENT} value="90" path="pathengine.pointdecorator_1" />
							<parameter id={SplatterDecorator.PARAMETER_N_SPLAT_FACTOR} value="0" minValue="0" maxValue="5" path="pathengine.pointdecorator_1" showInUI="1"/>
							<parameter id={SplatterDecorator.PARAMETER_N_SIZE_FACTOR} value="0" path="pathengine.pointdecorator_1" />
							<parameter id={SplatterDecorator.PARAMETER_N_MINIMUM_OFFSET} value="0" path="pathengine.pointdecorator_1" />
						</SplatterDecorator>	
						</pathengine>
				</brush>
		
		public function BrushKit_Cutout()
		{
			init(definitionXML);
		}
	}
}