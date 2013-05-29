package jp.shichiseki.exif {
	/**
	 * The Tags class has some tagset that contain tags will be appeared in IFD of a
	 * JPEG file.
	 */
	public class Tags {
		/**
		 * The 0th IFD tagset.
		 */
		public static const PRIMARY:XML = <tags level="0th IFD TIFF Tags">
  <tag tag_name="Image width" field_name="ImageWidth" id="0x0100" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image height" field_name="ImageLength" id="0x0101" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Number of bits per component" field_name="BitsPerSample" id="0x0102" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Compression scheme" field_name="Compression" id="0x0103" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Pixel composition" field_name="PhotometricInterpretation" id="0x0106" compressed="N">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image title" field_name="ImageDescription" id="0x010e" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Manufacturer of image input equipment" field_name="Make" id="0x010f" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Model of image input equipment" field_name="Model" id="0x0110" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Image data location" field_name="StripOffsets" id="0x0111" compressed="N">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Orientation of image" field_name="Orientation" id="0x0112" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Number of components" field_name="SamplesPerPixel" id="0x0115" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Number of rows per strip" field_name="RowsPerStrip" id="0x0116" compressed="N">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Bytes per compressed strip" field_name="StripByteCounts" id="0x0117" compressed="N">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image resolution in width direction" field_name="XResolution" id="0x011a" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image resolution in height direction" field_name="YResolution" id="0x011b" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image data arrangement" field_name="PlanarConfiguration" id="0x011c" compressed="J">
	<uncompressed chunky="O" planar="M" ycc="O" />
  </tag>
  <tag tag_name="Unit of X and Y resolution" field_name="ResolutionUnit" id="0x0128" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Transfer function" field_name="TransferFunction" id="0x012d" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Software used" field_name="Software" id="0x0131" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="File change date and time" field_name="DateTime" id="0x0132" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Person who created the image" field_name="Artist" id="0x013b" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="White point chromaticity" field_name="WhitePoint" id="0x013e" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Chromaticities of primaries" field_name="PrimaryChromaticities" id="0x013f" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Offset to JPEG SOI" field_name="JPEGInterchangeFormat" id="0x0201" compressed="N">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Bytes of JPEG data" field_name="JPEGInterchangeFormatLength" id="0x0202" compressed="N">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Color space transformation matrix coefficients" field_name="YCbCrCoefficients" id="0x0211" compressed="O">
	<uncompressed chunky="N" planar="N" ycc="O" />
  </tag>
  <tag tag_name="Subsampling ratio of Y to C" field_name="YCbCrSubSampling" id="0x0212" compressed="J">
	<uncompressed chunky="N" planar="N" ycc="M" />
  </tag>
  <tag tag_name="Y and C positioning" field_name="YCbCrPositioning" id="0x0213" compressed="M">
	<uncompressed chunky="N" planar="N" ycc="M" />
  </tag>
  <tag tag_name="Pair of black and white reference values" field_name="ReferenceBlackWhite" id="0x0214" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Copyright holder" field_name="Copyright" id="0x8298" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Exif tag" field_name="ExifIFDPointer" id="0x8769" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="GPS tag" field_name="GPSInfoIFDPointer" id="0x8825" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
</tags>;


		
		/**
		 * The 0th exif IFD tagset.
		 */
		public static const EXIF:XML = <tags level="0th IFD Exif Private Tags">
  <tag tag_name="Exposure time" field_name="ExposureTime" id="0x829a" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="F number" field_name="FNumber" id="0x829d" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Exposure program" field_name="ExposureProgram" id="0x8822" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Spectral sensitivity" field_name="SpectralSensitivity" id="0x8824" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="ISO speed ratings" field_name="ISOSpeedRatings" id="0x8827" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Optoelectric coefficient" field_name="OECF" id="0x8828" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Exif Version" field_name="ExifVersion" id="0x9000" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Date and time original image was generated" field_name="DateTimeOriginal" id="0x9003" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Date and time image was made digital data" field_name="DateTimeDigitized" id="0x9004" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Meaning of each component" field_name="ComponentsConfiguration" id="0x9101" compressed="M">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Image compression mode" field_name="CompressedBitsPerPixel" id="0x9102" compressed="O">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Shutter speed" field_name="ShutterSpeedValue" id="0x9201" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Aperture" field_name="ApertureValue" id="0x9202" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Brightness" field_name="BrightnessValue" id="0x9203" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Exposure bias" field_name="ExposureBiasValue" id="0x9204" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Maximum lens aperture" field_name="MaxApertureValue" id="0x9205" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Subject distance" field_name="SubjectDistance" id="0x9206" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Metering mode" field_name="MeteringMode" id="0x9207" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Light source" field_name="LightSource" id="0x9208" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Flash" field_name="Flash" id="0x9209" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Lens focal length" field_name="FocalLength" id="0x920a" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Subject area" field_name="SubjectArea" id="0x9214" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Manufacturer notes" field_name="MakerNote" id="0x927c" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="User comments" field_name="UserComment" id="0x9286" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="DateTime subseconds" field_name="SubSecTime" id="0x9290" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="DateTimeOriginal subseconds" field_name="SubSecTimeOriginal" id="0x9291" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="DateTimeDigitized subseconds" field_name="SubSecTimeDigitized" id="0x9292" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Supported Flashpix version" field_name="FlashpixVersion" id="0xa000" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Color space information" field_name="ColorSpace" id="0xa001" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Valid image width" field_name="PixelXDimension" id="0xa002" compressed="M">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Valid image height" field_name="PixelYDimension" id="0xa003" compressed="M">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Related audio file" field_name="RelatedSoundFile" id="0xa004" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Interoperability tag" field_name="InteroperabilityIFDPointer" id="0xa005" compressed="O">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Flash energy" field_name="FlashEnergy" id="0xa20b" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Spatial frequency response" field_name="SpatialFrequencyResponse" id="0xa20c" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Focal plane X resolution" field_name="FocalPlaneXResolution" id="0xa20e" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Focal plane Y resolution" field_name="FocalPlaneYResolution" id="0xa20f" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Focal plane resolution unit" field_name="FocalPlaneResolutionUnit" id="0xa210" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Subject location" field_name="SubjectLocation" id="0xa214" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Exposure index" field_name="ExposureIndex" id="0xa215" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Sensing method" field_name="SensingMethod" id="0xa217" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="File source" field_name="FileSource" id="0xa300" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Scene type" field_name="SceneType" id="0xa301" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="CFA pattern" field_name="CFAPattern" id="0xa302" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Custom image processing" field_name="CustomRendered" id="0xa401" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Exposure mode" field_name="ExposureMode" id="0xa402" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="White balance" field_name="WhiteBalance" id="0xa403" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Digital zoom ratio" field_name="DigitalZoomRatio" id="0xa404" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Focal length in 35 mm film" field_name="FocalLengthIn35mmFilm" id="0xa405" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Scene capture type" field_name="SceneCaptureType" id="0xa406" compressed="R">
	<uncompressed chunky="R" planar="R" ycc="R" />
  </tag>
  <tag tag_name="Gain control" field_name="GainControl" id="0xa407" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Contrast" field_name="Contrast" id="0xa408" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Saturation" field_name="Saturation" id="0xa409" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Sharpness" field_name="Sharpness" id="0xa40a" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Device settings description" field_name="DeviceSettingDescription" id="0xa40b" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Subject distance range" field_name="SubjectDistanceRange" id="0xa40c" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Unique image ID" field_name="ImageUniqueID" id="0xa420" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
</tags>;

		/**
		 * The 0th GPS IFD tagset.
		 */
		public static const GPS:XML = <tags level="0th IFD GPS Info Tags">
  <tag tag_name="GPS tag version" field_name="GPSVersionID" id="0x0000" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="North or South Latitude" field_name="GPSLatitudeRef" id="0x0001" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Latitude" field_name="GPSLatitude" id="0x0002" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="East or West Longitude" field_name="GPSLongitudeRef" id="0x0003" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Longitude" field_name="GPSLongitude" id="0x0004" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Altitude reference" field_name="GPSAltitudeRef" id="0x0005" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Altitude" field_name="GPSAltitude" id="0x0006" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="GPS time (atomic clock)" field_name="GPSTimeStamp" id="0x0007" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="GPS satellites used for measurement" field_name="GPSSatellites" id="0x0008" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="GPS receiver status" field_name="GPSStatus" id="0x0009" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="GPS measurement mode" field_name="GPSMeasureMode" id="0x000a" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Measurement precision" field_name="GPSDOP" id="0x000b" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Speed unit" field_name="GPSSpeedRef" id="0x000c" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Speed of GPS receiver" field_name="GPSSpeed" id="0x000d" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Reference for direction of movement" field_name="GPSTrackRef" id="0x000e" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Direction of movement" field_name="GPSTrack" id="0x000f" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Reference for direction of image" field_name="GPSImgDirectionRef" id="0x0010" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Direction of image" field_name="GPSImgDirection" id="0x0011" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Geodetic survey data used" field_name="GPSMapDatum" id="0x0012" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Reference for latitude of destination" field_name="GPSDestLatitudeRef" id="0x0013" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Latitude of destination" field_name="GPSDestLatitude" id="0x0014" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Reference for longitude of destination" field_name="GPSDestLongitudeRef" id="0x0015" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Longitude of destination" field_name="GPSDestLongitude" id="0x0016" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Reference for bearing of destination" field_name="GPSDestBearingRef" id="0x0017" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Bearing of destination" field_name="GPSDestBearing" id="0x0018" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Reference for distance to destination" field_name="GPSDestDistanceRef" id="0x0019" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Distance to destination" field_name="GPSDestDistance" id="0x001a" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Name of GPS processing method" field_name="GPSProcessingMethod" id="0x001b" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Name of GPS area" field_name="GPSAreaInformation" id="0x001c" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="GPS date" field_name="GPSDateStamp" id="0x001d" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="GPS differential correction" field_name="GPSDifferential" id="0x001e" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
</tags>;

		/**
		 * The 0th Interoperability IFD tagset.
		 */
		public static const INTEROPERABILITY:XML = <tags level="0th IFD Interoperability Tags">
  <tag tag_name="Interoperability Identification" field_name="InteroperabilityIndex" id="0x0001" compressed="O">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
</tags>;

		/**
		 * The 1st IFD(Thumbnail) tagset.
		 */
		public static const THUMBNAIL:XML = <tags level="1th IFD TIFF Tags">
  <tag tag_name="Image width" field_name="ImageWidth" id="0x0100" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image height" field_name="ImageLength" id="0x0101" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Number of bits per component" field_name="BitsPerSample" id="0x0102" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Compression scheme" field_name="Compression" id="0x0103" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Pixel composition" field_name="PhotometricInterpretation" id="0x0106" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image title" field_name="ImageDescription" id="0x010e" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Manufacturer of image input equipment" field_name="Make" id="0x010f" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Model of image input equipment" field_name="Model" id="0x0110" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Image data location" field_name="StripOffsets" id="0x0111" compressed="N">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Orientation of image" field_name="Orientation" id="0x0112" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Number of components" field_name="SamplesPerPixel" id="0x0115" compressed="J">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Number of rows per strip" field_name="RowsPerStrip" id="0x0116" compressed="N">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Bytes per compressed strip" field_name="StripByteCounts" id="0x0117" compressed="N">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image resolution in width direction" field_name="XResolution" id="0x011a" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image resolution in height direction" field_name="YResolution" id="0x011b" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Image data arrangement" field_name="PlanarConfiguration" id="0x011c" compressed="J">
	<uncompressed chunky="O" planar="M" ycc="O" />
  </tag>
  <tag tag_name="Unit of X and Y resolution" field_name="ResolutionUnit" id="0x0128" compressed="M">
	<uncompressed chunky="M" planar="M" ycc="M" />
  </tag>
  <tag tag_name="Transfer function" field_name="TransferFunction" id="0x012d" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Software used" field_name="Software" id="0x0131" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="File change date and time" field_name="DateTime" id="0x0132" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Person who created the image" field_name="Artist" id="0x013b" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="White point chromaticity" field_name="WhitePoint" id="0x013e" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Chromaticities of primaries" field_name="PrimaryChromaticities" id="0x013f" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Offset to JPEG SOI" field_name="JPEGInterchangeFormat" id="0x0201" compressed="M">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Bytes of JPEG data" field_name="JPEGInterchangeFormatLength" id="0x0202" compressed="M">
	<uncompressed chunky="N" planar="N" ycc="N" />
  </tag>
  <tag tag_name="Color space transformation matrix coefficients" field_name="YCbCrCoefficients" id="0x0211" compressed="O">
	<uncompressed chunky="N" planar="N" ycc="O" />
  </tag>
  <tag tag_name="Subsampling ratio of Y to C" field_name="YCbCrSubSampling" id="0x0212" compressed="J">
	<uncompressed chunky="N" planar="N" ycc="M" />
  </tag>
  <tag tag_name="Y and C positioning" field_name="YCbCrPositioning" id="0x0213" compressed="O">
	<uncompressed chunky="N" planar="N" ycc="O" />
  </tag>
  <tag tag_name="Pair of black and white reference values" field_name="ReferenceBlackWhite" id="0x0214" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Copyright holder" field_name="Copyright" id="0x8298" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="Exif tag" field_name="ExifIFDPointer" id="0x8769" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
  <tag tag_name="GPS tag" field_name="GPSInfoIFDPointer" id="0x8825" compressed="O">
	<uncompressed chunky="O" planar="O" ycc="O" />
  </tag>
</tags>;

		private static const levels:Object = {
			"primary": PRIMARY,
			"exif": EXIF,
			"gps": GPS,
			"interoperability": INTEROPERABILITY,
			"thumbnail": THUMBNAIL
		};

		/**
		 * Gets the tagset specified by <code>level</code>
		 */
		public static function getSet(level:String):XML {
			if (!levels[level])
				return null;
			return levels[level];
		}
	}
}
