<?php
$ini = parse_ini_file("lib/config.ini", true);
$oculus = $ini['ENVIRON']['OCULUS'];
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="x-ua-compatible" content="IE=Edge">
    <meta name="viewport" content="width=device-width, user-scalable=no, minimal-ui">
    <meta name="apple-mobile-web-app-capable" content="yes">
	<script type="text/javascript" src="usrobject/environ.js"></script>
    <script type="text/javascript" src="extlib/three.min.js"></script>
    <script type="text/javascript" src="extlib/ColladaLoader.js"></script>
<?php
    if ($oculus == true) {
?>
    <script type="text/javascript" src="extlib/OculusRiftEffect.js"></script>
    <script type="text/javascript">OCULUS = true;</script>
<?php
    } else {
?>
    <script type="text/javascript">OCULUS = false;</script>
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
<body bgcolor="gray">
    <div id="webgl"></div>
</body>
</html>
