package net.psykosoft.psykopaint2.core.drawing.colortransfer
{
	import com.quasimondo.geom.ColorMatrix;
	import com.quasimondo.geom.CoordinateShuffler;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import avm2.intrinsics.memory.li32;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.intrinsics.PyramidMapIntrinsics;
	
	import ru.inspirit.linalg.JacobiSVD;
	
	public class ColorTransfer
	{
		public var hasSource:Boolean;
		public var hasTarget:Boolean;
		
		private var means:Vector.<Vector.<Vector3D>>;
		private var dimensions:Vector.<Vector.<Vector3D>>;
		private var rotationMatrices:Vector.<Vector.<Matrix3D>>;
		private var invRotationMatrices:Vector.<Vector.<Matrix3D>>;
		private var histograms:Vector.<HistogramLuminance>;
		
		private var jacobi:JacobiSVD;
		
		private var currentSourceToTargetMatrices:Vector.<Matrix3D>;
		private var targetMap:BitmapData;
		private var targetPyramidMap:PyramidMapIntrinsics;
		private var threshold_target:int;
		
		public function ColorTransfer()
		{
			
			means 				= new Vector.<Vector.<Vector3D>>(2,true);
			dimensions 			= new Vector.<Vector.<Vector3D>>(2,true);
			rotationMatrices 	= new Vector.<Vector.<Matrix3D>>(2,true);
			invRotationMatrices = new Vector.<Vector.<Matrix3D>>(2,true);
			
			means[0] = new Vector.<Vector3D>(2,true);
			means[1] = new Vector.<Vector3D>(2,true);
			dimensions[0] = new Vector.<Vector3D>(2,true);
			dimensions[1] = new Vector.<Vector3D>(2,true);
			rotationMatrices[0] = new Vector.<Matrix3D>(2,true);
			rotationMatrices[1] = new Vector.<Matrix3D>(2,true);
			invRotationMatrices[0] = new Vector.<Matrix3D>(2,true);
			invRotationMatrices[1] = new Vector.<Matrix3D>(2,true);
			histograms = new Vector.<HistogramLuminance>(2,true);
			
			
			jacobi = new JacobiSVD();
		}
		
		public function setSource( value:BitmapData, maxPixelCount:uint = 0xffffffff ):void
		{
			if ( value != null ) analyzeMap( value, 0, maxPixelCount );
			hasSource = ( value != null );
			
		}
		
		public function setTarget( value:BitmapData, maxPixelCount:uint = 0xffffffff ):void
		{
			if ( value != null ) analyzeMap( value, 1, maxPixelCount );
			targetMap = value;
			hasTarget = ( value != null );
		}
		
		public function setTargetFromPyramidMap( value:PyramidMapIntrinsics, maxPixelCount:uint = 0xffffffff ):void
		{
			if ( value != null ) analyzePyramidMap( value, 1, maxPixelCount );
			targetPyramidMap = value;
			hasTarget = ( value != null );
		}
		
		public function dispose():void
		{
			
			means 				= null;
			dimensions 			= null;
			rotationMatrices 	= null;
			invRotationMatrices = null;
			histograms = null;
			jacobi = null;
			currentSourceToTargetMatrices = null;
			targetMap = null;
		
		}
		
		private function analyzeMap( map:BitmapData, index:int,  maxPixelCount:uint = 0xffffffff ):void
		{
			var colorData:Vector.<uint>;
			var lumaData:Vector.<uint>;
			var histogram:HistogramLuminance;
			
			if ( map.width * map.height < maxPixelCount )
			{
				colorData = map.getVector( map.rect );
				histogram = histograms[index] = new HistogramLuminance(map);
				lumaData = histogram.lumaMap.getVector(map.rect);
			} else {
				var scale:Number = maxPixelCount / (map.width * map.height);
				var tmpMap:BitmapData = new TrackedBitmapData(map.width * scale, map.height * scale,true,0);
				tmpMap.draw( map, new Matrix(scale,0,0,scale),null,"normal",null,true);
				colorData = tmpMap.getVector( tmpMap.rect );
				histogram = histograms[index] = new HistogramLuminance(tmpMap);
				lumaData = histogram.lumaMap.getVector(tmpMap.rect);
			}
			
			var threshold:int = histogram.histo.getThreshold(Histogram.THRESHOLD_ENTROPY);
			if ( index == 1 ) threshold_target = threshold;
			var rgbValues:Vector.<int> = new Vector.<int>();
			var sum_r:Vector.<Number> = new Vector.<Number>(2,true);
			var sum_g:Vector.<Number> = new Vector.<Number>(2,true);
			var sum_b:Vector.<Number> = new Vector.<Number>(2,true);
			var mx:Vector.<int> = new Vector.<int>(2,true);
			var my:Vector.<int> = new Vector.<int>(2,true);
			var mz:Vector.<int> = new Vector.<int>(2,true);
			var c11:Vector.<Number> = new Vector.<Number>(2,true);
			var c22:Vector.<Number> = new Vector.<Number>(2,true);
			var c33:Vector.<Number> = new Vector.<Number>(2,true);
			var c12:Vector.<Number> = new Vector.<Number>(2,true);
			var c13:Vector.<Number> = new Vector.<Number>(2,true);
			var c23:Vector.<Number> = new Vector.<Number>(2,true);
			var totalColors:Vector.<uint> = new Vector.<uint>(2,true);
			var binIndices:Object = {};
			
			var idx:int = colorData.length;
			var binIndex:int;
			var c:int;
			var i:int = 0;
			while( --idx != -1 )
			{
				c = colorData[idx] & 0xffffff;
				if ( binIndices[c] == null )
				{
					binIndices[c] = binIndex = ((lumaData[idx] & 0xff) < threshold ? 0 : 1);
					sum_r[binIndex] += ( c >> 16 ) & 0xff;
					sum_g[binIndex] += ( c >> 8 ) & 0xff;
					sum_b[binIndex] += c & 0xff;
					rgbValues[i++] = c;
					totalColors[binIndex]++;
				}
			}
			
			if ( totalColors[0] != 0 )
			{
				mx[0] = 0.5 + sum_r[0] / totalColors[0];
				my[0] = 0.5 + sum_g[0] / totalColors[0];
				mz[0] = 0.5 + sum_b[0] / totalColors[0];
			} else {
				totalColors[0] = 1;
			}
			
			if ( totalColors[1] != 0 )
			{
				mx[1] = 0.5 + sum_r[1] / totalColors[1];
				my[1] = 0.5 + sum_g[1] / totalColors[1];
				mz[1] = 0.5 + sum_b[1] / totalColors[1];
			}  else {
				totalColors[1] = 1;
			}
			
			
			for ( i = rgbValues.length; --i > -1; )
			{
				c = rgbValues[i];
				idx = binIndices[c];
				var dx:int = (( c >> 16 ) & 0xff) - mx[idx];
				var dy:int = (( c >> 8 ) & 0xff) - my[idx];
				var dz:int = (c & 0xff) - mz[idx];
				c11[idx] += dx * dx;
				c22[idx] += dy * dy;
				c33[idx] += dz * dz;
				c12[idx] += dx * dy;
				c13[idx] += dx * dz;
				c23[idx] += dy * dz;
				
			}
			
			var sv:Vector.<Number> = new Vector.<Number>(3,true);
			var U:Vector.<Number> = new Vector.<Number>(9,true);
			var V:Vector.<Number> = new Vector.<Number>(9,true);
			for ( i = 0; i < 2; i++ )
			{
				jacobi.decompose( Vector.<Number>([ c11[i] / totalColors[i], c12[i] / totalColors[i], c13[i] / totalColors[i] ,
					c12[i] / totalColors[i], c22[i] / totalColors[i], c23[i] / totalColors[i] ,
					c13[i] / totalColors[i], c23[i] / totalColors[i], c33[i] / totalColors[i] ]),
					3,3,
					sv,U,V);
				
				var svr:Number = Math.sqrt(sv[0]);
				var svg:Number = Math.sqrt(sv[1]);
				var svb:Number = Math.sqrt(sv[2]);
				
				
				var pcv_r:Vector3D = new Vector3D( U[0] * svr, U[3] * svr, U[6] * svr );
				var pcv_g:Vector3D = new Vector3D( U[1] * svg, U[4] * svg, U[7] * svg );
				var pcv_b:Vector3D = new Vector3D( U[2] * svb, U[5] * svb, U[8] * svb );
				
				dimensions[index][i] = new Vector3D( svr*2, svg*2, svb*2 );
				invRotationMatrices[index][i] = new Matrix3D( Vector.<Number>([U[0],U[1],U[2],0,U[3],U[4],U[5],0,U[6],U[7],U[8],0,0,0,0,1]));
				rotationMatrices[index][i] = invRotationMatrices[index][i].clone();
				rotationMatrices[index][i].invert();
				
				means[index][i] = new Vector3D(mx[i],my[i],mz[i]);
				
			}
		}
		
		
		private function analyzePyramidMap( map:PyramidMapIntrinsics, index:int,  maxPixelCount:uint = 0xffffffff ):void
		{
			
			var shuffler:CoordinateShuffler = new CoordinateShuffler(map.width>>1,map.height>>1,777777);
			maxPixelCount = Math.min(maxPixelCount, (map.width>>1) * (map.height>>1));
			var idxOffset:int = map.getMemoryOffset(1);
			var histo:Histogram = new Histogram(256);
			var lumaLut:Object = {};
			var indices:Vector.<uint> = shuffler.getCoordinateIndices(maxPixelCount);
			for ( var i:int = maxPixelCount; --i > -1; )
			{
				var c:int = li32(idxOffset+(indices[i]<<2));
				histo.add( lumaLut[c] = int((76 * (( c >> 8 ) & 0xff) + 150 * (( c >> 16 ) & 0xff) +  29 * (( c >>> 24 ) & 0xff) + 128) >> 8 ));
			}
			
			var threshold:int = histo.getThreshold(Histogram.THRESHOLD_ENTROPY);
			if ( index == 1 ) threshold_target = threshold;
			var rgbValues:Vector.<int> = new Vector.<int>();
			var sum_r:Vector.<Number> = new Vector.<Number>(2,true);
			var sum_g:Vector.<Number> = new Vector.<Number>(2,true);
			var sum_b:Vector.<Number> = new Vector.<Number>(2,true);
			var mx:Vector.<int> = new Vector.<int>(2,true);
			var my:Vector.<int> = new Vector.<int>(2,true);
			var mz:Vector.<int> = new Vector.<int>(2,true);
			var c11:Vector.<Number> = new Vector.<Number>(2,true);
			var c22:Vector.<Number> = new Vector.<Number>(2,true);
			var c33:Vector.<Number> = new Vector.<Number>(2,true);
			var c12:Vector.<Number> = new Vector.<Number>(2,true);
			var c13:Vector.<Number> = new Vector.<Number>(2,true);
			var c23:Vector.<Number> = new Vector.<Number>(2,true);
			var totalColors:Vector.<uint> = new Vector.<uint>(2,true);
			var binIndices:Object = {};
			
			
			var binIndex:int;
			var idx:int = maxPixelCount;
			i = 0;
			while( --idx > -1 )
			{
				c = li32(idxOffset+(indices[idx]<<2));
				if ( binIndices[c] == null )
				{
					binIndices[c] = binIndex = (int(lumaLut[c]) < threshold ? 0 : 1);
					sum_r[binIndex] += ( c >> 8 ) & 0xff;
					sum_g[binIndex] += ( c >> 16 ) & 0xff;
					sum_b[binIndex] += ( c >>> 24 ) & 0xff;
					rgbValues[i++] = c;
					totalColors[binIndex]++;
				}
			}
			
			if ( totalColors[0] != 0 )
			{
				mx[0] = 0.5 + sum_r[0] / totalColors[0];
				my[0] = 0.5 + sum_g[0] / totalColors[0];
				mz[0] = 0.5 + sum_b[0] / totalColors[0];
			} else {
				totalColors[0] = 1;
			}
			
			if ( totalColors[1] != 0 )
			{
				mx[1] = 0.5 + sum_r[1] / totalColors[1];
				my[1] = 0.5 + sum_g[1] / totalColors[1];
				mz[1] = 0.5 + sum_b[1] / totalColors[1];
			}  else {
				totalColors[1] = 1;
			}
			
			
			for ( i = rgbValues.length; --i > -1; )
			{
				c = rgbValues[i];
				idx = binIndices[c];
				var dx:int = (( c >> 16 ) & 0xff) - mx[idx];
				var dy:int = (( c >> 8 ) & 0xff) - my[idx];
				var dz:int = (c & 0xff) - mz[idx];
				c11[idx] += dx * dx;
				c22[idx] += dy * dy;
				c33[idx] += dz * dz;
				c12[idx] += dx * dy;
				c13[idx] += dx * dz;
				c23[idx] += dy * dz;
				
			}
			
			var sv:Vector.<Number> = new Vector.<Number>(3,true);
			var U:Vector.<Number> = new Vector.<Number>(9,true);
			var V:Vector.<Number> = new Vector.<Number>(9,true);
			for ( i = 0; i < 2; i++ )
			{
				jacobi.decompose( Vector.<Number>([ c11[i] / totalColors[i], c12[i] / totalColors[i], c13[i] / totalColors[i] ,
					c12[i] / totalColors[i], c22[i] / totalColors[i], c23[i] / totalColors[i] ,
					c13[i] / totalColors[i], c23[i] / totalColors[i], c33[i] / totalColors[i] ]),
					3,3,
					sv,U,V);
				
				var svr:Number = Math.sqrt(sv[0]);
				var svg:Number = Math.sqrt(sv[1]);
				var svb:Number = Math.sqrt(sv[2]);
				
				
				var pcv_r:Vector3D = new Vector3D( U[0] * svr, U[3] * svr, U[6] * svr );
				var pcv_g:Vector3D = new Vector3D( U[1] * svg, U[4] * svg, U[7] * svg );
				var pcv_b:Vector3D = new Vector3D( U[2] * svb, U[5] * svb, U[8] * svb );
				
				dimensions[index][i] = new Vector3D( svr*2, svg*2, svb*2 );
				invRotationMatrices[index][i] = new Matrix3D( Vector.<Number>([U[0],U[1],U[2],0,U[3],U[4],U[5],0,U[6],U[7],U[8],0,0,0,0,1]));
				rotationMatrices[index][i] = invRotationMatrices[index][i].clone();
				rotationMatrices[index][i].invert();
				
				means[index][i] = new Vector3D(mx[i],my[i],mz[i]);
				
			}
		}
		
		public function calculateColorMatrices():void
		{
			currentSourceToTargetMatrices = new Vector.<Matrix3D>();
			
			var matrix:Matrix3D = new Matrix3D();
			if ( hasSource && hasTarget )
			{
				for ( var i:int = 0; i < 2; i++ )
				{
					matrix.identity();
					matrix.appendTranslation(-means[1][i].x,-means[1][i].y,-means[1][i].z);
					if ( (dimensions[1][i].x != 0) && (dimensions[1][i].y != 0) && (dimensions[1][i].z != 0) )
					{
						if ( (dimensions[0][i].x != 0) && (dimensions[0][i].y != 0) && (dimensions[0][i].z != 0) )
						{
							matrix.append(invRotationMatrices[1][i]);
							matrix.appendScale( dimensions[0][i].x  / dimensions[1][i].x, 
								dimensions[0][i].y  / dimensions[1][i].y , 
								dimensions[0][i].z  / dimensions[1][i].z  );
							matrix.append(rotationMatrices[0][i]);
						} else {
							matrix.copyRowFrom(0, new Vector3D(0.33333,0.33333,0.33333));
							matrix.copyRowFrom(1, new Vector3D(0.33333,0.33333,0.33333));
							matrix.copyRowFrom(2, new Vector3D(0.33333,0.33333,0.33333));
						}
					}
					matrix.appendTranslation(means[0][i].x,means[0][i].y,means[0][i].z);
					
					
					var angles1:Vector3D = invRotationMatrices[1][i].decompose(Orientation3D.EULER_ANGLES)[1];
					var angleX1_ok:Boolean = ( angles1.x <= Math.PI / 2 && angles1.x >= -Math.PI / 2 );
					var angleY1_ok:Boolean = ( angles1.y <= Math.PI / 2 && angles1.y >= -Math.PI / 2 );
					var angleZ1_ok:Boolean = ( angles1.z <= Math.PI / 2 && angles1.z >= -Math.PI / 2 );
					
					var angles2:Vector3D = rotationMatrices[0][i].decompose(Orientation3D.EULER_ANGLES)[1];
					var angleX2_ok:Boolean = ( angles2.x <= Math.PI / 2 && angles2.x >= -Math.PI / 2 );
					var angleY2_ok:Boolean = ( angles2.y <= Math.PI / 2 && angles2.y >= -Math.PI / 2 );
					var angleZ2_ok:Boolean = ( angles2.z <= Math.PI / 2 && angles2.z >= -Math.PI / 2 );
					
					if ( !angleX1_ok || !angleY1_ok || !angleZ1_ok || !angleX2_ok || !angleY2_ok || !angleZ2_ok )
					{
						matrix.identity();
						matrix.appendTranslation(-means[1][i].x,-means[1][i].y,-means[1][i].z);
						if ( (dimensions[1][i].x != 0) && (dimensions[1][i].y != 0) && (dimensions[1][i].z != 0) )
						{
							if ( (dimensions[0][i].x != 0) && (dimensions[0][i].y != 0) && (dimensions[0][i].z != 0) )
							{
								matrix.append(invRotationMatrices[1][i]);
								if ( !angleX1_ok ) matrix.appendRotation( 180, Vector3D.X_AXIS);
								if ( !angleY1_ok ) matrix.appendRotation( 180, Vector3D.Y_AXIS);
								if ( !angleZ1_ok ) matrix.appendRotation( 180, Vector3D.Z_AXIS );
								matrix.appendScale( dimensions[0][i].x  / dimensions[1][i].x, 
									dimensions[0][i].y  / dimensions[1][i].y , 
									dimensions[0][i].z  / dimensions[1][i].z  );
								if ( !angleX2_ok ) matrix.appendRotation( 180, Vector3D.X_AXIS);
								if ( !angleY2_ok ) matrix.appendRotation( 180, Vector3D.Y_AXIS );
								if ( !angleZ2_ok ) matrix.appendRotation( 180, Vector3D.Z_AXIS);
								matrix.append(rotationMatrices[0][i]);
							} else {
								matrix.copyRowFrom(0, new Vector3D(0.33333,0.33333,0.33333));
								matrix.copyRowFrom(1, new Vector3D(0.33333,0.33333,0.33333));
								matrix.copyRowFrom(2, new Vector3D(0.33333,0.33333,0.33333));
							}
						}
						matrix.appendTranslation(means[0][i].x,means[0][i].y,means[0][i].z);
					}
					
					
					currentSourceToTargetMatrices.push( matrix.clone() );
				}	
				
			}
			
		}
		
		
		
		public function applyMatrices( target:BitmapData = null, transition1:int = 16, transition2:int = 16):void
		{
			if ( hasTarget )
			{
				if ( target == null ) target = targetMap;
				
				var cm:ColorMatrix = new ColorMatrix();
				cm.setMatrix3D( currentSourceToTargetMatrices[0] );
				
				var result:BitmapData = target.clone();
				result.applyFilter( targetMap, result.rect, new Point(), cm.filter );
				
				var blendStartIndex:int = Math.max(0,threshold_target - transition1); 
				var blendEndIndex:int = Math.min(threshold_target + transition2 + 1, 255 );
				var scale:Number = 256 / (blendEndIndex - blendStartIndex);
				var overlay:BitmapData = new TrackedBitmapData( target.width, target.height, true, 0 );
				
				cm.reset();
				cm.desaturate();
				cm.setMultiplicators(scale,scale,scale);
				cm.adjustBrightness( -blendStartIndex * scale );
				cm.blue2Alpha(true);
				cm.applyMatrix3D(currentSourceToTargetMatrices[1]);
				
				overlay.applyFilter( targetMap, result.rect, new Point(), cm.filter );
				
				result.draw(overlay);
				target.copyPixels( result,target.rect,new Point());
				
			}
		}
		
		public function setFactors( index:int, factors:XML ):void
		{
			var bins:XMLList =  factors..bin;
			if (bins.length() != 2 || index < 0 || index > 1) return;
			if ( index == 0 ) 
				hasSource = true;
			else 
				hasTarget = true;
			
			for ( var i:int = 0; i < bins.length(); i++ )
			{
				var dim:XML = bins[i].dimension[0];
				dimensions[index][i] = new Vector3D(dim.@x,dim.@y,dim.@z);
				var mean:XML = bins[i].mean[0];
				means[index][i] = new Vector3D(mean.@x,mean.@y,mean.@z);
				var irm:Array = bins[i].invRotationMatrix[0].@m.toString().split(",");
				var raw:Vector.<Number> = new Vector.<Number>();
				for ( var j:int = 0; j < irm.length; j++ )
				{
					raw[j] = parseFloat(irm[j]);
				}
				
				invRotationMatrices[index][i] = new Matrix3D(raw);
				var rm:Array = bins[i].rotationMatrix[0].@m.toString().split(",");
				raw.length = 0;
				for ( j = 0; j < rm.length; j++ )
				{
					raw[j] = parseFloat(rm[j]);
				}
				rotationMatrices[index][i]  = new Matrix3D(raw);
			}
		}
		
		public function getFactors(index:int):XML
		{
			var factors:XML = <factors />;
			for ( var i:int = 0; i < 2; i++ )
			{
				var bin:XML = <bin/>;
				
				bin.appendChild(<dimension x={dimensions[index][i].x} y={dimensions[index][i].y} z={dimensions[index][i].z}/>);
				bin.appendChild(<invRotationMatrix m={invRotationMatrices[index][i].rawData.toString()}/>);
				bin.appendChild(<rotationMatrix m={rotationMatrices[index][i].rawData.toString()}/>);
				bin.appendChild(<mean x={means[index][i].x} y={means[index][i].y} z={means[index][i].z}/>);
				factors.appendChild(bin);		
			}
			return factors;
		}
		
		public function getThreshold( transition1:int = 16, transition2:int = 16 ):Number
		{
			return threshold_target - (transition1 + transition2) * 0.5;
		}
		
		public function getColorMatrix( index:int ):ColorMatrix
		{
			var cm:ColorMatrix = new ColorMatrix();
			cm.setMatrix3D( currentSourceToTargetMatrices[index] );
			return cm;
		}
	}
}

