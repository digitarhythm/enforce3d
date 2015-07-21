<?php
$ini = parse_ini_file("lib/config.ini", true);
$gametitle = $ini['ENVIRON']['TITLE'];
$vr3dview = $ini['ENVIRON']['VR3DVIEW'];
$vrmotion = $ini['ENVIRON']['VRMOTION'];
?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title><?php echo $gametitle;?></title>
  <meta http-equiv="x-ua-compatible" content="IE=Edge">
  <meta property='og:image' content='lib/enforce_icon.png'>
<?php
  if ($gametitle != "") {
    echo "<meta property='og:title' content='$gametitle'>\n";
  } else {
    echo "<meta property='og:title' content='enforce games'>\n";
  }
?>
  <script type="tet/javascript">
    _useragent = window.navigator.userAgent.toLowerCase();
  </script>
	<script type="text/javascript" src="usrobject/environ.js"></script>
  <script type="text/javascript" src="extlib/three.min.js"></script>
  <script type="text/javascript" src="extlib/ColladaLoader.js"></script>
  <script type="text/javascript" src="extlib/TrackballControls.js"></script>
  <script type="text/javascript" src="extlib/OBJLoader.js"></script>
  <script type="text/javascript" src="extlib/Detector.js"></script>
<?php
  if ($vrmotion == true || $vr3dview == true) {
?>
    <script type="text/javascript" src="extlib/vr.js"></script>
    <script type="text/javascript" src="extlib/DeviceOrientationControls.js"></script>
    <script type="text/javascript" src="extlib/OrbitControls.js"></script>
<?php
  }
  if ($vrmotion == true) {
?>
    <script type="text/javascript">VRMOTION = true;</script>
<?php
  } else {
?>
    <script type="text/javascript">VRMOTION = false;</script>
<?php
  }
  if ($vr3dview == true) {
?>
    <script type="text/javascript" src="extlib/OculusRiftEffect.js"></script>
    <script type="text/javascript">VR3DVIEW = true;</script>
<?php
  } else {
?>
    <script type="text/javascript">VR3DVIEW = false;</script>
<?php
  }
?>
  <script type="text/javascript" src="sysobject/enforce.core.js"></script>
<?php
  // #################################################################################
  // ライブラリー読み込み
  // #################################################################################
	$srcdir = "./plugins";
	$dir = opendir($srcdir);
	while ($fname = readdir($dir)) {
		if (is_dir($srcdir."/".$fname) || !preg_match("/.*.js/", $fname)) {
			continue;
		}
		echo "<script type='text/javascript' src='$srcdir/$fname'></script>\n";
	}

  // #################################################################################
  // アプリケーションスクリプト読み込み
  // #################################################################################
	$srcdir = "./usrobject";
	$dir = opendir($srcdir);
	while ($fname = readdir($dir)) {
		if (is_dir($srcdir."/".$fname) || preg_match("/environ.js/", $fname)) {
			continue;
		}
		echo "<script type='text/javascript' src='$srcdir/$fname'></script>\n";
	}
?>
  <style type="text/css">
    body {
      margin: 0;
      padding: 0;
    }
  </style>
</head>
<body style="overflow:hidden;background-color:gray;">
<div id="webgl" style="position:absolute; width: 100%; height:100%; left:0px; top:0px;"></div>
  <!--div id="status" style="position:absolute; width:100%; height:24px; font-size:12pt; left:0px; top:0px; background-color:white; opacity: 0.4; color:black;"-->
</body>
</html>
