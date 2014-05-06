package net.psykosoft.psykopaint2.core.drawing.brushkits
{
	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.BumpDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.ColorDecorator;
	import net.psykosoft.psykopaint2.core.drawing.paths.decorators.SizeDecorator;

	public class BrushKit_Eraser extends BrushKit
	{
		
		private static const definitionXML:XML = <brush engine={BrushType.SPRAY_CAN} name="Eraser">
					<parameter id={AbstractBrush.PARAMETER_NR_SIZE_FACTOR} path="brush" value1="0" value2="1"/>
					<parameter id={AbstractBrush.PARAMETER_N_BUMPINESS} path="brush" value="0"/>
					<parameter id={AbstractBrush.PARAMETER_IL_SHAPES} path="brush" index="0" list="splotch,basic smooth,splat,basic,noisy" showInUI="0"/>
					<parameter id={AbstractBrush.PARAMETER_SL_BLEND_MODE} path="brush" index="1"/>
					
					<pathengine type={PathManager.ENGINE_TYPE_EXPERIMENTAL}>
						<SizeDecorator>
							<parameter id={SizeDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_0" index={SizeDecorator.INDEX_MODE_FIXED} />
							<parameter id={SizeDecorator.PARAMETER_N_FACTOR} path="pathengine.pointdecorator_0" value="0.55" minValue="0" maxValue="2" showInUI="1"/>
							<parameter id={SizeDecorator.PARAMETER_N_RANGE} path="pathengine.pointdecorator_0" value="0.15" minValue="0" maxValue="1" />
							<parameter id={SizeDecorator.PARAMETER_SL_MAPPING} path="pathengine.pointdecorator_0" index="1"/>
						</SizeDecorator>
						<ColorDecorator>
							<parameter id={ColorDecorator.PARAMETER_N_OPACITY} value="0.5" path="pathengine.pointdecorator_1" showInUI="2" />
							<!--<parameter id={ColorDecorator.PARAMETER_C_COLOR}  path="pathengine.pointdecorator_1" color="0xffffffff" />-->
						</ColorDecorator>
						<BumpDecorator>
							<parameter id={BumpDecorator.PARAMETER_SL_MODE} path="pathengine.pointdecorator_2" index={BumpDecorator.INDEX_MODE_FIXED} />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMPINESS_RANGE} path="pathengine.pointdecorator_2" value="0"/>
							<parameter id={BumpDecorator.PARAMETER_N_SHININESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_GLOSSINESS} path="pathengine.pointdecorator_2" value="0" />
							<parameter id={BumpDecorator.PARAMETER_N_BUMP_INFLUENCE}  path="pathengine.pointdecorator_2" value="1" minValue="0" maxValue="1" />
						</BumpDecorator>
					</pathengine>
				</brush>

				
		
		public function BrushKit_Eraser()
		{
			init(definitionXML);
		}
	}
}